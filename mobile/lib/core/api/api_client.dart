import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_exception.dart';
import 'token_storage.dart';

/// HTTP-клиент приложения.
///
/// Один экземпляр на всё приложение. Создаётся в main.dart и
/// передаётся в сервисы (AuthService, PlotsService и т.д.) через конструктор.
///
/// Все сервисы должны работать только через [dio]. Никаких прямых
/// http.get/post в коде — иначе мимо интерцепторов пройдут запросы без JWT.
class ApiClient {
  /// Базовый URL backend. Переопределяется через --dart-define:
  ///
  /// flutter run -d chrome --dart-define=API_BASE_URL=http://192.168.1.50:8000/api/v1
  ///
  /// Дефолт подходит для:
  /// - Flutter Web (Chrome / Edge) — localhost напрямую.
  /// - Windows-десктоп — localhost напрямую.
  /// - iOS-симулятор — localhost напрямую.
  ///
  /// Для Android-эмулятора используй: --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
  /// Для реального телефона: --dart-define=API_BASE_URL=http://<IP-твоего-ПК>:8000/api/v1
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api/v1',
  );

  late final Dio dio;
  final TokenStorage _tokenStorage;

  // Чтобы не зацикливаться: если refresh-запрос сам вернул 401, не пытаемся
  // обновлять токен снова — просто выходим.
  bool _isRefreshing = false;

  ApiClient(this._tokenStorage) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(_AuthInterceptor(this));

    // Логи только в debug, в проде никаких HTTP-логов в консоль.
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: false,
          requestHeader: false,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
    }
  }

  /// Преобразует [DioException] в одно из наших [ApiException]-наследников.
  ApiException mapDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError) {
      return const NetworkException(
        'Нет связи с сервером. Проверь подключение.',
      );
    }

    final status = error.response?.statusCode;
    final data = error.response?.data;
    final detail = _extractMessage(data) ?? error.message ?? 'Неизвестная ошибка';

    switch (status) {
      case 400:
      case 422:
        return ValidationException(detail, statusCode: status);
      case 401:
        return UnauthorizedException(detail);
      case 409:
        return ConflictException(detail);
      default:
        return ApiException(detail, statusCode: status);
    }
  }

  /// FastAPI присылает ошибки в формате {"detail": "..."} или
  /// {"detail": [{"msg": "...", "loc": [...]}]}.
  String? _extractMessage(dynamic data) {
    if (data is Map && data['detail'] != null) {
      final detail = data['detail'];
      if (detail is String) return detail;
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first['msg'] is String) {
          return first['msg'] as String;
        }
      }
    }
    return null;
  }
}

/// Интерцептор, который:
/// 1. Подставляет Authorization: Bearer <access_token> в каждый запрос.
/// 2. При 401 пробует обновить access_token через /auth/refresh
///    и повторяет оригинальный запрос.
class _AuthInterceptor extends Interceptor {
  final ApiClient _client;

  _AuthInterceptor(this._client);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Эндпоинты, где токен не нужен и даже мешает.
    const publicPaths = ['/auth/login', '/auth/register', '/auth/refresh'];
    final isPublic = publicPaths.any((p) => options.path.contains(p));

    if (!isPublic) {
      final token = await _client._tokenStorage.readAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final isAuthEndpoint = err.requestOptions.path.contains('/auth/');

    // 401 на не-auth эндпоинте — пробуем обновить токен.
    if (status == 401 && !isAuthEndpoint && !_client._isRefreshing) {
      _client._isRefreshing = true;
      try {
        final refreshed = await _tryRefresh();
        if (refreshed) {
          // Повторяем оригинальный запрос с новым токеном.
          final newToken = await _client._tokenStorage.readAccessToken();
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newToken';
          final response = await _client.dio.fetch(opts);
          return handler.resolve(response);
        }
      } finally {
        _client._isRefreshing = false;
      }
    }
    handler.next(err);
  }

  /// Пытается обновить access_token через refresh_token.
  /// Возвращает true в случае успеха, false если refresh тоже невалиден.
  Future<bool> _tryRefresh() async {
    final refreshToken = await _client._tokenStorage.readRefreshToken();
    if (refreshToken == null) return false;

    try {
      // Делаем «чистый» Dio без интерцепторов, чтобы не бесконечно ходить
      // через onRequest и не подцепить старый access_token.
      final response = await Dio(BaseOptions(baseUrl: ApiClient.baseUrl))
          .post('/auth/refresh', data: {'refresh_token': refreshToken});

      final newAccess = response.data['access_token'] as String?;
      final newRefresh = response.data['refresh_token'] as String? ?? refreshToken;

      if (newAccess != null) {
        await _client._tokenStorage.saveTokens(
          accessToken: newAccess,
          refreshToken: newRefresh,
        );
        return true;
      }
      return false;
    } catch (_) {
      // Refresh не сработал — токены битые, нужно перелогиниться.
      await _client._tokenStorage.clear();
      return false;
    }
  }
}

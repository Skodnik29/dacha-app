import 'package:dio/dio.dart';

import '../core/api/api_client.dart';
import '../core/api/token_storage.dart';
import '../models/user.dart';

/// Сервис авторизации.
///
/// Изолирует всю работу с /auth/* эндпоинтами от UI. Возвращает уже
/// типизированные User/исключения — экранам не нужно знать про Dio и JSON.
class AuthService {
  final ApiClient _api;
  final TokenStorage _tokenStorage;

  AuthService(this._api, this._tokenStorage);

  /// Регистрация. Сразу логинит пользователя (на /auth/register backend
  /// возвращает только User, поэтому после регистрации зовём /auth/login).
  Future<User> register({
    required String email,
    required String name,
    required String password,
  }) async {
    try {
      await _api.dio.post('/auth/register', data: {
        'email': email,
        'name': name,
        'password': password,
      });
      // Регистрация прошла — теперь логинимся, чтобы получить токены.
      return await login(email: email, password: password);
    } on DioException catch (e) {
      throw _api.mapDioError(e);
    }
  }

  /// Логин. Сохраняет токены в TokenStorage и возвращает пользователя.
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data as Map<String, dynamic>;
      await _tokenStorage.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );

      return await getMe();
    } on DioException catch (e) {
      throw _api.mapDioError(e);
    }
  }

  /// Текущий пользователь. Используется и после login, и при автозагрузке
  /// в AuthGate (если токен есть в хранилище — проверяем его валидность).
  Future<User> getMe() async {
    try {
      final response = await _api.dio.get('/auth/me');
      return User.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _api.mapDioError(e);
    }
  }

  /// Выход: чистим токены. На backend ничего звать не нужно — JWT
  /// невозможно отозвать на сервере без отдельного blacklist'а.
  Future<void> logout() async {
    await _tokenStorage.clear();
  }
}

import 'package:flutter/foundation.dart';

import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../api/api_exception.dart';

/// Состояние авторизации.
enum AuthStatus {
  /// Только что запустились, ещё не проверили токен в хранилище.
  initial,

  /// Идёт сетевой запрос (login/register/getMe).
  loading,

  /// Юзер залогинен, в [AuthProvider.user] лежит профиль.
  authenticated,

  /// Юзер не залогинен — показать LoginScreen.
  unauthenticated,
}

/// Глобальное состояние авторизации.
///
/// Подписан через ChangeNotifierProvider в main.dart, так что UI
/// автоматически перерисовывается при login/logout.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider(this._authService);

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// Вызывается в AuthGate при старте приложения.
  /// Если в хранилище есть токен и он валиден — сразу логиним юзера.
  Future<void> tryAutoLogin() async {
    try {
      final user = await _authService.getMe();
      _user = user;
      _status = AuthStatus.authenticated;
    } catch (_) {
      // Токена нет, или он невалиден — это нормально при первом запуске.
      _user = null;
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.login(email: email, password: password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on UnauthorizedException {
      _errorMessage = 'Неверный email или пароль';
      _status = AuthStatus.unauthenticated;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _errorMessage = 'Не удалось войти. Попробуй позже.';
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String email,
    required String name,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.register(
        email: email,
        name: name,
        password: password,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ConflictException {
      _errorMessage = 'Пользователь с таким email уже существует';
      _status = AuthStatus.unauthenticated;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _errorMessage = 'Не удалось зарегистрироваться. Попробуй позже.';
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}

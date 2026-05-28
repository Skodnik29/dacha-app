/// Типизированные исключения API.
///
/// Все ошибки сети, авторизации и валидации, которые приходят от сервера,
/// мы оборачиваем в эти классы. Это позволяет писать в UI просто:
///
/// ```dart
/// try {
///   await authService.login(...);
/// } on UnauthorizedException {
///   // показать «Неверный email или пароль»
/// } on ValidationException catch (e) {
///   // показать e.message
/// } on NetworkException {
///   // показать «Нет связи с сервером»
/// }
/// ```
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// 401 Unauthorized — нет токена, токен протух, неверный пароль.
class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message) : super(statusCode: 401);
}

/// 422 / 400 — невалидные данные.
class ValidationException extends ApiException {
  const ValidationException(super.message, {super.statusCode});
}

/// Любая сетевая ошибка: нет интернета, таймаут, сервер недоступен.
class NetworkException extends ApiException {
  const NetworkException(super.message);
}

/// 409 Conflict — например, email уже зарегистрирован.
class ConflictException extends ApiException {
  const ConflictException(super.message) : super(statusCode: 409);
}

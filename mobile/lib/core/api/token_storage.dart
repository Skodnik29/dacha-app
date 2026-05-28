import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Безопасное хранилище JWT-токенов.
///
/// Платформо-специфика flutter_secure_storage:
/// - iOS: Keychain (защищён биометрией/паролем).
/// - Android: EncryptedSharedPreferences (AES-256 поверх KeyStore).
/// - Web: window.localStorage (там нет настоящего шифрования, но это
///   ограничение браузера — лучшего варианта без серверной сессии нет).
/// - Windows/macOS/Linux: системные хранилища (DPAPI / Keychain / SecretService).
///
/// Никогда не клади сюда что-то некритичное (типа настроек): для этого
/// есть shared_preferences. TokenStorage — только для секретов.
class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  // На Android используем EncryptedSharedPreferences (новый, безопасный вариант).
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}

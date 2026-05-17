import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Almacenamiento seguro de tokens JWT con cifrado AES-256.
///
/// Cumple RNF03 (Confidencialidad de Datos) del proyecto AgroField.
/// - En Android: usa Keystore (AES-256 nativo)
/// - En iOS: usa Keychain
/// - En Web: usa IndexedDB con cifrado del navegador
class TokenStorage {
  static const _accessTokenKey = 'agrofield_access_token';
  static const _refreshTokenKey = 'agrofield_refresh_token';
  static const _userIdKey = 'agrofield_user_id';
  static const _roleKey = 'agrofield_user_role';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? userId,
    String? role,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    if (userId != null) {
      await _storage.write(key: _userIdKey, value: userId);
    }
    if (role != null) {
      await _storage.write(key: _roleKey, value: role);
    }
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  Future<String?> getRole() async {
    return await _storage.read(key: _roleKey);
  }

  Future<bool> hasValidSession() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _roleKey);
  }
}

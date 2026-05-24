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
  static const _nameKey = 'agrofield_user_name';
  static const _emailKey = 'agrofield_user_email';
  static const _photoKey = 'agrofield_user_photo';

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

  Future<String?> getName() async => await _storage.read(key: _nameKey);
  Future<String?> getEmail() async => await _storage.read(key: _emailKey);
  Future<String?> getPhoto() async => await _storage.read(key: _photoKey);

  Future<void> saveOfflineProfile(dynamic user) async {
    await _storage.write(key: _userIdKey, value: user.id);
    await _storage.write(key: _roleKey, value: user.role);
    await _storage.write(key: _nameKey, value: user.nombreCompleto);
    await _storage.write(key: _emailKey, value: user.email);
    if (user.fotoPerfilUrl != null && user.fotoPerfilUrl!.isNotEmpty) {
      await _storage.write(key: _photoKey, value: user.fotoPerfilUrl);
    } else {
      await _storage.delete(key: _photoKey);
    }
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
    await _storage.delete(key: _nameKey);
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _photoKey);
  }
}

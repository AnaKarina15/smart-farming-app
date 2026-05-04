import 'user_model.dart';

/// Modelo que representa la respuesta de autenticacion del backend.
///
/// Backend devuelve: accessToken, refreshToken, tokenType, user
class AuthTokensModel {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final UserModel user;

  AuthTokensModel({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.user,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthTokensModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

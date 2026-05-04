import 'package:dio/dio.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/token_storage.dart';
import '../../core/errors/api_exception.dart';
import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';

/// Servicio de autenticacion contra el backend AgroField.
///
/// Implementa los flujos de:
/// - Registro (POST /auth/register)
/// - Login (POST /auth/login)
/// - Logout (POST /auth/logout)
/// - Obtener usuario actual (GET /users/me)
class AuthService {
  final DioClient _dioClient;
  final TokenStorage _tokenStorage;

  AuthService(this._dioClient, this._tokenStorage);

  /// Registra un nuevo Pequeno Productor en AgroField.
  ///
  /// Si exitoso (201), guarda los tokens en almacenamiento seguro.
  /// Lanza [ApiException] en caso de error.
  Future<AuthTokensModel> register({
    required String nombreCompleto,
    required String email,
    required String telefono,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.register,
        data: {
          'nombreCompleto': nombreCompleto,
          'email': email,
          'telefono': telefono,
          'password': password,
        },
      );

      if (response.statusCode == 201) {
        final tokens = AuthTokensModel.fromJson(response.data['data']);
        await _tokenStorage.saveTokens(
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
          userId: tokens.user.id,
        );
        return tokens;
      }

      throw ApiException(
        message: response.data['message']?.toString() ?? 'Error en registro',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Inicia sesion con email y password.
  ///
  /// Si exitoso (200), guarda los tokens en almacenamiento seguro.
  /// Lanza [ApiException] en caso de error.
  Future<AuthTokensModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final tokens = AuthTokensModel.fromJson(response.data['data']);
        await _tokenStorage.saveTokens(
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
          userId: tokens.user.id,
        );
        return tokens;
      }

      throw ApiException(
        message: response.data['message']?.toString() ?? 'Credenciales invalidas',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Cierra sesion en el backend e invalida los tokens.
  Future<void> logout() async {
    try {
      await _dioClient.dio.post(ApiEndpoints.logout);
    } catch (_) {
      // Ignorar errores en logout, igual limpiamos local
    } finally {
      await _tokenStorage.clearTokens();
    }
  }

  /// Obtiene los datos del usuario actualmente autenticado.
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.me);

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['data']);
      }

      throw ApiException(
        message: 'No se pudo obtener el usuario actual',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

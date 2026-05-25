import 'package:dio/dio.dart';
import '../storage/token_storage.dart';
import 'api_endpoints.dart';

/// Cliente HTTP centralizado para AgroField.
///
/// Configura:
/// - URL base
/// - Headers JSON
/// - Timeouts amplios para backend en Render free (cold starts)
/// - Interceptor que agrega JWT automaticamente
/// - Refresh token automatico cuando expira el access token
/// - Logging en modo debug
class DioClient {
  late final Dio _dio;
  final TokenStorage _tokenStorage;

  DioClient(this._tokenStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  Dio get dio => _dio;

  void _setupInterceptors() {
    // Interceptor de autenticacion: agrega JWT automaticamente
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final isPublic = _isPublicEndpoint(options.path);
          if (!isPublic) {
            final token = await _tokenStorage.getAccessToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Si el token expiro (401), intentar refresh una vez
          if (error.response?.statusCode == 401 &&
              !_isPublicEndpoint(error.requestOptions.path) &&
              error.requestOptions.path != ApiEndpoints.refresh) {
            final refreshed = await _tryRefreshToken();
            if (refreshed) {
              // Reintentar la peticion original con el nuevo token
              final newToken = await _tokenStorage.getAccessToken();
              error.requestOptions.headers['Authorization'] =
                  'Bearer $newToken';
              try {
                final response = await _dio.fetch(error.requestOptions);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
          }
          handler.next(error);
        },
      ),
    );

    // Logger en modo debug
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
        error: true,
      ),
    );
  }

  bool _isPublicEndpoint(String path) {
    return path == ApiEndpoints.register ||
        path == ApiEndpoints.login ||
        path == ApiEndpoints.refresh ||
        path == ApiEndpoints.health;
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio.post(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        await _tokenStorage.saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );
        return true;
      }
      return false;
    } catch (_) {
      // Si falla el refresh, limpiar tokens (sesion invalida)
      await _tokenStorage.clearTokens();
      return false;
    }
  }
}

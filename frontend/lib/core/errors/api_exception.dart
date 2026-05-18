import 'package:dio/dio.dart';

/// Excepcion especifica de la API de AgroField.
///
/// Convierte errores HTTP de Dio en mensajes amigables en espanol
/// listos para mostrar al usuario en SnackBars o dialogos.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic rawError;

  ApiException({
    required String message,
    this.statusCode,
    this.rawError,
  }) : message = message.replaceAll(RegExp(r'[\[\]]'), '');

  @override
  String toString() => message;

  /// Crea una ApiException a partir de un DioException.
  factory ApiException.fromDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    // Si el servidor devolvio un mensaje especifico, usarlo
    String? serverMessage;
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];
      if (message is String) {
        serverMessage = message.replaceAll(RegExp(r'[\[\]]'), '');
      } else if (message is List && message.isNotEmpty) {
        serverMessage = message.first.toString().replaceAll(RegExp(r'[\[\]]'), '');
      }
    }

    String message;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Tiempo de conexion agotado. Verifica tu internet.';
        break;
      case DioExceptionType.connectionError:
        message = 'No se pudo conectar al servidor. Verifica tu internet.';
        break;
      case DioExceptionType.badResponse:
        message = serverMessage ?? _defaultMessageForStatus(statusCode);
        break;
      case DioExceptionType.cancel:
        message = 'Operacion cancelada.';
        break;
      default:
        message = serverMessage ?? 'Ocurrio un error inesperado.';
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      rawError: error,
    );
  }

  static String _defaultMessageForStatus(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Datos invalidos. Verifica la informacion ingresada.';
      case 401:
        return 'Credenciales invalidas o sesion expirada.';
      case 403:
        return 'No tienes permiso para realizar esta accion.';
      case 404:
        return 'Recurso no encontrado.';
      case 409:
        return 'El recurso ya existe.';
      case 429:
        return 'Demasiadas peticiones. Intenta en unos minutos.';
      case 500:
        return 'Error del servidor. Intenta de nuevo.';
      default:
        return 'Error inesperado (${statusCode ?? '?'}).';
    }
  }
}

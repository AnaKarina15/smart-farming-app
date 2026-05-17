import 'package:dio/dio.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../core/errors/api_exception.dart';
import '../models/lote_model.dart';

/// Servicio de gestion de Lotes contra el backend AgroField.
///
/// Implementa el CRUD completo de lotes (RF02-RF04):
/// - Listar lotes del productor (GET /lotes)
/// - Obtener detalle de un lote (GET /lotes/:id)
/// - Crear lote validando 5 hectareas maximas (POST /lotes)
/// - Actualizar lote (PATCH /lotes/:id)
/// - Eliminar lote (DELETE /lotes/:id)
class LotesService {
  final DioClient _dioClient;

  LotesService(this._dioClient);

  /// Lista todos los lotes del productor autenticado.
  Future<List<LoteModel>> listarLotes() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.lotes);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List;
        return data
            .map((json) => LoteModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw ApiException(
        message: 'Error al listar lotes',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Obtiene el detalle de un lote por su ID.
  Future<LoteModel> obtenerLote(String id) async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.loteById(id));

      if (response.statusCode == 200) {
        return LoteModel.fromJson(response.data['data']);
      }

      throw ApiException(
        message: 'Lote no encontrado',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Crea un nuevo lote.
  ///
  /// El backend valida que el total de superficies del productor
  /// no exceda 5 hectareas (regla de negocio AgroField).
  Future<LoteModel> crearLote({
    required String nombre,
    String? descripcion,
    required double superficieHectareas,
    String? cultivoActual,
    String? cultivoActualId,
    String? municipioId,
    String? tipoSueloId,
    double? latitud,
    double? longitud,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.lotes,
        data: {
          'nombre': nombre,
          if (descripcion != null) 'descripcion': descripcion,
          'superficieHectareas': superficieHectareas,
          if (cultivoActual != null) 'cultivoActual': cultivoActual,
          if (cultivoActualId != null) 'cultivoActualId': cultivoActualId,
          if (municipioId != null) 'municipioId': municipioId,
          if (tipoSueloId != null) 'tipoSueloId': tipoSueloId,
          if (latitud != null) 'latitud': latitud,
          if (longitud != null) 'longitud': longitud,
        },
      );

      if (response.statusCode == 201) {
        return LoteModel.fromJson(response.data['data']);
      }

      throw ApiException(
        message: response.data['message']?.toString() ?? 'Error al crear lote',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Actualiza un lote existente.
  Future<LoteModel> actualizarLote({
    required String id,
    String? nombre,
    String? descripcion,
    double? superficieHectareas,
    String? cultivoActual,
    double? latitud,
    double? longitud,
    String? estado,
  }) async {
    try {
      final response = await _dioClient.dio.patch(
        ApiEndpoints.loteById(id),
        data: {
          if (nombre != null) 'nombre': nombre,
          if (descripcion != null) 'descripcion': descripcion,
          if (superficieHectareas != null) 'superficieHectareas': superficieHectareas,
          if (cultivoActual != null) 'cultivoActual': cultivoActual,
          if (latitud != null) 'latitud': latitud,
          if (longitud != null) 'longitud': longitud,
          if (estado != null) 'estado': estado,
        },
      );

      if (response.statusCode == 200) {
        return LoteModel.fromJson(response.data['data']);
      }

      throw ApiException(
        message: 'Error al actualizar lote',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Elimina un lote.
  Future<void> eliminarLote(String id) async {
    try {
      final response = await _dioClient.dio.delete(ApiEndpoints.loteById(id));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ApiException(
          message: 'Error al eliminar lote',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

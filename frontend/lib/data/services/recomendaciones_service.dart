import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';
import '../models/recomendacion_model.dart';

/// Servicio que consume el Sistema Experto de Recomendaciones del backend.
///
/// Endpoints:
/// - GET  /api/v1/recomendaciones/lote/:loteId  → evaluar reglas para un lote
/// - POST /api/v1/recomendaciones/:reglaId/aplicar → registrar decisión
/// - GET  /api/v1/recomendaciones/historial/:loteId → historial de decisiones
class RecomendacionesService {
  final DioClient _dioClient;

  RecomendacionesService(this._dioClient);

  /// Evalúa las 187 reglas del sistema experto para un lote dado.
  /// Retorna lista vacía si hay error de red (modo offline-safe).
  Future<List<Recomendacion>> evaluar(String loteId) async {
    try {
      final response = await _dioClient.dio
          .get(ApiEndpoints.recomendacionesLote(loteId));

      final data = response.data;
      List<dynamic> items = [];

      if (data is Map && data.containsKey('data')) {
        items = data['data'] as List<dynamic>;
      } else if (data is List) {
        items = data;
      }

      return items
          .whereType<Map<String, dynamic>>()
          .map(Recomendacion.fromJson)
          .toList();
    } on DioException {
      // Offline o backend no disponible — retornar lista vacía
      return [];
    }
  }

  /// Registra la decisión del productor sobre una recomendación específica.
  ///
  /// [decision] puede ser 'aplicar' o 'descartar'.
  Future<bool> registrarDecision({
    required String reglaId,
    required String loteId,
    required String decision,
    String? nota,
  }) async {
    try {
      await _dioClient.dio.post(
        ApiEndpoints.aplicarRecomendacion(reglaId),
        data: {
          'loteId': loteId,
          'decision': decision,
          if (nota != null && nota.isNotEmpty) 'notaProductor': nota,
          'fecha': DateTime.now().toIso8601String(),
        },
      );
      return true;
    } on DioException {
      return false;
    }
  }

  /// Obtiene el historial de decisiones para un lote.
  Future<List<RecomendacionAplicada>> historial(String loteId) async {
    try {
      final response = await _dioClient.dio
          .get(ApiEndpoints.historialRecomendaciones(loteId));

      final data = response.data;
      List<dynamic> items = [];

      if (data is Map && data.containsKey('data')) {
        items = data['data'] as List<dynamic>;
      } else if (data is List) {
        items = data;
      }

      return items
          .whereType<Map<String, dynamic>>()
          .map(RecomendacionAplicada.fromJson)
          .toList();
    } on DioException {
      return [];
    }
  }
}

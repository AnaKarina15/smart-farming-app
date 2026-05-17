import 'package:dio/dio.dart';
import '../models/operaciones_models.dart';
import '../../core/network/api_endpoints.dart';

class OperacionesService {
  final Dio _dio;

  OperacionesService(this._dio);

  // --- SIEMBRAS ---
  Future<Siembra> createSiembra(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiEndpoints.siembras, data: data);
    return Siembra.fromJson(response.data['data']);
  }

  Future<List<Siembra>> getSiembras(String loteId) async {
    final response = await _dio.get('${ApiEndpoints.siembras}?loteId=$loteId');
    return (response.data['data']['data'] as List).map((e) => Siembra.fromJson(e)).toList();
  }

  // --- RIEGO ---
  Future<Riego> createRiego(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiEndpoints.riego, data: data);
    return Riego.fromJson(response.data['data']);
  }

  Future<List<Riego>> getRiegos(String loteId) async {
    final response = await _dio.get('${ApiEndpoints.riego}?loteId=$loteId');
    return (response.data['data']['data'] as List).map((e) => Riego.fromJson(e)).toList();
  }

  // --- FERTILIZACION ---
  Future<Fertilizacion> createFertilizacion(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiEndpoints.fertilizacion, data: data);
    return Fertilizacion.fromJson(response.data['data']);
  }

  Future<List<Fertilizacion>> getFertilizaciones(String loteId) async {
    final response = await _dio.get('${ApiEndpoints.fertilizacion}?loteId=$loteId');
    return (response.data['data']['data'] as List).map((e) => Fertilizacion.fromJson(e)).toList();
  }

  // --- HALLAZGOS ---
  Future<Hallazgo> createHallazgo(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiEndpoints.hallazgos, data: data);
    return Hallazgo.fromJson(response.data['data']);
  }

  Future<List<Hallazgo>> getHallazgos(String loteId) async {
    final response = await _dio.get('${ApiEndpoints.hallazgos}?loteId=$loteId');
    return (response.data['data']['data'] as List).map((e) => Hallazgo.fromJson(e)).toList();
  }

  // --- TRATAMIENTOS ---
  Future<Tratamiento> createTratamiento(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiEndpoints.tratamientos, data: data);
    return Tratamiento.fromJson(response.data['data']);
  }

  Future<List<Tratamiento>> getTratamientos(String loteId) async {
    final response = await _dio.get('${ApiEndpoints.tratamientos}?loteId=$loteId');
    return (response.data['data']['data'] as List).map((e) => Tratamiento.fromJson(e)).toList();
  }

  // --- OBSERVACIONES ---
  Future<Observacion> createObservacion(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiEndpoints.observaciones, data: data);
    return Observacion.fromJson(response.data['data']);
  }

  Future<List<Observacion>> getObservaciones(String loteId) async {
    final response = await _dio.get('${ApiEndpoints.observaciones}?loteId=$loteId');
    return (response.data['data']['data'] as List).map((e) => Observacion.fromJson(e)).toList();
  }
}

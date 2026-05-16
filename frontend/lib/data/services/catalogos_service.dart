import 'package:dio/dio.dart';

class CatalogosService {
  final Dio _dio;

  CatalogosService(this._dio);

  Future<List<Map<String, dynamic>>> getCultivos() async {
    final response = await _dio.get('/catalogos/cultivos');
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  Future<List<Map<String, dynamic>>> getMunicipios() async {
    final response = await _dio.get('/catalogos/municipios');
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  Future<List<Map<String, dynamic>>> getPlagas() async {
    final response = await _dio.get('/catalogos/plagas');
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  Future<List<Map<String, dynamic>>> getFertilizantes() async {
    final response = await _dio.get('/catalogos/fertilizantes');
    return List<Map<String, dynamic>>.from(response.data['data']);
  }

  Future<List<Map<String, dynamic>>> getTiposSuelo() async {
    final response = await _dio.get('/catalogos/tipos-suelo');
    return List<Map<String, dynamic>>.from(response.data['data']);
  }
}

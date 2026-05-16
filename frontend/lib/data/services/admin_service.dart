import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../models/usuario_admin.dart';
import '../models/stats_admin.dart';
import '../models/lote_admin.dart';

class AdminService {
  final DioClient _dioClient;

  AdminService(this._dioClient);

  Dio get _dio => _dioClient.dio;

  // ─── Estadísticas ────────────────────────────────────────────────────────────

  Future<StatsAdmin> obtenerStats() async {
    final response = await _dio.get('/users/stats');
    return StatsAdmin.fromJson(response.data['data'] ?? response.data);
  }

  // ─── Usuarios ────────────────────────────────────────────────────────────────

  Future<List<UsuarioAdmin>> listarUsuarios({
    String? role,
    bool? activo,
    String? search,
    bool includeDeleted = false,
    int limit = 20,
    int offset = 0,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      'offset': offset,
      'includeDeleted': includeDeleted,
    };
    if (role != null && role.isNotEmpty) queryParams['role'] = role;
    if (activo != null) queryParams['activo'] = activo;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _dio.get('/users', queryParameters: queryParams);
    final data = response.data['data'] ?? response.data;
    final List lista = data is List ? data : (data['items'] ?? data['users'] ?? []);
    return lista.map((e) => UsuarioAdmin.fromJson(e)).toList();
  }

  Future<UsuarioAdmin> obtenerUsuario(String id) async {
    final response = await _dio.get('/users/$id');
    final data = response.data['data'] ?? response.data;
    return UsuarioAdmin.fromJson(data);
  }

  Future<UsuarioAdmin> crearUsuario({
    required String nombreCompleto,
    required String email,
    required String password,
    required String role,
    String? telefono,
  }) async {
    final body = <String, dynamic>{
      'nombreCompleto': nombreCompleto,
      'email': email,
      'password': password,
      'role': role,
    };
    if (telefono != null && telefono.isNotEmpty) body['telefono'] = telefono;

    final response = await _dio.post('/users', data: body);
    final data = response.data['data'] ?? response.data;
    return UsuarioAdmin.fromJson(data);
  }

  Future<UsuarioAdmin> editarUsuario(
    String id, {
    String? nombreCompleto,
    String? telefono,
    String? role,
    bool? activo,
  }) async {
    final body = <String, dynamic>{};
    if (nombreCompleto != null) body['nombreCompleto'] = nombreCompleto;
    if (telefono != null) body['telefono'] = telefono;
    if (role != null) body['role'] = role;
    if (activo != null) body['activo'] = activo;

    final response = await _dio.patch('/users/$id', data: body);
    final data = response.data['data'] ?? response.data;
    return UsuarioAdmin.fromJson(data);
  }

  Future<void> resetearPassword(String id, String nuevaPassword) async {
    await _dio.post('/users/$id/reset-password', data: {'newPassword': nuevaPassword});
  }

  Future<void> eliminarUsuario(String id) async {
    await _dio.delete('/users/$id');
  }

  Future<void> restaurarUsuario(String id) async {
    await _dio.post('/users/$id/restore');
  }

  // ─── Lotes (admin) ───────────────────────────────────────────────────────────

  Future<List<LoteAdmin>> listarTodosLotes({String? propietarioId}) async {
    final queryParams = <String, dynamic>{};
    if (propietarioId != null) queryParams['propietarioId'] = propietarioId;

    final response = await _dio.get('/lotes/admin/todos', queryParameters: queryParams);
    final data = response.data['data'] ?? response.data;
    final List lista = data is List ? data : (data['items'] ?? data['lotes'] ?? []);
    return lista.map((e) => LoteAdmin.fromJson(e)).toList();
  }
}
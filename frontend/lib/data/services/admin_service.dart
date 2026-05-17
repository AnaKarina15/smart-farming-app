import '../../core/network/dio_client.dart';
import '../models/usuario_admin.dart';
import '../models/stats_admin.dart';
import '../models/lote_admin.dart';

class AdminService {
  final DioClient _dioClient;
  AdminService(this._dioClient);

  // ─── Stats ───────────────────────────────────────────────────────────────

  Future<StatsAdmin> obtenerStats() async {
    final response = await _dioClient.dio.get('/users/stats');
    final data = response.data['data'] ?? response.data;
    return StatsAdmin.fromJson(data as Map<String, dynamic>);
  }

  // ─── Usuarios ────────────────────────────────────────────────────────────

  Future<List<UsuarioAdmin>> listarUsuarios({
    String? role,
    bool?   activo,
    String? search,
    bool    includeDeleted = false,
    int     limit          = 20,
    int     offset         = 0,
  }) async {
    final q = <String, dynamic>{
      'limit':          limit,
      'offset':         offset,
      'includeDeleted': includeDeleted,
    };
    if (role   != null && role.isNotEmpty)   q['role']   = role;
    if (activo != null)                      q['activo'] = activo;
    if (search != null && search.isNotEmpty) q['search'] = search;

    final response =
        await _dioClient.dio.get('/users', queryParameters: q);

    if (response.statusCode != null && response.statusCode! >= 400) {
      final errorMsg = response.data is Map ? response.data['message'] : response.statusMessage;
      throw Exception(errorMsg ?? 'Error al listar usuarios');
    }

    final data = response.data['data'] ?? response.data;
    final List lista = data is List
        ? data
        : (data['data'] ?? data['items'] ?? data['users'] ?? []) as List;
    return lista
        .map((e) => UsuarioAdmin.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<UsuarioAdmin> obtenerUsuario(String id) async {
    final response = await _dioClient.dio.get('/users/$id');
    final data = response.data['data'] ?? response.data;
    return UsuarioAdmin.fromJson(data as Map<String, dynamic>);
  }

  Future<UsuarioAdmin> crearUsuario({
    required String nombreCompleto,
    required String email,
    required String password,
    required String role,
    String?         telefono,
  }) async {
    final body = <String, dynamic>{
      'nombreCompleto': nombreCompleto,
      'email':          email,
      'password':       password,
      'role':           role.toUpperCase(),
    };
    if (telefono != null && telefono.isNotEmpty) body['telefono'] = telefono;

    final response = await _dioClient.dio.post('/users', data: body);
    
    if (response.statusCode != null && response.statusCode! >= 400) {
      final data = response.data is Map ? response.data : {};
      final msg = data['message'] ?? 'Error al crear usuario';
      throw Exception(msg is List ? msg.join(', ') : msg.toString());
    }

    final data = response.data['data'] ?? response.data;
    return UsuarioAdmin.fromJson(data as Map<String, dynamic>);
  }

  Future<UsuarioAdmin> editarUsuario(
    String id, {
    String? nombreCompleto,
    String? telefono,
    String? role,
    bool?   activo,
  }) async {
    final body = <String, dynamic>{};
    if (nombreCompleto != null) body['nombreCompleto'] = nombreCompleto;
    if (telefono       != null) body['telefono']       = telefono;
    if (role           != null) body['role']           = role.toUpperCase();
    if (activo         != null) body['activo']         = activo;

    final response =
        await _dioClient.dio.patch('/users/$id', data: body);
        
    if (response.statusCode != null && response.statusCode! >= 400) {
      final data = response.data is Map ? response.data : {};
      final msg = data['message'] ?? 'Error al actualizar usuario';
      throw Exception(msg is List ? msg.join(', ') : msg.toString());
    }

    final data = response.data['data'] ?? response.data;
    return UsuarioAdmin.fromJson(data as Map<String, dynamic>);
  }

  Future<void> resetearPassword(String id, String nuevaPassword) async {
    await _dioClient.dio.post(
      '/users/$id/reset-password',
      data: {'newPassword': nuevaPassword},
    );
  }

  Future<void> eliminarUsuario(String id) async {
    await _dioClient.dio.delete('/users/$id');
  }

  Future<void> restaurarUsuario(String id) async {
    await _dioClient.dio.post('/users/$id/restore');
  }

  // ─── Lotes (admin) ───────────────────────────────────────────────────────

  Future<List<LoteAdmin>> listarTodosLotes({String? propietarioId}) async {
    final q = <String, dynamic>{};
    if (propietarioId != null) q['propietarioId'] = propietarioId;

    final response = await _dioClient.dio
        .get('/lotes/admin/todos', queryParameters: q);
    final data = response.data['data'] ?? response.data;
    final List lista = data is List
        ? data
        : (data['data'] ?? data['items'] ?? data['lotes'] ?? []) as List;
    return lista
        .map((e) => LoteAdmin.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
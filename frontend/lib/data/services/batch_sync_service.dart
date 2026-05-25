import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/storage/database_helper.dart';

/// Servicio de Sincronización por Lote (Sprint 5).
///
/// Implementa el protocolo batch sync del backend:
/// 1. Validar token con GET /sync/validate-token
/// 2. Construir batch desde tablas con isPendingSync=1
/// 3. POST /api/v1/sync/batch
/// 4. Procesar resultados item por item (created/updated/error/duplicate)
/// 5. Pull incremental con GET /api/v1/sync/since?timestamp=lastPulledAt
/// 6. Guardar lastPulledAt en SharedPreferences
class BatchSyncService {
  final DioClient _dioClient;
  final DatabaseHelper _db = DatabaseHelper.instance;

  static const _keyLastPulledAt = 'sync_last_pulled_at';

  // Tablas operativas y sus tipos de recurso para el batch
  static const _tablasTipos = {
    DatabaseHelper.tableSiembras: 'siembras',
    DatabaseHelper.tableRiego: 'riego',
    DatabaseHelper.tableFertilizacion: 'fertilizacion',
    DatabaseHelper.tableHallazgos: 'hallazgos',
    DatabaseHelper.tableTratamientos: 'tratamientos',
    DatabaseHelper.tableObservaciones: 'observaciones',
    DatabaseHelper.tableEstadoTerreno: 'estado-terreno',
  };

  BatchSyncService(this._dioClient);

  // ─── Punto de entrada principal ───────────────────────────

  /// Ejecuta la sincronización batch completa.
  /// Retorna true si el proceso completó sin errores críticos.
  Future<bool> syncBatch() async {
    if (!await _checkConnectivity()) return false;

    // 1. Validar token
    final tokenValido = await _validarToken();
    if (!tokenValido) return false;

    // 2. Construir payload del batch
    final items = await _construirBatchItems();
    if (items.isEmpty) {
      // No hay pendientes — sólo hacer pull incremental
      await _pullIncremental();
      return true;
    }

    // 3. Enviar batch al backend
    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.syncBatch,
        data: {'items': items},
      );

      // 4. Procesar resultados
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = _unwrapResponseData(response.data);
        final resultados = (data['results'] as List<dynamic>?) ?? [];
        await _procesarResultados(resultados);
        final tieneErrores = resultados.any(
          (resultado) =>
              resultado is Map<String, dynamic> &&
              resultado['status'] == 'error',
        );

        // Guardar serverTime como nuevo lastPulledAt
        final serverTime = data['serverTime'] as String?;
        if (serverTime != null) {
          await _guardarLastPulledAt(serverTime);
        }

        // 5. Pull incremental
        await _pullIncremental();
        return !tieneErrores;
      }
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Token expirado: intentar refresh (DioClient maneja esto)
        return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ─── Validación de token ──────────────────────────────────

  Future<bool> _validarToken() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.syncValidateToken);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ─── Construcción del batch ───────────────────────────────

  Future<List<Map<String, dynamic>>> _construirBatchItems() async {
    final items = <Map<String, dynamic>>[];

    for (final entry in _tablasTipos.entries) {
      final tabla = entry.key;
      final resourceType = entry.value;

      final pendientes = await _db.queryWhere(
        tabla,
        'isPendingSync = ?',
        [1],
      );

      for (final row in pendientes) {
        final localId = '$tabla:${row['id']}';
        final payload = _limpiarPayload(tabla, row);

        items.add({
          'localId': localId,
          'resourceType': resourceType,
          'operation': 'create',
          'clientUpdatedAt':
              row['createdAt'] ?? DateTime.now().toIso8601String(),
          'payload': payload,
        });
      }
    }

    return items;
  }

  /// Elimina campos internos que no debe conocer el backend.
  Map<String, dynamic> _limpiarPayload(
    String tabla,
    Map<String, dynamic> row,
  ) {
    final excluir = {
      'id',
      'isPendingSync',
      'serverId',
      'syncError',
      'userId',
      'loteNombre',
      'createdAt',
    };
    final payload = Map.fromEntries(
      row.entries.where((e) {
        if (excluir.contains(e.key)) return false;
        if (e.value == null) return false;
        if (e.value is String && (e.value as String).isEmpty) return false;
        return true;
      }),
    );

    if (tabla == DatabaseHelper.tableRiego) {
      final tipo = _normalizarTipoRiego(payload['tipo']);
      if (tipo != null) {
        payload['tipo'] = tipo;
      }
    }

    return payload;
  }

  String? _normalizarTipoRiego(dynamic value) {
    if (value == null) return null;

    final normalized = value
        .toString()
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    const aliases = {
      'goteo': 'goteo',
      'aspersion': 'aspersion',
      'microaspersion': 'microaspersion',
      'micro_aspersion': 'microaspersion',
      'gravedad': 'gravedad',
      'manual': 'manual',
      'inundacion': 'inundacion',
    };

    return aliases[normalized] ?? normalized;
  }

  // ─── Procesamiento de resultados ──────────────────────────

  Future<void> _procesarResultados(List<dynamic> resultados) async {
    final db = await _db.database;

    for (final resultado in resultados) {
      if (resultado is! Map<String, dynamic>) continue;

      final localId = resultado['localId'] as String?;
      if (localId == null) continue;

      // localId tiene formato "tabla:id"
      final parts = localId.split(':');
      if (parts.length < 2) continue;
      final tabla = parts[0];
      final rowId = parts.sublist(1).join(':'); // por si el id tiene ':'

      final status = resultado['status'] as String? ?? '';

      switch (status) {
        case 'created':
        case 'updated':
        case 'duplicate':
          final serverId = resultado['serverId'] as String?;
          if (serverId != null) {
            await db.update(
              tabla,
              {
                'isPendingSync': 0,
                'serverId': serverId,
                'syncError': null,
              },
              where: 'id = ?',
              whereArgs: [rowId],
            );
          }
          break;

        case 'error':
          final errorMsg =
              resultado['error'] as String? ?? 'Error del servidor';
          await db.update(
            tabla,
            {'syncError': errorMsg},
            where: 'id = ?',
            whereArgs: [rowId],
          );
          break;

        case 'deleted':
          // Eliminar físicamente del local si el server lo borró
          await db.delete(tabla, where: 'id = ?', whereArgs: [rowId]);
          break;
      }
    }
  }

  // ─── Pull incremental ─────────────────────────────────────

  Future<void> _pullIncremental() async {
    try {
      final lastPulledAt = await _getLastPulledAt();
      final url = lastPulledAt != null
          ? '${ApiEndpoints.syncSince}?timestamp=${Uri.encodeComponent(lastPulledAt)}'
          : ApiEndpoints.syncSince;

      final response = await _dioClient.dio.get(url);
      if (response.statusCode != 200) return;

      final data = _unwrapResponseData(response.data);
      final registros = _flattenChanges(data['changes']);

      await _upsertRegistrosLocales(registros);

      // Actualizar lastPulledAt con el tiempo del servidor
      final serverTime = data['serverTime'] as String?;
      if (serverTime != null) {
        await _guardarLastPulledAt(serverTime);
      }
    } catch (_) {
      // Pull incremental falla silenciosamente; se reintentará en el próximo sync
    }
  }

  Map<String, dynamic> _unwrapResponseData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final data = responseData['data'];
      if (data is Map<String, dynamic>) return data;
      return responseData;
    }
    return {};
  }

  List<Map<String, dynamic>> _flattenChanges(dynamic changes) {
    if (changes is! Map<String, dynamic>) return [];

    final pullKeyToResourceType = {
      'siembras': 'siembras',
      'riego': 'riego',
      'fertilizacion': 'fertilizacion',
      'hallazgos': 'hallazgos',
      'tratamientos': 'tratamientos',
      'observaciones': 'observaciones',
      'estadoTerreno': 'estado-terreno',
    };

    final registros = <Map<String, dynamic>>[];
    for (final entry in changes.entries) {
      final resourceType = pullKeyToResourceType[entry.key];
      final items = entry.value;
      if (resourceType == null || items is! List) continue;

      for (final item in items) {
        if (item is Map<String, dynamic>) {
          registros.add({
            'resourceType': resourceType,
            'payload': item,
            'deletedAt': item['deletedAt'],
          });
        }
      }
    }

    return registros;
  }

  Future<void> _upsertRegistrosLocales(List<dynamic> registros) async {
    final db = await _db.database;

    for (final reg in registros) {
      if (reg is! Map<String, dynamic>) continue;

      final resourceType = reg['resourceType'] as String?;
      final tabla = _tablasTipos.entries
          .where((e) => e.value == resourceType)
          .map((e) => e.key)
          .firstOrNull;

      if (tabla == null) continue;

      final payload = reg['payload'] as Map<String, dynamic>?;
      if (payload == null) continue;

      final deletedAt = reg['deletedAt'] as String?;

      if (deletedAt != null) {
        // Soft-delete del servidor: eliminar localmente
        await db
            .delete(tabla, where: 'serverId = ?', whereArgs: [payload['id']]);
      } else {
        // Upsert
        final row = Map<String, dynamic>.from(payload);
        row['isPendingSync'] = 0;
        row['serverId'] = row['id'];
        // Usar id del servidor como id local si no existe uno
        await db.insert(tabla, row,
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
  }

  // ─── SharedPreferences ────────────────────────────────────

  Future<String?> _getLastPulledAt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastPulledAt);
  }

  Future<void> _guardarLastPulledAt(String timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastPulledAt, timestamp);
  }

  // ─── Helper ───────────────────────────────────────────────

  Future<bool> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    return !(result.contains(ConnectivityResult.none) && result.length == 1);
  }
}

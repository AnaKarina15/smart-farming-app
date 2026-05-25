import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/database_helper.dart';
import '../providers/lotes_provider.dart';
import 'batch_sync_service.dart';

/// Servicio de sincronización offline → backend.
///
/// Responsabilidades:
/// 1. Drena la sync_queue cuando hay internet (lotes, etc. del Sprint 1).
/// 2. Delega a [BatchSyncService] para sincronizar las operaciones con
///    el protocolo batch del Sprint 5.
class SyncService {
  final DioClient _dioClient;
  final DatabaseHelper _db = DatabaseHelper.instance;
  late final BatchSyncService _batchSync;

  SyncService(this._dioClient) {
    _batchSync = BatchSyncService(_dioClient);
  }

  // ─── Sincronización principal ─────────────────────────────

  /// Sincroniza TODOS los datos pendientes con el servidor.
  ///
  /// Retorna `true` si hubo internet y la sincronización fue exitosa.
  Future<bool> syncNow({LotesProvider? lotesProvider}) async {
    final conectado = await _checkConnectivity();
    if (!conectado) return false;

    bool huboErrores = false;

    // 1. Crear primero los lotes pendientes.
    // Las operaciones agrícolas guardadas offline pueden apuntar a un lote
    // local_..., por eso primero obtenemos el UUID real del backend y lo
    // propagamos en SQLite antes del batch.
    final lotesOk = await _drenaQueueLotes();
    if (!lotesOk) huboErrores = true;

    // 2. Sincronizar operaciones via Batch Sync (Sprint 5)
    final batchOk = await _batchSync.syncBatch();
    if (!batchOk) huboErrores = true;

    // 3. Drenar la cola genérica restante (PATCH/DELETE de lotes y limpieza)
    // y limpiar entradas duplicadas de operaciones ya sincronizadas por batch.
    huboErrores = !(await _drenaQueueGeneral()) || huboErrores;

    // 4. Recargar lotes desde el backend y actualizar caché local
    if (lotesProvider != null) {
      await lotesProvider.recargar();
    }

    final pendientes = await _db.getPendingSyncCount();
    return !huboErrores && pendientes == 0;
  }

  Future<bool> _drenaQueueLotes() async {
    try {
      final queue = await _db.queryAllRows(DatabaseHelper.tableSyncQueue);
      final db = await _db.database;
      var todoOk = true;

      for (final action in queue) {
        final endpoint = action['endpoint'] as String;
        final method = (action['method'] as String).toUpperCase();

        if (!_isLoteEndpoint(endpoint) || method != 'POST') continue;

        try {
          final rawPayload = action['payload'] != null
              ? json.decode(action['payload'] as String) as Map<String, dynamic>
              : <String, dynamic>{};
          final localId = rawPayload['localId'] as String?;
          final payload = _sanitizePayload(rawPayload)..remove('localId');

          final response = await _dioClient.dio.post(endpoint, data: payload);
          final data = _unwrapResponseData(response.data);
          final serverId = data['id'] as String?;

          if (localId != null && localId.isNotEmpty && serverId != null) {
            await _replaceLocalLoteId(localId: localId, serverId: serverId);
          }

          await db.delete(
            DatabaseHelper.tableSyncQueue,
            where: 'id = ?',
            whereArgs: [action['id']],
          );
        } catch (_) {
          todoOk = false;
        }
      }

      return todoOk;
    } catch (_) {
      return false;
    }
  }

  /// Drena la tabla sync_queue: envía cada acción pendiente al backend.
  Future<bool> _drenaQueueGeneral() async {
    try {
      final queue = await _db.queryAllRows(DatabaseHelper.tableSyncQueue);
      final db = await _db.database;
      var todoOk = true;

      for (final action in queue) {
        try {
          final method = action['method'] as String;
          final endpoint = action['endpoint'] as String;
          final rawPayload = action['payload'] != null
              ? json.decode(action['payload'] as String) as Map<String, dynamic>
              : null;

          final localId = rawPayload?['localId'] as String?;
          if (await _isStaleOperationQueueItem(endpoint, localId)) {
            await db.delete(
              DatabaseHelper.tableSyncQueue,
              where: 'id = ?',
              whereArgs: [action['id']],
            );
            continue;
          }

          // Limpiar campos UUID vacíos antes de enviar al servidor
          // Evita error "must be a UUID" por registros encolados con string vacío
          final payload =
              rawPayload != null ? _sanitizePayload(rawPayload) : null;

          if (payload != null) {
            payload.remove('localId');
          }

          if (method == 'POST') {
            await _dioClient.dio.post(endpoint, data: payload);
          } else if (method == 'PATCH') {
            await _dioClient.dio.patch(endpoint, data: payload);
          } else if (method == 'DELETE') {
            await _dioClient.dio.delete(endpoint);
          }

          // Eliminar de la cola solo si el envío fue exitoso
          await db.delete(
            DatabaseHelper.tableSyncQueue,
            where: 'id = ?',
            whereArgs: [action['id']],
          );
        } catch (_) {
          todoOk = false;
          // Deja la acción en la cola para el próximo intento
        }
      }
      return todoOk;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _isStaleOperationQueueItem(
    String endpoint,
    String? localId,
  ) async {
    final table = _operationTableForEndpoint(endpoint);
    if (table == null) return false;
    if (localId == null || localId.isEmpty) return true;

    final rows = await _db.queryWhere(table, 'id = ?', [localId]);
    if (rows.isEmpty) return true;

    final isPending = rows.first['isPendingSync'] == 1;
    return !isPending;
  }

  String? _operationTableForEndpoint(String endpoint) {
    final path = endpoint.split('?').first;
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return null;

    const endpointTables = {
      'siembras': DatabaseHelper.tableSiembras,
      'riego': DatabaseHelper.tableRiego,
      'fertilizacion': DatabaseHelper.tableFertilizacion,
      'hallazgos': DatabaseHelper.tableHallazgos,
      'tratamientos': DatabaseHelper.tableTratamientos,
      'observaciones': DatabaseHelper.tableObservaciones,
      'estado-terreno': DatabaseHelper.tableEstadoTerreno,
    };

    for (final segment in segments) {
      final table = endpointTables[segment];
      if (table != null) return table;
    }

    return null;
  }

  bool _isLoteEndpoint(String endpoint) {
    final path = endpoint.split('?').first;
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    return segments.contains('lotes');
  }

  Map<String, dynamic> _sanitizePayload(Map<String, dynamic> rawPayload) {
    return Map<String, dynamic>.fromEntries(
      rawPayload.entries.where((e) {
        final v = e.value;
        if (v == null) return false;
        if (v is String && v.isEmpty) return false;
        return true;
      }),
    );
  }

  Map<String, dynamic> _unwrapResponseData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final data = responseData['data'];
      if (data is Map<String, dynamic>) return data;
      return responseData;
    }
    return {};
  }

  Future<void> _replaceLocalLoteId({
    required String localId,
    required String serverId,
  }) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.update(
        DatabaseHelper.tableLotes,
        {
          'id': serverId,
          'isPendingSync': 0,
        },
        where: 'id = ?',
        whereArgs: [localId],
      );

      const tablesWithLoteId = [
        DatabaseHelper.tableSiembras,
        DatabaseHelper.tableRiego,
        DatabaseHelper.tableFertilizacion,
        DatabaseHelper.tableHallazgos,
        DatabaseHelper.tableTratamientos,
        DatabaseHelper.tableObservaciones,
        DatabaseHelper.tableEstadoTerreno,
      ];

      for (final table in tablesWithLoteId) {
        await txn.update(
          table,
          {'loteId': serverId},
          where: 'loteId = ?',
          whereArgs: [localId],
        );
      }
    });
  }

  // ─── Añadir a la cola ─────────────────────────────────────

  /// Añade una acción genérica a la sync_queue (usado internamente).
  Future<void> addToQueue(
    String method,
    String endpoint, [
    Map<String, dynamic>? data,
  ]) async {
    await _db.insert(DatabaseHelper.tableSyncQueue, {
      'method': method,
      'endpoint': endpoint,
      'payload': data != null ? json.encode(data) : null,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // ─── Helper ───────────────────────────────────────────────

  Future<bool> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    return !(result.contains(ConnectivityResult.none) && result.length == 1);
  }
}

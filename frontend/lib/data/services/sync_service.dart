import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
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

    // 1. Drenar la cola genérica (acciones POST/PATCH/DELETE de lotes)
    huboErrores = !(await _drenaQueueGeneral()) || huboErrores;

    // 2. Sincronizar operaciones via Batch Sync (Sprint 5)
    final batchOk = await _batchSync.syncBatch();
    if (!batchOk) huboErrores = true;

    // 3. Recargar lotes desde el backend y actualizar caché local
    if (lotesProvider != null) {
      await lotesProvider.recargar();
    }

    return !huboErrores;
  }

  /// Drena la tabla sync_queue: envía cada acción pendiente al backend.
  Future<bool> _drenaQueueGeneral() async {
    try {
      final queue = await _db.queryAllRows(DatabaseHelper.tableSyncQueue);
      final db = await _db.database;

      for (final action in queue) {
        try {
          final method = action['method'] as String;
          final endpoint = action['endpoint'] as String;
          final rawPayload = action['payload'] != null
              ? json.decode(action['payload'] as String) as Map<String, dynamic>
              : null;

          // Limpiar campos UUID vacíos antes de enviar al servidor
          // Evita error "must be a UUID" por registros encolados con string vacío
          final payload = rawPayload != null
              ? Map<String, dynamic>.fromEntries(
                  rawPayload.entries.where((e) {
                    final v = e.value;
                    if (v == null) return false;
                    if (v is String && v.isEmpty) return false;
                    return true;
                  }),
                )
              : null;

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
          // Deja la acción en la cola para el próximo intento
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─── Módulos Operativos (Sprint 3) ───────────────────────

  // Método legacy mantenido por compatibilidad retroactiva.
  // La lógica real de sync de operaciones ahora vive en BatchSyncService.
  // Puede ser eliminado en una próxima iteración de limpieza.
  Future<void> _syncOperaciones() async {
    // No-op: ahora delega al BatchSyncService
  }

  Future<void> _syncModuloOperativo({
    required String tabla,
    required String endpointBase,
    required Map<String, dynamic> Function(Map<String, dynamic>) mapper,
  }) async {
    final pendientes = await _db.queryWhere(
      tabla,
      'isPendingSync = ? AND syncError IS NULL',
      [1],
    );

    final db = await _db.database;

    for (final row in pendientes) {
      try {
        final payload = mapper(row);
        final response = await _dioClient.dio.post(endpointBase, data: payload);
        
        // 201 Created -> Marcar como sincronizado y guardar serverId
        if (response.statusCode == 201) {
          await db.update(
            tabla,
            {
              'isPendingSync': 0,
              'serverId': response.data['data']['id'],
              'syncError': null,
            },
            where: 'id = ?',
            whereArgs: [row['id']],
          );
        }
      } on DioException catch (e) {
        // Solo marcar con syncError en errores de negocio (400, 403)
        // Los 404 ya no generan IDs mock_ — se dejan en cola para el batch sync
        if (e.response != null &&
            (e.response!.statusCode == 400 ||
                e.response!.statusCode == 403)) {
          final errorData = e.response!.data;
          String errorMsg = 'Error desconocido';
          if (errorData is Map && errorData.containsKey('message')) {
            final msg = errorData['message'];
            errorMsg = msg is List ? msg.join('\n') : msg.toString();
          }

          // Marcar con syncError para revisión manual
          await db.update(
            tabla,
            {'syncError': errorMsg},
            where: 'id = ?',
            whereArgs: [row['id']],
          );
        }
        // 404 y errores de red: dejar en cola sin modificar
      } catch (_) {
        // Fallos de red se dejan para el siguiente intento
      }
    }
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

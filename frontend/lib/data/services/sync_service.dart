import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/database_helper.dart';
import '../providers/lotes_provider.dart';

/// Servicio de sincronización offline → backend.
///
/// Responsabilidades:
/// 1. Drena la sync_queue cuando hay internet (lotes, etc. del Sprint 1).
/// 2. Sincroniza registros locales de todas las tablas con `isPendingSync=1`
///    cuando el backend Sprint 2 esté disponible.
class SyncService {
  final DioClient _dioClient;
  final DatabaseHelper _db = DatabaseHelper.instance;

  SyncService(this._dioClient);

  // ─── Sincronización principal ─────────────────────────────

  /// Sincroniza TODOS los datos pendientes con el servidor.
  ///
  /// Retorna `true` si hubo internet y la sincronización fue exitosa.
  Future<bool> syncNow({LotesProvider? lotesProvider}) async {
    final conectado = await _checkConnectivity();
    if (!conectado) return false;

    bool huboErrores = false;

    // 1. Drenar la cola genérica (acciones POST/PATCH/DELETE)
    huboErrores = !(await _drenaQueueGeneral()) || huboErrores;

    // 2. Recargar lotes desde el backend y actualizar caché local
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
          final payload = action['payload'] != null
              ? json.decode(action['payload'] as String)
              : null;

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

  // ─── Para Sprint 2 ────────────────────────────────────────
  // Cuando el backend tenga los endpoints de siembras, riego, etc.,
  // se llamarán aquí automáticamente al sincronizar.

  /// Sincroniza registros de cualquier tabla local contra un endpoint REST.
  /// Usar cuando el backend Sprint 2 esté listo.
  Future<void> sincronizarTabla({
    required String tabla,
    required String endpointBase,
    required Map<String, dynamic> Function(Map<String, dynamic>) mapper,
  }) async {
    final pendientes = await _db.queryWhere(
      tabla,
      'isPendingSync = ?',
      [1],
    );

    final db = await _db.database;

    for (final row in pendientes) {
      try {
        final payload = mapper(row);
        await _dioClient.dio.post(endpointBase, data: payload);

        // Marcar como sincronizado
        await db.update(
          tabla,
          {'isPendingSync': 0},
          where: 'id = ?',
          whereArgs: [row['id']],
        );
      } catch (_) {
        // Dejar para el próximo intento
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

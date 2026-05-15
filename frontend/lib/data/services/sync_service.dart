import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/database_helper.dart';

class SyncService {
  final DioClient _dioClient;
  final DatabaseHelper _db = DatabaseHelper.instance;

  SyncService(this._dioClient);

  /// Sincroniza los datos locales con el servidor cuando hay internet.
  Future<bool> syncNow() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none) && connectivityResult.length == 1) {
      return false; // No hay internet
    }

    try {
      // 1. Enviar acciones pendientes (POST/PATCH/DELETE)
      final queue = await _db.queryAllRows(DatabaseHelper.tableSyncQueue);
      
      for (var action in queue) {
        final method = action['method'];
        final endpoint = action['endpoint'];
        final payload = action['payload'] != null ? json.decode(action['payload']) : null;

        if (method == 'POST') {
          await _dioClient.dio.post(endpoint, data: payload);
        } else if (method == 'PATCH') {
          await _dioClient.dio.patch(endpoint, data: payload);
        } else if (method == 'DELETE') {
          await _dioClient.dio.delete(endpoint);
        }

        // Eliminar de la cola si tuvo éxito
        await _db.database.then((db) => db.delete(
          DatabaseHelper.tableSyncQueue,
          where: 'id = ?',
          whereArgs: [action['id']],
        ));
      }

      // 2. Aquí iría la lógica para descargar los lotes actualizados (GET)
      // y sobreescribir la tabla Lotes local.
      
      return true; // Sincronización exitosa
    } catch (e) {
      return false; // Falló la sincronización
    }
  }

  /// Añade una acción a la cola cuando estamos offline.
  Future<void> addToQueue(String method, String endpoint, [Map<String, dynamic>? data]) async {
    await _db.insert(DatabaseHelper.tableSyncQueue, {
      'method': method,
      'endpoint': endpoint,
      'payload': data != null ? json.encode(data) : null,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }
}

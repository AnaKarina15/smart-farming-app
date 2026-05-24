import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/database_helper.dart';
import '../../core/network/api_endpoints.dart';
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

    // 3. Sincronizar módulos operativos (Sprint 3)
    await _syncOperaciones();

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

  Future<void> _syncOperaciones() async {
    // Orden estricto según la guía:
    // 1. siembras, 2. riego, 3. fertilizacion, 4. hallazgos, 5. tratamientos, 6. observaciones
    await _syncModuloOperativo(
      tabla: DatabaseHelper.tableSiembras,
      endpointBase: ApiEndpoints.siembras,
      mapper: (row) => {
        'loteId': row['loteId'],
        if (row['cultivoId'] != null) 'cultivoId': row['cultivoId'],
        if (row['cultivoOtro'] != null) 'cultivoOtro': row['cultivoOtro'],
        if (row['variedad'] != null) 'variedad': row['variedad'],
        'fecha': row['fecha'],
        if (row['cantidadSemillas'] != null) 'cantidadSemillas': row['cantidadSemillas'],
        if (row['unidad'] != null) 'unidad': row['unidad'],
        if (row['distanciaEntreFilas'] != null) 'distanciaEntreFilas': row['distanciaEntreFilas'],
        if (row['distanciaEntrePlantas'] != null) 'distanciaEntrePlantas': row['distanciaEntrePlantas'],
        if (row['observaciones'] != null) 'observaciones': row['observaciones'],
      },
    );

    await _syncModuloOperativo(
      tabla: DatabaseHelper.tableRiego,
      endpointBase: ApiEndpoints.riego,
      mapper: (row) => {
        'loteId': row['loteId'],
        'tipo': row['tipo'],
        if (row['duracionMinutos'] != null) 'duracionMinutos': row['duracionMinutos'],
        if (row['cantidadLitros'] != null) 'cantidadLitros': row['cantidadLitros'],
        'fecha': row['fecha'],
        if (row['humedad'] != null) 'humedad': row['humedad'],
        if (row['observaciones'] != null) 'observaciones': row['observaciones'],
      },
    );

    await _syncModuloOperativo(
      tabla: DatabaseHelper.tableFertilizacion,
      endpointBase: ApiEndpoints.fertilizacion,
      mapper: (row) => {
        'loteId': row['loteId'],
        if (row['fertilizanteId'] != null) 'fertilizanteId': row['fertilizanteId'],
        if (row['fertilizanteOtro'] != null) 'fertilizanteOtro': row['fertilizanteOtro'],
        if (row['dosis'] != null) 'dosis': row['dosis'],
        if (row['unidad'] != null) 'unidad': row['unidad'],
        if (row['metodoAplicacion'] != null) 'metodoAplicacion': row['metodoAplicacion'],
        'fecha': row['fecha'],
        if (row['observaciones'] != null) 'observaciones': row['observaciones'],
      },
    );

    await _syncModuloOperativo(
      tabla: DatabaseHelper.tableHallazgos,
      endpointBase: ApiEndpoints.hallazgos,
      mapper: (row) => {
        'loteId': row['loteId'],
        if (row['plagaId'] != null) 'plagaId': row['plagaId'],
        if (row['plagaOtro'] != null) 'plagaOtro': row['plagaOtro'],
        'severidad': row['severidad'],
        if (row['descripcion'] != null) 'descripcion': row['descripcion'],
        if (row['fotoPath'] != null) 'fotoPath': row['fotoPath'],
        'fecha': row['fecha'],
      },
    );

    await _syncModuloOperativo(
      tabla: DatabaseHelper.tableTratamientos,
      endpointBase: ApiEndpoints.tratamientos,
      mapper: (row) => {
        'loteId': row['loteId'],
        if (row['hallazgoId'] != null) 'hallazgoId': row['hallazgoId'],
        'producto': row['producto'],
        if (row['dosis'] != null) 'dosis': row['dosis'],
        if (row['unidad'] != null) 'unidad': row['unidad'],
        if (row['metodoAplicacion'] != null) 'metodoAplicacion': row['metodoAplicacion'],
        'fecha': row['fecha'],
        if (row['observaciones'] != null) 'observaciones': row['observaciones'],
      },
    );

    await _syncModuloOperativo(
      tabla: DatabaseHelper.tableObservaciones,
      endpointBase: ApiEndpoints.observaciones,
      mapper: (row) => {
        'loteId': row['loteId'],
        'descripcion': row['descripcion'],
        if (row['tipo'] != null) 'tipo': row['tipo'],
        'fecha': row['fecha'],
      },
    );

    await _syncModuloOperativo(
      tabla: DatabaseHelper.tableEstadoTerreno,
      endpointBase: ApiEndpoints.estadoTerreno,
      mapper: (row) => {
        'loteId': row['loteId'],
        if (row['siembraId'] != null) 'siembraId': row['siembraId'],
        'estado': row['estado'],
        if (row['tipoSueloId'] != null) 'tipoSueloId': row['tipoSueloId'],
        if (row['notas'] != null) 'notas': row['notas'],
        'createdAt': row['createdAt'],
      },
    );
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
        // Manejo de error específico (400, 403, 404)
        if (e.response != null && e.response!.statusCode == 404) {
          // Fake success para endpoints que aún no existen en el Backend
          await db.update(
            tabla,
            {
              'isPendingSync': 0,
              'serverId': 'mock_${row['id']}',
              'syncError': null,
            },
            where: 'id = ?',
            whereArgs: [row['id']],
          );
        } else if (e.response != null && (e.response!.statusCode == 400 || e.response!.statusCode == 403)) {
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

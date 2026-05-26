import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/storage/database_helper.dart';
import '../../core/network/api_endpoints.dart';
import '../models/lote_model.dart';
import '../services/lotes_service.dart';

/// Provider de Lotes con estrategia Offline-First.
///
/// Flujo de carga:
/// 1. Carga inmediata desde SQLite (sin esperar red) → pantalla responde al instante.
/// 2. En paralelo, intenta descargar del backend.
/// 3. Si descarga exitosa → actualiza SQLite y notifica UI.
/// 4. Si falla la red → mantiene los datos locales sin error visible.
///
/// Flujo de escritura:
/// - Con internet: POST al backend → guarda en SQLite si exitoso.
/// - Sin internet: guarda en SQLite con `isPendingSync=1` + encola en `sync_queue`.
class LotesProvider extends ChangeNotifier {
  final LotesService _lotesService;
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<LoteModel> _lotes = [];
  bool _isLoading = false;
  bool _isOnline = true;
  String? _errorMessage;
  DateTime? _lastSync;
  int _pendingSyncCount = 0;

  LotesProvider(this._lotesService);

  // ─── Getters ──────────────────────────────────────────────

  List<LoteModel> get lotes => _lotes;
  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;
  String? get errorMessage => _errorMessage;
  DateTime? get lastSync => _lastSync;
  int get pendingSyncCount => _pendingSyncCount;
  bool get hasLotes => _lotes.isNotEmpty;

  /// Nombres de lotes para usar en dropdowns de otras pantallas.
  List<String> get lotesNombres => _lotes.map((l) => l.nombre).toList();

  // ─── Inicialización ───────────────────────────────────────

  /// Inicializar: carga local primero, luego intenta sincronizar.
  Future<void> init() async {
    if (!kIsWeb) {
      await _cargarDesdeLocal();
    }
    await _sincronizarConBackend();
    await _actualizarContadorPendientes();
  }

  /// Carga los lotes desde SQLite (sin necesitar internet).
  Future<void> _cargarDesdeLocal() async {
    if (kIsWeb) return;

    try {
      final rows = await _db.getLotes();
      _lotes = rows.map((row) => _loteFromDb(row)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('[LotesProvider] Error cargando SQLite: $e');
    }
  }

  /// Intenta descargar los lotes del backend y actualiza SQLite.
  Future<void> _sincronizarConBackend() async {
    final conectado = await _checkConnectivity().timeout(
      const Duration(seconds: 3),
      onTimeout: () => true,
    );
    _isOnline = conectado;

    if (!conectado) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final remoteLotes = await _lotesService
          .listarLotes()
          .timeout(const Duration(seconds: 15));
      _lotes = remoteLotes;
      _lastSync = DateTime.now();

      if (!kIsWeb) {
        try {
          final rows = remoteLotes.map((l) => _loteToDb(l)).toList();
          await _db.clearTable(DatabaseHelper.tableLotes);
          await _db.upsertLotes(rows);
        } catch (dbError) {
          debugPrint(
              '[LotesProvider] No se pudo actualizar cache local: $dbError');
        }
      }

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      // No mostramos error si tenemos datos locales
      if (_lotes.isEmpty) {
        _errorMessage = 'Sin conexión y sin datos guardados localmente.';
      }
      notifyListeners();
    }
  }

  // ─── API pública ─────────────────────────────────────────

  /// Recarga forzada (botón "Sincronizar" en Settings).
  /// Devuelve el valor solo si tiene formato UUID v4 válido, de lo contrario null.
  /// Evita enviar IDs inválidos al backend ("must be a UUID").
  String? _sanitizeUuid(String? value) {
    if (value == null || value.isEmpty) return null;
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(value) ? value : null;
  }

  Future<String?> _resolveCatalogUuid(String? value, String table) async {
    final directUuid = _sanitizeUuid(value);
    if (directUuid != null || value == null || value.isEmpty) {
      return directUuid;
    }
    if (kIsWeb) return null;

    try {
      final selectedRows = await _db.queryWhere(table, 'id = ?', [value]);
      if (selectedRows.isEmpty) return null;

      final selectedName = selectedRows.first['nombre'] as String?;
      if (selectedName == null || selectedName.isEmpty) return null;

      final rowsWithSameName = await _db.queryWhere(
        table,
        'LOWER(nombre) = LOWER(?)',
        [selectedName],
      );
      for (final row in rowsWithSameName) {
        final id = row['id'] as String?;
        final uuid = _sanitizeUuid(id);
        if (uuid != null) return uuid;
      }
    } catch (e) {
      debugPrint('[LotesProvider] No se pudo resolver UUID de catálogo: $e');
    }

    return null;
  }

  Future<bool> recargar() async {
    _errorMessage = null;
    await _sincronizarConBackend();
    await _actualizarContadorPendientes();
    return _isOnline;
  }

  /// Crea un lote nuevo.
  ///
  /// - Con internet: POST al backend → guarda en SQLite.
  /// - Sin internet: guarda en SQLite local + encola para sincronizar después.
  Future<bool> crearLote({
    required String nombre,
    String? descripcion,
    required double superficieHectareas,
    String? cultivoActual,
    String? cultivoActualId,
    String? municipioId,
    String? tipoSueloId,
    double? latitud,
    double? longitud,
    required String propietarioId,
  }) async {
    final conectado = await _checkConnectivity();
    final serverMunicipioId = await _resolveCatalogUuid(
      municipioId,
      DatabaseHelper.tableCatMunicipios,
    );
    final serverTipoSueloId = await _resolveCatalogUuid(
      tipoSueloId,
      DatabaseHelper.tableCatTiposSuelo,
    );

    if (conectado) {
      try {
        final lote = await _lotesService.crearLote(
          nombre: nombre,
          descripcion: descripcion,
          superficieHectareas: superficieHectareas,
          cultivoActual: cultivoActual,
          cultivoActualId: _sanitizeUuid(cultivoActualId),
          municipioId: serverMunicipioId,
          tipoSueloId: serverTipoSueloId,
          latitud: latitud,
          longitud: longitud,
        );
        _lotes.add(lote);
        try {
          await _db.insert(DatabaseHelper.tableLotes, _loteToDb(lote));
        } catch (dbError) {
          debugPrint(
              'Aviso: Lote creado en servidor pero falló caché local: $dbError');
          // No lanzamos error porque el objetivo principal (guardar en la nube) ya se cumplió.
        }
        notifyListeners();
        return true;
      } catch (e) {
        _errorMessage = e.toString();
        notifyListeners();
        return false;
      }
    } else {
      try {
        // Offline: guardar local con UUID temporal
        final tempId = 'local_${DateTime.now().millisecondsSinceEpoch}';
        final now = DateTime.now().toIso8601String();
        final loteLocal = {
          'id': tempId,
          'nombre': nombre,
          'descripcion': descripcion,
          'superficieHectareas': superficieHectareas,
          'cultivoActual': cultivoActual,
          'cultivoActualId': cultivoActualId,
          'municipioId': serverMunicipioId ?? municipioId,
          'tipoSueloId': serverTipoSueloId ?? tipoSueloId,
          'latitud': latitud,
          'longitud': longitud,
          'estado': 'saludable',
          'propietarioId': propietarioId,
          'createdAt': now,
          'updatedAt': now,
          'isPendingSync': 1,
        };
        await _db.insert(DatabaseHelper.tableLotes, loteLocal);

        // Encolar para cuando vuelva internet
        await _db.insert(DatabaseHelper.tableSyncQueue, {
          'method': 'POST',
          'endpoint': ApiEndpoints.lotes,
          'payload': json.encode({
            'localId': tempId,
            'nombre': nombre,
            if (descripcion != null) 'descripcion': descripcion,
            'superficieHectareas': superficieHectareas,
            if (cultivoActual != null && cultivoActual.isNotEmpty)
              'cultivoActual': cultivoActual,
            if (_sanitizeUuid(cultivoActualId) != null)
              'cultivoActualId': _sanitizeUuid(cultivoActualId),
            if (serverMunicipioId != null) 'municipioId': serverMunicipioId,
            if (serverTipoSueloId != null) 'tipoSueloId': serverTipoSueloId,
            if (latitud != null) 'latitud': latitud,
            if (longitud != null) 'longitud': longitud,
          }),
          'createdAt': now,
        });

        await _cargarDesdeLocal();
        await _actualizarContadorPendientes();
        return true;
      } catch (e) {
        _errorMessage = e.toString();
        notifyListeners();
        return false;
      }
    }
  }

  /// Actualiza un lote existente (soporte offline).
  Future<bool> actualizarLote({
    required String id,
    String? nombre,
    String? descripcion,
    double? superficieHectareas,
    String? cultivoActual,
    String? municipioId,
    String? tipoSueloId,
    double? latitud,
    double? longitud,
  }) async {
    final conectado = await _checkConnectivity();
    final isLocalOnly = id.startsWith('local_');
    final serverMunicipioId = await _resolveCatalogUuid(
      municipioId,
      DatabaseHelper.tableCatMunicipios,
    );
    final serverTipoSueloId = await _resolveCatalogUuid(
      tipoSueloId,
      DatabaseHelper.tableCatTiposSuelo,
    );

    // 1. Actualizamos localmente en memoria y SQLite
    final index = _lotes.indexWhere((l) => l.id == id);
    if (index != -1) {
      final old = _lotes[index];
      final updated = LoteModel(
        id: old.id,
        nombre: nombre ?? old.nombre,
        descripcion: descripcion ?? old.descripcion,
        superficieHectareas: superficieHectareas ?? old.superficieHectareas,
        cultivoActual: cultivoActual ?? old.cultivoActual,
        cultivoActualId: old.cultivoActualId,
        municipioId: serverMunicipioId ?? municipioId ?? old.municipioId,
        tipoSueloId: serverTipoSueloId ?? tipoSueloId ?? old.tipoSueloId,
        siembraActualNombre: old.siembraActualNombre,
        latitud: latitud ?? old.latitud,
        longitud: longitud ?? old.longitud,
        estado: old.estado,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
        propietarioId: old.propietarioId,
      );
      _lotes[index] = updated;

      if (!kIsWeb) {
        try {
          await _db.update(
            DatabaseHelper.tableLotes,
            {
              'nombre': updated.nombre,
              'descripcion': updated.descripcion,
              'superficieHectareas': updated.superficieHectareas,
              'cultivoActual': updated.cultivoActual,
              'cultivoActualId': updated.cultivoActualId,
              'municipioId': updated.municipioId,
              'tipoSueloId': updated.tipoSueloId,
              'latitud': updated.latitud,
              'longitud': updated.longitud,
              'estado': updated.estado,
              'updatedAt': updated.updatedAt.toIso8601String(),
              'isPendingSync': 1,
            },
            'id = ?',
            [id],
          );
        } catch (e) {
          _errorMessage = e.toString();
          notifyListeners();
          return false;
        }
      }
    }

    final payload = {
      if (nombre != null) 'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      if (superficieHectareas != null)
        'superficieHectareas': superficieHectareas,
      if (cultivoActual != null) 'cultivoActual': cultivoActual,
      if (serverMunicipioId != null) 'municipioId': serverMunicipioId,
      if (serverTipoSueloId != null) 'tipoSueloId': serverTipoSueloId,
      if (latitud != null) 'latitud': latitud,
      if (longitud != null) 'longitud': longitud,
    };

    if (isLocalOnly) {
      // Si es un lote que no ha subido al servidor, basta con la edicion en SQLite
      notifyListeners();
      return true;
    }

    if (conectado) {
      try {
        final remoteLote = await _lotesService.actualizarLote(
          id: id,
          nombre: nombre,
          descripcion: descripcion,
          superficieHectareas: superficieHectareas,
          cultivoActual: cultivoActual,
          municipioId: serverMunicipioId,
          tipoSueloId: serverTipoSueloId,
          latitud: latitud,
          longitud: longitud,
        );
        final remoteIndex = _lotes.indexWhere((l) => l.id == id);
        if (remoteIndex != -1) {
          _lotes[remoteIndex] = remoteLote;
        }
        if (!kIsWeb) {
          try {
            await _db.update(
              DatabaseHelper.tableLotes,
              _loteToDb(remoteLote),
              'id = ?',
              [id],
            );
          } catch (dbError) {
            debugPrint(
                '[LotesProvider] Lote actualizado en servidor pero fallo cache local: $dbError');
          }
        }
        notifyListeners();
        return true;
      } catch (e) {
        // Falló internet, pasamos al modo offline
      }
    }

    // Modo offline (encolamos el PATCH)
    try {
      await _db.insert(DatabaseHelper.tableSyncQueue, {
        'method': 'PATCH',
        'endpoint': '${ApiEndpoints.lotes}/$id',
        'payload': json.encode(payload),
        'createdAt': DateTime.now().toIso8601String(),
      });
      await _actualizarContadorPendientes();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Elimina un lote (soporte offline).
  Future<bool> eliminarLote(String id) async {
    final conectado = await _checkConnectivity();
    final isLocalOnly = id.startsWith('local_');

    // Siempre lo desaparecemos de memoria y DB local de inmediato (Eliminación fantasma)
    _lotes.removeWhere((l) => l.id == id);
    await _db.deleteById(DatabaseHelper.tableLotes, id);

    // Limpiar cualquier acción pendiente (POST/PATCH) para este lote de la sync_queue
    try {
      final db = await _db.database;
      if (isLocalOnly) {
        final queue = await _db.queryAllRows(DatabaseHelper.tableSyncQueue);
        for (final action in queue) {
          if (action['payload'] != null) {
            final Map<String, dynamic> data =
                json.decode(action['payload'] as String);
            if (data['localId'] == id) {
              await db.delete(
                DatabaseHelper.tableSyncQueue,
                where: 'id = ?',
                whereArgs: [action['id']],
              );
            }
          }
        }
      } else {
        await db.delete(
          DatabaseHelper.tableSyncQueue,
          where: 'endpoint = ? OR endpoint = ?',
          whereArgs: ['${ApiEndpoints.lotes}/$id', ApiEndpoints.loteById(id)],
        );
      }
    } catch (e) {
      debugPrint(
          '[LotesProvider] Error al limpiar cola de sincronización para lote: $e');
    }

    if (isLocalOnly) {
      notifyListeners();
      return true;
    }

    if (conectado) {
      try {
        await _lotesService.eliminarLote(id);
        notifyListeners();
        return true;
      } catch (e) {
        // Fallo en la red, pasamos a modo offline fallback
      }
    }

    // Modo offline (o si falló la red): encolamos la tarea para borrarlo luego
    try {
      await _db.insert(DatabaseHelper.tableSyncQueue, {
        'method': 'DELETE',
        'endpoint': '${ApiEndpoints.lotes}/$id',
        'payload': json.encode({}),
        'createdAt': DateTime.now().toIso8601String(),
      });
      await _actualizarContadorPendientes();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ─── Helpers privados ─────────────────────────────────────

  Future<bool> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    return !(result.contains(ConnectivityResult.none) && result.length == 1);
  }

  Future<void> _actualizarContadorPendientes() async {
    if (kIsWeb) {
      _pendingSyncCount = 0;
      notifyListeners();
      return;
    }

    try {
      _pendingSyncCount = await _db.getPendingSyncCount();
      notifyListeners();
    } catch (e) {
      debugPrint('[LotesProvider] Error contando pendientes: $e');
    }
  }

  LoteModel _loteFromDb(Map<String, dynamic> row) {
    return LoteModel(
      id: row['id'] as String,
      nombre: row['nombre'] as String,
      descripcion: row['descripcion'] as String?,
      superficieHectareas: (row['superficieHectareas'] as num).toDouble(),
      cultivoActual: row['cultivoActual'] as String?,
      cultivoActualId: row['cultivoActualId'] as String?,
      municipioId: row['municipioId'] as String?,
      tipoSueloId: row['tipoSueloId'] as String?,
      latitud:
          row['latitud'] != null ? (row['latitud'] as num).toDouble() : null,
      longitud:
          row['longitud'] != null ? (row['longitud'] as num).toDouble() : null,
      estado: row['estado'] as String? ?? 'saludable',
      propietarioId: row['propietarioId'] as String,
      createdAt: DateTime.parse(row['createdAt'] as String),
      updatedAt: DateTime.parse(row['updatedAt'] as String),
    );
  }

  Map<String, dynamic> _loteToDb(LoteModel lote) {
    return {
      'id': lote.id,
      'nombre': lote.nombre,
      'descripcion': lote.descripcion,
      'superficieHectareas': lote.superficieHectareas,
      'cultivoActual': lote.cultivoActual,
      'cultivoActualId': lote.cultivoActualId,
      'municipioId': lote.municipioId,
      'tipoSueloId': lote.tipoSueloId,
      'latitud': lote.latitud,
      'longitud': lote.longitud,
      'estado': lote.estado,
      'propietarioId': lote.propietarioId,
      'createdAt': lote.createdAt.toIso8601String(),
      'updatedAt': lote.updatedAt.toIso8601String(),
      'isPendingSync': 0,
    };
  }
}

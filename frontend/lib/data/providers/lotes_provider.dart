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
  List<String> get lotesNombres =>
      _lotes.map((l) => l.nombre).toList();

  // ─── Inicialización ───────────────────────────────────────

  /// Inicializar: carga local primero, luego intenta sincronizar.
  Future<void> init() async {
    await _cargarDesdeLocal();
    await _sincronizarConBackend();
    await _actualizarContadorPendientes();
  }

  /// Carga los lotes desde SQLite (sin necesitar internet).
  Future<void> _cargarDesdeLocal() async {
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
    final conectado = await _checkConnectivity();
    _isOnline = conectado;

    if (!conectado) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final remoteLotes = await _lotesService.listarLotes();
      _lotes = remoteLotes;
      _lastSync = DateTime.now();

      // Persistir en SQLite
      final rows = remoteLotes.map((l) => _loteToDb(l)).toList();
      await _db.clearTable(DatabaseHelper.tableLotes);
      await _db.upsertLotes(rows);

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

    if (conectado) {
      try {
        final lote = await _lotesService.crearLote(
          nombre: nombre,
          descripcion: descripcion,
          superficieHectareas: superficieHectareas,
          cultivoActual: cultivoActual,
          cultivoActualId: cultivoActualId,
          municipioId: municipioId,
          tipoSueloId: tipoSueloId,
          latitud: latitud,
          longitud: longitud,
        );
        _lotes.add(lote);
        await _db.insert(DatabaseHelper.tableLotes, _loteToDb(lote));
        notifyListeners();
        return true;
      } catch (e) {
        _errorMessage = e.toString();
        notifyListeners();
        return false;
      }
    } else {
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
        'municipioId': municipioId,
        'tipoSueloId': tipoSueloId,
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
          'nombre': nombre,
          if (descripcion != null) 'descripcion': descripcion,
          'superficieHectareas': superficieHectareas,
          if (cultivoActual != null) 'cultivoActual': cultivoActual,
          if (cultivoActualId != null) 'cultivoActualId': cultivoActualId,
          if (municipioId != null) 'municipioId': municipioId,
          if (tipoSueloId != null) 'tipoSueloId': tipoSueloId,
          if (latitud != null) 'latitud': latitud,
          if (longitud != null) 'longitud': longitud,
        }),
        'createdAt': now,
      });

      await _cargarDesdeLocal();
      await _actualizarContadorPendientes();
      return true;
    }
  }

  /// Elimina un lote (solo con internet por ahora).
  Future<bool> eliminarLote(String id) async {
    try {
      await _lotesService.eliminarLote(id);
      _lotes.removeWhere((l) => l.id == id);
      await _db.deleteById(DatabaseHelper.tableLotes, id);
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
    _pendingSyncCount = await _db.getPendingSyncCount();
    notifyListeners();
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
      latitud: row['latitud'] != null ? (row['latitud'] as num).toDouble() : null,
      longitud: row['longitud'] != null ? (row['longitud'] as num).toDouble() : null,
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

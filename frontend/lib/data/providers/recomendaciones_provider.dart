import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/storage/database_helper.dart';
import '../models/recomendacion_model.dart';
import '../services/recomendaciones_service.dart';

/// Provider de Estado para el Sistema Experto de Recomendaciones.
///
/// - Carga recomendaciones del backend para el lote activo.
/// - Cachea resultados en SQLite para uso offline.
/// - Expone [recomendacionesCriticas] (prioridad >= 4) para las alertas.
class RecomendacionesProvider extends ChangeNotifier {
  final RecomendacionesService _service;
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Recomendacion> _recomendaciones = [];
  bool _isLoading = false;
  String? _error;
  String? _loteIdActual;

  RecomendacionesProvider(this._service);

  List<Recomendacion> get recomendaciones => _recomendaciones;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get loteIdActual => _loteIdActual;

  /// Recomendaciones de prioridad alta (4) y crítica (5) — para la pantalla de alertas.
  List<Recomendacion> get recomendacionesCriticas =>
      _recomendaciones.where((r) => r.esCritica).toList();

  /// Total de alertas críticas activas.
  int get totalAlertas => recomendacionesCriticas.length;

  /// Carga recomendaciones del backend para [loteId].
  /// Si el backend no responde, intenta cargar del caché SQLite.
  Future<void> cargarParaLote(String loteId) async {
    if (_isLoading && _loteIdActual == loteId) return;

    _loteIdActual = loteId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Intentar cargar desde el backend
      final lista = await _service.evaluar(loteId);

      if (lista.isNotEmpty) {
        _recomendaciones = lista;
        // Guardar en caché SQLite
        await _cacheRecomendaciones(loteId, lista);
      } else {
        // 2. Fallback al caché local si el backend devuelve vacío o falla
        _recomendaciones = await _cargarDesdeCache(loteId);
      }
    } catch (_) {
      _recomendaciones = await _cargarDesdeCache(loteId);
      _error = 'Sin conexión — mostrando datos en caché';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Registra la decisión del productor (aplicar/descartar) y elimina la
  /// recomendación de la lista activa.
  Future<bool> registrarDecision({
    required String reglaId,
    required String loteId,
    required String decision,
    String? nota,
  }) async {
    // Guardar en SQLite para sync posterior
    await _guardarDecisionLocal(
      reglaId: reglaId,
      loteId: loteId,
      decision: decision,
      nota: nota,
    );

    // Intentar enviar al backend inmediatamente
    final ok = await _service.registrarDecision(
      reglaId: reglaId,
      loteId: loteId,
      decision: decision,
      nota: nota,
    );

    if (ok) {
      // Marcar como sincronizada
      final dbObj = await _db.database;
      await dbObj.update(
        DatabaseHelper.tableRecomendacionesAplicadas,
        {'isPendingSync': 0},
        where: 'reglaId = ? AND loteId = ?',
        whereArgs: [reglaId, loteId],
      );
    }

    // Quitar de la lista activa
    _recomendaciones.removeWhere((r) => r.reglaId == reglaId);
    notifyListeners();

    return ok;
  }

  /// Limpia las recomendaciones actuales (al cambiar de lote).
  void limpiar() {
    _recomendaciones = [];
    _loteIdActual = null;
    _error = null;
    notifyListeners();
  }

  // ─── Cache SQLite ──────────────────────────────────────────

  Future<void> _cacheRecomendaciones(
    String loteId,
    List<Recomendacion> lista,
  ) async {
    final db = await _db.database;
    final batch = db.batch();
    final now = DateTime.now().toIso8601String();

    // Limpiar caché anterior para este lote
    batch.delete(
      DatabaseHelper.tableReglas,
      where: '1=1', // Limpiamos todas las reglas cacheadas y reemplazamos
    );

    for (final r in lista) {
      batch.insert(
        DatabaseHelper.tableReglas,
        {
          'id': r.reglaId,
          'codigo': r.codigo,
          'nombre': r.nombre,
          'tipoRecomendacion': r.tipoRecomendacion,
          'accionSugerida': r.accionSugerida,
          'productoSugerido': r.productoSugerido,
          'dosisRecomendada': r.dosisRecomendada,
          'unidadRecomendada': r.unidadRecomendada,
          'metodoAplicacion': r.metodoAplicacion,
          'prioridad': r.prioridad,
          'fuenteCientifica': r.fuenteCientifica,
          'motivoMatch': r.motivoMatch,
          'loteId': loteId,
          'activo': 1,
          'syncedAt': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Recomendacion>> _cargarDesdeCache(String loteId) async {
    try {
      final db = await _db.database;
      final rows = await db.query(
        DatabaseHelper.tableReglas,
        where: 'loteId = ? AND activo = 1',
        whereArgs: [loteId],
        orderBy: 'prioridad DESC',
      );

      return rows.map((row) {
        return Recomendacion(
          reglaId: row['id'] as String,
          codigo: row['codigo'] as String? ?? '',
          nombre: row['nombre'] as String,
          tipoRecomendacion: row['tipoRecomendacion'] as String? ?? '',
          accionSugerida: row['accionSugerida'] as String? ?? '',
          productoSugerido: row['productoSugerido'] as String?,
          dosisRecomendada: row['dosisRecomendada'] as String?,
          unidadRecomendada: row['unidadRecomendada'] as String?,
          metodoAplicacion: row['metodoAplicacion'] as String?,
          prioridad: (row['prioridad'] as int?) ?? 1,
          fuenteCientifica: row['fuenteCientifica'] as String?,
          motivoMatch: row['motivoMatch'] as String?,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _guardarDecisionLocal({
    required String reglaId,
    required String loteId,
    required String decision,
    String? nota,
  }) async {
    await _db.insert(DatabaseHelper.tableRecomendacionesAplicadas, {
      'reglaId': reglaId,
      'loteId': loteId,
      'decision': decision,
      if (nota != null) 'notaProductor': nota,
      'fecha': DateTime.now().toIso8601String(),
      'isPendingSync': 1,
    });
  }
}

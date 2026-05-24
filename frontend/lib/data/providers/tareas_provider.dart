import 'package:flutter/foundation.dart';
import '../../core/storage/database_helper.dart';
import '../../core/services/weather_service.dart';
import '../services/operaciones_service.dart';

// ─── Enums ─────────────────────────────────────────────────

enum TareaTipo { riego, hallazgo, tratamiento, evaluacion, fertilizacion, observacion, clima }

enum TareaPrioridad { alta, media, baja }

// ─── Modelo de tarea ───────────────────────────────────────

class TareaItem {
  final TareaTipo tipo;
  final String loteId;
  final String loteNombre;
  final String titulo;
  final String descripcion;
  final String motivo;
  final String accionLabel;
  final TareaPrioridad prioridad;

  // Datos contextuales para pre-llenar las pantallas destino
  final String? hallazgoId;
  final String? plagaNombre;
  final String? productoTratamiento;
  final String? tiempoTratamiento;

  const TareaItem({
    required this.tipo,
    required this.loteId,
    required this.loteNombre,
    required this.titulo,
    required this.descripcion,
    required this.motivo,
    required this.accionLabel,
    required this.prioridad,
    this.hallazgoId,
    this.plagaNombre,
    this.productoTratamiento,
    this.tiempoTratamiento,
  });
}

// ─── Provider ─────────────────────────────────────────────

class TareasProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final WeatherService _weatherService = WeatherService();
  // OperacionesService se mantiene para uso futuro con el backend
  // ignore: unused_field
  final OperacionesService _operacionesService;

  TareasProvider(this._operacionesService);

  List<TareaItem> _tareas = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TareaItem> get tareas => _tareas;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasTareas => _tareas.isNotEmpty;
  /// Cantidad de tareas pendientes — usado por el badge del nav.
  int get pendingCount => _tareas.length;

  /// Carga las tareas solo si aún no hay ninguna (evita recargas redundantes).
  /// Ideal para disparar en segundo plano desde el árbol de providers.
  Future<void> cargarSiNoHay() async {
    if (_tareas.isNotEmpty || _isLoading) return;
    await cargarTareas();
  }

  // ─── Punto de entrada ──────────────────────────────────

  /// Carga y genera todas las tareas para el usuario actual.
  /// 
  /// Estrategia offline-first:
  ///  1. Lee los lotes del SQLite local.
  ///  2. Para cada lote analiza riegos, hallazgos, fertilizaciones,
  ///     tratamientos y observaciones recientes.
  ///  3. Genera sugerencias/alertas inteligentes basadas en reglas.
  Future<void> cargarTareas() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final lotes = await _db.getLotes();
      if (lotes.isEmpty) {
        _tareas = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      final List<TareaItem> generadas = [];

      for (final lote in lotes) {
        final loteId = lote['id'] as String;
        final loteNombre = lote['nombre'] as String;

        // 1. Riego: si no hay riego en 3+ días o nunca
        final tareaRiego = await _evaluarRiego(loteId, loteNombre);
        if (tareaRiego != null) generadas.add(tareaRiego);

        // 2. Hallazgos sin tratar (alta/crítica)
        final tareasHallazgos = await _evaluarHallazgosSinTratamiento(loteId, loteNombre);
        generadas.addAll(tareasHallazgos);

        // 3. Evaluación post-tratamiento (24-72h después de aplicar)
        final tareasEvaluacion = await _evaluarTratamientosRecientes(loteId, loteNombre);
        generadas.addAll(tareasEvaluacion);

        // 4. Fertilización: si no hay fertilización en 30+ días
        final tareaFert = await _evaluarFertilizacion(loteId, loteNombre);
        if (tareaFert != null) generadas.add(tareaFert);

        // 5. Observación: si no hay en 7+ días
        final tareaObs = await _evaluarObservacion(loteId, loteNombre);
        if (tareaObs != null) generadas.add(tareaObs);

        // 6. Alerta climática: anomalías según api de clima
        final tareaClima = await _evaluarClima(lote, loteId, loteNombre);
        if (tareaClima != null) generadas.add(tareaClima);
      }

      // Ordenar por prioridad: alta → media → baja
      generadas.sort((a, b) => a.prioridad.index.compareTo(b.prioridad.index));

      _tareas = generadas;
    } catch (e) {
      _errorMessage = 'Error cargando tareas: $e';
      debugPrint('[TareasProvider] $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Regla 1: Riego ────────────────────────────────────

  Future<TareaItem?> _evaluarRiego(String loteId, String loteNombre) async {
    try {
      final riegos = await _db.queryWhere(
        DatabaseHelper.tableRiego,
        'loteId = ?',
        [loteId],
      );

      DateTime? ultimoRiego;
      if (riegos.isNotEmpty) {
        riegos.sort((a, b) =>
            (b['fecha'] as String? ?? '').compareTo(a['fecha'] as String? ?? ''));
        final fechaStr = riegos.first['fecha'] as String?;
        ultimoRiego = fechaStr != null ? DateTime.tryParse(fechaStr) : null;
      }

      final now = DateTime.now();
      int diasSinRiego = 999;
      if (ultimoRiego != null) {
        diasSinRiego = now.difference(ultimoRiego).inDays;
      }

      if (diasSinRiego < 3) return null; // Regado recientemente

      // Calcular litros recomendados según días
      int litrosRecomendados;
      String prioridadStr;
      TareaPrioridad prioridad;

      if (diasSinRiego >= 7) {
        litrosRecomendados = 50;
        prioridadStr = 'Urgente: lleva $diasSinRiego días sin riego';
        prioridad = TareaPrioridad.alta;
      } else if (diasSinRiego >= 5) {
        litrosRecomendados = 40;
        prioridadStr = 'Lleva $diasSinRiego días sin riego';
        prioridad = TareaPrioridad.media;
      } else {
        litrosRecomendados = 25;
        prioridadStr = 'Lleva $diasSinRiego días sin riego';
        prioridad = TareaPrioridad.baja;
      }

      // Obtener cultivo del lote para mensaje contextual
      final loteRows = await _db.queryWhere(DatabaseHelper.tableLotes, 'id = ?', [loteId]);
      final cultivoActual = loteRows.isNotEmpty
          ? (loteRows.first['cultivoActual'] as String? ?? '')
          : '';
      final cultivoTexto =
          cultivoActual.isNotEmpty ? ' para el cultivo de ${cultivoActual.toLowerCase()}' : '';

      return TareaItem(
        tipo: TareaTipo.riego,
        loteId: loteId,
        loteNombre: loteNombre,
        titulo: 'Sugerencia de Riego',
        descripcion: ultimoRiego == null
            ? '$loteNombre: Aún no se ha registrado ningún riego. Aplica ${litrosRecomendados}L$cultivoTexto.'
            : '$loteNombre: Aplicar ${litrosRecomendados}L$cultivoTexto.',
        motivo: ultimoRiego == null ? 'Sin registros previos de riego' : prioridadStr,
        accionLabel: 'EJECUTAR RIEGO',
        prioridad: prioridad,
      );
    } catch (e) {
      debugPrint('[TareasProvider] _evaluarRiego error: $e');
      return null;
    }
  }

  // ─── Regla 2: Hallazgos sin tratamiento ────────────────

  Future<List<TareaItem>> _evaluarHallazgosSinTratamiento(
      String loteId, String loteNombre) async {
    final List<TareaItem> tareas = [];
    try {
      final hallazgos = await _db.queryWhere(
        DatabaseHelper.tableHallazgos,
        'loteId = ?',
        [loteId],
      );

      if (hallazgos.isEmpty) return tareas;

      for (final h in hallazgos) {
        final severidad = (h['severidad'] as String? ?? 'baja').toLowerCase();
        if (severidad != 'alta' && severidad != 'critica') continue;

        final hallazgoId = h['id'] as String;
        final plagaNombre =
            (h['tipo'] as String? ?? h['plagaOtro'] as String? ?? 'Plaga desconocida');

        // Verificar si ya hay un tratamiento reciente para este hallazgo
        final tratamientos = await _db.queryWhere(
          DatabaseHelper.tableTratamientos,
          'hallazgoId = ?',
          [hallazgoId],
        );

        bool tieneTratamientoReciente = false;
        if (tratamientos.isNotEmpty) {
          tratamientos.sort((a, b) =>
              (b['fecha'] as String? ?? '').compareTo(a['fecha'] as String? ?? ''));
          final ultimoFechaStr = tratamientos.first['fecha'] as String?;
          if (ultimoFechaStr != null) {
            final ultimo = DateTime.tryParse(ultimoFechaStr);
            if (ultimo != null &&
                DateTime.now().difference(ultimo).inHours < 48) {
              tieneTratamientoReciente = true;
            }
          }
        }

        if (tieneTratamientoReciente) continue;

        final prioridad =
            severidad == 'critica' ? TareaPrioridad.alta : TareaPrioridad.alta;
        final severidadLabel =
            severidad == 'critica' ? 'CRÍTICA' : 'ALTA';

        tareas.add(TareaItem(
          tipo: TareaTipo.tratamiento,
          loteId: loteId,
          loteNombre: loteNombre,
          titulo: 'Aplicar Tratamiento',
          descripcion: '$loteNombre: Se detectó presencia de $plagaNombre. Severidad $severidadLabel.',
          motivo: 'Hallazgo sin tratamiento reciente',
          accionLabel: 'APLICAR TRATAMIENTO',
          prioridad: prioridad,
          hallazgoId: hallazgoId,
          plagaNombre: plagaNombre,
        ));
      }
    } catch (e) {
      debugPrint('[TareasProvider] _evaluarHallazgosSinTratamiento error: $e');
    }
    return tareas;
  }

  // ─── Regla 3: Evaluación post-tratamiento ──────────────

  Future<List<TareaItem>> _evaluarTratamientosRecientes(
      String loteId, String loteNombre) async {
    final List<TareaItem> tareas = [];
    try {
      final tratamientos = await _db.queryWhere(
        DatabaseHelper.tableTratamientos,
        'loteId = ?',
        [loteId],
      );

      if (tratamientos.isEmpty) return tareas;

      final now = DateTime.now();

      for (final t in tratamientos) {
        final fechaStr = t['fecha'] as String?;
        if (fechaStr == null) continue;
        final fecha = DateTime.tryParse(fechaStr);
        if (fecha == null) continue;

        final horas = now.difference(fecha).inHours;
        // Evaluar si el tratamiento fue hace entre 24 y 96 horas
        if (horas < 24 || horas > 96) continue;

        final producto = t['producto'] as String? ?? 'Tratamiento aplicado';
        final hallazgoId = t['hallazgoId'] as String?;

        // Obtener nombre de la plaga del hallazgo si existe
        String plagaNombre = 'plaga tratada';
        if (hallazgoId != null) {
          final hallazgos = await _db.queryWhere(
            DatabaseHelper.tableHallazgos,
            'id = ?',
            [hallazgoId],
          );
          if (hallazgos.isNotEmpty) {
            plagaNombre = hallazgos.first['tipo'] as String? ??
                hallazgos.first['plagaOtro'] as String? ??
                'plaga tratada';
          }
        }

        final tiempoLabel = horas < 48
            ? '${horas}H'
            : '${(horas / 24).round()} días';

        tareas.add(TareaItem(
          tipo: TareaTipo.evaluacion,
          loteId: loteId,
          loteNombre: loteNombre,
          titulo: 'Alerta de Revisión',
          descripcion:
              '$loteNombre: Han pasado $tiempoLabel desde el tratamiento. Evalúe si la plaga disminuyó.',
          motivo: 'Tratamiento aplicado hace $tiempoLabel',
          accionLabel: 'REGISTRAR EVALUACIÓN',
          prioridad: TareaPrioridad.media,
          hallazgoId: hallazgoId,
          plagaNombre: plagaNombre,
          productoTratamiento: producto,
          tiempoTratamiento: tiempoLabel,
        ));
      }
    } catch (e) {
      debugPrint('[TareasProvider] _evaluarTratamientosRecientes error: $e');
    }
    return tareas;
  }

  // ─── Regla 4: Fertilización ────────────────────────────

  Future<TareaItem?> _evaluarFertilizacion(String loteId, String loteNombre) async {
    try {
      final ferts = await _db.queryWhere(
        DatabaseHelper.tableFertilizacion,
        'loteId = ?',
        [loteId],
      );

      DateTime? ultimaFert;
      if (ferts.isNotEmpty) {
        ferts.sort((a, b) =>
            (b['fecha'] as String? ?? '').compareTo(a['fecha'] as String? ?? ''));
        final fechaStr = ferts.first['fecha'] as String?;
        ultimaFert = fechaStr != null ? DateTime.tryParse(fechaStr) : null;
      }

      final now = DateTime.now();
      int diasSinFert = 999;
      if (ultimaFert != null) {
        diasSinFert = now.difference(ultimaFert).inDays;
      }

      // Solo alertar si lleva 30+ días sin fertilizar
      if (diasSinFert < 30) return null;

      // Verificar si el lote tiene cultivo activo
      final loteRows = await _db.queryWhere(DatabaseHelper.tableLotes, 'id = ?', [loteId]);
      if (loteRows.isEmpty) return null;
      final cultivoActual = loteRows.first['cultivoActual'] as String? ?? '';
      final cultivoActualId = loteRows.first['cultivoActualId'] as String? ?? '';

      // Solo sugerir fertilización si hay un cultivo registrado
      if (cultivoActual.isEmpty && cultivoActualId.isEmpty) return null;

      String motivo;
      TareaPrioridad prioridad;
      if (ultimaFert == null) {
        motivo = 'Sin registros de fertilización';
        prioridad = TareaPrioridad.media;
      } else if (diasSinFert >= 60) {
        motivo = 'Hace $diasSinFert días sin fertilizar';
        prioridad = TareaPrioridad.alta;
      } else {
        motivo = 'Hace $diasSinFert días sin fertilizar';
        prioridad = TareaPrioridad.media;
      }

      final cultivoLabel = cultivoActual.isNotEmpty
          ? 'El cultivo de ${cultivoActual.toLowerCase()} '
          : 'El lote ';

      return TareaItem(
        tipo: TareaTipo.fertilizacion,
        loteId: loteId,
        loteNombre: loteNombre,
        titulo: 'Fertilización Pendiente',
        descripcion: ultimaFert == null
            ? '$loteNombre: Aún no se ha registrado ninguna fertilización para este lote.'
            : '$loteNombre: ${cultivoLabel}requiere aplicación de fertilizante.',
        motivo: motivo,
        accionLabel: 'REGISTRAR FERTILIZACIÓN',
        prioridad: prioridad,
      );
    } catch (e) {
      debugPrint('[TareasProvider] _evaluarFertilizacion error: $e');
      return null;
    }
  }

  // ─── Regla 5: Observación general ──────────────────────

  Future<TareaItem?> _evaluarObservacion(String loteId, String loteNombre) async {
    try {
      final obs = await _db.queryWhere(
        DatabaseHelper.tableObservaciones,
        'loteId = ?',
        [loteId],
      );

      DateTime? ultimaObs;
      if (obs.isNotEmpty) {
        obs.sort((a, b) =>
            (b['fecha'] as String? ?? '').compareTo(a['fecha'] as String? ?? ''));
        final fechaStr = obs.first['fecha'] as String?;
        ultimaObs = fechaStr != null ? DateTime.tryParse(fechaStr) : null;
      }

      final now = DateTime.now();
      int diasSinObs = 999;
      if (ultimaObs != null) {
        diasSinObs = now.difference(ultimaObs).inDays;
      }

      // Solo sugerir si lleva 7+ días sin observación
      if (diasSinObs < 7) return null;

      return TareaItem(
        tipo: TareaTipo.observacion,
        loteId: loteId,
        loteNombre: loteNombre,
        titulo: 'Registrar Observación',
        descripcion: ultimaObs == null
            ? '$loteNombre: Aún no se ha registrado ninguna observación para este lote.'
            : '$loteNombre: No se ha registrado ninguna observación en los últimos $diasSinObs días.',
        motivo: ultimaObs == null
            ? 'Sin registros de observaciones'
            : 'Hace $diasSinObs días sin registros',
        accionLabel: 'REGISTRAR OBSERVACIÓN',
        prioridad: TareaPrioridad.baja,
      );
    } catch (e) {
      debugPrint('[TareasProvider] _evaluarObservacion error: $e');
      return null;
    }
  }

  // ─── Regla 6: Alerta Climática ──────────────────────────

  Future<TareaItem?> _evaluarClima(Map<String, dynamic> lote, String loteId, String loteNombre) async {
    final lat = lote['latitud'] as double?;
    final lon = lote['longitud'] as double?;
    if (lat == null || lon == null) return null;

    try {
      final weather = await _weatherService.getWeatherData(lat, lon);
      final tempStr = weather['temperature'] ?? '';
      final rainStr = weather['rainProbability'] ?? '';

      // Parseadores seguros
      final cleanRain = rainStr.replaceAll('%', '').trim();
      final rainPct = int.tryParse(cleanRain) ?? 0;

      final cleanTemp = tempStr.replaceAll('°C', '').replaceAll('°', '').trim();
      final tempVal = double.tryParse(cleanTemp);

      // Regla A: Alta probabilidad de lluvia (anomalía / prevención)
      if (rainPct >= 60) {
        return TareaItem(
          tipo: TareaTipo.clima,
          loteId: loteId,
          loteNombre: loteNombre,
          titulo: 'Alerta Climática',
          descripcion: '$loteNombre: Lluvias intensas pronosticadas ($rainStr). Se recomienda posponer la fertilización o el riego.',
          motivo: 'Lluvia inminente detectada',
          accionLabel: 'REGISTRAR OBSERVACIÓN',
          prioridad: TareaPrioridad.media,
        );
      }

      // Regla B: Temperaturas extremas - Calor extremo
      if (tempVal != null && tempVal >= 35) {
        return TareaItem(
          tipo: TareaTipo.clima,
          loteId: loteId,
          loteNombre: loteNombre,
          titulo: 'Alerta Climática',
          descripcion: '$loteNombre: Temperatura extrema detectada ($tempStr). Se recomienda incrementar el volumen de riego y regar al amanecer o atardecer.',
          motivo: 'Ola de calor detectada',
          accionLabel: 'EJECUTAR RIEGO',
          prioridad: TareaPrioridad.alta,
        );
      }

      // Regla C: Temperaturas bajas / Heladas
      if (tempVal != null && tempVal <= 15) {
        return TareaItem(
          tipo: TareaTipo.clima,
          loteId: loteId,
          loteNombre: loteNombre,
          titulo: 'Alerta Climática',
          descripcion: '$loteNombre: Bajas temperaturas registradas ($tempStr). Monitoree el cultivo para prevenir daños por heladas.',
          motivo: 'Helada / Frío detectado',
          accionLabel: 'REGISTRAR OBSERVACIÓN',
          prioridad: TareaPrioridad.media,
        );
      }
    } catch (e) {
      debugPrint('[TareasProvider] _evaluarClima error: $e');
    }
    return null;
  }
}

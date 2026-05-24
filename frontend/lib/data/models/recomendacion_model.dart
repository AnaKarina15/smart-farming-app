/// Modelo que representa una recomendación generada por el Sistema Experto.
///
/// Mapea la respuesta del endpoint GET /api/v1/recomendaciones/lote/:loteId
class Recomendacion {
  final String reglaId;
  final String codigo;
  final String nombre;
  final String tipoRecomendacion;
  final String accionSugerida;
  final String? productoSugerido;
  final String? dosisRecomendada;
  final String? unidadRecomendada;
  final String? metodoAplicacion;

  /// Prioridad del 1 al 5 (5 = máxima urgencia)
  final int prioridad;
  final String? fuenteCientifica;
  final String? motivoMatch;

  const Recomendacion({
    required this.reglaId,
    required this.codigo,
    required this.nombre,
    required this.tipoRecomendacion,
    required this.accionSugerida,
    this.productoSugerido,
    this.dosisRecomendada,
    this.unidadRecomendada,
    this.metodoAplicacion,
    required this.prioridad,
    this.fuenteCientifica,
    this.motivoMatch,
  });

  factory Recomendacion.fromJson(Map<String, dynamic> json) {
    return Recomendacion(
      reglaId: json['reglaId'] as String? ?? json['id'] as String,
      codigo: json['codigo'] as String? ?? '',
      nombre: json['nombre'] as String,
      tipoRecomendacion: json['tipoRecomendacion'] as String? ?? '',
      accionSugerida: json['accionSugerida'] as String? ?? '',
      productoSugerido: json['productoSugerido'] as String?,
      dosisRecomendada: json['dosisRecomendada'] as String?,
      unidadRecomendada: json['unidadRecomendada'] as String?,
      metodoAplicacion: json['metodoAplicacion'] as String?,
      prioridad: (json['prioridad'] as num?)?.toInt() ?? 1,
      fuenteCientifica: json['fuenteCientifica'] as String?,
      motivoMatch: json['motivoMatch'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'reglaId': reglaId,
        'codigo': codigo,
        'nombre': nombre,
        'tipoRecomendacion': tipoRecomendacion,
        'accionSugerida': accionSugerida,
        if (productoSugerido != null) 'productoSugerido': productoSugerido,
        if (dosisRecomendada != null) 'dosisRecomendada': dosisRecomendada,
        if (unidadRecomendada != null) 'unidadRecomendada': unidadRecomendada,
        if (metodoAplicacion != null) 'metodoAplicacion': metodoAplicacion,
        'prioridad': prioridad,
        if (fuenteCientifica != null) 'fuenteCientifica': fuenteCientifica,
        if (motivoMatch != null) 'motivoMatch': motivoMatch,
      };

  /// Helper: color según prioridad
  /// 5=morado (crítica), 4=rojo (alta), 3=naranja (media), 2=amarillo (baja), 1=verde (mínima)
  String get prioridadLabel {
    switch (prioridad) {
      case 5:
        return 'CRÍTICA';
      case 4:
        return 'ALTA';
      case 3:
        return 'MEDIA';
      case 2:
        return 'BAJA';
      default:
        return 'MÍNIMA';
    }
  }

  bool get esCritica => prioridad >= 4;
}

/// Modelo que representa una decisión registrada sobre una recomendación aplicada.
class RecomendacionAplicada {
  final int? id;
  final String reglaId;
  final String loteId;
  final String decision; // 'aplicar' | 'descartar'
  final String? notaProductor;
  final String fecha;
  final bool isPendingSync;

  const RecomendacionAplicada({
    this.id,
    required this.reglaId,
    required this.loteId,
    required this.decision,
    this.notaProductor,
    required this.fecha,
    this.isPendingSync = true,
  });

  factory RecomendacionAplicada.fromJson(Map<String, dynamic> json) {
    return RecomendacionAplicada(
      id: json['id'] as int?,
      reglaId: json['reglaId'] as String,
      loteId: json['loteId'] as String,
      decision: json['decision'] as String,
      notaProductor: json['notaProductor'] as String?,
      fecha: json['fecha'] as String,
      isPendingSync: (json['isPendingSync'] as int? ?? 1) == 1,
    );
  }

  Map<String, dynamic> toSqlite() => {
        if (id != null) 'id': id,
        'reglaId': reglaId,
        'loteId': loteId,
        'decision': decision,
        if (notaProductor != null) 'notaProductor': notaProductor,
        'fecha': fecha,
        'isPendingSync': isPendingSync ? 1 : 0,
      };
}

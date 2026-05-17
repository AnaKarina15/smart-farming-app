class Siembra {
  final String id;
  final String loteId;
  final String? loteNombre;
  final String? cultivoId;
  final String? cultivoNombre;
  final String? cultivoOtro;
  final String? variedad;
  final DateTime fecha;
  final double? cantidadSemillas;
  final String? unidad;
  final double? distanciaEntreFilas;
  final double? distanciaEntrePlantas;
  final String? observaciones;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Siembra({
    required this.id,
    required this.loteId,
    this.loteNombre,
    this.cultivoId,
    this.cultivoNombre,
    this.cultivoOtro,
    this.variedad,
    required this.fecha,
    this.cantidadSemillas,
    this.unidad,
    this.distanciaEntreFilas,
    this.distanciaEntrePlantas,
    this.observaciones,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Siembra.fromJson(Map<String, dynamic> json) => Siembra(
    id: json['id'] ?? '',
    loteId: json['loteId'] ?? '',
    loteNombre: json['loteNombre'],
    cultivoId: json['cultivoId'],
    cultivoNombre: json['cultivoNombre'],
    cultivoOtro: json['cultivoOtro'],
    variedad: json['variedad'],
    fecha: json['fecha'] != null ? DateTime.parse(json['fecha']) : DateTime.now(),
    cantidadSemillas: (json['cantidadSemillas'] as num?)?.toDouble(),
    unidad: json['unidad'],
    distanciaEntreFilas: (json['distanciaEntreFilas'] as num?)?.toDouble(),
    distanciaEntrePlantas: (json['distanciaEntrePlantas'] as num?)?.toDouble(),
    observaciones: json['observaciones'],
    userId: json['userId'] ?? '',
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
  );

  Map<String, dynamic> toCreateJson() => {
    'loteId': loteId,
    if (cultivoId != null) 'cultivoId': cultivoId,
    if (cultivoOtro != null) 'cultivoOtro': cultivoOtro,
    if (variedad != null) 'variedad': variedad,
    'fecha': fecha.toUtc().toIso8601String(),
    if (cantidadSemillas != null) 'cantidadSemillas': cantidadSemillas,
    if (unidad != null) 'unidad': unidad,
    if (distanciaEntreFilas != null) 'distanciaEntreFilas': distanciaEntreFilas,
    if (distanciaEntrePlantas != null) 'distanciaEntrePlantas': distanciaEntrePlantas,
    if (observaciones != null) 'observaciones': observaciones,
  };
}

class Riego {
  final String id;
  final String loteId;
  final String? loteNombre;
  final String tipo;
  final double? duracionMinutos;
  final double? cantidadLitros;
  final DateTime fecha;
  final double? humedad;
  final String? observaciones;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Riego({
    required this.id,
    required this.loteId,
    this.loteNombre,
    required this.tipo,
    this.duracionMinutos,
    this.cantidadLitros,
    required this.fecha,
    this.humedad,
    this.observaciones,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Riego.fromJson(Map<String, dynamic> json) => Riego(
    id: json['id'] ?? '',
    loteId: json['loteId'] ?? '',
    loteNombre: json['loteNombre'],
    tipo: json['tipo'] ?? 'goteo',
    duracionMinutos: (json['duracionMinutos'] as num?)?.toDouble(),
    cantidadLitros: (json['cantidadLitros'] as num?)?.toDouble(),
    fecha: json['fecha'] != null ? DateTime.parse(json['fecha']) : DateTime.now(),
    humedad: (json['humedad'] as num?)?.toDouble(),
    observaciones: json['observaciones'],
    userId: json['userId'] ?? '',
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
  );

  Map<String, dynamic> toCreateJson() => {
    'loteId': loteId,
    'tipo': tipo,
    if (duracionMinutos != null) 'duracionMinutos': duracionMinutos,
    if (cantidadLitros != null) 'cantidadLitros': cantidadLitros,
    'fecha': fecha.toUtc().toIso8601String(),
    if (humedad != null) 'humedad': humedad,
    if (observaciones != null) 'observaciones': observaciones,
  };
}

class Fertilizacion {
  final String id;
  final String loteId;
  final String? loteNombre;
  final String? fertilizanteId;
  final String? fertilizanteNombre;
  final String? fertilizanteOtro;
  final double? dosis;
  final String? unidad;
  final String? metodoAplicacion;
  final DateTime fecha;
  final String? observaciones;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Fertilizacion({
    required this.id,
    required this.loteId,
    this.loteNombre,
    this.fertilizanteId,
    this.fertilizanteNombre,
    this.fertilizanteOtro,
    this.dosis,
    this.unidad,
    this.metodoAplicacion,
    required this.fecha,
    this.observaciones,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Fertilizacion.fromJson(Map<String, dynamic> json) => Fertilizacion(
    id: json['id'] ?? '',
    loteId: json['loteId'] ?? '',
    loteNombre: json['loteNombre'],
    fertilizanteId: json['fertilizanteId'],
    fertilizanteNombre: json['fertilizanteNombre'],
    fertilizanteOtro: json['fertilizanteOtro'],
    dosis: (json['dosis'] as num?)?.toDouble(),
    unidad: json['unidad'],
    metodoAplicacion: json['metodoAplicacion'],
    fecha: json['fecha'] != null ? DateTime.parse(json['fecha']) : DateTime.now(),
    observaciones: json['observaciones'],
    userId: json['userId'] ?? '',
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
  );

  Map<String, dynamic> toCreateJson() => {
    'loteId': loteId,
    if (fertilizanteId != null) 'fertilizanteId': fertilizanteId,
    if (fertilizanteOtro != null) 'fertilizanteOtro': fertilizanteOtro,
    if (dosis != null) 'dosis': dosis,
    if (unidad != null) 'unidad': unidad,
    if (metodoAplicacion != null) 'metodoAplicacion': metodoAplicacion,
    'fecha': fecha.toUtc().toIso8601String(),
    if (observaciones != null) 'observaciones': observaciones,
  };
}

class Hallazgo {
  final String id;
  final String loteId;
  final String? loteNombre;
  final String? plagaId;
  final String? plagaNombre;
  final String? plagaOtro;
  final String severidad;
  final String? descripcion;
  final String? fotoPath;
  final DateTime fecha;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Hallazgo({
    required this.id,
    required this.loteId,
    this.loteNombre,
    this.plagaId,
    this.plagaNombre,
    this.plagaOtro,
    required this.severidad,
    this.descripcion,
    this.fotoPath,
    required this.fecha,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Hallazgo.fromJson(Map<String, dynamic> json) => Hallazgo(
    id: json['id'] ?? '',
    loteId: json['loteId'] ?? '',
    loteNombre: json['loteNombre'],
    plagaId: json['plagaId'],
    plagaNombre: json['plagaNombre'],
    plagaOtro: json['plagaOtro'],
    severidad: json['severidad'] ?? 'baja',
    descripcion: json['descripcion'],
    fotoPath: json['fotoPath'],
    fecha: json['fecha'] != null ? DateTime.parse(json['fecha']) : DateTime.now(),
    userId: json['userId'] ?? '',
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
  );

  Map<String, dynamic> toCreateJson() => {
    'loteId': loteId,
    if (plagaId != null) 'plagaId': plagaId,
    if (plagaOtro != null) 'plagaOtro': plagaOtro,
    'severidad': severidad,
    if (descripcion != null) 'descripcion': descripcion,
    if (fotoPath != null) 'fotoPath': fotoPath,
    'fecha': fecha.toUtc().toIso8601String(),
  };
}

class Tratamiento {
  final String id;
  final String loteId;
  final String? loteNombre;
  final String? hallazgoId;
  final String? hallazgoSeveridad;
  final String producto;
  final double? dosis;
  final String? unidad;
  final String? metodoAplicacion;
  final DateTime fecha;
  final String? observaciones;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Tratamiento({
    required this.id,
    required this.loteId,
    this.loteNombre,
    this.hallazgoId,
    this.hallazgoSeveridad,
    required this.producto,
    this.dosis,
    this.unidad,
    this.metodoAplicacion,
    required this.fecha,
    this.observaciones,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Tratamiento.fromJson(Map<String, dynamic> json) => Tratamiento(
    id: json['id'] ?? '',
    loteId: json['loteId'] ?? '',
    loteNombre: json['loteNombre'],
    hallazgoId: json['hallazgoId'],
    hallazgoSeveridad: json['hallazgoSeveridad'],
    producto: json['producto'] ?? '',
    dosis: (json['dosis'] as num?)?.toDouble(),
    unidad: json['unidad'],
    metodoAplicacion: json['metodoAplicacion'],
    fecha: json['fecha'] != null ? DateTime.parse(json['fecha']) : DateTime.now(),
    observaciones: json['observaciones'],
    userId: json['userId'] ?? '',
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
  );

  Map<String, dynamic> toCreateJson() => {
    'loteId': loteId,
    if (hallazgoId != null) 'hallazgoId': hallazgoId,
    'producto': producto,
    if (dosis != null) 'dosis': dosis,
    if (unidad != null) 'unidad': unidad,
    if (metodoAplicacion != null) 'metodoAplicacion': metodoAplicacion,
    'fecha': fecha.toUtc().toIso8601String(),
    if (observaciones != null) 'observaciones': observaciones,
  };
}

class Observacion {
  final String id;
  final String loteId;
  final String? loteNombre;
  final String descripcion;
  final String? tipo;
  final DateTime fecha;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Observacion({
    required this.id,
    required this.loteId,
    this.loteNombre,
    required this.descripcion,
    this.tipo,
    required this.fecha,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Observacion.fromJson(Map<String, dynamic> json) => Observacion(
    id: json['id'] ?? '',
    loteId: json['loteId'] ?? '',
    loteNombre: json['loteNombre'],
    descripcion: json['descripcion'] ?? '',
    tipo: json['tipo'],
    fecha: json['fecha'] != null ? DateTime.parse(json['fecha']) : DateTime.now(),
    userId: json['userId'] ?? '',
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
  );

  Map<String, dynamic> toCreateJson() => {
    'loteId': loteId,
    'descripcion': descripcion,
    if (tipo != null) 'tipo': tipo,
    'fecha': fecha.toUtc().toIso8601String(),
  };
}

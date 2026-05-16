class Cultivo {
  final String id;
  final String nombre;
  final String? nombreCientifico;
  final String? categoria;
  final String? cicloVegetativo;
  final int? diasCosecha;
  final int? densidadSiembraPorHa;
  final String? descripcion;
  final bool activo;

  Cultivo({
    required this.id,
    required this.nombre,
    this.nombreCientifico,
    this.categoria,
    this.cicloVegetativo,
    this.diasCosecha,
    this.densidadSiembraPorHa,
    this.descripcion,
    this.activo = true,
  });

  factory Cultivo.fromJson(Map<String, dynamic> json) {
    return Cultivo(
      id: json['id'],
      nombre: json['nombre'],
      nombreCientifico: json['nombreCientifico'],
      categoria: json['categoria'],
      cicloVegetativo: json['cicloVegetativo'],
      diasCosecha: json['diasCosecha'],
      densidadSiembraPorHa: json['densidadSiembraPorHa'],
      descripcion: json['descripcion'],
      activo: json['activo'] == 1 || json['activo'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'nombreCientifico': nombreCientifico,
      'categoria': categoria,
      'cicloVegetativo': cicloVegetativo,
      'diasCosecha': diasCosecha,
      'densidadSiembraPorHa': densidadSiembraPorHa,
      'descripcion': descripcion,
      'activo': activo ? 1 : 0,
    };
  }
}

class Municipio {
  final String id;
  final String? codigoDane;
  final String nombre;
  final String? subregion;
  final double? latitud;
  final double? longitud;
  final bool activo;

  Municipio({
    required this.id,
    this.codigoDane,
    required this.nombre,
    this.subregion,
    this.latitud,
    this.longitud,
    this.activo = true,
  });

  factory Municipio.fromJson(Map<String, dynamic> json) {
    return Municipio(
      id: json['id'],
      codigoDane: json['codigoDane'],
      nombre: json['nombre'],
      subregion: json['subregion'],
      latitud: (json['latitud'] as num?)?.toDouble(),
      longitud: (json['longitud'] as num?)?.toDouble(),
      activo: json['activo'] == 1 || json['activo'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigoDane': codigoDane,
      'nombre': nombre,
      'subregion': subregion,
      'latitud': latitud,
      'longitud': longitud,
      'activo': activo ? 1 : 0,
    };
  }
}

class Plaga {
  final String id;
  final String nombre;
  final String? nombreCientifico;
  final String? tipo;
  final String? severidadTipica;
  final String? sintomas;
  final String? cultivosAfectados;
  final bool activo;

  Plaga({
    required this.id,
    required this.nombre,
    this.nombreCientifico,
    this.tipo,
    this.severidadTipica,
    this.sintomas,
    this.cultivosAfectados,
    this.activo = true,
  });

  factory Plaga.fromJson(Map<String, dynamic> json) {
    return Plaga(
      id: json['id'],
      nombre: json['nombre'],
      nombreCientifico: json['nombreCientifico'],
      tipo: json['tipo'],
      severidadTipica: json['severidadTipica'],
      sintomas: json['sintomas'],
      cultivosAfectados: json['cultivosAfectados'],
      activo: json['activo'] == 1 || json['activo'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'nombreCientifico': nombreCientifico,
      'tipo': tipo,
      'severidadTipica': severidadTipica,
      'sintomas': sintomas,
      'cultivosAfectados': cultivosAfectados,
      'activo': activo ? 1 : 0,
    };
  }
}

class Fertilizante {
  final String id;
  final String nombre;
  final String? tipo;
  final String? composicionNpk;
  final String? presentacion;
  final double? dosisRecomendadaKgHa;
  final String? descripcion;
  final bool activo;

  Fertilizante({
    required this.id,
    required this.nombre,
    this.tipo,
    this.composicionNpk,
    this.presentacion,
    this.dosisRecomendadaKgHa,
    this.descripcion,
    this.activo = true,
  });

  factory Fertilizante.fromJson(Map<String, dynamic> json) {
    return Fertilizante(
      id: json['id'],
      nombre: json['nombre'],
      tipo: json['tipo'],
      composicionNpk: json['composicionNpk'],
      presentacion: json['presentacion'],
      dosisRecomendadaKgHa: (json['dosisRecomendadaKgHa'] as num?)?.toDouble(),
      descripcion: json['descripcion'],
      activo: json['activo'] == 1 || json['activo'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'tipo': tipo,
      'composicionNpk': composicionNpk,
      'presentacion': presentacion,
      'dosisRecomendadaKgHa': dosisRecomendadaKgHa,
      'descripcion': descripcion,
      'activo': activo ? 1 : 0,
    };
  }
}

class TipoSuelo {
  final String id;
  final String nombre;
  final String? clase;
  final String? drenaje;
  final double? retencionHumedadPct;
  final double? phTipico;
  final String? cultivosRecomendados;
  final String? descripcion;
  final bool activo;

  TipoSuelo({
    required this.id,
    required this.nombre,
    this.clase,
    this.drenaje,
    this.retencionHumedadPct,
    this.phTipico,
    this.cultivosRecomendados,
    this.descripcion,
    this.activo = true,
  });

  factory TipoSuelo.fromJson(Map<String, dynamic> json) {
    return TipoSuelo(
      id: json['id'],
      nombre: json['nombre'],
      clase: json['clase'],
      drenaje: json['drenaje'],
      retencionHumedadPct: (json['retencionHumedadPct'] as num?)?.toDouble(),
      phTipico: (json['phTipico'] as num?)?.toDouble(),
      cultivosRecomendados: json['cultivosRecomendados'],
      descripcion: json['descripcion'],
      activo: json['activo'] == 1 || json['activo'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'clase': clase,
      'drenaje': drenaje,
      'retencionHumedadPct': retencionHumedadPct,
      'phTipico': phTipico,
      'cultivosRecomendados': cultivosRecomendados,
      'descripcion': descripcion,
      'activo': activo ? 1 : 0,
    };
  }
}

/// Modelo de Lote que mapea la respuesta del backend AgroField.
///
/// Cumple los RF02-RF04 del proyecto:
/// - Maximo 5 hectareas por productor
/// - Coordenadas geograficas (lat/lng)
/// - Estado del lote (saludable, alerta, critico)
class LoteModel {
  final String id;
  final String nombre;
  final String? descripcion;
  final double superficieHectareas;
  final String? cultivoActual;
  final double? latitud;
  final double? longitud;
  final String estado;
  final String propietarioId;
  final DateTime createdAt;
  final DateTime updatedAt;

  LoteModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.superficieHectareas,
    this.cultivoActual,
    this.latitud,
    this.longitud,
    required this.estado,
    required this.propietarioId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LoteModel.fromJson(Map<String, dynamic> json) {
    return LoteModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      superficieHectareas: (json['superficieHectareas'] as num).toDouble(),
      cultivoActual: json['cultivoActual'] as String?,
      latitud: json['latitud'] != null ? (json['latitud'] as num).toDouble() : null,
      longitud: json['longitud'] != null ? (json['longitud'] as num).toDouble() : null,
      estado: json['estado'] as String? ?? 'saludable',
      propietarioId: json['propietarioId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      'superficieHectareas': superficieHectareas,
      if (cultivoActual != null) 'cultivoActual': cultivoActual,
      if (latitud != null) 'latitud': latitud,
      if (longitud != null) 'longitud': longitud,
    };
  }
}

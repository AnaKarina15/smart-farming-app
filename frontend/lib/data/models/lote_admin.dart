class LoteAdmin {
  final String id;
  final String nombre;
  final double superficie;
  final String? cultivo;
  final String? estado;
  final String? propietarioId;
  final String? propietarioNombre;
  final String? imagenUrl;

  const LoteAdmin({
    required this.id,
    required this.nombre,
    required this.superficie,
    this.cultivo,
    this.estado,
    this.propietarioId,
    this.propietarioNombre,
    this.imagenUrl,
  });

  factory LoteAdmin.fromJson(Map<String, dynamic> json) {
    return LoteAdmin(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      superficie: (json['superficieHectareas'] as num?)?.toDouble() ?? 0.0,
      cultivo: json['cultivoActual'] as String?,
      estado: json['estado'] as String?,
      propietarioId: json['propietarioId'] as String?,
      propietarioNombre: json['propietarioNombre'] as String?,
      imagenUrl: json['imagenUrl'] as String?,
    );
  }

  String get estadoHumanizado {
    switch (estado?.toLowerCase()) {
      case 'saludable':
        return 'Saludable';
      case 'afectado':
        return 'Afectado';
      case 'cosechado':
        return 'Cosechado';
      default:
        return estado ?? 'Sin estado';
    }
  }
}
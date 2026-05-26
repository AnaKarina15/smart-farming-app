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
    final ultimaSiembra = json['ultimaSiembra'] is Map<String, dynamic>
        ? json['ultimaSiembra'] as Map<String, dynamic>
        : null;
    final propietario = json['propietario'] is Map<String, dynamic>
        ? json['propietario'] as Map<String, dynamic>
        : null;

    return LoteAdmin(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      superficie: ((json['superficie'] ?? json['superficieHectareas']) as num?)
              ?.toDouble() ??
          0.0,
      cultivo: json['cultivo'] as String? ??
          json['siembraActualNombre'] as String? ??
          ultimaSiembra?['cultivoNombre'] as String? ??
          ultimaSiembra?['cultivoOtro'] as String? ??
          json['cultivoActual'] as String?,
      estado: json['estado'] as String?,
      propietarioId: json['propietarioId'] as String?,
      propietarioNombre: json['propietarioNombre'] as String? ??
          propietario?['nombreCompleto'] as String?,
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

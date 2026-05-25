/// Modelo de Usuario que mapea la respuesta del backend AgroField.
///
/// Coincide con la entidad User del backend (NestJS).
class UserModel {
  final String id;
  final String nombreCompleto;
  final String email;
  final String? telefono;
  final String role;
  final bool activo;
  final DateTime? ultimoAcceso;
  final DateTime createdAt;
  final DateTime updatedAt;
  /// Optional field indicating who created the user record in the backend.
  final String? createdBy;
  final String? fotoPerfilUrl;

  /// Si es true, el backend requiere que el usuario cambie su contraseña
  /// antes de acceder a la app (Sprint 1).
  final bool mustChangePassword;

  UserModel({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    this.telefono,
    required this.role,
    required this.activo,
    this.ultimoAcceso,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.fotoPerfilUrl,
    this.mustChangePassword = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      nombreCompleto: json['nombreCompleto'] as String,
      email: json['email'] as String,
      telefono: json['telefono'] as String?,
      role: json['role'] as String,
      activo: json['activo'] as bool? ?? true,
      ultimoAcceso: json['ultimoAcceso'] != null
          ? DateTime.tryParse(json['ultimoAcceso'].toString())
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String?,
      fotoPerfilUrl: json['fotoPerfilUrl'] as String?,
      mustChangePassword: json['mustChangePassword'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreCompleto': nombreCompleto,
      'email': email,
      'telefono': telefono,
      'role': role,
      'activo': activo,
      'ultimoAcceso': ultimoAcceso?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (createdBy != null) 'createdBy': createdBy,
      if (fotoPerfilUrl != null) 'fotoPerfilUrl': fotoPerfilUrl,
    };
  }

  /// Helper: nombre corto para mostrar en pantalla
  String get firstName {
    final parts = nombreCompleto.trim().split(' ');
    return parts.isNotEmpty ? parts.first : nombreCompleto;
  }

  /// Helper: tipo de usuario legible
  String get roleLegible {
    switch (role) {
      case 'pequeno_productor':
        return 'Pequeño Productor';
      case 'trabajador':
        return 'Trabajador';
      case 'gestor':
        return 'Gestor';
      case 'administrador':
        return 'Administrador';
      default:
        if (role.isEmpty) return role;
        return role[0].toUpperCase() + role.substring(1);
    }
  }

  // ─── Helpers booleanos de rol (Sprint 1) ─────────────────

  /// true si el usuario es administrador del sistema.
  bool get esAdmin => role == 'administrador';

  /// true si el usuario es pequeño productor (acceso principal a la app).
  bool get esProductor => role == 'pequeno_productor';

  /// true si el usuario es gestor de campo.
  bool get esGestor => role == 'gestor';

  /// true si el usuario es trabajador de campo.
  bool get esTrabajador => role == 'trabajador';

  /// true si el usuario tiene acceso al panel de administración.
  bool get tieneAccesoAdmin => esAdmin;
}

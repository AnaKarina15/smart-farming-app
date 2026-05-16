class UsuarioAdmin {
  final String id;
  final String nombreCompleto;
  final String email;
  final String? telefono;
  final String role;
  final bool activo;
  final bool mustChangePassword;
  final String? ultimoAcceso;
  final String? deletedAt;
  final String createdAt;

  const UsuarioAdmin({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    this.telefono,
    required this.role,
    required this.activo,
    required this.mustChangePassword,
    this.ultimoAcceso,
    this.deletedAt,
    required this.createdAt,
  });

  factory UsuarioAdmin.fromJson(Map<String, dynamic> json) {
    return UsuarioAdmin(
      id: json['id'] as String,
      nombreCompleto: json['nombreCompleto'] as String,
      email: json['email'] as String,
      telefono: json['telefono'] as String?,
      role: json['role'] as String,
      activo: json['activo'] as bool? ?? true,
      mustChangePassword: json['mustChangePassword'] as bool? ?? false,
      ultimoAcceso: json['ultimoAcceso'] as String?,
      deletedAt: json['deletedAt'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  bool get estaEliminado => deletedAt != null;

  String get roleHumanizado {
    switch (role) {
      case 'administrador':
        return 'Admin';
      case 'pequeno_productor':
        return 'Productor';
      case 'trabajador':
        return 'Trabajador';
      case 'gestor':
        return 'Gestor';
      default:
        return role;
    }
  }

  String get iniciales {
    final partes = nombreCompleto.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nombreCompleto.substring(0, 2).toUpperCase();
  }
}
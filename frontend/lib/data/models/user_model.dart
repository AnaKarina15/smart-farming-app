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
        return 'Pequeno Productor';
      case 'trabajador':
        return 'Trabajador';
      case 'gestor':
        return 'Gestor';
      default:
        return role;
    }
  }
}

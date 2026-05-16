class StatsAdmin {
  final int totalUsuarios;
  final int administrador;
  final int pequenoProductor;
  final int trabajador;
  final int gestor;
  final int activos;
  final int inactivos;

  const StatsAdmin({
    required this.totalUsuarios,
    required this.administrador,
    required this.pequenoProductor,
    required this.trabajador,
    required this.gestor,
    required this.activos,
    required this.inactivos,
  });

  factory StatsAdmin.fromJson(Map<String, dynamic> json) {
    final porRol = json['porRol'] as Map<String, dynamic>? ?? {};
    return StatsAdmin(
      totalUsuarios: json['totalUsuarios'] as int? ?? 0,
      administrador: porRol['administrador'] as int? ?? 0,
      pequenoProductor: porRol['pequeno_productor'] as int? ?? 0,
      trabajador: porRol['trabajador'] as int? ?? 0,
      gestor: porRol['gestor'] as int? ?? 0,
      activos: json['activos'] as int? ?? 0,
      inactivos: json['inactivos'] as int? ?? 0,
    );
  }
}
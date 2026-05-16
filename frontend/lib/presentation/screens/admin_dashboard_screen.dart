import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/admin_provider.dart';
import '../../data/models/stats_admin.dart';
import '../widgets/admin_widgets.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().cargarStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: Row(
          children: [
            // Foto de perfil admin (avatar genérico)
            CircleAvatar(
              radius: 18,
              backgroundColor: AdminColors.primary,
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'AgroField',
              style: TextStyle(
                color: AdminColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AdminColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          if (provider.cargando && provider.stats == null) {
            return const Center(
              child: CircularProgressIndicator(color: AdminColors.primary),
            );
          }
          if (provider.error != null && provider.stats == null) {
            return _ErrorView(
              mensaje: provider.error!,
              onReintentar: () => provider.cargarStats(),
            );
          }
          final stats = provider.stats;
          return RefreshIndicator(
            color: AdminColors.primary,
            onRefresh: () => provider.cargarStats(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Tarjetas resumen ───────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _TarjetaResumen(
                          icono: Icons.people,
                          label: 'Total Usuarios',
                          valor: '${stats?.totalUsuarios ?? 0}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TarjetaResumen(
                          icono: Icons.person_outline,
                          label: 'Usuarios Activos',
                          valor: '${stats?.activos ?? 0}',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ─── Actividad mensual (gráfico simplificado) ───────────────
                  const Text(
                    'Actividad Mensual',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _GraficoActividad(),

                  const SizedBox(height: 24),

                  // ─── Usuarios por rol ───────────────────────────────────────
                  const Text(
                    'Usuarios por Rol',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (stats != null) _GridRoles(stats: stats),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Subwidgets
// ─────────────────────────────────────────────────────────────────────────────

class _TarjetaResumen extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;

  const _TarjetaResumen({
    required this.icono,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: AdminColors.primary, size: 28),
          const SizedBox(height: 12),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AdminColors.textPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AdminColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GraficoActividad extends StatelessWidget {
  // Datos de ejemplo — en producción vendría del backend
  final List<double> _semanas = const [11, 19, 16, 15, 24];
  final List<String> _labels = const ['Semana 1', 'Semana 2', 'Semana 3', 'Semana 4', ''];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.border),
      ),
      child: CustomPaint(
        painter: _GraficoPainter(datos: _semanas),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _labels
                  .take(4)
                  .map(
                    (l) => Text(
                      l,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _GraficoPainter extends CustomPainter {
  final List<double> datos;

  _GraficoPainter({required this.datos});

  @override
  void paint(Canvas canvas, Size size) {
    if (datos.isEmpty) return;

    final maxVal = datos.reduce((a, b) => a > b ? a : b);
    final minVal = datos.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    final areaAltura = size.height - 32;
    final paso = size.width / (datos.length - 1);

    final puntos = List.generate(datos.length, (i) {
      final x = i * paso;
      final y = areaAltura - ((datos[i] - minVal) / range * (areaAltura - 16)) + 8;
      return Offset(x, y);
    });

    // Área rellena
    final areaPath = Path()..moveTo(puntos.first.dx, areaAltura + 8);
    for (final p in puntos) {
      areaPath.lineTo(p.dx, p.dy);
    }
    areaPath.lineTo(puntos.last.dx, areaAltura + 8);
    areaPath.close();
    canvas.drawPath(
      areaPath,
      Paint()
        ..color = AdminColors.primary.withOpacity(0.08)
        ..style = PaintingStyle.fill,
    );

    // Línea
    final linePaint = Paint()
      ..color = AdminColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path()..moveTo(puntos.first.dx, puntos.first.dy);
    for (int i = 1; i < puntos.length; i++) {
      linePath.lineTo(puntos[i].dx, puntos[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Punto final destacado
    canvas.drawCircle(
      puntos.last,
      5,
      Paint()..color = AdminColors.primary,
    );
    canvas.drawCircle(
      puntos.last,
      3,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GridRoles extends StatelessWidget {
  final StatsAdmin stats;

  const _GridRoles({required this.stats});

  @override
  Widget build(BuildContext context) {
    final roles = [
      _RolItem(
        icono: Icons.agriculture,
        label: 'Pequeño...',
        valor: stats.pequenoProductor,
        color: AdminColors.primary,
      ),
      _RolItem(
        icono: Icons.construction,
        label: 'Trabajad...',
        valor: stats.trabajador,
        color: const Color(0xFF1565C0),
      ),
      _RolItem(
        icono: Icons.manage_accounts,
        label: 'Gestor',
        valor: stats.gestor,
        color: const Color(0xFF6A1B9A),
      ),
      _RolItem(
        icono: Icons.admin_panel_settings,
        label: 'Administ...',
        valor: stats.administrador,
        color: AdminColors.chipAdmin,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: roles.map((r) => _TarjetaRol(item: r)).toList(),
    );
  }
}

class _RolItem {
  final IconData icono;
  final String label;
  final int valor;
  final Color color;

  const _RolItem({
    required this.icono,
    required this.label,
    required this.valor,
    required this.color,
  });
}

class _TarjetaRol extends StatelessWidget {
  final _RolItem item;

  const _TarjetaRol({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(item.icono, color: item.color, size: 20),
              const Spacer(),
            ],
          ),
          const Spacer(),
          Text(
            '${item.valor}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: item.color,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            style: const TextStyle(
              fontSize: 11,
              color: AdminColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintentar;

  const _ErrorView({required this.mensaje, required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AdminColors.error, size: 48),
            const SizedBox(height: 12),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AdminColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onReintentar,
              style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary),
              child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
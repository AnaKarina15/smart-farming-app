import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/stats_admin.dart';
import '../../data/providers/admin_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../widgets/admin_widgets.dart';
import '../widgets/custom_app_bar.dart';

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
    final auth = context.watch<AuthProvider>();
    // Nombre del admin logueado (campo según user_model.dart del proyecto)
    final nombreAdmin = auth.currentUser?.nombreCompleto ?? 'Administrador';

    return Scaffold(
      backgroundColor: AK.bg,
      appBar: const CustomAppBar(),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          if (provider.cargando && provider.stats == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (provider.error != null && provider.stats == null) {
            return ErrorView(
              mensaje: provider.error!,
              onReintentar: () => provider.cargarStats(),
            );
          }
          final stats = provider.stats;
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => provider.cargarStats(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Tarjetas resumen ─────────────────────────────────────
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
                          label: 'Activos',
                          valor: '${stats?.activos ?? 0}',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ─── Actividad mensual ────────────────────────────────────
                  const Text(
                    'Actividad Mensual',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AK.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _GraficoActividad(),

                  const SizedBox(height: 24),

                  // ─── Usuarios por rol ─────────────────────────────────────
                  const Text(
                    'Usuarios por Rol',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AK.text,
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

  String _iniciales(String nombre) {
    final partes = nombre.trim().split(' ');
    if (partes.length >= 2)
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    if (nombre.length >= 2) return nombre.substring(0, 2).toUpperCase();
    return nombre.toUpperCase();
  }
}

// ─── Subwidgets ───────────────────────────────────────────────────────────────

class _TarjetaResumen extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;
  const _TarjetaResumen(
      {required this.icono, required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AK.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icono, color: AppColors.primary, size: 28),
          const SizedBox(height: 12),
          Text(
            valor,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AK.subtext,
            ),
          ),
        ],
      ),
    );
  }
}

class _GraficoActividad extends StatelessWidget {
  // Datos de placeholder de 4 semanas para alinearse exactamente con las etiquetas de la base
  static const List<double> _semanas = [12, 19, 15, 25];

  const _GraficoActividad();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AK.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _GraficoPainter(datos: _semanas),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Semana 1', 'Semana 2', 'Semana 3', 'Semana 4']
                  .map((l) => Text(
                        l,
                        style: const TextStyle(
                            fontSize: 10,
                            color: AK.subtext,
                            fontWeight: FontWeight.w500),
                      ))
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
  const _GraficoPainter({required this.datos});

  @override
  void paint(Canvas canvas, Size size) {
    if (datos.isEmpty) return;
    final maxVal = datos.reduce((a, b) => a > b ? a : b);
    final minVal = datos.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;
    final areaH = size.height - 32;
    final paso = size.width / (datos.length - 1);

    final puntos = List.generate(
        datos.length,
        (i) => Offset(
              i * paso,
              areaH - ((datos[i] - minVal) / range * (areaH - 16)) + 8,
            ));

    // Área rellena con curva Bezier cúbica
    final area = Path()..moveTo(puntos.first.dx, areaH + 8);
    area.lineTo(puntos.first.dx, puntos.first.dy);
    for (int i = 0; i < puntos.length - 1; i++) {
      final p0 = puntos[i];
      final p1 = puntos[i + 1];
      final cp1 = Offset(p0.dx + paso / 2, p0.dy);
      final cp2 = Offset(p1.dx - paso / 2, p1.dy);
      area.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
    }
    area.lineTo(puntos.last.dx, areaH + 8);
    area.close();
    canvas.drawPath(
      area,
      Paint()
        ..color = AppColors.primary.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill,
    );

    // Línea suave con curva Bezier cúbica
    final line = Path()..moveTo(puntos.first.dx, puntos.first.dy);
    for (int i = 0; i < puntos.length - 1; i++) {
      final p0 = puntos[i];
      final p1 = puntos[i + 1];
      final cp1 = Offset(p0.dx + paso / 2, p0.dy);
      final cp2 = Offset(p1.dx - paso / 2, p1.dy);
      line.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
    }
    canvas.drawPath(
      line,
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dibujar puntos/círculos en cada coordenada
    for (final p in puntos) {
      canvas.drawCircle(p, 5, Paint()..color = AppColors.primary);
      canvas.drawCircle(p, 3, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _GridRoles extends StatelessWidget {
  final StatsAdmin stats;
  const _GridRoles({required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = [
      _RolItem(Icons.agriculture, 'Pequeño Productor', stats.pequenoProductor,
          const Color(0xFF2E7D32)),
      _RolItem(Icons.construction, 'Trabajador', stats.trabajador,
          const Color(0xFF00687E)),
      _RolItem(Icons.manage_accounts, 'Gestor', stats.gestor,
          const Color(0xFF6A1B9A)),
      _RolItem(Icons.admin_panel_settings, 'Administrador', stats.administrador,
          AK.error),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: items.map((r) => _TarjetaRol(item: r)).toList(),
    );
  }
}

class _RolItem {
  final IconData icono;
  final String label;
  final int valor;
  final Color color;
  const _RolItem(this.icono, this.label, this.valor, this.color);
}

class _TarjetaRol extends StatelessWidget {
  final _RolItem item;
  const _TarjetaRol({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AK.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icono, color: item.color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AK.text,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '${item.valor}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AK.text,
              height: 1,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

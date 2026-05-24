import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/stats_admin.dart';
import '../../data/providers/admin_provider.dart';
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
                          icono: Icons.sync,
                          label: 'Sincronizados',
                          valor: '${stats?.activos ?? 0}',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ─── Distribución por rol (pie) ───────────────────────────
                  const Text(
                    'Distribución por Rol',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AK.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (stats != null) _GraficoPieRoles(stats: stats),

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

// ─── Gráfica de Pie por Rol ───────────────────────────────────────────────────

class _PieSegment {
  final String label;
  final int valor;
  final Color color;
  const _PieSegment(this.label, this.valor, this.color);
}

class _GraficoPieRoles extends StatelessWidget {
  final StatsAdmin stats;
  const _GraficoPieRoles({required this.stats});

  static const _colores = [
    Color(0xFF2E7D32), // Pequeño Productor - verde oscuro
    Color(0xFF00687E), // Trabajador - teal
    Color(0xFF6A1B9A), // Gestor - violeta
    Color(0xFFBA1A1A), // Administrador - rojo
  ];

  @override
  Widget build(BuildContext context) {
    final segmentos = [
      _PieSegment('Pequeño Productor', stats.pequenoProductor, _colores[0]),
      _PieSegment('Trabajador', stats.trabajador, _colores[1]),
      _PieSegment('Gestor', stats.gestor, _colores[2]),
      _PieSegment('Administrador', stats.administrador, _colores[3]),
    ];
    final total = segmentos.fold<int>(0, (s, e) => s + e.valor);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
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
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: _PiePainter(segmentos: segmentos, total: total),
              size: const Size.fromHeight(200),
            ),
          ),
          const SizedBox(height: 20),
          // Leyenda
          Wrap(
            spacing: 16,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: segmentos.map((s) {
              final pct = total > 0
                  ? (s.valor / total * 100).toStringAsFixed(1)
                  : '0.0';
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: s.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${s.label} ($pct%)',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AK.subtext,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  final List<_PieSegment> segmentos;
  final int total;
  const _PiePainter({required this.segmentos, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) * 0.85;
    const gap = 0.025; // separación en radianes entre sectores

    double startAngle = -3.14159265 / 2; // empezar desde arriba

    for (final seg in segmentos) {
      if (seg.valor == 0) continue;
      final sweep = (seg.valor / total) * 2 * 3.14159265 - gap;

      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        true,
        paint,
      );

      // Borde blanco sutil
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        true,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Etiqueta de porcentaje dentro del sector
      final pct = seg.valor / total * 100;
      if (pct >= 8) {
        final labelAngle = startAngle + sweep / 2;
        final labelR = radius * 0.65;
        final labelPos = Offset(
          center.dx + labelR * _cos(labelAngle),
          center.dy + labelR * _sin(labelAngle),
        );
        final tp = TextPainter(
          text: TextSpan(
            text: '${pct.toStringAsFixed(0)}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset(labelPos.dx - tp.width / 2, labelPos.dy - tp.height / 2),
        );
      }

      startAngle += sweep + gap;
    }

    // Círculo central (efecto donut)
    canvas.drawCircle(
      center,
      radius * 0.42,
      Paint()..color = Colors.white,
    );

    // Total en el centro
    final tp = TextPainter(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: '$total',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const TextSpan(
            text: '\nusuarios',
            style: TextStyle(
              color: AK.subtext,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: radius * 0.8);
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
    );
  }

  double _cos(double angle) => math.cos(angle);
  double _sin(double angle) => math.sin(angle);

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
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

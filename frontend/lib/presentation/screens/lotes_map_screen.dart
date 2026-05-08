import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../common/agro_bottom_nav.dart';
import '../widgets/custom_app_bar.dart';
import 'lote_history_screen.dart';
import 'treatment_apply_screen.dart';

class LotesMapScreen extends StatelessWidget {
  const LotesMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // ── Map area ─────────────────────────────────────
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 320,
                  color: AppColors.surfaceContainer,
                  child: CustomPaint(painter: _MapPainter()),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Column(
                    children: [
                      _mapBtn(
                        Icons.add,
                        AppColors.surface,
                        AppColors.onSurface,
                      ),
                      const SizedBox(height: 8),
                      _mapBtn(
                        Icons.my_location,
                        AppColors.primaryContainer,
                        AppColors.onPrimaryContainer,
                      ),
                    ],
                  ),
                ),
                Positioned(top: 80, left: 80, child: _label('LOTE 1')),
                Positioned(top: 80, right: 80, child: _label('LOTE 2')),
                Positioned(bottom: 80, left: 100, child: _label('LOTE 3')),
              ],
            ),

            // ── Detail card Lote 1 ───────────────────────────
            Transform.translate(
              offset: const Offset(0, -24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        offset: const Offset(0, 4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lote 1',
                                  style: AppText.h2(color: AppColors.primary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Sector Norte • Zona A',
                                  style: AppText.labelCaps(),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.warning,
                                  color: AppColors.onError,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Afectado',
                                  style: AppText.labelCaps(
                                    color: AppColors.onError,
                                  ).copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _statBox(
                              'SUPERFICIE',
                              '3.5 Ha',
                              Icons.straighten,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _statBox('CULTIVO', 'Maíz', Icons.grass),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.error.withValues(alpha: 0.1),
                              ),
                              child: const Icon(
                                Icons.bug_report,
                                color: AppColors.error,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PLAGA DETECTADA',
                                    style: AppText.labelCaps(
                                      color: AppColors.error,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Spodoptera frugiperda',
                                    style: AppText.bodyMd().copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '(Gusano Cogollero)',
                                    style: AppText.bodyMd(
                                      color: AppColors.onSurfaceVariant,
                                    ).copyWith(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TreatmentApplyScreen(),
                            ),
                          ),
                          icon: const Icon(
                            Icons.science,
                            color: AppColors.onPrimary,
                          ),
                          label: Text(
                            'Iniciar Tratamiento',
                            style: AppText.bodyMd(
                              color: AppColors.onPrimary,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const LoteHistoryScreen(loteName: 'Lote 1'),
                            ),
                          ),
                          icon: const Icon(
                            Icons.history,
                            color: AppColors.primary,
                          ),
                          label: Text(
                            'Ver Historial del Lote',
                            style: AppText.bodyMd(
                              color: AppColors.primary,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Other lotes ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('OTROS LOTES CERCANOS', style: AppText.labelCaps()),
                  const SizedBox(height: 12),
                  _otherLote('Lote 2', 'Saludable • 8 Ha • Trigo'),
                  const SizedBox(height: 8),
                  _otherLote('Lote 3', 'Saludable • 15 Ha • Soja'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AgroBottomNav(current: AgroTab.lotes),
    );
  }

  Widget _mapBtn(IconData icon, Color bg, Color fg) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Icon(icon, color: fg, size: 22),
    );
  }

  Widget _label(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.inverseSurface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppText.labelCaps(
          color: AppColors.inverseOnSurface,
        ).copyWith(fontSize: 10),
      ),
    );
  }

  Widget _statBox(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border.all(color: AppColors.outlineVariant, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.labelCaps()),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 18),
              const SizedBox(width: 6),
              Text(value, style: AppText.h3()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _otherLote(String name, String detail) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.outlineVariant, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppText.bodyMd().copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  detail.toUpperCase(),
                  style: AppText.labelCaps().copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.outline),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background "satellite" feel
    final bg = Paint()..color = const Color(0xFFB8C4A6);
    canvas.drawRect(Offset.zero & size, bg);

    final w = size.width;
    final h = size.height;

    // Lote 1 (red - afectado)
    final lote1Fill = Paint()
      ..color = AppColors.error.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    final lote1Stroke = Paint()
      ..color = AppColors.error
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final p1 = Path()
      ..moveTo(w * 0.12, h * 0.17)
      ..lineTo(w * 0.45, h * 0.13)
      ..lineTo(w * 0.47, h * 0.47)
      ..lineTo(w * 0.10, h * 0.50)
      ..close();
    canvas.drawPath(p1, lote1Fill);
    canvas.drawPath(p1, lote1Stroke);

    // Lote 2 (green)
    final greenFill = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    final greenStroke = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final p2 = Path()
      ..moveTo(w * 0.50, h * 0.13)
      ..lineTo(w * 0.87, h * 0.18)
      ..lineTo(w * 0.85, h * 0.43)
      ..lineTo(w * 0.52, h * 0.47)
      ..close();
    canvas.drawPath(p2, greenFill);
    canvas.drawPath(p2, greenStroke);

    // Lote 3 (green)
    final p3 = Path()
      ..moveTo(w * 0.10, h * 0.55)
      ..lineTo(w * 0.52, h * 0.52)
      ..lineTo(w * 0.55, h * 0.87)
      ..lineTo(w * 0.15, h * 0.93)
      ..close();
    canvas.drawPath(p3, greenFill);
    canvas.drawPath(p3, greenStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

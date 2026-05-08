import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../common/agro_bottom_nav.dart';
import '../widgets/offline_banner.dart';
import '../widgets/custom_app_bar.dart';
import 'find_finding_screen.dart';
import 'phyto_history_screen.dart';
import 'treatment_apply_screen.dart';

class PhytosanitaryScreen extends StatelessWidget {
  const PhytosanitaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: OfflineBanner()),
            const SizedBox(height: 16),
            Text('Gestión Fitosanitaria', style: AppText.h2()),
            const SizedBox(height: 4),
            Text(
              'Administra la sanidad vegetal de tus lotes',
              style: AppText.bodyMd(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            _hubItem(
              context,
              icon: Icons.pest_control,
              title: 'Registrar Hallazgo',
              subtitle: 'Reporta nuevas plagas o enfermedades',
              destination: const FindFindingScreen(),
            ),
            const SizedBox(height: 12),
            _hubItem(
              context,
              icon: Icons.warning,
              title: 'Alertas Activas',
              subtitle: '2 alertas críticas detectadas',
              badge: '2',
              destination: const PhytoHistoryScreen(),
            ),
            const SizedBox(height: 12),
            _hubItem(
              context,
              icon: Icons.vaccines,
              title: 'Aplicar Tratamiento',
              subtitle: 'Ejecutar acciones correctivas',
              destination: const TreatmentApplyScreen(),
            ),
            const SizedBox(height: 12),
            _hubItem(
              context,
              icon: Icons.history,
              title: 'Historial',
              subtitle: 'Consulta registros anteriores',
              destination: const PhytoHistoryScreen(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AgroBottomNav(current: AgroTab.tareas),
    );
  }

  Widget _hubItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget destination,
    String? badge,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => destination),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          border: Border.all(color: AppColors.outlineVariant, width: 1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.04),
              offset: const Offset(0, 4),
              blurRadius: 16,
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryFixed,
                  ),
                  child: Icon(icon, color: AppColors.onPrimaryFixed, size: 26),
                ),
                if (badge != null)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.error,
                        border: Border.all(
                          color: AppColors.surfaceContainerLowest,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        badge,
                        style: AppText.labelCaps(color: AppColors.onError),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.bodyLg().copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppText.bodyMd(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, color: AppColors.outline, size: 22),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../common/agro_bottom_nav.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/rugged_button.dart';
import '../widgets/offline_banner.dart';
import 'lote_history_screen.dart';
import 'home_screen.dart';
import 'map_onboarding_screen.dart';
import 'profile_screen.dart';
import 'tasks_screen.dart';

class TreatmentSuccessScreen extends StatelessWidget {
  final String lote;
  final String metodo;
  final AgroTab currentTab;

  const TreatmentSuccessScreen({
    super.key,
    this.lote = 'Lote 1 - Sector Norte',
    this.metodo = 'Control Biológico',
    this.currentTab = AgroTab.tareas,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryFixedDim,
                border: Border.all(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '¡TRATAMIENTO REGISTRADO!',
              textAlign: TextAlign.center,
              style: AppText.h2(color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: OfflineBanner.showGlobal,
              builder: (context, isOffline, child) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    isOffline
                        ? 'La información se guardó en el celular y se sincronizará cuando tengas internet.'
                        : 'La información se ha registrado y sincronizado correctamente en tu cuenta.',
                    textAlign: TextAlign.center,
                    style: AppText.bodyLg(color: AppColors.onSurfaceVariant),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Summary card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'RESUMEN DE OPERACIÓN',
                      style: AppText.labelCaps(),
                    ),
                  ),
                  const Divider(
                    color: AppColors.outlineVariant,
                    height: 1,
                    thickness: 1,
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _summaryItem(
                        Icons.location_on,
                        'Ubicación',
                        lote,
                        AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: AppColors.outlineVariant, height: 1),
                      const SizedBox(height: 16),
                      _summaryItem(
                        Icons.bug_report,
                        'Plaga',
                        'Gusano Cogollero',
                        AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: AppColors.outlineVariant, height: 1),
                      const SizedBox(height: 16),
                      _summaryItem(
                        Icons.science,
                        'Método Aplicado',
                        metodo,
                        AppColors.secondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            RuggedButton(
              text: 'VER HISTORIAL DEL LOTE',
              icon: Icons.history,
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => LoteHistoryScreen(loteName: lote),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: AgroBottomNav(
        current: currentTab,
        onTap: (tab) {
          if (tab == AgroTab.home) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          } else if (tab == AgroTab.lotes) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const MapOnboardingScreen()));
          } else if (tab == AgroTab.perfil) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()));
          } else if (tab == AgroTab.tareas) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const TasksScreen()));
          }
        },
      ),
    );
  }

  Widget _summaryItem(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: AppText.labelCaps(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppText.h3(color: color).copyWith(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

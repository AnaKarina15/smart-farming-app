import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../widgets/custom_app_bar.dart';
import '../common/agro_bottom_nav.dart';
import '../widgets/offline_banner.dart';
import 'home_screen.dart';
import 'map_onboarding_screen.dart';
import 'profile_screen.dart';

class EvaluationSuccessScreen extends StatelessWidget {
  final String loteName;
  final String plagueName;
  final bool isControlled;

  const EvaluationSuccessScreen({
    super.key,
    required this.loteName,
    required this.plagueName,
    required this.isControlled,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                '¡Evaluación\nRegistrada!',
                textAlign: TextAlign.center,
                style: AppText.h1(color: AppColors.onBackground).copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 24),

              ValueListenableBuilder<bool>(
                valueListenable: OfflineBanner.showGlobal,
                builder: (context, isOffline, child) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isOffline
                          ? 'La información se guardó en el celular y se sincronizará cuando tengas internet.'
                          : 'La información se ha registrado y sincronizado correctamente en tu cuenta.',
                      textAlign: TextAlign.center,
                      style: AppText.bodyMd(color: AppColors.onSurfaceVariant).copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RESUMEN DE REGISTRO',
                      style: AppText.labelCaps(color: AppColors.primary)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // Location
                    _SummaryRow(
                      icon: Icons.location_on_outlined,
                      label: 'Ubicación',
                      value: loteName.toUpperCase(),
                    ),
                    const Divider(height: 32),

                    // Evaluation
                    _SummaryRow(
                      icon: Icons.pest_control_outlined,
                      label: 'Evaluación',
                      value: plagueName.toUpperCase(),
                    ),
                    const Divider(height: 32),

                    // Final State
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.assignment_outlined,
                            color: AppColors.onSurfaceVariant, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ESTADO FINAL',
                                style: AppText.labelCaps(color: AppColors.onSurfaceVariant),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isControlled
                                      ? AppColors.primary
                                      : AppColors.error,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isControlled
                                      ? 'PLAGA CONTROLADA'
                                      : 'PLAGA CONTINÚA',
                                  style: AppText.labelCaps(color: Colors.white)
                                      .copyWith(fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Return button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to tasks screen, removing the evaluation screen from stack
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text(
                    'VOLVER A TAREAS',
                    style: AppText.labelCapsLg(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AgroBottomNav(
        current: AgroTab.tareas,
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
          }
        },
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.onSurfaceVariant, size: 22),
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
                style: AppText.h3(color: AppColors.onBackground).copyWith(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

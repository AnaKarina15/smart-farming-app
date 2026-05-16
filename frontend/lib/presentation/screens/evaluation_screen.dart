import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../widgets/custom_app_bar.dart';
import '../common/agro_bottom_nav.dart';
import '../widgets/offline_banner.dart';
import 'evaluation_success_screen.dart';
import 'home_screen.dart';
import 'map_onboarding_screen.dart';
import 'profile_screen.dart';

class EvaluationScreen extends StatefulWidget {
  final String loteName;
  final String plagueName;
  final String treatment;
  final String treatmentTime;

  const EvaluationScreen({
    super.key,
    required this.loteName,
    required this.plagueName,
    required this.treatment,
    required this.treatmentTime,
  });

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  bool? _isControlled;
  final TextEditingController _observationsController = TextEditingController();

  @override
  void dispose() {
    _observationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: OfflineBanner()),
            const SizedBox(height: 16),
            Text(
              'Registrar Evaluación',
              style: AppText.h2(color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              '${widget.loteName} - ${widget.plagueName}',
              style: AppText.bodyLg(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),

            // Card 1: Tratamiento
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.science, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TRATAMIENTO APLICADO\nHACE ${widget.treatmentTime}',
                          style: AppText.labelCaps(
                              color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.treatment,
                          style: AppText.bodyLg(color: AppColors.onBackground)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Se observa una disminución de la plaga en el cultivo?',
                    style: AppText.bodyLg(color: AppColors.onBackground)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Option: Yes
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isControlled = true;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: _isControlled == true
                            ? AppColors.primaryContainer
                            : AppColors.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isControlled == true
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle_outline,
                              color: AppColors.primary, size: 28),
                          const SizedBox(height: 8),
                          Text(
                            'SÍ, PLAGA CONTROLADA',
                            style: AppText.labelCaps(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Option: No
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isControlled = false;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: _isControlled == false
                            ? AppColors.errorContainer
                            : AppColors.errorContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isControlled == false
                              ? AppColors.error
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: AppColors.error, size: 28),
                          const SizedBox(height: 8),
                          Text(
                            'NO, LA PLAGA CONTINÚA',
                            style: AppText.labelCaps(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Observations
                  Text(
                    'OBSERVACIONES (OPCIONAL)',
                    style: AppText.labelCaps(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _observationsController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Escriba aquí los detalles...',
                      hintStyle: AppText.bodyMd(color: AppColors.outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isControlled == null
                    ? null
                    : () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EvaluationSuccessScreen(
                              loteName: widget.loteName,
                              plagueName: widget.plagueName,
                              isControlled: _isControlled!,
                            ),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.outlineVariant,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                icon: const Icon(Icons.save, color: Colors.white),
                label: Text(
                  'GUARDAR EVALUACIÓN',
                  style: AppText.labelCapsLg(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
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

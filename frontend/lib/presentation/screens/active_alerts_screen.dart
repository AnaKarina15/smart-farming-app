import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../widgets/custom_app_bar.dart';
import '../common/agro_bottom_nav.dart';
import 'treatment_apply_screen.dart';
import 'home_screen.dart';
import 'map_onboarding_screen.dart';
import 'profile_screen.dart';
import 'tasks_screen.dart';
import 'register_observation_screen.dart';

class ActiveAlertsScreen extends StatelessWidget {
  final AgroTab currentTab;
  const ActiveAlertsScreen({super.key, this.currentTab = AgroTab.home});

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
            Text('Alertas Activas',
                style: AppText.h1(color: AppColors.primary)),
            const SizedBox(height: 5),
            _alertCard(
              context: context,
              lote: 'LOTE 1',
              title: 'Gusano Cogollero',
              description:
                  'Nivel de infestación crítico detectado en cuadrante norte.',
              priority: 'ALTA PRIORIDAD',
              priorityColor: AppColors.error,
              timeAgo: 'HACE 2H',
              buttonText: 'APLICAR TRATAMIENTO',
              buttonColor: AppColors.error,
              bgColor: const Color(0xFFFCF3F3), // Light red bg
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TreatmentApplyScreen(
                      alertLoteName: 'Lote 1 - Sector Norte',
                      alertPlagueName: 'Gusano Cogollero',
                      currentTab: currentTab,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _alertCard(
              context: context,
              lote: 'LOTE 4',
              title: 'Roya Amarilla',
              description:
                  'Presencia moderada en etapa temprana. Monitoreo requerido.',
              priority: 'MONITOREAR',
              priorityIcon: Icons.visibility_outlined,
              priorityColor: AppColors.secondary,
              timeAgo: 'HACE 5H',
              buttonText: 'REGISTRAR OBSERVACIÓN',
              buttonColor: Colors.transparent,
              buttonTextColor: AppColors.secondary,
              bgColor: const Color(0xFFFDFBF0), // Light yellow bg
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RegisterObservationScreen(
                      loteName: 'Lote 4',
                      currentTab: currentTab,
                    ),
                  ),
                );
              },
            ),
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

  Widget _alertCard({
    required BuildContext context,
    required String lote,
    required String title,
    required String description,
    required String priority,
    IconData? priorityIcon,
    required Color priorityColor,
    required String timeAgo,
    required String buttonText,
    required Color buttonColor,
    Color? buttonTextColor,
    required Color bgColor,
    required VoidCallback onPressed,
  }) {
    final bool isOutlinedButton = buttonColor == Colors.transparent;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              lote,
              style:
                  AppText.labelCaps(color: Colors.white).copyWith(fontSize: 10),
            ),
          ),
          const SizedBox(height: 12),
          Text(title, style: AppText.h2()),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppText.bodyMd(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.outlineVariant),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(priorityIcon ?? Icons.warning_amber_rounded,
                      color: priorityColor, size: 18),
                  const SizedBox(width: 8),
                  Text(priority,
                      style: AppText.labelCaps(color: priorityColor)),
                ],
              ),
              Text(timeAgo,
                  style: AppText.labelCaps(color: AppColors.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                elevation: 0,
                side: isOutlinedButton
                    ? BorderSide(color: buttonTextColor ?? Colors.black)
                    : BorderSide.none,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: onPressed,
              child: Text(
                buttonText,
                style: AppText.labelCaps(
                        color: isOutlinedButton
                            ? (buttonTextColor ?? Colors.black)
                            : Colors.white)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../common/agro_bottom_nav.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/offline_banner.dart';
import 'home_screen.dart';
import 'map_onboarding_screen.dart';
import 'profile_screen.dart';
import 'irrigation_screen.dart';
import 'evaluation_screen.dart';
import 'fertilization_screen.dart';
import 'treatment_apply_screen.dart';
import 'soil_humidity_screen.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

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
            const OfflineBanner(),
            const SizedBox(height: 2),
            Text('Sugerencias y Alertas del Sistema',
                style: AppText.h2(color: AppColors.primary)),
            const SizedBox(height: 5),

            // Card 1: Riego
            _TaskCard(
              icon: Icons.water_drop,
              iconColor: AppColors.onPrimary,
              iconBgColor: AppColors.primary,
              cardColor: AppColors.secondaryContainer,
              title: 'Sugerencia de Riego',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style:
                          AppText.bodyMd(color: AppColors.onSecondaryContainer),
                      children: [
                        const TextSpan(
                            text: 'Lote 1: ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(text: 'Aplicar 20 Litros.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style:
                          AppText.bodyMd(color: AppColors.onSecondaryContainer),
                      children: [
                        const TextSpan(
                            text: 'Motivo: ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(
                            text: 'Pronóstico de sequía extrema hoy'),
                      ],
                    ),
                  ),
                ],
              ),
              actionLabel: 'EJECUTAR RIEGO',
              onAction: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          const IrrigationScreen(fixedLote: 'Lote 1'))),
              footer: Text(
                'Calculado con datos de ayer',
                style: AppText.bodyMd(color: AppColors.onSecondaryContainer)
                    .copyWith(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 16),

            // Card 2: Fitosanitario
            _TaskCard(
              icon: Icons.bug_report,
              iconColor: AppColors.onPrimary,
              iconBgColor: AppColors.primary,
              cardColor: AppColors.errorContainer,
              title: 'Alerta de Revisión',
              content: RichText(
                text: TextSpan(
                  style: AppText.bodyMd(color: AppColors.onErrorContainer),
                  children: [
                    const TextSpan(
                        text: 'Lote 1: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(
                        text:
                            'Han pasado 36 horas desde el tratamiento. Evalúe si la plaga disminuyó'),
                  ],
                ),
              ),
              actionLabel: 'REGISTRAR EVALUACIÓN',
              onAction: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const EvaluationScreen(
                            loteName: 'Lote 1',
                            plagueName: 'Gusano Cogollero',
                            treatment: 'Control Biológico',
                            treatmentTime: '36H',
                          ))),
            ),
            const SizedBox(height: 16),

            // Card 3: Fertilización
            _TaskCard(
              icon: Icons.science,
              iconColor: AppColors.onPrimary,
              iconBgColor: AppColors.primary,
              cardColor: const Color(0xFFE8F5E9),
              title: 'Fertilización Pendiente',
              content: RichText(
                text: TextSpan(
                  style: AppText.bodyMd(color: const Color(0xFF1B5E20)),
                  children: const [
                    TextSpan(
                        text: 'Lote 2: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text:
                            'El análisis indica deficiencia de Nitrógeno. Se recomienda aplicar 400 KG.'),
                  ],
                ),
              ),
              actionLabel: 'REGISTRAR FERTILIZACIÓN',
              onAction: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const FertilizationScreen(
                          fixedLote: 'Lote 2 - Ladera Este'))),
            ),
            const SizedBox(height: 16),

            // Card 4: Aplicar Tratamiento
            _TaskCard(
              icon: Icons.healing,
              iconColor: AppColors.onPrimary,
              iconBgColor: AppColors.primary,
              cardColor: const Color(0xFFFFF3E0),
              title: 'Aplicar Tratamiento',
              content: RichText(
                text: TextSpan(
                  style: AppText.bodyMd(color: const Color(0xFFE65100)),
                  children: const [
                    TextSpan(
                        text: 'Lote 3: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text:
                            'Se detectó presencia de Roya. Se recomienda aplicar fungicida preventivo.'),
                  ],
                ),
              ),
              actionLabel: 'APLICAR TRATAMIENTO',
              onAction: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const TreatmentApplyScreen(
                            alertLoteName: 'Lote 3',
                            alertPlagueName: 'Roya',
                            currentTab: AgroTab.tareas,
                          ))),
            ),
            const SizedBox(height: 16),

            // Card 5: Estado del Suelo
            _TaskCard(
              icon: Icons.terrain,
              iconColor: AppColors.onPrimary,
              iconBgColor: AppColors.primary,
              cardColor: const Color(0xFFEFEBE9),
              title: 'Registrar Estado del Suelo',
              content: RichText(
                text: TextSpan(
                  style: AppText.bodyMd(color: const Color(0xFF4E342E)),
                  children: const [
                    TextSpan(
                        text: 'Lote 1: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text:
                            'No se ha registrado humedad del suelo en 5 días. Verifique el estado actual.'),
                  ],
                ),
              ),
              actionLabel: 'REGISTRAR ESTADO',
              onAction: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SoilHumidityScreen(
                            fixedLote: 'Lote 1',
                            currentTab: AgroTab.tareas,
                          ))),
            ),
            const SizedBox(height: 16),

            // Card 6: Clima
            _TaskCard(
              icon: Icons.cloud,
              iconColor: AppColors.onPrimary,
              iconBgColor: AppColors.primary,
              cardColor: AppColors.surfaceVariant,
              title: 'Alerta Climática',
              content: Text(
                'Lluvias intensas pronosticadas para mañana. Se recomienda posponer la fertilización del Lote 3',
                style: AppText.bodyMd(color: AppColors.onSurfaceVariant),
              ),
            ),
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

class _TaskCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final Color cardColor;
  final String title;
  final Widget content;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? footer;

  const _TaskCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.cardColor,
    required this.title,
    required this.content,
    this.actionLabel,
    this.onAction,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppText.h3(color: AppColors.primary)
                            .copyWith(fontSize: 22)),
                    const SizedBox(height: 8),
                    content,
                  ],
                ),
              ),
            ],
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999)),
                ),
                child: Text(
                  actionLabel!,
                  style: AppText.labelCapsLg(color: AppColors.onPrimary),
                ),
              ),
            ),
          ],
          if (footer != null) ...[
            const SizedBox(height: 8),
            footer!,
          ]
        ],
      ),
    );
  }
}

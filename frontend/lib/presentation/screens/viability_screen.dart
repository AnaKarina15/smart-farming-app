import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/rugged_button.dart';
import '../common/agro_bottom_nav.dart';
import 'home_screen.dart';
import 'map_onboarding_screen.dart';
import 'profile_screen.dart';
import 'tasks_screen.dart';
import 'viability_success_screen.dart';

class ViabilityScreen extends StatefulWidget {
  final String lote;
  final AgroTab currentTab;

  const ViabilityScreen({
    super.key,
    required this.lote,
    this.currentTab = AgroTab.home,
  });

  @override
  State<ViabilityScreen> createState() => _ViabilityScreenState();
}

class _ViabilityScreenState extends State<ViabilityScreen> {
  double _viability = 85.0;
  String _quality = 'EXCELENTE';

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
            Text('VIABILIDAD DE\nPLÁNTULAS',
                style: AppText.h1().copyWith(height: 1.1)),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PORCENTAJE DE VIABILIDAD',
                      style: AppText.labelCaps(color: const Color(0xFF1E5266))),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 48, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F4F4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _viability.toInt().toString(),
                          style: AppText.h1(color: const Color(0xFF1E5266))
                              .copyWith(fontSize: 48),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text('%',
                          style: AppText.h1(color: const Color(0xFF1E5266))
                              .copyWith(fontSize: 48)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF1E5266),
                      inactiveTrackColor: AppColors.outlineVariant,
                      thumbColor: const Color(0xFF1E5266),
                      trackHeight: 8,
                    ),
                    child: Slider(
                      value: _viability,
                      min: 0,
                      max: 100,
                      onChanged: (val) => setState(() => _viability = val),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('CALIDAD OBSERVADA',
                style: AppText.labelCaps(color: const Color(0xFF1E5266))),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _qualityCard('EXCELENTE', Icons.verified)),
                const SizedBox(width: 12),
                Expanded(
                    child: _qualityCard('BUENA', Icons.thumb_up_alt_outlined)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _qualityCard('REGULAR', Icons.remove)),
                const SizedBox(width: 12),
                Expanded(
                    child: _qualityCard('BAJA', Icons.thumb_down_alt_outlined,
                        isRed: true)),
              ],
            ),
            const SizedBox(height: 48),
            RuggedButton(
              text: 'REGISTRAR VIABILIDAD',
              icon: Icons.save,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ViabilitySuccessScreen(
                      lote: widget.lote,
                      viability: _viability.toInt(),
                      quality: _quality,
                      currentTab: widget.currentTab,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: AgroBottomNav(
        current: widget.currentTab,
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

  Widget _qualityCard(String label, IconData icon, {bool isRed = false}) {
    final isSelected = _quality == label;
    final color = isRed ? AppColors.error : const Color(0xFF1E5266);

    return GestureDetector(
      onTap: () => setState(() => _quality = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1E5266)
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isSelected
                  ? const Color(0xFF1E5266)
                  : AppColors.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppText.labelCaps(
                      color:
                          isSelected ? Colors.white : const Color(0xFF1E5266))
                  .copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

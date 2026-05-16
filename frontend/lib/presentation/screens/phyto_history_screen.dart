import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../widgets/custom_app_bar.dart';
import '../common/agro_bottom_nav.dart';
import 'home_screen.dart';
import 'map_onboarding_screen.dart';
import 'profile_screen.dart';
import 'tasks_screen.dart';

class PhytoHistoryScreen extends StatefulWidget {
  final AgroTab currentTab;
  const PhytoHistoryScreen({super.key, this.currentTab = AgroTab.home});

  @override
  State<PhytoHistoryScreen> createState() => _PhytoHistoryScreenState();
}

class _PhytoHistoryScreenState extends State<PhytoHistoryScreen> {
  String _selectedFilter = 'TODOS';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text('Historial DE GESTION FITOSANITARIA',
                style: AppText.labelCaps(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 24),

            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterPill('TODOS'),
                  const SizedBox(width: 8),
                  _filterPill('LOTE 1'),
                  const SizedBox(width: 8),
                  _filterPill('PLAGAS'),
                ],
              ),
            ),

            // Timeline
            Stack(
              children: [
                Positioned(
                  left: 7,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 1,
                    color: AppColors.outlineVariant,
                  ),
                ),
                Column(
                  children: [
                    _timelineItem(
                      dotColor: AppColors.error,
                      dateStr: '12 OCT 2023 - 08:30 AM',
                      icon: Icons.bug_report,
                      iconColor: AppColors.error,
                      title: 'Detección de Mosca Blanca',
                      description:
                          'Lote 3, sector Norte. Nivel de infestación severo detectado en hojas inferiores.',
                    ),
                    _timelineItem(
                      dotColor: AppColors.primary,
                      dateStr: '10 OCT 2023 - 14:15 PM',
                      icon: Icons.vaccines,
                      iconColor: AppColors.primary,
                      title: 'Aplicación de Fungicida',
                      description:
                          'Lote 1 y 2. Aplicación preventiva de Cobre. Dosis: 2L/Ha.',
                    ),
                    _timelineItem(
                      dotColor: AppColors.outline,
                      dateStr: '05 OCT 2023 - 09:00 AM',
                      icon: Icons.assignment,
                      iconColor: AppColors.outline,
                      title: 'Inspección de Rutina',
                      description:
                          'Todos los lotes revisados. Sin novedades significativas. Humedad del suelo óptima.',
                      isLast: true,
                    ),
                  ],
                ),
              ],
            ),
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

  Widget _filterPill(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primary : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppText.labelCaps(
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant),
        ),
      ),
    );
  }

  Widget _timelineItem({
    required Color dotColor,
    required String dateStr,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 16),
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.background, width: 2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(dateStr,
                            style: AppText.labelCaps(
                                color: AppColors.onSurfaceVariant)),
                      ),
                      Icon(icon, color: iconColor, size: 20),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(title, style: AppText.h3()),
                  const SizedBox(height: 8),
                  Text(description,
                      style: AppText.bodyMd(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

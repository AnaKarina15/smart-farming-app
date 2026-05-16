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
import 'terrain_success_screen.dart';

class TerrainStatusScreen extends StatefulWidget {
  final String lote;
  final AgroTab currentTab;

  const TerrainStatusScreen({
    super.key,
    required this.lote,
    this.currentTab = AgroTab.home,
  });

  @override
  State<TerrainStatusScreen> createState() => _TerrainStatusScreenState();
}

class _TerrainStatusScreenState extends State<TerrainStatusScreen> {
  String _selectedStatus = 'ARADO';
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

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
            Text('Estado del terreno',
                style: AppText.h3(color: const Color(0xFF1E5266))),
            const SizedBox(height: 5),
            Text(
              'Seleccione la condición actual del lote asignado.',
              style: AppText.bodyMd(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            _statusCard('LIMPIO', Icons.eco_outlined),
            const SizedBox(height: 12),
            _statusCard('ARADO', Icons.agriculture),
            const SizedBox(height: 12),
            _statusCard('ADECUADO', Icons.checklist_rtl),
            const SizedBox(height: 12),
            _statusCard('CON MALEZA', Icons.grass),
            const SizedBox(height: 32),
            Text('NOTAS ADICIONALES',
                style: AppText.labelCaps(color: const Color(0xFF1E5266))),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                hintText: 'Observaciones del terreno...',
                hintStyle: AppText.bodyMd(color: AppColors.outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 48),
            RuggedButton(
              text: 'GUARDAR ESTADO',
              icon: Icons.save,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TerrainSuccessScreen(
                      lote: widget.lote,
                      status: _selectedStatus,
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

  Widget _statusCard(String label, IconData icon) {
    final isSelected = _selectedStatus == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = label),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2E5D42)
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected
                  ? const Color(0xFF2E5D42)
                  : AppColors.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : AppColors.onSurface,
                size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppText.labelCaps(
                      color: isSelected
                          ? Colors.white
                          : AppColors.onSurface)
                  .copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

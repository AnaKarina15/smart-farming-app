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
import '../../data/providers/catalogos_provider.dart';
import 'package:provider/provider.dart';

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
  String? _selectedSueloId;
  String? _recomendaciones;
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
      appBar: const CustomAppBar(showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estado del terreno',
                style: AppText.h2(color: AppColors.onSurface)),
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
            Text('CARACTERIZACIÓN DEL SUELO',
                style: AppText.labelCaps(color: const Color(0xFF1E5266))),
            const SizedBox(height: 8),
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                border: Border.all(color: AppColors.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Consumer<CatalogosProvider>(
                builder: (context, provider, child) {
                  final list = provider.tiposSuelo;
                  if (_selectedSueloId == null && list.isNotEmpty) {
                    _selectedSueloId = list.first.id;
                    _recomendaciones = list.first.cultivosRecomendados;
                  }

                  return DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSueloId,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: AppColors.onSurfaceVariant),
                      items: list.map((s) {
                        return DropdownMenuItem(
                          value: s.id,
                          child: Text(s.nombre),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() {
                          _selectedSueloId = v;
                          _recomendaciones = list
                              .firstWhere((s) => s.id == v)
                              .cultivosRecomendados;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            if (_recomendaciones != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cultivos recomendados: $_recomendaciones',
                        style: AppText.bodyMd(color: AppColors.onPrimaryContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
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
                      color: isSelected ? Colors.white : AppColors.onSurface)
                  .copyWith(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

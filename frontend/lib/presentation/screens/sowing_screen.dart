import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../common/agro_bottom_nav.dart';
import '../widgets/offline_banner.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/rugged_button.dart';
import 'sowing_success_screen.dart';
import 'terrain_status_screen.dart';
import 'viability_screen.dart';

class SowingScreen extends StatefulWidget {
  final AgroTab currentTab;
  const SowingScreen({super.key, this.currentTab = AgroTab.tareas});

  @override
  State<SowingScreen> createState() => _SowingScreenState();
}

class _SowingScreenState extends State<SowingScreen> {
  String _crop = 'Maíz';
  String _lote = 'Lote Norte - Sector A1';
  final _dateController = TextEditingController(text: '24/05/2026');

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Registrar Nueva Siembra', style: AppText.h1()),
                  const SizedBox(height: 4),
                  Text(
                    'Complete los detalles técnicos del lote.',
                    style: AppText.bodyMd(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 32),

                  Text('SELECCIONAR CULTIVO', style: AppText.labelCaps()),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _cropCard('Maíz', Icons.agriculture)),
                      const SizedBox(width: 8),
                      Expanded(child: _cropCard('Banano', Icons.bakery_dining)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _cropCard('Café', Icons.energy_savings_leaf),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Verificar viabilidad
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ViabilityScreen(),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified_user,
                            color: AppColors.onSecondaryContainer,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Verificar Viabilidad',
                              style: AppText.labelCaps(
                                color: AppColors.onSecondaryContainer,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: AppColors.onSecondaryContainer,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '* Recomendado antes de registrar la siembra (RF03)',
                    style: AppText.bodyMd(
                      color: AppColors.onSurfaceVariant,
                    ).copyWith(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 24),

                  Text('ESTADO PREVIO', style: AppText.labelCaps()),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TerrainStatusScreen(),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        border: Border.all(
                          color: AppColors.outlineVariant,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surfaceContainer,
                            ),
                            child: const Icon(
                              Icons.analytics,
                              color: AppColors.onSurface,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Estado del Terreno',
                                  style: AppText.bodyMd().copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Consultar condiciones actuales del suelo (RF04)',
                                  style: AppText.bodyMd(
                                    color: AppColors.onSurfaceVariant,
                                  ).copyWith(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.open_in_new,
                            color: AppColors.onSurfaceVariant,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('FECHA DE SIEMBRA', style: AppText.labelCaps()),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.calendar_today,
                        color: AppColors.onSurfaceVariant,
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceContainerLowest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.outlineVariant,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.outlineVariant,
                          width: 1,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('SELECCIONAR LOTE', style: AppText.labelCaps()),
                  const SizedBox(height: 8),
                  _selector(),
                  const SizedBox(height: 24),

                  // Area
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ÁREA DISPONIBLE',
                                style: AppText.labelCaps(
                                  color: AppColors.onPrimaryFixedVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '12.5',
                                    style: AppText.h1(
                                      color: AppColors.onPrimaryFixed,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'ha',
                                    style: AppText.bodyLg(
                                      color: AppColors.onPrimaryFixed,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.straighten,
                          size: 64,
                          color: AppColors.primaryContainer.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  RuggedButton(
                    text: 'GUARDAR CULTIVO',
                    icon: Icons.save,
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SowingSuccessScreen(lote: _lote, crop: _crop),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AgroBottomNav(current: widget.currentTab),
    );
  }

  Widget _cropCard(String name, IconData icon) {
    final selected = _crop == name;
    return GestureDetector(
      onTap: () => setState(() => _crop = name),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryFixed
              : AppColors.surfaceContainerLowest,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outlineVariant,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: selected ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: AppText.bodyMd(
                color: selected
                    ? AppColors.onSurface
                    : AppColors.onSurfaceVariant,
              ).copyWith(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _selector() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.outlineVariant, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.map, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _lote,
                isExpanded: true,
                icon: const Icon(
                  Icons.expand_more,
                  color: AppColors.onSurfaceVariant,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Lote Norte - Sector A1',
                    child: Text('Lote Norte - Sector A1'),
                  ),
                  DropdownMenuItem(
                    value: 'Lote Sur - Sector B2',
                    child: Text('Lote Sur - Sector B2'),
                  ),
                  DropdownMenuItem(
                    value: 'Lote Este - Reserva',
                    child: Text('Lote Este - Reserva'),
                  ),
                ],
                onChanged: (v) =>
                    setState(() => _lote = v ?? 'Lote Norte - Sector A1'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

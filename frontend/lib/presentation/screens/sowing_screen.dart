import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../common/agro_bottom_nav.dart';
import '../widgets/offline_banner.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/rugged_button.dart';
import 'home_screen.dart';
import 'map_onboarding_screen.dart';
import 'profile_screen.dart';
import 'tasks_screen.dart';
import 'sowing_success_screen.dart';
import 'terrain_status_screen.dart';
import 'viability_screen.dart';

class SowingScreen extends StatefulWidget {
  final AgroTab currentTab;
  final String? fixedLote;
  const SowingScreen({super.key, this.currentTab = AgroTab.tareas, this.fixedLote});

  @override
  State<SowingScreen> createState() => _SowingScreenState();
}

class _SowingScreenState extends State<SowingScreen> {
  String _crop = 'Maíz';
  late String _lote;
  final _dateController = TextEditingController(text: '24/05/2026');
  final _otherCropController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _lote = widget.fixedLote ?? 'Lote Norte - Sector A1';
  }

  @override
  void dispose() {
    _dateController.dispose();
    _otherCropController.dispose();
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
                  const SizedBox(height: 5),
                  Text(
                    'Complete los detalles técnicos del lote.',
                    style: AppText.bodyMd(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 32),

                  Text('SELECCIONAR CULTIVO', style: AppText.labelCaps()),
                  const SizedBox(height: 8),
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      border: Border.all(color: AppColors.outlineVariant),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _crop,
                        isExpanded: true,
                        icon: const Icon(Icons.expand_more,
                            color: AppColors.onSurfaceVariant),
                        items: ['Maíz', 'Banano', 'Café', 'Otro']
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => _crop = v ?? _crop),
                      ),
                    ),
                  ),
                  if (_crop == 'Otro') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _otherCropController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surfaceContainerLowest,
                        hintText: 'Especifique el cultivo',
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
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Verificar viabilidad
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ViabilityScreen(
                            lote: _lote, currentTab: widget.currentTab),
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
                    '* Recomendado antes de registrar la siembra *',
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
                        builder: (_) => TerrainStatusScreen(
                            lote: _lote, currentTab: widget.currentTab),
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
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() {
                          _dateController.text =
                              "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
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
                                    _lote.contains('A1')
                                        ? '12.5'
                                        : (_lote.contains('B2')
                                            ? '8.0'
                                            : '20.0'),
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
                    onPressed: () {
                      final finalCrop = _crop == 'Otro' &&
                              _otherCropController.text.isNotEmpty
                          ? _otherCropController.text
                          : _crop;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SowingSuccessScreen(lote: _lote, crop: finalCrop, currentTab: widget.currentTab),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
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

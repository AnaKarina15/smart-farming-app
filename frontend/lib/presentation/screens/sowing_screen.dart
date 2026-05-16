import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../common/agro_bottom_nav.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/rugged_button.dart';
import '../widgets/offline_banner.dart';
import 'home_screen.dart';
import 'map_onboarding_screen.dart';
import 'profile_screen.dart';
import 'tasks_screen.dart';
import 'sowing_success_screen.dart';
import 'terrain_status_screen.dart';

class SowingScreen extends StatefulWidget {
  final String? fixedLote;
  final AgroTab currentTab;

  const SowingScreen({
    super.key,
    this.fixedLote,
    this.currentTab = AgroTab.home,
  });

  @override
  State<SowingScreen> createState() => _SowingScreenState();
}

class _SowingScreenState extends State<SowingScreen> {
  String _crop = 'Maíz';
  late String _lote;
  final TextEditingController _dateController = TextEditingController(
    text: "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
  );
  final TextEditingController _otherCropController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _lote = widget.fixedLote ?? 'Lote 1 — Sector Norte';
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
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  Text('FECHA DE SIEMBRA', style: AppText.labelCaps()),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceContainerLowest,
                      hintText: 'Seleccione la fecha',
                      suffixIcon: const Icon(Icons.calendar_today,
                          color: AppColors.primary),
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
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _dateController.text =
                              "${picked.day}/${picked.month}/${picked.year}";
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  Text('LOTE ASIGNADO', style: AppText.labelCaps()),
                  const SizedBox(height: 8),
                  _selector(),
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
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.terrain,
                              color: AppColors.onPrimaryContainer,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Estado del Terreno',
                                  style: AppText.bodyLg().copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Verificar condiciones antes',
                                  style: AppText.bodyMd(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.outline,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

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
                          builder: (_) => SowingSuccessScreen(
                              lote: _lote,
                              crop: finalCrop,
                              currentTab: widget.currentTab),
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
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const HomeScreen()));
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
                    value: 'Lote 1 — Sector Norte',
                    child: Text('Lote 1 — Sector Norte'),
                  ),
                  DropdownMenuItem(
                    value: 'Lote 2 — Ladera Este',
                    child: Text('Lote 2 — Ladera Este'),
                  ),
                  DropdownMenuItem(
                    value: 'Lote 3 — Valle Sur',
                    child: Text('Lote 3 — Valle Sur'),
                  ),
                ],
                onChanged: (v) =>
                    setState(() => _lote = v ?? 'Lote 1 — Sector Norte'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

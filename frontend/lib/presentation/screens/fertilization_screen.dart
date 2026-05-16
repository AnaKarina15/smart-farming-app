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
import 'fertilization_success_screen.dart';

class FertilizationScreen extends StatefulWidget {
  final AgroTab currentTab;
  final String? fixedLote;

  const FertilizationScreen({
    super.key,
    this.currentTab = AgroTab.tareas,
    this.fixedLote,
  });

  @override
  State<FertilizationScreen> createState() => _FertilizationScreenState();
}

class _FertilizationScreenState extends State<FertilizationScreen> {
  String _fertilizer = 'Nitrógeno';
  int _amount = 50;
  String _unit = 'KG';
  late String _lote;
  final _otherFertController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _lote = widget.fixedLote ?? 'Lote 1 - Sector Norte';
    _amountController.text = _amount.toString();
  }

  @override
  void dispose() {
    _otherFertController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _updateAmountFromText() {
    final parsed = int.tryParse(_amountController.text);
    if (parsed != null && parsed >= 0) {
      setState(() => _amount = parsed);
    }
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
                  Text('Registro de Fertilización', style: AppText.h1()),
                  const SizedBox(height: 5),

                  Text('SELECCIONAR FERTILIZANTE', style: AppText.labelCaps()),
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
                        value: _fertilizer,
                        isExpanded: true,
                        icon: const Icon(Icons.expand_more,
                            color: AppColors.onSurfaceVariant),
                        items: ['Nitrógeno', 'Fósforo', 'Orgánico', 'Otro']
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _fertilizer = v ?? _fertilizer),
                      ),
                    ),
                  ),
                  if (_fertilizer == 'Otro') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _otherFertController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surfaceContainerLowest,
                        hintText: 'Especifique el fertilizante...',
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
                  const SizedBox(height: 15),

                  // Tip
                  Row(
                    children: [
                      const Icon(Icons.lightbulb,
                          color: AppColors.secondary, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'Dosis sugerida: 400 KG',
                        style: AppText.bodyMd(color: AppColors.secondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  Text('UNIDAD DE MEDIDA', style: AppText.labelCaps()),
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
                        value: _unit,
                        isExpanded: true,
                        icon: const Icon(Icons.expand_more,
                            color: AppColors.onSurfaceVariant),
                        items: [
                          const DropdownMenuItem(
                              value: 'KG',
                              child:
                                  Text('Kilogramos (kg) — Sólido/Granulado')),
                          const DropdownMenuItem(
                              value: 'L', child: Text('Litros (L) — Líquido')),
                          const DropdownMenuItem(
                              value: 'g',
                              child: Text('Gramos (g) — Concentrado')),
                          const DropdownMenuItem(
                              value: 'ml',
                              child: Text('Mililitros (ml) — Soluble')),
                        ],
                        onChanged: (v) => setState(() => _unit = v ?? _unit),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('CANTIDAD APLICADA', style: AppText.labelCaps()),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _circleBtn(
                        Icons.remove,
                        () {
                          setState(() {
                            if (_amount >= 1) {
                              _amount -= 1;
                              _amountController.text = _amount.toString();
                            }
                          });
                        },
                        AppColors.surfaceContainer,
                        AppColors.onSurface,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            border: Border.all(
                                color: AppColors.outlineVariant, width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: AppText.h1(),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                  onChanged: (_) => _updateAmountFromText(),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _unit,
                                style: AppText.bodyMd(
                                    color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _circleBtn(
                        Icons.add,
                        () {
                          setState(() {
                            _amount += 1;
                            _amountController.text = _amount.toString();
                          });
                        },
                        AppColors.primaryContainer,
                        AppColors.onPrimaryContainer,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text('SELECCIONAR LOTE', style: AppText.labelCaps()),
                  const SizedBox(height: 12),
                  if (widget.fixedLote != null)
                    Container(
                      height: 56,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        border: Border.all(
                            color: AppColors.outlineVariant, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(widget.fixedLote!, style: AppText.bodyMd()),
                    )
                  else
                    _selector(),
                  const SizedBox(height: 12),
                  RuggedButton(
                    text: 'GUARDAR REGISTRO',
                    icon: Icons.save,
                    onPressed: () {
                      final finalFert = _fertilizer == 'Otro' &&
                              _otherFertController.text.isNotEmpty
                          ? _otherFertController.text
                          : _fertilizer;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FertilizationSuccessScreen(
                            lote: _lote,
                            fertilizer: finalFert,
                            amount: _amount,
                            unit: _unit,
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

  Widget _circleBtn(IconData icon, VoidCallback onTap, Color bg, Color fg) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bg,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, color: fg, size: 24),
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
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _lote,
          isExpanded: true,
          icon:
              const Icon(Icons.expand_more, color: AppColors.onSurfaceVariant),
          items: const [
            DropdownMenuItem(
                value: 'Lote 1 - Sector Norte',
                child: Text('Lote 1 - Sector Norte')),
            DropdownMenuItem(
                value: 'Lote 2 - Ladera Este',
                child: Text('Lote 2 - Ladera Este')),
            DropdownMenuItem(
                value: 'Lote 3 - Valle Sur', child: Text('Lote 3 - Valle Sur')),
          ],
          onChanged: (v) =>
              setState(() => _lote = v ?? 'Lote 1 - Sector Norte'),
        ),
      ),
    );
  }
}

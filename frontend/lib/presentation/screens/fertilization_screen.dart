import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../common/agro_bottom_nav.dart';
import '../widgets/offline_banner.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/rugged_button.dart';
import 'fertilization_success_screen.dart';

class FertilizationScreen extends StatefulWidget {
  const FertilizationScreen({super.key});

  @override
  State<FertilizationScreen> createState() => _FertilizationScreenState();
}

class _FertilizationScreenState extends State<FertilizationScreen> {
  String _fertilizer = 'Nitrógeno';
  int _kg = 450;
  String _lote = 'Lote 1 - Sector Norte';

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
                  const SizedBox(height: 32),

                  Text('SELECCIONAR FERTILIZANTE', style: AppText.labelCaps()),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _fertCard('Nitrógeno', Icons.science)),
                      const SizedBox(width: 8),
                      Expanded(child: _fertCard('Fósforo', Icons.water_drop)),
                      const SizedBox(width: 8),
                      Expanded(child: _fertCard('Orgánico', Icons.eco)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Tip
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb,
                        color: AppColors.secondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Dosis sugerida por el sistema: 400 KG',
                        style: AppText.bodyMd(color: AppColors.secondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text('CANTIDAD APLICADA', style: AppText.labelCaps()),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _circleBtn(
                        Icons.remove,
                        () {
                          setState(() {
                            if (_kg >= 50) _kg -= 50;
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
                              color: AppColors.outlineVariant,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text('$_kg', style: AppText.h1()),
                              const SizedBox(width: 4),
                              Text(
                                'KG',
                                style: AppText.bodyMd(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _circleBtn(
                        Icons.add,
                        () => setState(() => _kg += 50),
                        AppColors.primaryContainer,
                        AppColors.onPrimaryContainer,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text('SELECCIONAR LOTE', style: AppText.labelCaps()),
                  const SizedBox(height: 12),
                  _selector(),
                  const SizedBox(height: 32),
                  RuggedButton(
                    text: 'GUARDAR REGISTRO',
                    icon: Icons.save,
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FertilizationSuccessScreen(
                          lote: _lote,
                          fertilizer: _fertilizer,
                          amount: _kg,
                        ),
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
      bottomNavigationBar: const AgroBottomNav(current: AgroTab.tareas),
    );
  }

  Widget _fertCard(String name, IconData icon) {
    final selected = _fertilizer == name;
    return GestureDetector(
      onTap: () => setState(() => _fertilizer = name),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: selected ? AppColors.primary : AppColors.outline,
              ),
              const SizedBox(height: 8),
              Text(
                name.toUpperCase(),
                style: AppText.labelCaps(
                  color: selected ? AppColors.primary : AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
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
          icon: const Icon(
            Icons.expand_more,
            color: AppColors.onSurfaceVariant,
          ),
          items: const [
            DropdownMenuItem(
              value: 'Lote 1 - Sector Norte',
              child: Text('Lote 1 - Sector Norte'),
            ),
            DropdownMenuItem(
              value: 'Lote 2 - Ladera Este',
              child: Text('Lote 2 - Ladera Este'),
            ),
            DropdownMenuItem(
              value: 'Lote 3 - Valle Sur',
              child: Text('Lote 3 - Valle Sur'),
            ),
          ],
          onChanged: (v) =>
              setState(() => _lote = v ?? 'Lote 1 - Sector Norte'),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../common/agro_bottom_nav.dart';
import '../widgets/offline_banner.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/rugged_button.dart';
import 'irrigation_success_screen.dart';

class IrrigationScreen extends StatefulWidget {
  const IrrigationScreen({super.key});

  @override
  State<IrrigationScreen> createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends State<IrrigationScreen> {
  int _liters = 20;
  String _selectedLote = 'Lote 1';

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
            const Center(child: OfflineBanner()),
            const SizedBox(height: 24),
            Text('Registrar Riego', style: AppText.h2()),
            const SizedBox(height: 24),

            // Suggestion
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant, width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info, color: AppColors.secondary, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sugerencia de riego',
                          style: AppText.bodyMd(
                            color: AppColors.onSecondaryContainer,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Aplicar 20L en Lote 1 para optimizar el rendimiento del suelo hoy.',
                          style: AppText.bodyMd(
                            color: AppColors.onSecondaryContainer,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sugerencia calculada localmente',
                          style: AppText.bodyMd(
                            color: AppColors.onSecondaryContainer,
                          ).copyWith(fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Lote selector
            Text('SELECCIONAR LOTE', style: AppText.labelCaps()),
            const SizedBox(height: 8),
            _selector(),
            const SizedBox(height: 24),

            // Cantidad stepper
            Text('CANTIDAD APLICADA (LITROS)', style: AppText.labelCaps()),
            const SizedBox(height: 8),
            Row(
              children: [
                _stepBtn(Icons.remove, () {
                  setState(() {
                    if (_liters >= 5) _liters -= 5;
                  });
                }),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      border: Border.all(
                        color: AppColors.outlineVariant,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '$_liters',
                        style: AppText.h2(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _stepBtn(Icons.add, () => setState(() => _liters += 5)),
              ],
            ),
            const SizedBox(height: 24),

            // Context info
            Row(
              children: [
                Expanded(child: _statCard('ÚLTIMO RIEGO', 'Hace 2 días')),
                const SizedBox(width: 16),
                Expanded(child: _statCard('ESTADO SUELO', 'Seco')),
              ],
            ),
            const SizedBox(height: 32),
            RuggedButton(
              text: 'CONFIRMAR RIEGO',
              icon: Icons.check_circle,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => IrrigationSuccessScreen(
                      lote: _selectedLote,
                      liters: _liters,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const AgroBottomNav(current: AgroTab.tareas),
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
          value: _selectedLote,
          isExpanded: true,
          icon: const Icon(
            Icons.expand_more,
            color: AppColors.onSurfaceVariant,
          ),
          items: const [
            DropdownMenuItem(value: 'Lote 1', child: Text('Lote 1')),
            DropdownMenuItem(value: 'Lote 2', child: Text('Lote 2')),
            DropdownMenuItem(value: 'Lote 3', child: Text('Lote 3')),
          ],
          onChanged: (v) => setState(() => _selectedLote = v ?? 'Lote 1'),
        ),
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          border: Border.all(color: AppColors.outlineVariant, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.onSurface, size: 22),
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.outlineVariant, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.labelCaps()),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppText.bodyLg().copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

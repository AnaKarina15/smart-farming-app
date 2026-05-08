import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../common/agro_bottom_nav.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/rugged_button.dart';
import 'lote_history_screen.dart';

class TreatmentSuccessScreen extends StatelessWidget {
  final String lote;
  final String metodo;

  const TreatmentSuccessScreen({
    super.key,
    this.lote = 'Lote 1 - Sector Norte',
    this.metodo = 'Control Biológico',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryContainer,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.16),
                    offset: const Offset(0, 8),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.onPrimaryContainer,
                size: 80,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '¡TRATAMIENTO REGISTRADO!',
              textAlign: TextAlign.center,
              style: AppText.h2(color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'La información se guardó en el celular y se sincronizará cuando tengas internet',
                textAlign: TextAlign.center,
                style: AppText.bodyLg(color: AppColors.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 32),

            // Summary card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'RESUMEN DE OPERACIÓN',
                      style: AppText.labelCaps(),
                    ),
                  ),
                  const Divider(
                    color: AppColors.outlineVariant,
                    height: 1,
                    thickness: 1,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _summaryItem(
                          Icons.location_on,
                          'Ubicación',
                          lote,
                          AppColors.primary,
                        ),
                      ),
                      Expanded(
                        child: _summaryItem(
                          Icons.bug_report,
                          'Plaga',
                          'Gusano Cogollero',
                          AppColors.error,
                        ),
                      ),
                      Expanded(
                        child: _summaryItem(
                          Icons.science,
                          'Método Aplicado',
                          metodo,
                          AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            RuggedButton(
              text: 'VER HISTORIAL DEL LOTE',
              icon: Icons.history,
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => LoteHistoryScreen(loteName: lote),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const AgroBottomNav(current: AgroTab.lotes),
    );
  }

  Widget _summaryItem(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label.toUpperCase(),
                  style: AppText.labelCaps(color: color).copyWith(fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppText.bodyMd().copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

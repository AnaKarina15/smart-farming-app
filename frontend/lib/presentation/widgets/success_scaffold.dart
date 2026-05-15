import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/rugged_button.dart';
import '../common/agro_bottom_nav.dart';
import 'offline_banner.dart';

/// Layout reusable para pantallas de éxito (riego, fertilización, siembra…).
class SuccessScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final String location;
  final String detailLabel;
  final String detailValue;
  final IconData detailIcon;
  final String? imageUrl;
  final IconData? fallbackIcon;
  final String primaryButtonText;
  final VoidCallback onPrimaryPressed;

  const SuccessScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.detailLabel,
    required this.detailValue,
    required this.detailIcon,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    this.imageUrl,
    this.fallbackIcon,
  });

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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 448),
                  child: Column(
                    children: [
                      // ── Success Icon ─────────────────────────
                      Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryContainer,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: AppColors.onPrimaryContainer,
                          size: 56,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        title.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: AppText.h2(color: AppColors.primary),
                      ),
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: AppText.bodyMd(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Summary Card ─────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.outlineVariant,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.inventory_2,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'RESUMEN DE REGISTRO',
                                  style: AppText.labelCaps(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _row('Ubicación', location, AppColors.onSurface),
                            const SizedBox(height: 16),
                            const Divider(
                              color: AppColors.outlineVariant,
                              height: 1,
                              thickness: 1,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  detailIcon,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        detailLabel.toUpperCase(),
                                        style: AppText.labelCaps(),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        detailValue,
                                        style: AppText.h3(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Image / fallback ─────────────────────
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 160,
                          child: imageUrl != null
                              ? Image.network(
                                  imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: AppColors.primaryContainer,
                                    child: Icon(
                                      fallbackIcon ?? Icons.eco,
                                      color: AppColors.onPrimaryContainer,
                                      size: 56,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: AppColors.primaryContainer,
                                  child: Icon(
                                    fallbackIcon ?? Icons.eco,
                                    color: AppColors.onPrimaryContainer,
                                    size: 56,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom Actions ──────────────────────────────────
          Container(
            color: AppColors.surfaceContainerLowest,
            padding: const EdgeInsets.all(24),
            child: SafeArea(
              top: false,
              child: RuggedButton(
                text: primaryButtonText,
                onPressed: onPrimaryPressed,
                icon: Icons.history,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AgroBottomNav(current: AgroTab.lotes),
    );
  }

  Widget _row(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppText.labelCaps()),
        const SizedBox(height: 4),
        Text(value, style: AppText.h3(color: color)),
      ],
    );
  }
}

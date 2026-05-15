import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

/// Banner offline AgroField - Estilo de píldora
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Conectar esto al estado real de red (ConnectivityPlus / Backend)
    bool isOffline = true;

    // if (!isOffline) return const SizedBox.shrink();

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.outlineVariant, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 22,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Text(
              'Modo sin conexión',
              style: AppText.bodyMd(
                color: AppColors.onSurfaceVariant,
              ).copyWith(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

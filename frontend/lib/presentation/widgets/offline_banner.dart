import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

enum OfflineBannerStyle { compact, error, primary, surface }

/// Banner offline AgroField - 4 estilos según la pantalla.
class OfflineBanner extends StatelessWidget {
  final OfflineBannerStyle style;
  final String text;
  final String? subtitle;

  const OfflineBanner({
    super.key,
    this.style = OfflineBannerStyle.compact,
    this.text = 'Modo sin conexión',
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case OfflineBannerStyle.compact:
        return _compact();
      case OfflineBannerStyle.error:
        return _error();
      case OfflineBannerStyle.primary:
        return _primary();
      case OfflineBannerStyle.surface:
        return _surface();
    }
  }

  Widget _compact() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.outlineVariant, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 18,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: AppText.bodyMd(
                color: AppColors.onSurfaceVariant,
              ).copyWith(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _error() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: AppColors.error,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, color: AppColors.onError, size: 20),
          const SizedBox(width: 8),
          Text(
            text.toUpperCase(),
            style: AppText.labelCaps(color: AppColors.onError),
          ),
        ],
      ),
    );
  }

  Widget _primary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: AppColors.primary,
      child: Row(
        children: [
          const Icon(Icons.cloud_off, color: AppColors.primaryFixed, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MODO OFFLINE',
                  style: AppText.labelCaps(color: AppColors.onPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle ?? 'Guardando en el celular',
                  style: AppText.bodyMd(
                    color: AppColors.onPrimary,
                  ).copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _surface() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, color: AppColors.outline, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MODO OFFLINE',
                  style: AppText.labelCaps(color: AppColors.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle ?? 'Guardando en el celular',
                  style: AppText.bodyMd(
                    color: AppColors.onSurfaceVariant,
                  ).copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../common/agro_bottom_nav.dart';
import '../common/offline_banner.dart';
import '../widgets/custom_app_bar.dart';

enum SyncStatus { syncing, local, completed }

class LoteHistoryScreen extends StatelessWidget {
  final String loteName;

  const LoteHistoryScreen({super.key, this.loteName = 'Lote 1'});

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
            const OfflineBanner(style: OfflineBannerStyle.error),
            const SizedBox(height: 16),
            Text('Historial - $loteName', style: AppText.h2()),
            const SizedBox(height: 16),
            _activityCard(
              icon: Icons.pest_control,
              iconBg: AppColors.primaryContainer,
              iconFg: AppColors.onPrimaryContainer,
              title: 'Tratamiento Fitosanitario',
              time: 'Hace 2 horas',
              status: SyncStatus.syncing,
            ),
            const SizedBox(height: 12),
            _activityCard(
              icon: Icons.water_drop,
              iconBg: AppColors.secondaryContainer,
              iconFg: AppColors.onSecondaryContainer,
              title: 'Riego (20L)',
              time: 'Ayer',
              status: SyncStatus.local,
            ),
            const SizedBox(height: 12),
            _activityCard(
              icon: Icons.agriculture,
              iconBg: AppColors.tertiaryContainer,
              iconFg: AppColors.onTertiaryContainer,
              title: 'Siembra de Maíz',
              time: 'Hace 3 meses',
              status: SyncStatus.completed,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AgroBottomNav(current: AgroTab.lotes),
    );
  }

  Widget _activityCard({
    required IconData icon,
    required Color iconBg,
    required Color iconFg,
    required String title,
    required String time,
    required SyncStatus status,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.outlineVariant, width: 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconFg, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppText.bodyMd().copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _badge(status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: AppText.bodyMd(
                    color: AppColors.onSurfaceVariant,
                  ).copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(SyncStatus status) {
    late Color bg;
    late Color fg;
    late IconData icon;
    late String label;
    switch (status) {
      case SyncStatus.syncing:
        bg = AppColors.primaryContainer.withValues(alpha: 0.2);
        fg = AppColors.primary;
        icon = Icons.sync;
        label = 'Sincronizando';
        break;
      case SyncStatus.local:
        bg = AppColors.surfaceVariant;
        fg = AppColors.onSurfaceVariant;
        icon = Icons.cloud_off;
        label = 'Local';
        break;
      case SyncStatus.completed:
        bg = AppColors.secondaryContainer.withValues(alpha: 0.5);
        fg = AppColors.secondary;
        icon = Icons.cloud_done;
        label = 'Completado';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label.toUpperCase(),
            style: AppText.labelCaps(color: fg).copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

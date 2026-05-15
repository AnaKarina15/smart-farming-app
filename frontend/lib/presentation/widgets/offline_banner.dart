import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

/// Banner offline AgroField - Estilo de píldora
class OfflineBanner extends StatelessWidget {
  static final ValueNotifier<bool> showGlobal = ValueNotifier(true);

  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: showGlobal,
      builder: (context, show, child) {
        if (!show) return const SizedBox.shrink();

        return StreamBuilder<List<ConnectivityResult>>(
          stream: Connectivity().onConnectivityChanged,
          builder: (context, snapshot) {
            // Asumimos que hay conexión hasta que se compruebe lo contrario
            bool isOffline = false;

            if (snapshot.hasData) {
              final results = snapshot.data!;
              // Estamos offline si el resultado incluye únicamente 'none'
              isOffline = results.contains(ConnectivityResult.none) && results.length == 1;
            }

            if (!isOffline) return const SizedBox.shrink();

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
                      size: 18,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Modo sin conexión',
                      style: AppText.bodyMd(
                        color: AppColors.onSurfaceVariant,
                      ).copyWith(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

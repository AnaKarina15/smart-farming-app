import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/providers/auth_provider.dart';
import '../widgets/custom_app_bar.dart';
import 'welcome_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBack: true, showSettings: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with underline
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CONFIGURACIÓN',
                  style: AppText.labelCaps(color: AppColors.onSurface)
                      .copyWith(fontSize: 14, letterSpacing: 1.2),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 150,
                  height: 2,
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Card 1: Network Status
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                border: Border.all(color: AppColors.outlineVariant, width: 1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.wifi_off,
                          color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'ESTADO DE RED: OFFLINE',
                        style: AppText.labelCaps(color: AppColors.onSurface),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(color: AppColors.outlineVariant, height: 1),
                  ),
                  Text(
                    'Última sincronización: Hoy 08:00 AM',
                    style: AppText.bodyMd(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.sync,
                          color: AppColors.onPrimary, size: 20),
                      label: Text(
                        'SINCRONIZAR DATOS AHORA',
                        style: AppText.labelCaps(color: AppColors.onPrimary),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Settings options
            _SettingsTile(
              icon: Icons.notifications_none,
              title: 'NOTIFICACIONES Y ALERTAS',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _SettingsTile(
              icon: Icons.text_fields,
              title: 'TAMAÑO DE LETRA',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _SettingsTile(
              icon: Icons.shield_outlined,
              title: 'TÉRMINOS Y PRIVACIDAD',
              onTap: () {},
            ),
            const SizedBox(height: 48),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        backgroundColor: AppColors.surfaceContainerHigh,
                        title: Text(
                          'Cerrar Sesión',
                          style: AppText.h3(color: AppColors.onSurface),
                        ),
                        content: Text(
                          '¿Estás seguro de que deseas salir de tu cuenta?',
                          style:
                              AppText.bodyMd(color: AppColors.onSurfaceVariant),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: Text(
                              'CANCELAR',
                              style:
                                  AppText.labelCaps(color: AppColors.primary),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(dialogContext);
                              await context.read<AuthProvider>().logout();
                              if (!context.mounted) return;
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const WelcomeScreen()),
                                (_) => false,
                              );
                            },
                            child: Text(
                              'SALIR',
                              style: AppText.labelCaps(color: AppColors.error),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: Text(
                  'CERRAR SESIÓN',
                  style: AppText.labelCapsLg(color: AppColors.error),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.errorContainer,
                  shape: const StadiumBorder(),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          border: Border.all(color: AppColors.outlineVariant, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppText.labelCaps(color: AppColors.onSurface)
                    .copyWith(fontSize: 13, height: 1.4),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

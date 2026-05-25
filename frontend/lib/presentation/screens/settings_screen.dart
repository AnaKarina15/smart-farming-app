import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/lotes_provider.dart';
import '../../data/services/sync_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/offline_banner.dart';
import 'welcome_screen.dart';
import 'global_history_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _sincronizando = false;
  String? _mensajeSync;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OfflineBanner.showGlobal.value = false;
    });
  }

  @override
  void dispose() {
    OfflineBanner.showGlobal.value = true;
    super.dispose();
  }

  Future<void> _sincronizar() async {
    setState(() {
      _sincronizando = true;
      _mensajeSync = null;
    });

    final syncService = context.read<SyncService>();
    final lotesProvider = context.read<LotesProvider>();
    final exito = await syncService.syncNow(lotesProvider: lotesProvider);

    if (!mounted) return;
    final sigueOnline = lotesProvider.isOnline;
    setState(() {
      _sincronizando = false;
      _mensajeSync = exito
          ? '✓ Sincronización exitosa'
          : sigueOnline
              ? '✗ No se pudieron enviar todos los pendientes. Inténtalo de nuevo.'
              : '✗ Sin conexión. Los datos locales están seguros.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final lotesProvider = context.watch<LotesProvider>();
    final pendientes = lotesProvider.pendingSyncCount;
    final isOnline = lotesProvider.isOnline;
    final lastSync = lotesProvider.lastSync;
    final syncExitosa = _mensajeSync?.startsWith('✓') ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBack: true, showSettings: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CONFIGURACIÓN',
                  style: AppText.labelCaps(color: AppColors.onSurface)
                      .copyWith(fontSize: 14, letterSpacing: 1.2),
                ),
                const SizedBox(height: 5),
                Container(
                  width: 150,
                  height: 2,
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Card: Estado de Red
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
                      Icon(
                        isOnline ? Icons.wifi : Icons.wifi_off,
                        color: isOnline ? AppColors.primary : AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isOnline
                            ? 'ESTADO DE RED: ONLINE'
                            : 'ESTADO DE RED: OFFLINE',
                        style: AppText.labelCaps(color: AppColors.onSurface),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(color: AppColors.outlineVariant, height: 1),
                  ),
                  // Última sincronización
                  Text(
                    lastSync != null
                        ? 'Última sincronización: ${_formatTime(lastSync)}'
                        : 'Sin sincronización reciente',
                    style: AppText.bodyMd(color: AppColors.onSurfaceVariant),
                  ),
                  // Pendientes
                  if (!syncExitosa && pendientes > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.pending_actions,
                            size: 16, color: AppColors.error),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '$pendientes registro(s) pendientes de enviar',
                            style: AppText.bodyMd(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ] else if (!syncExitosa) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Todo sincronizado',
                          style: AppText.bodyMd(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                  // Mensaje de resultado
                  if (_mensajeSync != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _mensajeSync!.startsWith('✓')
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _mensajeSync!,
                        style: AppText.bodyMd(
                          color: _mensajeSync!.startsWith('✓')
                              ? AppColors.primary
                              : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _sincronizando ? null : _sincronizar,
                      icon: _sincronizando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onPrimary,
                              ),
                            )
                          : const Icon(Icons.sync,
                              color: AppColors.onPrimary, size: 20),
                      label: Text(
                        _sincronizando
                            ? 'SINCRONIZANDO...'
                            : 'SINCRONIZAR DATOS AHORA',
                        style: AppText.labelCaps(color: AppColors.onPrimary),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor:
                            AppColors.primary.withValues(alpha: 0.6),
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Opciones de configuración
            _SettingsTile(
              icon: Icons.history,
              title: 'HISTORIAL GLOBAL',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const GlobalHistoryScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
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

            // Botón Cerrar Sesión
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

  String _formatTime(DateTime dt) {
    final hora = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final dia = dt.day.toString().padLeft(2, '0');
    final mes = dt.month.toString().padLeft(2, '0');
    return '$dia/$mes ${dt.year} $hora:$min';
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/network/api_endpoints.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/profile_image_provider.dart';
import '../common/agro_bottom_nav.dart';
import '../widgets/custom_app_bar.dart';
import 'home_screen.dart';
import 'welcome_screen.dart';
import 'map_onboarding_screen.dart';
import 'tasks_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifications = true;

  void _showActionDialog(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('La función "$action" estará disponible pronto'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final profileImage = context.watch<ProfileImageProvider>();
    final name = user?.nombreCompleto ?? 'Usuario';
    final email = user?.email ?? 'usuario@correo.com';
    final role = user?.roleLegible ?? 'Usuario';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            GestureDetector(
              onTap: () => profileImage.pickImage(context),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryContainer,
                      border: Border.all(color: AppColors.surface, width: 4),
                      image: profileImage.imageFile != null
                          ? DecorationImage(
                              image: FileImage(profileImage.imageFile!),
                              fit: BoxFit.cover,
                            )
                          : user?.fotoPerfilUrl != null && user!.fotoPerfilUrl!.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(
                                    user.fotoPerfilUrl!.startsWith('http')
                                        ? user.fotoPerfilUrl!
                                        : user.fotoPerfilUrl!.startsWith('/public')
                                            ? '${ApiEndpoints.baseUrl.replaceAll('/api/v1', '')}${user.fotoPerfilUrl}'
                                            : '${ApiEndpoints.baseUrl.replaceAll('/api/v1', '')}/public${user.fotoPerfilUrl}',
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : const DecorationImage(
                                  image: NetworkImage(
                                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCTJGCEi16aUTDw3teJYYIG4o1sxhol2vxdeCDJd_xTonNe12Xf1kwbshQ25TtdlrWtlRcQjf1jwF9dTVqHu1tyjOt6u5S7TfEBN9pj9aRcwZZlN1gyXHmJZdWvkNY4gZj2fKmnxNlRKM9M2x--gjPXGDZOM4ROQ29HS6R_mNK7AM-xsv_0nRQcjbocYWRLFNyyNxlBsP3KuhDLKcX8mj7LaEVo1rnPVG4XYxIHCN3svc1Hz144HJM-1Nl4V5xfFKi41FQgiNCpX4p3',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          offset: const Offset(0, 4),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child: const Icon(
                      Icons.photo_camera,
                      color: AppColors.onPrimary,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(name, style: AppText.h2()),
            const SizedBox(height: 4),
            Text(role, style: AppText.bodyLg(color: AppColors.outline)),
            const SizedBox(height: 32),

            // Información Personal
            _sectionCard(
              icon: Icons.person,
              title: 'Información Personal',
              children: [
                _field('NOMBRE COMPLETO', name),
                const SizedBox(height: 16),
                _field(
                  'CORREO ELECTRÓNICO',
                  email,
                  actionText: 'Cambiar',
                  onActionTap: () => _showActionDialog('Cambiar correo'),
                ),
                const SizedBox(height: 16),
                _field(
                  'TELÉFONO',
                  user?.telefono ?? '+57 300 0000000',
                  actionText: 'Cambiar',
                  onActionTap: () => _showActionDialog('Cambiar teléfono'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Seguridad
            _sectionCard(
              icon: Icons.lock,
              title: 'Seguridad',
              children: [
                _field(
                  'CONTRASEÑA',
                  '••••••••',
                  obscure: true,
                  actionText: 'Cambiar',
                  onActionTap: () => _showActionDialog('Cambiar contraseña'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Preferencias
            _sectionCard(
              icon: Icons.tune,
              title: 'Preferencias',
              children: [
                _switchRow(
                  'Notificaciones Push',
                  _notifications,
                  (v) => setState(() => _notifications = v),
                ),
              ],
            ),
            const SizedBox(height: 15),
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
      bottomNavigationBar: user?.role == 'administrador'
          ? null
          : AgroBottomNav(
              current: AgroTab.perfil,
              onTap: (tab) {
                if (tab == AgroTab.home) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()));
                } else if (tab == AgroTab.lotes) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MapOnboardingScreen()));
                } else if (tab == AgroTab.tareas) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const TasksScreen()));
                }
              },
            ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppText.h3(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _field(
    String label,
    String value, {
    bool obscure = false,
    String? hint,
    String? actionText,
    VoidCallback? onActionTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppText.labelCaps()),
            if (actionText != null && onActionTap != null)
              GestureDetector(
                onTap: onActionTap,
                child: Text(
                  actionText,
                  style: AppText.labelCaps(color: AppColors.primary).copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.outlineVariant, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            obscure && value.isNotEmpty
                ? '••••••••'
                : (value.isEmpty ? (hint ?? '') : value),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.bodyMd(
              color: value.isEmpty ? AppColors.outline : AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _switchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppText.bodyMd())),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.onPrimary,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

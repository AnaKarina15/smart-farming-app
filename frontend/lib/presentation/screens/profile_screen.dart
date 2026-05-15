import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/providers/auth_provider.dart';
import '../common/agro_bottom_nav.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/rugged_button.dart';
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
  bool _offlineSync = true;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final name = user?.nombreCompleto ?? 'Usuario';
    final email = user?.email ?? 'usuario@correo.com';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryContainer,
                    border: Border.all(color: AppColors.surface, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        offset: const Offset(0, 4),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.onPrimaryContainer,
                    size: 64,
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
            const SizedBox(height: 16),
            Text(name, style: AppText.h2()),
            const SizedBox(height: 4),
            Text(email, style: AppText.bodyLg(color: AppColors.outline)),
            const SizedBox(height: 32),

            // Información Personal
            _sectionCard(
              icon: Icons.person,
              title: 'Información Personal',
              children: [
                _field('NOMBRE COMPLETO', name),
                const SizedBox(height: 16),
                _field('CORREO ELECTRÓNICO', email),
                const SizedBox(height: 16),
                _field('TELÉFONO', user?.telefono ?? '+57 300 0000000'),
              ],
            ),
            const SizedBox(height: 24),

            // Seguridad
            _sectionCard(
              icon: Icons.lock,
              title: 'Seguridad',
              children: [
                _field('CONTRASEÑA ACTUAL', '••••••••', obscure: true),
                const SizedBox(height: 16),
                _field(
                  'NUEVA CONTRASEÑA',
                  '',
                  obscure: true,
                  hint: 'Ingresar nueva contraseña',
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
                const Divider(
                  color: AppColors.outlineVariant,
                  height: 1,
                  thickness: 1,
                ),
                _switchRow(
                  'Sincronización Offline',
                  _offlineSync,
                  (v) => setState(() => _offlineSync = v),
                ),
              ],
            ),
            const SizedBox(height: 32),
            RuggedButton(
              text: 'GUARDAR CAMBIOS',
              icon: Icons.save,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Cambios guardados',
                      style: AppText.bodyMd(color: AppColors.onPrimary),
                    ),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await context.read<AuthProvider>().logout();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    (_) => false,
                  );
                },
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: Text(
                  'CERRAR SESIÓN',
                  style: AppText.labelCapsLg(color: AppColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error, width: 1.5),
                  shape: const StadiumBorder(),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: AgroBottomNav(
        current: AgroTab.perfil,
        onTap: (tab) {
          if (tab == AgroTab.home) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          } else if (tab == AgroTab.lotes) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MapOnboardingScreen()));
          } else if (tab == AgroTab.tareas) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TasksScreen()));
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.labelCaps()),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.outlineVariant, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            obscure && value.isNotEmpty
                ? '••••••••'
                : (value.isEmpty ? (hint ?? '') : value),
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
            activeColor: AppColors.onPrimary,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

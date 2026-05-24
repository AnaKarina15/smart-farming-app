import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/providers/tareas_provider.dart';
import '../../data/providers/lotes_provider.dart';
import '../screens/home_screen.dart';
import '../screens/map_onboarding_screen.dart';
import '../screens/lotes_list_screen.dart';
import '../screens/tasks_screen.dart';
import '../screens/profile_screen.dart';

enum AgroTab { home, lotes, tareas, perfil }

/// BottomNavBar AgroField - 4 tabs con pill indicator en el activo.
class AgroBottomNav extends StatelessWidget {
  final AgroTab current;
  final bool isRoot;
  final ValueChanged<AgroTab>? onTap;

  const AgroBottomNav({
    super.key,
    required this.current,
    this.isRoot = false,
    this.onTap,
  });

  static void navigateToTab(BuildContext context, AgroTab tab) {
    switch (tab) {
      case AgroTab.home:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        break;
      case AgroTab.lotes:
        final hasLotes = context.read<LotesProvider>().hasLotes;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => hasLotes ? const LotesListScreen() : const MapOnboardingScreen(),
          ),
        );
        break;
      case AgroTab.tareas:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TasksScreen()),
        );
        break;
      case AgroTab.perfil:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    int pendingTasks = 0;
    try {
      final provider = context.watch<TareasProvider>();
      pendingTasks = provider.tareas.length;
    } catch (_) {
      // Evita excepciones si el provider no estuviera en el árbol de este contexto específico
    }

    void handleTap(AgroTab tab) {
      if (tab == current && isRoot) return;
      if (onTap != null) {
        onTap!(tab);
      } else {
        navigateToTab(context, tab);
      }
    }

    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              iconActive: Icons.home,
              label: 'Inicio',
              active: current == AgroTab.home,
              onTap: () => handleTap(AgroTab.home),
            ),
            _NavItem(
              icon: Icons.map_outlined,
              iconActive: Icons.map,
              label: 'Lotes',
              active: current == AgroTab.lotes,
              onTap: () => handleTap(AgroTab.lotes),
            ),
            _NavItem(
              icon: Icons.assignment_outlined,
              iconActive: Icons.assignment,
              label: 'Tareas',
              active: current == AgroTab.tareas,
              badgeCount: pendingTasks,
              onTap: () => handleTap(AgroTab.tareas),
            ),
            _NavItem(
              icon: Icons.person_outline,
              iconActive: Icons.person,
              label: 'Perfil',
              active: current == AgroTab.perfil,
              onTap: () => handleTap(AgroTab.perfil),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData iconActive;
  final String label;
  final bool active;
  final int? badgeCount;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.iconActive,
    required this.label,
    required this.active,
    this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active
        ? AppColors.onSecondaryContainer
        : AppColors.onSurfaceVariant;
    final int count = badgeCount ?? 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 32,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.secondaryContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Icon(active ? iconActive : icon, color: color, size: 22),
                  if (count > 0)
                    Positioned(
                      top: -2,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryFixed,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: AppText.labelCaps(color: color).copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

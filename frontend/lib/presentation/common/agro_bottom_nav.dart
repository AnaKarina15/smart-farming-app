import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

enum AgroTab { home, lotes, tareas, perfil }

/// BottomNavBar AgroField - 4 tabs con pill indicator en el activo.
class AgroBottomNav extends StatelessWidget {
  final AgroTab current;
  final ValueChanged<AgroTab>? onTap;

  const AgroBottomNav({super.key, required this.current, this.onTap});

  @override
  Widget build(BuildContext context) {
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
              onTap: () => onTap?.call(AgroTab.home),
            ),
            _NavItem(
              icon: Icons.map_outlined,
              iconActive: Icons.map,
              label: 'Lotes',
              active: current == AgroTab.lotes,
              onTap: () => onTap?.call(AgroTab.lotes),
            ),
            _NavItem(
              icon: Icons.assignment_outlined,
              iconActive: Icons.assignment,
              label: 'Tareas',
              active: current == AgroTab.tareas,
              onTap: () => onTap?.call(AgroTab.tareas),
            ),
            _NavItem(
              icon: Icons.person_outline,
              iconActive: Icons.person,
              label: 'Perfil',
              active: current == AgroTab.perfil,
              onTap: () => onTap?.call(AgroTab.perfil),
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
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.iconActive,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active
        ? AppColors.onSecondaryContainer
        : AppColors.onSurfaceVariant;

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
              child: Icon(active ? iconActive : icon, color: color, size: 22),
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

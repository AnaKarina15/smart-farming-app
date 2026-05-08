import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

/// AppBar AgroField - 80px alto, branding "AGROFIELD", avatar derecho.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showMenu;
  final bool showBack;
  final bool showAvatar;
  final VoidCallback? onMenuTap;
  final VoidCallback? onBackTap;
  final VoidCallback? onAvatarTap;

  const CustomAppBar({
    super.key,
    this.title = 'AGROFIELD',
    this.showMenu = true,
    this.showBack = false,
    this.showAvatar = true,
    this.onMenuTap,
    this.onBackTap,
    this.onAvatarTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (showBack)
                    IconButton(
                      onPressed: onBackTap ?? () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.onSurface,
                        size: 28,
                      ),
                      splashRadius: 24,
                    )
                  else if (showMenu)
                    IconButton(
                      onPressed: onMenuTap,
                      icon: const Icon(
                        Icons.menu,
                        color: AppColors.onSurface,
                        size: 28,
                      ),
                      splashRadius: 24,
                    ),
                  if (showBack || showMenu) const SizedBox(width: 8),
                  Text(
                    title,
                    style: AppText.h3(
                      color: AppColors.primary,
                    ).copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              if (showAvatar)
                GestureDetector(
                  onTap: onAvatarTap,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceContainerHigh,
                      border: Border.all(
                        color: AppColors.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.onSurfaceVariant,
                      size: 22,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

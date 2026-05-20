import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/providers/profile_image_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../core/network/api_endpoints.dart';
import '../screens/settings_screen.dart';

/// AppBar AgroField - 80px alto, branding "AGROFIELD", avatar derecho.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final bool showAvatar;
  final bool showSettings;
  final VoidCallback? onBackTap;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onSettingsTap;

  const CustomAppBar({
    super.key,
    this.title = 'AgroField',
    this.showBack = false,
    this.showAvatar = true,
    this.showSettings = true,
    this.onBackTap,
    this.onAvatarTap,
    this.onSettingsTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    final profileImage = context.watch<ProfileImageProvider>();
    final user = context.watch<AuthProvider>().currentUser;

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
              // Left: Back button or Avatar
              if (showBack)
                IconButton(
                  onPressed: onBackTap ?? () => Navigator.maybePop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  splashRadius: 24,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              else if (showAvatar)
                GestureDetector(
                  onTap: onAvatarTap ?? () => profileImage.pickImage(context),
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceContainerHigh,
                      border: Border.all(
                        color: AppColors.outlineVariant,
                        width: 1,
                      ),
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
                                        : '${ApiEndpoints.baseUrl.replaceAll('/api/v1', '')}${user.fotoPerfilUrl}',
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : const DecorationImage(
                                  image: NetworkImage(
                                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCTJGCEi16aUTDw3teJYYIG4o1sxhol2vxdeCDJd_xTonNe12Xf1kwbshQ25TtdlrWtlRcQjf1jwF9dTVqHu1tyjOt6u5S7TfEBN9pj9aRcwZZlN1gyXHmJZdWvkNY4gZj2fKmnxNlRKM9M2x--gjPXGDZOM4ROQ29HS6R_mNK7AM-xsv_0nRQcjbocYWRLFNyyNxlBsP3KuhDLKcX8mj7LaEVo1rnPVG4XYxIHCN3svc1Hz144HJM-1Nl4V5xfFKi41FQgiNCpX4p3',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                    ),
                  ),
                )
              else
                const SizedBox(width: 48),

              // Center: Title
              Text(
                title,
                style: AppText.h2(
                  color: AppColors.primary,
                ).copyWith(fontWeight: FontWeight.w800),
              ),

              // Right: Settings or Spacer
              if (showSettings)
                IconButton(
                  onPressed: onSettingsTap ??
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsScreen()),
                        );
                      },
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: AppColors.primary,
                    size: 32,
                  ),
                  splashRadius: 24,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              else
                const SizedBox(width: 32),
            ],
          ),
        ),
      ),
    );
  }
}

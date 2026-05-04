import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 2.0); // +2 for the bottom border

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppColors.primary, size: 28),
        onPressed: () {
          // TODO: Abrir menú lateral (Drawer) si tienes uno
        },
      ),
      title: Text(
        'Smart Farming',
        style: GoogleFonts.lexend(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        // 1. Icono de Notificaciones con Badge
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.primary, size: 28),
              onPressed: () {
                // TODO: Navegar a pantalla de notificaciones
              },
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Color(0xFFBA1A1A), // Color de error/alerta
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 10,
                  minHeight: 10,
                ),
              ),
            )
          ],
        ),
        // 2. Foto de Perfil
        Padding(
          padding: const EdgeInsets.only(right: 16.0, left: 8.0),
          child: Center(
            child: Container(
              width: 36, // Un poco más pequeño que en tu código original para que quepa bien
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
                image: const DecorationImage(
                  image: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDSN3PC-r68fjYmxenSJhpeON5kYHq_FqUZAujP2XfNu3JJHwHWSgnCN9Mm79mUT-e6OebbOBqgIc99B8tup3iS0PJnmytuyZZktqjXVRIZLYy-ESL4kwGEoJAe-zbuBYr_xAOBApeI9dr99zxBRrgqOuruL2tbOPHRDxigBfNC744A0tG932QLdld5h7USNgZhYJ84JYhao2to2xVmuj7iaXDmBiqsY2uFfKiVOKnGAYGhCMl6sOASdn-0vA8-ceZz9ucme_xBy_B3'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2.0),
        child: Container(color: const Color(0xFFE4E4E7), height: 2.0),
      ),
    );
  }
}
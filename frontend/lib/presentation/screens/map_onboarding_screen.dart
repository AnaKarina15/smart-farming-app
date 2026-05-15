import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../common/agro_bottom_nav.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/rugged_button.dart';
import 'home_screen.dart';
import 'register_lote_screen.dart';
import 'tasks_screen.dart';
import 'profile_screen.dart';

class MapOnboardingScreen extends StatelessWidget {
  const MapOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                // Illustration
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: AppColors.primary.withValues(alpha: 0.05),
                  ),
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.eco,
                        size: 100,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  '¡Comencemos a mapear tu cultivo!',
                  textAlign: TextAlign.center,
                  style: AppText.h2(),
                ),
                const SizedBox(height: 24),
                Text(
                  'Para recibir recomendaciones de riego y alertas de plagas, necesitamos saber dónde está tu terreno.',
                  textAlign: TextAlign.center,
                  style: AppText.bodyMd(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 32),
                RuggedButton(
                  text: 'REGISTRAR MI PRIMER LOTE',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterLoteScreen(),
                    ),
                  ),
                  icon: Icons.add,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  ),
                  child: Text(
                    'Explorar la app y registrar más tarde',
                    textAlign: TextAlign.center,
                    style: AppText.bodyMd(
                      color: AppColors.onSurfaceVariant,
                    ).copyWith(decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AgroBottomNav(
        current: AgroTab.lotes,
        onTap: (tab) {
          if (tab == AgroTab.home) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          } else if (tab == AgroTab.tareas) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TasksScreen()));
          } else if (tab == AgroTab.perfil) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
          }
        },
      ),
    );
  }
}

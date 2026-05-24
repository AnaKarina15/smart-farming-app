import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../common/agro_bottom_nav.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/rugged_button.dart';
import 'home_screen.dart';
import 'register_lote_screen.dart';
import 'tasks_screen.dart';
import 'profile_screen.dart';
import 'lotes_list_screen.dart';
import 'package:provider/provider.dart';
import '../../data/providers/lotes_provider.dart';

import '../../core/storage/database_helper.dart';

class MapOnboardingScreen extends StatefulWidget {
  const MapOnboardingScreen({super.key});

  @override
  State<MapOnboardingScreen> createState() => _MapOnboardingScreenState();
}

class _MapOnboardingScreenState extends State<MapOnboardingScreen> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkLotes();
  }

  Future<void> _checkLotes() async {
    // Usamos el LotesProvider para cargar e intentar sincronizar primero
    final lotesProvider = context.read<LotesProvider>();
    if (lotesProvider.lotes.isEmpty) {
      await lotesProvider.init();
    }
    
    final hasLotesReal = lotesProvider.lotes.isNotEmpty;

    if (hasLotesReal) {
      // Actualizamos SharedPreferences para mantener consistencia
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_lotes', true);
    }

    if (!mounted) return;

    if (hasLotesReal) {
      // Already has registered lotes → go directly to list
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LotesListScreen()),
      );
    } else {
      setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

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
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterLoteScreen(),
                      ),
                    );
                    _checkLotes();
                  },
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
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const HomeScreen()));
          } else if (tab == AgroTab.tareas) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const TasksScreen()));
          } else if (tab == AgroTab.perfil) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()));
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../common/agro_bottom_nav.dart';
import '../widgets/offline_banner.dart';
import '../widgets/custom_app_bar.dart';
import 'fertilization_screen.dart';
import 'irrigation_screen.dart';
import 'lotes_map_screen.dart';
import 'phytosanitary_screen.dart';
import 'profile_screen.dart';
import 'soil_humidity_screen.dart';
import 'sowing_screen.dart';
import 'tasks_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const OfflineBanner(),
            const SizedBox(height: 24),

            // ── Hero card ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    offset: const Offset(0, 4),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryFixed,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'RESUMEN GENERAL',
                                style: AppText.labelCaps(
                                  color: AppColors.onPrimaryFixed,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text('Campo Norte, Lote B', style: AppText.h2()),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Humedad Suelo',
                            style: AppText.bodyMd(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '68%',
                            style: AppText.h1(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Glass cards
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _glassCard(Icons.thermostat, 'Temperatura', '24°C'),
                        const SizedBox(width: 12),
                        _glassCard(Icons.water_drop, 'Prob. Lluvia', '15%'),
                        const SizedBox(width: 12),
                        _glassCard(Icons.air, 'Viento', '12 km/h'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Quick Actions ─────────────────────────────────
            Text('Acciones Rápidas'),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _action(
                    context,
                    Icons.water_drop,
                    'Riego',
                    const IrrigationScreen(),
                  ),
                  const SizedBox(width: 16),
                  _action(
                    context,
                    Icons.eco,
                    'Fertilización',
                    const FertilizationScreen(),
                  ),
                  const SizedBox(width: 16),
                  _action(
                    context,
                    Icons.grass,
                    'Siembra',
                    const SowingScreen(),
                  ),
                  const SizedBox(width: 16),
                  _action(
                    context,
                    Icons.sensors,
                    'Humedad',
                    const SoilHumidityScreen(),
                  ),
                  const SizedBox(width: 16),
                  _action(
                    context,
                    Icons.bug_report,
                    'Manejo Fito',
                    const PhytosanitaryScreen(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: AgroBottomNav(
        current: AgroTab.home,
        onTap: (tab) {
          switch (tab) {
            case AgroTab.lotes:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LotesMapScreen()),
              );
              break;
            case AgroTab.tareas:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TasksScreen()),
              );
              break;
            case AgroTab.perfil:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
              break;
            case AgroTab.home:
              break;
          }
        },
      ),
    );
  }

  Widget _glassCard(IconData icon, String label, String value) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppText.bodyMd(
              color: AppColors.onSurfaceVariant,
            ).copyWith(fontSize: 14),
          ),
          Text(value, style: AppText.h3()),
        ],
      ),
    );
  }

  Widget _action(
    BuildContext context,
    IconData icon,
    String label,
    Widget destination,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => destination),
      ),
      child: Container(
        width: 130,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              offset: const Offset(0, 4),
              blurRadius: 16,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryFixed,
              ),
              child: Icon(icon, size: 28, color: AppColors.onPrimaryFixed),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppText.bodyMd().copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

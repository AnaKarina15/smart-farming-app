import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../common/agro_bottom_nav.dart';
import '../widgets/offline_banner.dart';
import '../widgets/custom_app_bar.dart';
import 'fertilization_screen.dart';
import 'irrigation_screen.dart';
import 'phytosanitary_screen.dart';
import 'profile_screen.dart';
import 'soil_humidity_screen.dart';
import 'sowing_screen.dart';
import 'tasks_screen.dart';
import 'map_onboarding_screen.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/services/weather_service.dart';

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
                image: DecorationImage(
                  image: const NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDBmDkKnSQCK70HtUXXKIcLw8198ttM7upvlEajcpi_bPTJDL9N29_zkawXK2DP1jLHE1ADWglpUKqx9kynA2B9NjAQMRtCui9IYwNKOE6Nfb04yLVg2GtMMu3wLLWVJbf9am6zqumPhaWEUZToOXKCG69z4dyI7KH4kOl2YyRn9rcnq955Jx2wNRPxTuwaN8_pWeEbxIxhLisYEsV5b5c91affAz284Ob9NnMDTS2tH5xaWS9E_yQSBzZeqG_II1gEsPAtQM_Em9gu'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.white.withValues(alpha: 0.8),
                    BlendMode.lighten,
                  ),
                ),
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
                                horizontal: 10,
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
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                          child: const _WeatherGlassCard()),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _glassCard(
                              Icons.water_drop, 'Prob. Lluvia', '15%')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Quick Actions ─────────────────────────────────
            Text('Acciones Rápidas', style: AppText.h3()),
            const SizedBox(height: 15),
            const _QuickActionsCarousel(),
            const SizedBox(height: 26),
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
                MaterialPageRoute(builder: (_) => const MapOnboardingScreen()),
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
}

class _QuickActionsCarousel extends StatefulWidget {
  const _QuickActionsCarousel();

  @override
  State<_QuickActionsCarousel> createState() => _QuickActionsCarouselState();
}

class _QuickActionsCarouselState extends State<_QuickActionsCarousel> {
  final ScrollController _scrollController = ScrollController();

  void _scrollLeft() {
    _scrollController.animateTo(
      (_scrollController.offset - 292)
          .clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      (_scrollController.offset + 292)
          .clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              const SizedBox(width: 25),
              _action(
                context,
                Icons.water_drop,
                'Riego',
                const IrrigationScreen(currentTab: AgroTab.home),
              ),
              const SizedBox(width: 25),
              _action(
                context,
                Icons.eco,
                'Fertilización',
                const FertilizationScreen(currentTab: AgroTab.home),
              ),
              const SizedBox(width: 20),
              _action(
                context,
                Icons.grass,
                'Siembra',
                const SowingScreen(currentTab: AgroTab.home),
              ),
              const SizedBox(width: 25),
              _action(
                context,
                Icons.sensors,
                'Humedad',
                const SoilHumidityScreen(currentTab: AgroTab.home),
              ),
              const SizedBox(width: 25),
              _action(
                context,
                Icons.bug_report,
                'Fitocontrol',
                const PhytosanitaryScreen(currentTab: AgroTab.home),
              ),
              const SizedBox(width: 25),
            ],
          ),
        ),
        Positioned(
          left: -12,
          child: _arrowButton(Icons.chevron_left, _scrollLeft),
        ),
        Positioned(
          right: -12,
          child: _arrowButton(Icons.chevron_right, _scrollRight),
        ),
      ],
    );
  }

  Widget _arrowButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
          border: Border.all(color: AppColors.outlineVariant, width: 0.5),
        ),
        child: Icon(icon, color: AppColors.primary),
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

class _WeatherGlassCard extends StatefulWidget {
  const _WeatherGlassCard();

  @override
  State<_WeatherGlassCard> createState() => _WeatherGlassCardState();
}

class _WeatherGlassCardState extends State<_WeatherGlassCard> {
  final WeatherService _weatherService = WeatherService();
  String _temperature = 'Calculando...';

  @override
  void initState() {
    super.initState();
    _fetchTemperature();
  }

  Future<void> _fetchTemperature() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _temperature = '--°C');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _temperature = '--°C');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _temperature = '--°C');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final temp = await _weatherService.getCurrentTemperature(
        position.latitude,
        position.longitude,
      );
      
      if (mounted) {
        setState(() => _temperature = temp);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _temperature = '--°C');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          const Icon(Icons.thermostat, color: AppColors.primary, size: 22),
          const SizedBox(height: 8),
          Text(
            'Temperatura',
            style: AppText.bodyMd(
              color: AppColors.onSurfaceVariant,
            ).copyWith(fontSize: 14),
          ),
          _temperature == 'Calculando...' 
              ? const SizedBox(
                  height: 24, 
                  width: 24, 
                  child: CircularProgressIndicator(strokeWidth: 2)
                ) 
              : Text(_temperature, style: AppText.h3()),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/providers/lotes_provider.dart';
import '../common/agro_bottom_nav.dart';
import '../widgets/custom_app_bar.dart';
import 'fertilization_screen.dart';
import 'irrigation_screen.dart';
import 'phytosanitary_screen.dart';
import 'soil_humidity_screen.dart';
import 'sowing_screen.dart';
import 'terrain_status_screen.dart';
import '../../data/services/sync_service.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/storage/database_helper.dart';
import 'package:geocoding/geocoding.dart';
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
            // ── Hero card ─────────────────────────────────────
            const _HeroSection(),
            const SizedBox(height: 24),

            // ── Quick Actions ─────────────────────────────────
            Text('Acciones Rápidas', style: AppText.h3()),
            const SizedBox(height: 15),
            const _QuickActionsCarousel(),
            const SizedBox(height: 26),
          ],
        ),
      ),
      bottomNavigationBar: const AgroBottomNav(
        current: AgroTab.home,
        isRoot: true,
      ),
    );
  }
}

class _HeroSection extends StatefulWidget {
  const _HeroSection();

  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection> {
  String _loteName = 'Cargando...';
  String? _loteLocation;
  String _soilStatus = '--%';
  String _temperature = '...';
  String _rainProb = '...';
  bool _isWeatherLoading = true;

  bool _isOnline = true;
  DateTime _lastSync = DateTime.now();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final WeatherService _weatherService = WeatherService();

  @override
  void initState() {
    super.initState();
    // Inicializar LotesProvider (carga SQLite + sincroniza backend)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LotesProvider>().init();
    });
    _fetchData();
    _checkConnectivity();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      if (mounted) {
        setState(() {
          _isOnline = !result.contains(ConnectivityResult.none);
          if (_isOnline) {
            _lastSync = DateTime.now();
            context
                .read<SyncService>()
                .syncNow(lotesProvider: context.read<LotesProvider>());
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() {
        _isOnline = !result.contains(ConnectivityResult.none);
        if (_isOnline) {
          _lastSync = DateTime.now();
          context
              .read<SyncService>()
              .syncNow(lotesProvider: context.read<LotesProvider>());
        }
      });
    }
  }

  Future<void> _fetchData() async {
    try {
      final lotes =
          await DatabaseHelper.instance.queryAllRows(DatabaseHelper.tableLotes);
      final latestLote = _latestRegisteredLote(lotes);

      if (latestLote == null) {
        if (mounted) {
          setState(() {
            _loteName = 'Sin lotes registrados';
            _loteLocation = 'Registra un lote para ver su clima';
            _temperature = '--°C';
            _rainProb = '--%';
            _isWeatherLoading = false;
          });
        }
        await _fetchSoilStatus();
        return;
      }

      final lat = _toDouble(latestLote['latitud']);
      final lon = _toDouble(latestLote['longitud']);
      final loteName = (latestLote['nombre'] as String?) ?? 'Último lote';

      String locationLabel = 'Sin coordenadas registradas';
      if (lat != null && lon != null) {
        locationLabel = await _locationLabel(lat, lon);
      }

      if (mounted) {
        setState(() {
          _loteName = loteName;
          _loteLocation = locationLabel;
        });
      }

      if (lat != null && lon != null) {
        await _fetchWeatherForLote(lat, lon);
      } else if (mounted) {
        setState(() {
          _temperature = '--°C';
          _rainProb = '--%';
          _isWeatherLoading = false;
        });
      }

      await _fetchSoilStatus();
    } catch (e) {
      if (mounted) {
        setState(() {
          _soilStatus = '68%';
          _temperature = '--°C';
          _rainProb = '--%';
          _isWeatherLoading = false;
        });
      }
    }
  }

  Map<String, dynamic>? _latestRegisteredLote(
      List<Map<String, dynamic>> lotes) {
    if (lotes.isEmpty) return null;

    final sorted = List<Map<String, dynamic>>.from(lotes);
    sorted.sort((a, b) {
      final aDate = _parseDate(a['createdAt']);
      final bDate = _parseDate(b['createdAt']);
      return bDate.compareTo(aDate);
    });
    return sorted.first;
  }

  DateTime _parseDate(dynamic value) {
    return DateTime.tryParse(value?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  Future<String> _locationLabel(double lat, double lon) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final locality = place.locality?.trim() ?? '';
        final area = place.subAdministrativeArea?.trim() ?? '';
        final department = place.administrativeArea?.trim() ?? '';

        final parts = <String>[
          if (locality.isNotEmpty) locality,
          if (area.isNotEmpty && area != locality) area,
          if (department.isNotEmpty &&
              department != area &&
              department != locality)
            department,
        ];

        if (parts.isNotEmpty) return parts.join(', ');
      }
    } catch (_) {
      // Si el geocoder no responde, se muestra la coordenada del lote.
    }

    return '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';
  }

  Future<void> _fetchWeatherForLote(double lat, double lon) async {
    if (mounted) {
      setState(() => _isWeatherLoading = true);
    }

    final data = await _weatherService.getWeatherData(lat, lon);
    if (mounted) {
      setState(() {
        _temperature = data['temperature'] ?? '--°C';
        _rainProb = data['rainProbability'] ?? '--%';
        _isWeatherLoading = false;
      });
    }
  }

  Future<void> _fetchSoilStatus() async {
    try {
      final url = Uri.parse('${ApiEndpoints.baseUrl}/weather/sensor/humidity');
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _soilStatus = '${data['currentValue'] ?? 68}%';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _soilStatus = '68%';
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _soilStatus = '68%';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Container(
            width: double.infinity,
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
              textAlign: TextAlign.center,
              style: AppText.labelCaps(
                color: AppColors.onPrimaryFixed,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _loteName,
                      style: AppText.h3(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_loteLocation != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _loteLocation!,
                        style: AppText.bodyMd(
                          color: AppColors.onSurfaceVariant,
                        ).copyWith(fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Estado del suelo',
                    style: AppText.bodyMd(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    _soilStatus,
                    style: AppText.h1(color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          _WeatherSection(
            temperature: _temperature,
            rainProb: _rainProb,
            isLoading: _isWeatherLoading,
          ),
          const SizedBox(height: 16),
          // Sync status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: _isOnline
                  ? Colors.white.withValues(alpha: 0.8)
                  : const Color(0xFFFFF3E0)
                      .withValues(alpha: 0.9), // Orange light for offline
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isOnline ? Icons.cloud_done : Icons.cloud_off,
                  size: 18,
                  color: _isOnline ? Colors.green[700] : Colors.orange[800],
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _isOnline
                        ? 'En línea - ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}'
                        : 'Última sincronización: ${DateFormat('dd/MM/yyyy HH:mm').format(_lastSync)}',
                    style: AppText.bodyMd(
                      color:
                          _isOnline ? Colors.green[800]! : Colors.orange[900]!,
                    ).copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!_isOnline) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.sync_problem, size: 18, color: Colors.orange[800]),
                ]
              ],
            ),
          ),
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
                Icons.grass,
                'Siembra',
                const SowingScreen(currentTab: AgroTab.home),
              ),
              const SizedBox(width: 25),
              _action(
                context,
                Icons.water_drop,
                'Riego',
                const IrrigationScreen(currentTab: AgroTab.home),
              ),
              const SizedBox(width: 20),
              _action(
                context,
                Icons.eco,
                'Fertilización',
                const FertilizationScreen(currentTab: AgroTab.home),
              ),
              const SizedBox(width: 20),
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
              _action(
                context,
                Icons.landscape,
                'Terreno',
                const TerrainStatusScreen(currentTab: AgroTab.home),
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
        width: 145,
        height: 155,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
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
          mainAxisAlignment: MainAxisAlignment.center,
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

class _WeatherSection extends StatelessWidget {
  const _WeatherSection({
    required this.temperature,
    required this.rainProb,
    required this.isLoading,
  });

  final String temperature;
  final String rainProb;
  final bool isLoading;

  IconData _getTempIcon() {
    if (temperature == '...' || temperature == '--°C') {
      return Icons.thermostat;
    }
    try {
      final val =
          double.tryParse(temperature.replaceAll('°C', '').trim()) ?? 25.0;
      if (val > 30) return Icons.wb_sunny; // Hot
      if (val < 15) return Icons.ac_unit; // Cold
      return Icons.thermostat; // Mild
    } catch (_) {
      return Icons.thermostat;
    }
  }

  IconData _getRainIcon() {
    if (rainProb == '...' || rainProb == '--%') return Icons.water_drop;
    try {
      final val = double.tryParse(rainProb.replaceAll('%', '').trim()) ?? 0.0;
      if (val > 50) return Icons.umbrella; // High chance of rain
      return Icons.water_drop;
    } catch (_) {
      return Icons.water_drop;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildCard(_getTempIcon(), 'Temperatura', temperature)),
        const SizedBox(width: 8),
        Expanded(child: _buildCard(_getRainIcon(), 'Prob. Lluvia', rainProb)),
      ],
    );
  }

  Widget _buildCard(IconData icon, String label, String value) {
    return Container(
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
          isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(value, style: AppText.h3()),
        ],
      ),
    );
  }
}

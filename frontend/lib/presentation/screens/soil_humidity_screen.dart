import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import '../../core/network/api_endpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../widgets/custom_app_bar.dart';

import '../common/agro_bottom_nav.dart';
import 'home_screen.dart';
import 'map_onboarding_screen.dart';
import 'profile_screen.dart';
import 'tasks_screen.dart';
import 'soil_success_screen.dart';

class SoilHumidityScreen extends StatefulWidget {
  final AgroTab currentTab;
  final String? fixedLote;
  const SoilHumidityScreen(
      {super.key, this.currentTab = AgroTab.home, this.fixedLote});

  @override
  State<SoilHumidityScreen> createState() => _SoilHumidityScreenState();
}

class _SoilHumidityScreenState extends State<SoilHumidityScreen> {
  bool _isSensorMode = false;

  // Manual Mode State
  String? _selectedPerception = 'Normal';

  // Sensor Mode State
  bool _isSensorConnected = false;
  bool _isConnecting = false;
  int _sensorValue = 0;
  List<int> _sensorHistory = [];

  Future<void> _connectSensor() async {
    setState(() => _isConnecting = true);
    // Simular tiempo de conexión Bluetooth/IoT
    await Future.delayed(const Duration(seconds: 2));

    try {
      final url =
          Uri.parse('${ApiEndpoints.baseUrl}/api/v1/weather/sensor/humidity');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _sensorValue = data['currentValue'] ?? 68;
            _sensorHistory = List<int>.from(data['history24h'] ?? []);
            _isSensorConnected = true;
          });
        }
      } else {
        // Fallback si falla el backend
        _setMockSensorData();
      }
    } catch (e) {
      _setMockSensorData();
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  void _setMockSensorData() {
    if (mounted) {
      setState(() {
        _sensorValue = 68;
        _sensorHistory = [
          55,
          58,
          60,
          62,
          60,
          58,
          55,
          54,
          52,
          50,
          55,
          60,
          65,
          68,
          70,
          72,
          70,
          68,
          67,
          66,
          68,
          68,
          69,
          68
        ];
        _isSensorConnected = true;
      });
    }
  }

  // Lotes simulados para asociar el registro o el sensor
  final List<String> _lotes = [
    'Lote 1 — Sector Norte',
    'Lote 2 — Ladera Este',
    'Lote 3 — Valle Sur'
  ];
  String _selectedLote = 'Lote 1 — Sector Norte';

  @override
  void initState() {
    super.initState();
    if (widget.fixedLote != null) {
      _selectedLote = widget.fixedLote!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              'Estado del Suelo',
              style: AppText.h2(color: AppColors.primary),
            ),
            const SizedBox(height: 5),

            // Selector de Lote
            Text(
              'LOTE',
              style: AppText.labelCaps(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            if (widget.fixedLote != null)
              Container(
                height: 56,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                alignment: Alignment.centerLeft,
                child: Text(widget.fixedLote!, style: AppText.bodyMd()),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLote,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down,
                        color: AppColors.primary),
                    items: _lotes.map((lote) {
                      return DropdownMenuItem(
                        value: lote,
                        child: Text(lote, style: AppText.bodyMd()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedLote = value;
                          _isSensorConnected = false;
                          _isConnecting = false;
                        });
                      }
                    },
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Toggle Manual / Sensor
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isSensorMode = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isSensorMode
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Modo Manual',
                          style: AppText.labelCaps(
                            color: !_isSensorMode
                                ? AppColors.onPrimary
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isSensorMode = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isSensorMode
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Modo Sensor',
                          style: AppText.labelCaps(
                            color: _isSensorMode
                                ? AppColors.onPrimary
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Contenido dinámico según el modo
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isSensorMode ? _buildSensorMode() : _buildManualMode(),
            ),
            const SizedBox(height: 32),
            // Save Button
            ElevatedButton.icon(
              onPressed: () {
                final perceptionValue = _isSensorMode
                    ? '$_sensorValue% (Sensor)'
                    : _selectedPerception!;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SoilSuccessScreen(
                      lote: _selectedLote,
                      perception: perceptionValue,
                      currentTab: widget.currentTab,
                      isSensor: _isSensorMode,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.save, color: AppColors.onPrimary),
              label: Text(
                'GUARDAR REGISTRO',
                style: AppText.labelCaps(color: AppColors.onPrimary),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AgroBottomNav(
        current: widget.currentTab,
        onTap: (tab) {
          if (tab == AgroTab.home) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          } else if (tab == AgroTab.lotes) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const MapOnboardingScreen()));
          } else if (tab == AgroTab.perfil) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()));
          } else if (tab == AgroTab.tareas) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const TasksScreen()));
          }
        },
      ),
    );
  }

  Widget _buildManualMode() {
    return Column(
      key: const ValueKey('manual'),
      children: [
        _buildManualOption(
          id: 'Seco',
          title: 'SECO',
          icon: Icons.wb_sunny_outlined,
          isSelected: _selectedPerception == 'Seco',
        ),
        const SizedBox(height: 16),
        _buildManualOption(
          id: 'Normal',
          title: 'NORMAL',
          icon: Icons.water_drop,
          isSelected: _selectedPerception == 'Normal',
        ),
        const SizedBox(height: 16),
        _buildManualOption(
          id: 'Húmedo',
          title: 'HÚMEDO',
          icon: Icons.waves,
          isSelected: _selectedPerception == 'Húmedo',
        ),
      ],
    );
  }

  Widget _buildManualOption({
    required String id,
    required String title,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPerception = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFB1F0CE)
              : AppColors.surface, // Verde claro cuando está seleccionado
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.5)
                    : AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 20),
            Text(
              title,
              style: AppText.h3().copyWith(letterSpacing: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorMode() {
    if (!_isSensorConnected) {
      return Container(
        key: const ValueKey('disconnected'),
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          children: [
            Text('Sin Sensor Conectado', style: AppText.h3()),
            const SizedBox(height: 12),
            Text(
              'Conecte un sensor para ver\nlos datos en tiempo real.',
              textAlign: TextAlign.center,
              style: AppText.bodyMd(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.cable, size: 100, color: AppColors.outline),
                if (_isConnecting)
                  const CircularProgressIndicator(color: AppColors.primary),
              ],
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: _isConnecting ? null : _connectSensor,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                _isConnecting ? 'CONECTANDO...' : 'CONECTAR SENSOR',
                style: AppText.labelCaps(color: AppColors.primary),
              ),
            ),
          ],
        ),
      );
    }

    // Connected State
    return Container(
      key: const ValueKey('connected'),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFD8F3DC), // Fondo verde muy claro
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF95D5B2), width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sensor Conectado',
                  style:
                      AppText.bodyLg().copyWith(fontWeight: FontWeight.w600)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.power, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Icon(Icons.language, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '$_sensorValue%',
            style: const TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
              height: 1,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 100,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: _sensorHistory.length.toDouble() - 1,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: _sensorHistory
                        .asMap()
                        .entries
                        .map(
                            (e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
                        .toList(),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Vista de las últimas 24 horas',
            style: AppText.bodyMd(color: AppColors.onSurfaceVariant)
                .copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

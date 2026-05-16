import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'dart:ui' as dart_ui;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../common/agro_bottom_nav.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/rugged_button.dart';
import '../widgets/offline_banner.dart';
import 'home_screen.dart';
import 'map_onboarding_screen.dart';
import 'profile_screen.dart';
import 'tasks_screen.dart';
import 'lotes_list_screen.dart';

class RegisterLoteScreen extends StatefulWidget {
  const RegisterLoteScreen({super.key});

  @override
  State<RegisterLoteScreen> createState() => _RegisterLoteScreenState();
}

class _RegisterLoteScreenState extends State<RegisterLoteScreen> {
  final _nameController = TextEditingController(text: 'Lote Sur');
  final _areaController = TextEditingController(text: '2.1');

  double? _lat;
  double? _lng;
  String? _locationLabel;
  bool _loadingLocation = false;
  bool _saving = false;

  int? _draggingPointIndex;
  List<Offset> _polygonPoints = [
    const Offset(0.22, 0.22),
    const Offset(0.78, 0.12),
    const Offset(0.88, 0.78),
    const Offset(0.18, 0.88),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  // ─── AREA ─────────────────────────────────────────────────────────────────
  void _calculateArea() {
    if (_polygonPoints.length < 3) return;
    double area = 0.0;
    for (int i = 0; i < _polygonPoints.length; i++) {
      int j = (i + 1) % _polygonPoints.length;
      area += _polygonPoints[i].dx * _polygonPoints[j].dy;
      area -= _polygonPoints[j].dx * _polygonPoints[i].dy;
    }
    area = (area.abs() / 2.0);
    // Fake scale: 1.0 area = 10 Ha
    double ha = area * 10.0;
    // ensure at least 0.1
    if (ha < 0.1) ha = 0.1;
    _areaController.text = ha.toStringAsFixed(1);
  }

  // ─── GPS ──────────────────────────────────────────────────────────────────
  Future<void> _getLocation() async {
    setState(() => _loadingLocation = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever ||
          perm == LocationPermission.denied) {
        _showSnack('Permiso de ubicación denegado. Actívalo en Ajustes.');
        setState(() => _loadingLocation = false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      _lat = pos.latitude;
      _lng = pos.longitude;

      try {
        final placemarks = await placemarkFromCoordinates(_lat!, _lng!);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = [p.street, p.subLocality, p.locality]
              .where((s) => s != null && s.isNotEmpty)
              .toList();
          _locationLabel = parts.isNotEmpty
              ? parts.join(', ')
              : '${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}';
        }
      } catch (_) {
        _locationLabel =
            '${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}';
      }

      setState(() => _loadingLocation = false);
    } catch (e) {
      _showSnack('No se pudo obtener la ubicación.');
      setState(() => _loadingLocation = false);
    }
  }

  // ─── SAVE ─────────────────────────────────────────────────────────────────
  Future<void> _saveLote() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showSnack('Por favor ingresa un nombre para el lote.');
      return;
    }
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    // Mark that lotes exist so onboarding is skipped next time
    final prefs = await SharedPreferences.getInstance();
    final isFirstLote = !(prefs.getBool('has_lotes') ?? false);
    await prefs.setBool('has_lotes', true);

    setState(() => _saving = false);

    if (!mounted) return;

    // Show success dialog
    await showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.3), // slightly dim
        builder: (ctx) => BackdropFilter(
              filter: dart_ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                elevation: 0,
                backgroundColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryContainer,
                        ),
                        child: const Icon(Icons.landscape,
                            color: AppColors.primary, size: 36),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isFirstLote
                            ? '¡Registraste tu\nprimer lote!'
                            : '¡Lote registrado!',
                        textAlign: TextAlign.center,
                        style: AppText.h2(),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '"$name" ya está disponible en tu sistema.',
                        textAlign: TextAlign.center,
                        style:
                            AppText.bodyMd(color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('VER MIS LOTES'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LotesListScreen(
          newLoteName: name,
          newLoteLocation: _locationLabel ?? 'Sin ubicación registrada',
          newLoteLat: _lat,
          newLoteLng: _lng,
          newLoteArea: _areaController.text.trim(),
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      // resizeToAvoidBottomInset keeps the form visible when keyboard opens
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          const OfflineBanner(),

          // ── MAP (fixed height, never scrolls) ──────────────────────────
          SizedBox(
            height: 220,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Rich map background
                CustomPaint(painter: _MapPainter(hasLocation: _lat != null)),
                // Location pin when GPS captured
                if (_lat != null)
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_pin,
                            color: AppColors.error, size: 44),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 8)
                            ],
                          ),
                          child: Text(
                            _locationLabel ?? '',
                            style: AppText.bodyMd(color: AppColors.onSurface)
                                .copyWith(fontSize: 11),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.touch_app,
                              color: AppColors.primary, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Toca "Usar mi ubicación" para marcar',
                            style: AppText.bodyMd(
                                    color: AppColors.onSurfaceVariant)
                                .copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Polygon overlay when location known
                if (_lat != null)
                  Positioned(
                    left: 40,
                    right: 40,
                    top: 30,
                    bottom: 50,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return GestureDetector(
                          onPanUpdate: (details) {
                            if (_draggingPointIndex == null) {
                              // Find closest point to start dragging
                              double minD = double.infinity;
                              int minIdx = 0;
                              for (int i = 0; i < _polygonPoints.length; i++) {
                                final p = Offset(
                                  _polygonPoints[i].dx * constraints.maxWidth,
                                  _polygonPoints[i].dy * constraints.maxHeight,
                                );
                                final d = (p - details.localPosition).distance;
                                if (d < minD) {
                                  minD = d;
                                  minIdx = i;
                                }
                              }
                              // Only start drag if within 40 pixels
                              if (minD < 40) {
                                _draggingPointIndex = minIdx;
                              }
                            }

                            if (_draggingPointIndex != null) {
                              setState(() {
                                double newX =
                                    _polygonPoints[_draggingPointIndex!].dx +
                                        details.delta.dx / constraints.maxWidth;
                                double newY =
                                    _polygonPoints[_draggingPointIndex!].dy +
                                        details.delta.dy /
                                            constraints.maxHeight;
                                // Clamp to 0..1
                                newX = newX.clamp(0.0, 1.0);
                                newY = newY.clamp(0.0, 1.0);
                                _polygonPoints[_draggingPointIndex!] =
                                    Offset(newX, newY);
                              });
                              _calculateArea();
                            }
                          },
                          onPanEnd: (_) => _draggingPointIndex = null,
                          onPanCancel: () => _draggingPointIndex = null,
                          child: CustomPaint(
                            size: Size(
                                constraints.maxWidth, constraints.maxHeight),
                            painter: _PolygonPainter(points: _polygonPoints),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // ── FORM (scrollable) ──────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, -4),
                      blurRadius: 16)
                ],
              ),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.outlineVariant,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text('Registrar Lote', style: AppText.h2()),
                    const SizedBox(height: 20),

                    // ── Nombre ────────────────────────────────────────────
                    Text('NOMBRE DEL LOTE', style: AppText.labelCaps()),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surface,
                        hintText: 'Ej: Lote Norte, Parcela 3...',
                        prefixIcon: const Icon(Icons.landscape,
                            color: AppColors.primary, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.outlineVariant),
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Área ──────────────────────────────────────────────
                    Text('ÁREA ESTIMADA', style: AppText.labelCaps()),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _areaController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surface,
                        hintText: 'Ej: 2.5',
                        prefixIcon: const Icon(Icons.straighten,
                            color: AppColors.primary, size: 20),
                        suffixText: 'hectáreas',
                        suffixStyle:
                            AppText.bodyMd(color: AppColors.onSurfaceVariant),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.outlineVariant),
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Ubicación capturada ───────────────────────────────
                    if (_locationLabel != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: AppColors.onSecondaryContainer,
                                size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _locationLabel!,
                                style: AppText.bodyMd(
                                    color: AppColors.onSecondaryContainer),
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // ── GPS button ────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _loadingLocation ? null : _getLocation,
                        icon: _loadingLocation
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppColors.primary),
                              )
                            : const Icon(Icons.my_location,
                                color: AppColors.primary),
                        label: Text(
                          _loadingLocation
                              ? 'OBTENIENDO UBICACIÓN...'
                              : _lat != null
                                  ? 'ACTUALIZAR UBICACIÓN'
                                  : 'USAR MI UBICACIÓN ACTUAL',
                          style: AppText.labelCapsLg(color: AppColors.primary),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                          shape: const StadiumBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Save ──────────────────────────────────────────────
                    RuggedButton(
                      text: _saving ? 'GUARDANDO...' : 'GUARDAR LOTE',
                      icon: Icons.save,
                      onPressed: _saving
                          ? null
                          : () {
                              _saveLote();
                            },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AgroBottomNav(
        current: AgroTab.lotes,
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
}

// ─── Painters ────────────────────────────────────────────────────────────────

/// Rich map background with terrain colors, roads, and water.
class _MapPainter extends CustomPainter {
  final bool hasLocation;
  _MapPainter({required this.hasLocation});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Base terrain — light green
    canvas.drawRect(
        Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFFD4E8C2));

    // Darker green patches (fields)
    final fieldPaint = Paint()..color = const Color(0xFFA8CC7A);
    canvas.drawRect(Rect.fromLTWH(0, 0, w * 0.45, h * 0.55), fieldPaint);
    canvas.drawRect(
        Rect.fromLTWH(w * 0.55, h * 0.4, w * 0.45, h * 0.6), fieldPaint);

    // Lighter field
    final lightField = Paint()..color = const Color(0xFFC5E09A);
    canvas.drawRect(
        Rect.fromLTWH(w * 0.3, h * 0.2, w * 0.4, h * 0.35), lightField);

    // Water / stream — blue strip
    final waterPaint = Paint()..color = const Color(0xFF90CAF9);
    final waterPath = Path()
      ..moveTo(w * 0.0, h * 0.62)
      ..quadraticBezierTo(w * 0.35, h * 0.55, w * 0.65, h * 0.68)
      ..quadraticBezierTo(w * 0.85, h * 0.76, w, h * 0.72)
      ..lineTo(w, h * 0.78)
      ..quadraticBezierTo(w * 0.85, h * 0.82, w * 0.65, h * 0.74)
      ..quadraticBezierTo(w * 0.35, h * 0.62, w * 0.0, h * 0.68)
      ..close();
    canvas.drawPath(waterPath, waterPaint);

    // Grid lines (faint)
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 0.8;
    const step = 36.0;
    for (double x = 0; x < w; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 0; y < h; y += step) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Road — horizontal
    final roadPaint = Paint()
      ..color = const Color(0xFFF5DEB3)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, h * 0.38), Offset(w, h * 0.42), roadPaint);

    final roadLine = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, h * 0.40), Offset(w, h * 0.40), roadLine);

    // Road — vertical
    canvas.drawLine(Offset(w * 0.72, 0), Offset(w * 0.68, h * 0.38), roadPaint);
    canvas.drawLine(Offset(w * 0.70, 0), Offset(w * 0.70, h * 0.38), roadLine);

    // Trees / dots (dark green)
    final treePaint = Paint()..color = const Color(0xFF558B2F);
    final treePositions = [
      Offset(w * 0.08, h * 0.15),
      Offset(w * 0.15, h * 0.28),
      Offset(w * 0.85, h * 0.12),
      Offset(w * 0.92, h * 0.25),
      Offset(w * 0.55, h * 0.85),
      Offset(w * 0.42, h * 0.80),
    ];
    for (final t in treePositions) {
      canvas.drawCircle(t, 7, treePaint);
      canvas.drawCircle(t, 5, Paint()..color = const Color(0xFF7CB342));
    }

    // Compass rose
    final compassPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    const cx = 24.0;
    const cy = 24.0;
    const cs = 8.0;
    canvas.drawCircle(const Offset(cx, cy), cs + 2,
        Paint()..color = Colors.black.withValues(alpha: 0.15));
    canvas.drawCircle(const Offset(cx, cy), cs, compassPaint);
    // N arrow
    final arrowPaint = Paint()..color = const Color(0xFF1E5266);
    final northPath = Path()
      ..moveTo(cx, cy - cs + 1)
      ..lineTo(cx - 3, cy)
      ..lineTo(cx + 3, cy)
      ..close();
    canvas.drawPath(northPath, arrowPaint);

    // Scale bar
    final scalePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(w - 70, h - 14), Offset(w - 14, h - 14), scalePaint);
    canvas.drawLine(Offset(w - 70, h - 14), Offset(w - 70, h - 10), scalePaint);
    canvas.drawLine(Offset(w - 14, h - 14), Offset(w - 14, h - 10), scalePaint);
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) =>
      oldDelegate.hasLocation != hasLocation;
}

class _PolygonPainter extends CustomPainter {
  final List<Offset> points;
  _PolygonPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final fill = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    path.moveTo(points[0].dx * size.width, points[0].dy * size.height);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx * size.width, points[i].dy * size.height);
    }
    path.close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    final handle = Paint()..color = Colors.white;
    final handleStroke = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final p in points) {
      final center = Offset(p.dx * size.width, p.dy * size.height);
      canvas.drawCircle(
          center, 9, handle); // slightly larger handle for dragging
      canvas.drawCircle(center, 9, handleStroke);
    }
  }

  @override
  bool shouldRepaint(covariant _PolygonPainter oldDelegate) =>
      true; // simplistic repaint
}

// ignore: unused_element
double _deg2rad(double deg) => deg * math.pi / 180;

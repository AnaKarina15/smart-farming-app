import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../common/agro_bottom_nav.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/offline_banner.dart';
import 'fertilization_screen.dart';
import 'home_screen.dart';
import 'irrigation_screen.dart';
import 'map_onboarding_screen.dart';
import 'profile_screen.dart';
import 'soil_humidity_screen.dart';
import 'sowing_screen.dart';
import 'phytosanitary_screen.dart';
import 'tasks_screen.dart';
import 'register_lote_screen.dart';
import 'lote_history_screen.dart';

/// Vista principal de Lotes — mapa aéreo + lista de cards.
class LotesListScreen extends StatefulWidget {
  final String? newLoteName;
  final String? newLoteLocation;
  final double? newLoteLat;
  final double? newLoteLng;
  final String? newLoteArea;

  const LotesListScreen({
    super.key,
    this.newLoteName,
    this.newLoteLocation,
    this.newLoteLat,
    this.newLoteLng,
    this.newLoteArea,
  });

  @override
  State<LotesListScreen> createState() => _LotesListScreenState();
}

class _LotesListScreenState extends State<LotesListScreen> {
  bool _showSuccess = false;
  int? _selectedLoteIndex;
  late List<_LoteData> _lotes;

  @override
  void initState() {
    super.initState();
    _lotes = [
      _LoteData(
        name: 'Lote 1',
        subtitle: 'Sector Norte',
        location: 'Vereda Las Palmas',
        area: '3.2',
        status: LoteStatus.alert,
      ),
      _LoteData(
        name: 'Lote 2',
        subtitle: 'Ladera Este',
        location: 'Finca El Progreso',
        area: '1.8',
        status: LoteStatus.active,
      ),
      _LoteData(
        name: 'Lote 3',
        subtitle: 'Valle Sur',
        location: 'Km 12 vía principal',
        area: '4.5',
        status: LoteStatus.active,
      ),
    ];

    if (widget.newLoteName != null) {
      _lotes.insert(
        0,
        _LoteData(
          name: widget.newLoteName!,
          subtitle: '',
          location: widget.newLoteLocation ?? 'Sin ubicación',
          area: widget.newLoteArea ?? '—',
          status: LoteStatus.active,
          lat: widget.newLoteLat,
          lng: widget.newLoteLng,
          isNew: true,
        ),
      );
      _showSuccess = true;
    }
  }

  Color _statusColor(LoteStatus s) {
    switch (s) {
      case LoteStatus.alert:
        return const Color(0xFFD32F2F);
      case LoteStatus.active:
        return const Color(0xFF2E5D42);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          const OfflineBanner(),

          // ── Success banner ──────────────────────────────────────────────
          if (_showSuccess)
            Container(
              color: AppColors.primaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.primary, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Registro de lote exitoso',
                      style: AppText.bodyMd(color: AppColors.primary)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        color: AppColors.onPrimaryContainer, size: 18),
                    onPressed: () => setState(() => _showSuccess = false),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

          // ── Aerial map ─────────────────────────────────────────────────
          SizedBox(
            height: 220,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background aerial image
                Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBsUK2cmiOCSLZbIzw72ZAGUTI9xT45aBEMw-YhRLnceBHfiaicb2r59y5pW0Ognlpok-C8xZoQVJu8VrEZRIlegBzMZBxV9rirIx12D4Nw33aYATZe3JR-zgA_xlzjMx5BVyKklXWXsJVrGtekg1t0ptJCKO2UqAlF5SBFeSTHMUhiC4ZOI5EVaRG2Yh-CMoGhl2BZXDbyKCPVPGUAyXJFg4Ez5d5UyQbx1AHJow1euOOwd87l8bRePyF_hT4QkublwLV8Mg7XwoF-',
                  fit: BoxFit.cover,
                  color: Colors.white.withValues(alpha: 0.8),
                  colorBlendMode: BlendMode.dstIn,
                ),

                // Polygons
                CustomPaint(
                  painter: _AerialMapPainter(
                    lotes: _lotes,
                    selectedIndex: _selectedLoteIndex,
                    statusColor: _statusColor,
                  ),
                ),

                // Bottom-right: Add + GPS buttons
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Add lote
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterLoteScreen()),
                        ),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 6)
                            ],
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.black87, size: 24),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // GPS / compass
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 6)
                          ],
                        ),
                        child: const Icon(Icons.gps_fixed,
                            color: Colors.white, size: 22),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Lot cards list ─────────────────────────────────────────────
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Static title row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Mis Lotes', style: AppText.h2()),
                        Text('${_lotes.length} registrados',
                            style: AppText.bodyMd(
                                color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Scrollable cards
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          ...List.generate(_lotes.length, (i) {
                            final lote = _lotes[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (_selectedLoteIndex == i) {
                                      _selectedLoteIndex = null; // Toggle to close
                                    } else {
                                      _selectedLoteIndex = i;
                                    }
                                  });
                                },
                                child: _LoteCard(
                                  lote: lote,
                                  isSelected: _selectedLoteIndex == i,
                                  statusColor: _statusColor(lote.status),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ],
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

// ─── Data model ──────────────────────────────────────────────────────────────

enum LoteStatus { active, alert }

class _LoteData {
  final String name;
  final String subtitle;
  final String location;
  final String area;
  final LoteStatus status;
  final double? lat;
  final double? lng;
  final bool isNew;

  _LoteData({
    required this.name,
    required this.subtitle,
    required this.location,
    required this.area,
    required this.status,
    this.lat,
    this.lng,
    this.isNew = false,
  });
}

// ─── Aerial map painter ───────────────────────────────────────────────────────

class _AerialMapPainter extends CustomPainter {
  final List<_LoteData> lotes;
  final int? selectedIndex;
  final Color Function(LoteStatus) statusColor;

  _AerialMapPainter({
    required this.lotes,
    required this.selectedIndex,
    required this.statusColor,
  });

  // Fixed polygon positions for up to 4 lotes on the map
  // SVG paths translated to relative coordinates (assuming 400x300 viewBox from HTML)
  static const _polygons = [
    // Lote 1: 50,50 -> 180,40 -> 190,140 -> 40,150
    [
      Offset(50 / 400, 50 / 300),
      Offset(180 / 400, 40 / 300),
      Offset(190 / 400, 140 / 300),
      Offset(40 / 400, 150 / 300),
    ],
    // Lote 2: 200,40 -> 350,55 -> 340,130 -> 210,140
    [
      Offset(200 / 400, 40 / 300),
      Offset(350 / 400, 55 / 300),
      Offset(340 / 400, 130 / 300),
      Offset(210 / 400, 140 / 300),
    ],
    // Lote 3: 40,165 -> 210,155 -> 220,260 -> 60,280
    [
      Offset(40 / 400, 165 / 300),
      Offset(210 / 400, 155 / 300),
      Offset(220 / 400, 260 / 300),
      Offset(60 / 400, 280 / 300),
    ],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Lote polygons ────────────────────────────────────────────────────
    for (int i = 0; i < lotes.length && i < _polygons.length; i++) {
      final lote = lotes[i];
      final poly = _polygons[i];
      final isSelected = i == selectedIndex;
      final color =
          isSelected ? const Color(0xFFD32F2F) : statusColor(lote.status);

      final path = Path();
      path.moveTo(poly[0].dx * w, poly[0].dy * h);
      for (int j = 1; j < poly.length; j++) {
        path.lineTo(poly[j].dx * w, poly[j].dy * h);
      }
      path.close();

      // Fill
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: isSelected ? 0.32 : 0.20)
          ..style = PaintingStyle.fill,
      );

      // Border
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 2.5 : 2.0,
      );

      // Label in center
      final cx =
          poly.map((o) => o.dx).reduce((a, b) => a + b) / poly.length * w;
      final cy =
          poly.map((o) => o.dy).reduce((a, b) => a + b) / poly.length * h;

      final label = lote.subtitle.isNotEmpty
          ? '${lote.name}\n${lote.subtitle}'.toUpperCase()
          : lote.name.toUpperCase();

      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: Colors.white,
            fontSize: isSelected ? 11 : 9,
            fontWeight: FontWeight.w800,
            shadows: const [
              Shadow(
                  color: Colors.black54, blurRadius: 4, offset: Offset(1, 1)),
            ],
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 80);

      tp.paint(
        canvas,
        Offset(cx - tp.width / 2, cy - tp.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AerialMapPainter old) =>
      old.selectedIndex != selectedIndex || old.lotes.length != lotes.length;
}

// ─── Lot card ─────────────────────────────────────────────────────────────────

class _LoteCard extends StatefulWidget {
  final _LoteData lote;
  final bool isSelected;
  final Color statusColor;

  const _LoteCard({
    required this.lote,
    required this.isSelected,
    required this.statusColor,
  });

  @override
  State<_LoteCard> createState() => _LoteCardState();
}

class _LoteCardState extends State<_LoteCard> {
  String get _loteName => widget.lote.subtitle.isNotEmpty
      ? '${widget.lote.name} — ${widget.lote.subtitle}'
      : widget.lote.name;

  void _navigate(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              widget.isSelected ? widget.statusColor : AppColors.outlineVariant,
          width: widget.isSelected ? 2 : 1,
        ),
        boxShadow: widget.isSelected
            ? [
                BoxShadow(
                  color: widget.statusColor.withValues(alpha: 0.15),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                )
              ],
      ),
      child: Column(
        children: [
          // ── Header row ─────────────────────────────────────────────────
          Row(
            children: [
              // Color indicator + icon
              Container(
                width: 56,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.landscape, color: widget.statusColor, size: 22),
                    const SizedBox(height: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.statusColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _loteName,
                              style: AppText.bodyLg()
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          if (widget.lote.isNew)
                            _Badge('NUEVO', AppColors.primary,
                                AppColors.onPrimary),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: AppColors.outline, size: 13),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              widget.lote.location,
                              style: AppText.bodyMd(
                                  color: AppColors.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _Chip(
                            icon: Icons.straighten,
                            label: '${widget.lote.area} hec',
                          ),
                          const SizedBox(width: 8),
                          _Chip(
                            icon: widget.lote.lat != null
                                ? Icons.gps_fixed
                                : Icons.gps_not_fixed,
                            label:
                                widget.lote.lat != null ? 'GPS ✓' : 'Sin GPS',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Quick actions (expandable) ──────────────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: widget.isSelected
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(15)),
              ),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Text('ACCIONES RÁPIDAS',
                      style:
                          AppText.labelCaps(color: AppColors.onSurfaceVariant)
                              .copyWith(fontSize: 10)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _QuickAction(
                        icon: Icons.water_drop,
                        label: 'Riego',
                        color: const Color(0xFF1565C0),
                        onTap: () => _navigate(IrrigationScreen(
                            fixedLote: _loteName, currentTab: AgroTab.lotes)),
                      ),
                      _QuickAction(
                        icon: Icons.science,
                        label: 'Fertilizar',
                        color: const Color(0xFF2E7D32),
                        onTap: () => _navigate(FertilizationScreen(
                            fixedLote: _loteName, currentTab: AgroTab.lotes)),
                      ),
                      _QuickAction(
                        icon: Icons.eco,
                        label: 'Siembra',
                        color: const Color(0xFF827717),
                        onTap: () => _navigate(SowingScreen(
                            fixedLote: _loteName, currentTab: AgroTab.lotes)),
                      ),
                      _QuickAction(
                        icon: Icons.bug_report,
                        label: 'Fitocontrol',
                        color: const Color(0xFFC62828),
                        onTap: () => _navigate(PhytosanitaryScreen(
                            fixedLote: _loteName, currentTab: AgroTab.lotes)),
                      ),
                      _QuickAction(
                        icon: Icons.opacity,
                        label: 'Humedad',
                        color: const Color(0xFF00838F),
                        onTap: () => _navigate(SoilHumidityScreen(
                            fixedLote: _loteName, currentTab: AgroTab.lotes)),
                      ),
                      _QuickAction(
                        icon: Icons.history,
                        label: 'Historial',
                        color: const Color(0xFF455A64),
                        onTap: () =>
                            _navigate(LoteHistoryScreen(loteName: _loteName)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const _Badge(this.text, this.bg, this.fg);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child:
          Text(text, style: AppText.labelCaps(color: fg).copyWith(fontSize: 9)),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: AppText.bodyMd(color: color)
                    .copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(label,
              style: AppText.bodyMd(color: AppColors.onSurfaceVariant)
                  .copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}

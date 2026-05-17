import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
import 'package:provider/provider.dart';
import '../../data/providers/lotes_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/catalogos_provider.dart';
import '../../data/models/lote_model.dart';

class RegisterLoteScreen extends StatefulWidget {
  final LoteModel? loteToEdit;

  const RegisterLoteScreen({super.key, this.loteToEdit});

  @override
  State<RegisterLoteScreen> createState() => _RegisterLoteScreenState();
}

class _RegisterLoteScreenState extends State<RegisterLoteScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _areaController;

  GoogleMapController? _mapController;

  double? _lat;
  double? _lng;
  String? _locationLabel;
  bool _loadingLocation = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.loteToEdit?.nombre ?? ' ');
    _areaController = TextEditingController(text: widget.loteToEdit != null ? widget.loteToEdit!.superficieHectareas.toString() : ' ');
    _lat = widget.loteToEdit?.latitud;
    _lng = widget.loteToEdit?.longitud;
    _locationLabel = widget.loteToEdit?.descripcion;
    _selectedCultivoId = widget.loteToEdit?.cultivoActualId;
    _selectedMunicipioId = widget.loteToEdit?.municipioId;
  }

  String? _selectedMunicipioId;
  String? _selectedCultivoId;

  int? _draggingPointIndex;
  final List<Offset> _polygonPoints = [
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

      if (_mapController != null) {
        _mapController!.animateCamera(CameraUpdate.newLatLngZoom(LatLng(_lat!, _lng!), 16.0));
      }

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

          // Auto-seleccionar municipio si coincide con el catálogo
          final locality = p.locality;
          if (locality != null) {
            if (!mounted) return;
            final catalogos = context.read<CatalogosProvider>();
            try {
              final match = catalogos.municipios.firstWhere(
                (m) => m.nombre.toLowerCase().contains(locality.toLowerCase()),
              );
              _selectedMunicipioId = match.id;
            } catch (_) {
              // No hay coincidencia exacta, se queda manual
            }
          }
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
    // ─── REAL SAVE ─────────────────────────────────────────
    final auth = context.read<AuthProvider>();
    final lotesProvider = context.read<LotesProvider>();

    final success = await lotesProvider.crearLote(
      nombre: name,
      descripcion: _locationLabel,
      superficieHectareas: double.tryParse(_areaController.text) ?? 0.0,
      latitud: _lat,
      longitud: _lng,
      propietarioId: auth.currentUser?.id ?? 'unknown',
      cultivoActualId: _selectedCultivoId,
      municipioId: _selectedMunicipioId,
    );

    setState(() => _saving = false);

    if (!success) {
      _showSnack('Error al guardar el lote: ${lotesProvider.errorMessage}');
      return;
    }

    if (!mounted) return;

    // Verificar si es el primer lote para mostrar un mensaje especial
    final prefs = await SharedPreferences.getInstance();
    final isFirstLote = !(prefs.getBool('has_lotes') ?? false);
    await prefs.setBool('has_lotes', true);

    // Show success dialog
    if (!mounted) return;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => BackdropFilter(
              filter: dart_ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
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
                    ],
                  ),
                ),
              ),
            ));

    // Wait 3 seconds, then pop dialog and screen
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    Navigator.pop(context); // Close dialog
    Navigator.pop(context); // Back to list
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

          Expanded(
            child: Stack(
              children: [
                // ── MAP (Full screen, interactive) ──────────────────────────
                Positioned.fill(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _lat != null && _lng != null
                          ? LatLng(_lat!, _lng!)
                          : const LatLng(10.46314, -73.25322), // Centro del Magdalena
                      zoom: 14.0,
                    ),
                    mapType: MapType.hybrid,
                    onMapCreated: (controller) => _mapController = controller,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    onTap: (LatLng location) async {
                      setState(() {
                        _lat = location.latitude;
                        _lng = location.longitude;
                        _locationLabel = "Buscando dirección...";
                      });
                      try {
                        List<Placemark> placemarks = await placemarkFromCoordinates(location.latitude, location.longitude);
                        if (placemarks.isNotEmpty) {
                          final place = placemarks.first;
                          setState(() {
                            _locationLabel = "${place.locality ?? place.subAdministrativeArea}, ${place.administrativeArea}";
                          });
                        }
                      } catch(e) {
                         setState(() { _locationLabel = "Ubicación en mapa"; });
                      }
                    },
                    markers: _lat != null && _lng != null ? {
                      Marker(
                        markerId: const MarkerId('lote_marker'),
                        position: LatLng(_lat!, _lng!),
                        infoWindow: InfoWindow(title: _locationLabel ?? 'Lote'),
                      )
                    } : {},
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
              
                // ── FORM (Draggable Bottom Sheet) ──────────────────────────
                DraggableScrollableSheet(
                  initialChildSize: 0.55,
                  minChildSize: 0.15,
                  maxChildSize: 0.9,
                  builder: (context, scrollController) {
                    return Container(
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
                        controller: scrollController,
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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

                    Text(widget.loteToEdit != null ? 'Configurar Lote' : 'Registrar Lote', style: AppText.h2()),
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

                    // ── Cultivo (Catálogo) ──────────────────────────────
                    Text('CULTIVO ACTUAL (OPCIONAL)', style: AppText.labelCaps()),
                    const SizedBox(height: 8),
                    Consumer<CatalogosProvider>(
                      builder: (context, provider, child) {
                        final list = provider.cultivos;
                        if (list.isEmpty) {
                          return Text('Cargando cultivos...', style: AppText.bodyMd(color: AppColors.outline));
                        }

                        String currentNombre = '';
                        if (_selectedCultivoId != null) {
                          try {
                            currentNombre = list.firstWhere((c) => c.id == _selectedCultivoId).nombre;
                          } catch (_) {}
                        }

                        return Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            border: Border.all(color: AppColors.outlineVariant),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Autocomplete<Object>(
                            key: ValueKey('auto_cul_$_selectedCultivoId'),
                            initialValue: TextEditingValue(text: currentNombre),
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == '') return list;
                              return list.where((c) => c.nombre.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                            },
                            displayStringForOption: (option) => (option as dynamic).nombre,
                            onSelected: (option) {
                              setState(() {
                                _selectedCultivoId = (option as dynamic).id;
                              });
                            },
                            fieldViewBuilder: (ctx, controller, focusNode, onSubmitted) {
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  hintText: 'Buscar cultivo...',
                                  hintStyle: AppText.bodyMd(color: AppColors.outline),
                                  prefixIcon: const Icon(Icons.grass, color: AppColors.primary, size: 20),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              );
                            },
                            optionsViewBuilder: (ctx, onSelected, options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 8.0,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width - 80,
                                    constraints: const BoxConstraints(maxHeight: 250),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListView.separated(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: options.length,
                                      separatorBuilder: (c, i) => const Divider(height: 1),
                                      itemBuilder: (ctx, index) {
                                        final option = options.elementAt(index);
                                        return ListTile(
                                          title: Text((option as dynamic).nombre, style: AppText.bodyMd()),
                                          subtitle: Text((option as dynamic).categoria ?? '', style: AppText.bodyMd(color: AppColors.outline).copyWith(fontSize: 14)),
                                          onTap: () => onSelected(option),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Municipio (Catálogo) ──────────────────────────────
                    Text('MUNICIPIO (OPCIONAL)', style: AppText.labelCaps()),
                    const SizedBox(height: 8),
                    Consumer<CatalogosProvider>(
                      builder: (context, provider, child) {
                        final list = provider.municipios;
                        if (list.isEmpty) {
                          return Text('Cargando municipios...',
                              style: AppText.bodyMd(color: AppColors.outline));
                        }

                        String currentNombre = '';
                        if (_selectedMunicipioId != null) {
                          try {
                            currentNombre = list
                                .firstWhere((m) => m.id == _selectedMunicipioId)
                                .nombre;
                          } catch (_) {}
                        }

                        return Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            border: Border.all(color: AppColors.outlineVariant),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Autocomplete<Object>(
                            key: ValueKey('auto_mun_$_selectedMunicipioId'),
                            initialValue: TextEditingValue(text: currentNombre),
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == '') return list;
                              return list.where((m) => m.nombre
                                  .toLowerCase()
                                  .contains(
                                      textEditingValue.text.toLowerCase()));
                            },
                            displayStringForOption: (option) =>
                                (option as dynamic).nombre,
                            onSelected: (option) {
                              setState(() {
                                _selectedMunicipioId = (option as dynamic).id;
                              });
                            },
                            fieldViewBuilder:
                                (ctx, controller, focusNode, onSubmitted) {
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                  hintText: 'Buscar municipio...',
                                  hintStyle:
                                      AppText.bodyMd(color: AppColors.outline),
                                  prefixIcon: const Icon(Icons.location_city,
                                      color: AppColors.primary, size: 20),
                                  border: InputBorder.none,
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                              );
                            },
                            optionsViewBuilder: (ctx, onSelected, options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 8.0,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width - 80,
                                    constraints:
                                        const BoxConstraints(maxHeight: 250),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListView.separated(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: options.length,
                                      separatorBuilder: (c, i) =>
                                          const Divider(height: 1),
                                      itemBuilder: (ctx, index) {
                                        final option = options.elementAt(index);
                                        return ListTile(
                                          title: Text(
                                              (option as dynamic).nombre,
                                              style: AppText.bodyMd()),
                                          onTap: () => onSelected(option),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
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
            );
          },
        ),
      ],
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:provider/provider.dart';
import '../../data/providers/lotes_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/catalogos_provider.dart';
import '../../data/models/lote_model.dart';
import 'home_screen.dart';

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
  bool _editingZone = false;
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _manualLocationCtrl = TextEditingController();
  final TextEditingController _manualMunicipioCtrl = TextEditingController();

  BitmapDescriptor? _dotMarker;

  @override
  void initState() {
    super.initState();
    _initDotMarker();
    _nameController =
        TextEditingController(text: widget.loteToEdit?.nombre ?? '');
    _areaController = TextEditingController(
        text: widget.loteToEdit != null
            ? widget.loteToEdit!.superficieHectareas.toString()
            : '');
    _lat = widget.loteToEdit?.latitud;
    _lng = widget.loteToEdit?.longitud;
    _locationLabel = widget.loteToEdit?.descripcion;
    _selectedMunicipioId = widget.loteToEdit?.municipioId;
    _selectedTipoSueloId = widget.loteToEdit?.tipoSueloId;
    if (widget.loteToEdit != null) {
      final desc = widget.loteToEdit!.descripcion ?? '';
      if (desc.contains(' – ')) {
        final parts = desc.split(' – ');
        _manualLocationCtrl.text = parts[0].trim();
        _manualMunicipioCtrl.text = parts[1].trim();
      } else {
        _manualLocationCtrl.text = desc;
      }
    }
    if (_lat != null && _lng != null) {
      _initializePolygon(_lat!, _lng!,
          ha: widget.loteToEdit?.superficieHectareas);
    }
    // Cargar catálogos (municipios) si no están cargados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final catalogos = context.read<CatalogosProvider>();
      if (catalogos.municipios.isEmpty) {
        catalogos.cargarCatalogos();
      }
      // Si es un lote nuevo (sin coords previas), centrar el mapa en la ubicación actual
      if (widget.loteToEdit == null) {
        _autoLocate();
      }
    });
  }

  /// Centra el mapa silenciosamente en la ubicación GPS actual al abrir la pantalla.
  /// No activa el polígono ni la geocodificación — solo mueve la cámara.
  Future<void> _autoLocate() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever ||
          perm == LocationPermission.denied) {
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (!mounted) return;
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 15.0),
      );
    } catch (_) {
      // Si falla el GPS silenciosamente, el mapa queda en Valledupar como respaldo
    }
  }

  Future<void> _initDotMarker() async {
    final int size = 32; // Puntos pequeños y finos
    final dart_ui.PictureRecorder pictureRecorder = dart_ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()..color = const Color(0xFFFF6B00);
    final Paint paint2 = Paint()..color = Colors.white;

    // Borde naranja y centro blanco
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
    canvas.drawCircle(Offset(size / 2, size / 2), (size / 2.0) - 4, paint2);

    final dart_ui.Image image =
        await pictureRecorder.endRecording().toImage(size, size);
    final ByteData? byteData =
        await image.toByteData(format: dart_ui.ImageByteFormat.png);
    final Uint8List uint8List = byteData!.buffer.asUint8List();

    if (mounted) {
      setState(() {
        _dotMarker = BitmapDescriptor.bytes(uint8List);
      });
    }
  }

  BitmapDescriptor? _areaMarkerIcon;
  String _lastAreaText = '';

  Future<void> _updateAreaMarker(String haText, String m2Text) async {
    final String text = '$m2Text m²\n($haText Ha)';
    if (text == _lastAreaText) return;
    _lastAreaText = text;

    final dart_ui.PictureRecorder pictureRecorder = dart_ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final textSpan = TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18, // Letra pequeña y sutil
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final paint = Paint()
      ..color = const Color(0xFFFF6B00).withValues(alpha: 0.85);
    final rect =
        Rect.fromLTRB(0, 0, textPainter.width + 24, textPainter.height + 12);
    final RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(rrect, paint);

    textPainter.paint(canvas, const Offset(12, 6));

    final dart_ui.Image img = await pictureRecorder
        .endRecording()
        .toImage(rect.width.toInt(), rect.height.toInt());
    final ByteData? data =
        await img.toByteData(format: dart_ui.ImageByteFormat.png);

    if (mounted) {
      setState(() {
        _areaMarkerIcon = BitmapDescriptor.bytes(data!.buffer.asUint8List());
      });
    }
  }

  LatLng _getPolygonCentroid() {
    if (_polygonLatLngs.isEmpty) return const LatLng(0, 0);
    double latSum = 0;
    double lngSum = 0;
    for (var p in _polygonLatLngs) {
      latSum += p.latitude;
      lngSum += p.longitude;
    }
    return LatLng(
        latSum / _polygonLatLngs.length, lngSum / _polygonLatLngs.length);
  }

  void _initializePolygon(double lat, double lng, {double? ha}) {
    final areaHa = ha ?? double.tryParse(_areaController.text) ?? 1.0;
    final totalAreaM2 = areaHa * 10000.0;
    final sideMeters = math.sqrt(totalAreaM2);

    final latRad = lat * math.pi / 180.0;
    final metersPerLat = 111132.95;
    final metersPerLng = 111132.95 * math.cos(latRad);

    final dLat = (sideMeters / 2.0) / metersPerLat;
    final dLng = (sideMeters / 2.0) / metersPerLng;

    setState(() {
      _polygonLatLngs = [
        LatLng(lat + dLat, lng - dLng),
        LatLng(lat + dLat, lng + dLng),
        LatLng(lat - dLat, lng + dLng),
        LatLng(lat - dLat, lng - dLng),
      ];
    });
    // Se asegura de generar el icono de área instantáneamente
    _calculateAreaFromLatLngs();
  }

  void _calculateAreaFromLatLngs() {
    if (_polygonLatLngs.length < 3) return;
    if (_lat == null || _lng == null) return;
    final latRad = _lat! * math.pi / 180.0;
    const metersPerLat = 111132.95;
    final metersPerLng = 111132.95 * math.cos(latRad);

    final points = _polygonLatLngs.map((ll) {
      return Offset(
        (ll.longitude - _lng!) * metersPerLng,
        (ll.latitude - _lat!) * metersPerLat,
      );
    }).toList();

    double area = 0.0;
    for (int i = 0; i < points.length; i++) {
      int j = (i + 1) % points.length;
      area += points[i].dx * points[j].dy;
      area -= points[j].dx * points[i].dy;
    }
    area = (area.abs() / 2.0); // Area in square meters
    double ha = area / 10000.0; // 1 Hectare = 10,000 m²
    if (ha < 0.1) ha = 0.1;
    final haText = ha.toStringAsFixed(1);
    final m2Text = area.toStringAsFixed(0);
    _areaController.text = haText;
    _updateAreaMarker(haText, m2Text);
  }

  String? _selectedMunicipioId;
  String? _selectedTipoSueloId;

  List<LatLng> _polygonLatLngs = [];

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _searchCtrl.dispose();
    _manualLocationCtrl.dispose();
    _manualMunicipioCtrl.dispose();
    super.dispose();
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

      // Auto-inicializar polígono de 4 puntos y habilitar modo de edición inmediato
      _initializePolygon(_lat!, _lng!);
      _editingZone = true;

      if (_mapController != null) {
        _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(_lat!, _lng!), 16.0));
      }

      try {
        final placemarks = await placemarkFromCoordinates(_lat!, _lng!);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = [p.street, p.subLocality, p.locality]
              .where((s) => s != null && s.isNotEmpty)
              .toList();
          final streetAddress = parts.isNotEmpty
              ? parts.join(', ')
              : '${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}';

          setState(() {
            _locationLabel = streetAddress;
            _manualLocationCtrl.text = streetAddress;
          });

          // Auto-seleccionar municipio si coincide con el catálogo
          final locality = p.locality;
          if (locality != null) {
            if (!mounted) return;
            final catalogos = context.read<CatalogosProvider>();
            try {
              final match = catalogos.municipios.firstWhere(
                (m) => m.nombre.toLowerCase().contains(locality.toLowerCase()),
              );
              setState(() {
                _selectedMunicipioId = match.id;
                _manualMunicipioCtrl.clear();
              });
            } catch (_) {
              // No hay coincidencia exacta, se coloca en manual de forma automática en el layout
              setState(() {
                _selectedMunicipioId = null;
                _manualMunicipioCtrl.text = locality;
              });
            }
          }
        }
      } catch (_) {
        final fallbackAddress =
            '${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}';
        setState(() {
          _locationLabel = fallbackAddress;
          _manualLocationCtrl.text = fallbackAddress;
        });
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
      _showSnack('Por favor ingresa el nombre de tu lote.');
      return;
    }

    final areaStr = _areaController.text.trim();
    final areaVal = double.tryParse(areaStr);
    if (areaStr.isEmpty || areaVal == null || areaVal <= 0.0) {
      _showSnack('Por favor ingresa un área válida (mayor a 0 hectáreas).');
      return;
    }

    // Validación de Municipio eliminada (ahora es opcional)

    if (_manualLocationCtrl.text.trim().isEmpty) {
      _showSnack('Por favor ingresa la dirección o ubicación de tu lote.');
      return;
    }

    // ─── Límite de 5 ha eliminado ─────────
    final lotesProvider = context.read<LotesProvider>();
    final auth = context.read<AuthProvider>();
    final isEditing = widget.loteToEdit != null;
    final prefs = await SharedPreferences.getInstance();
    final isFirstLote = !isEditing &&
        !lotesProvider.hasLotes &&
        !(prefs.getBool('has_lotes') ?? false);

    setState(() => _saving = true);
    try {
      // ─── REAL SAVE ─────────────────────────────────────────
      // Construir descripción completa para offline
      final partes = <String>[];
      if (_manualLocationCtrl.text.trim().isNotEmpty) {
        partes.add(_manualLocationCtrl.text.trim());
      }
      if (_manualMunicipioCtrl.text.trim().isNotEmpty) {
        partes.add(_manualMunicipioCtrl.text.trim());
      }
      if (_locationLabel != null && partes.isEmpty) {
        partes.add(_locationLabel!);
      }
      final descripcionFinal =
          partes.isNotEmpty ? partes.join(' – ') : _locationLabel;

      bool success = false;

      if (isEditing) {
        success = await lotesProvider.actualizarLote(
          id: widget.loteToEdit!.id,
          nombre: name,
          descripcion: descripcionFinal,
          superficieHectareas: double.tryParse(_areaController.text) ?? 0.0,
          municipioId: _selectedMunicipioId,
          tipoSueloId: _selectedTipoSueloId,
          latitud: _lat,
          longitud: _lng,
        );
      } else {
        success = await lotesProvider.crearLote(
          nombre: name,
          descripcion: descripcionFinal,
          superficieHectareas: double.tryParse(_areaController.text) ?? 0.0,
          latitud: _lat,
          longitud: _lng,
          propietarioId: auth.currentUser?.id ?? 'unknown',
          municipioId: _selectedMunicipioId,
          tipoSueloId: _selectedTipoSueloId,
        );
      }

      setState(() => _saving = false);

      if (!success) {
        final rawError = lotesProvider.errorMessage ?? '';
        final friendlyError =
            'Error al ${isEditing ? 'actualizar' : 'guardar'} el lote: $rawError';
        _showSnack(friendlyError);
        return;
      }
    } catch (e) {
      setState(() => _saving = false);
      _showSnack('Error inesperado al guardar el lote: $e');
      return;
    }

    if (!mounted) return;

    if (!isEditing) {
      await prefs.setBool('has_lotes', true);
    }

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
                        isEditing
                            ? '¡Lote Actualizado!'
                            : (isFirstLote
                                ? '¡Registraste tu\nprimer lote!'
                                : '¡Lote registrado!'),
                        textAlign: TextAlign.center,
                        style: AppText.h2(),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isEditing
                            ? 'Los cambios en "$name" han sido guardados.'
                            : '"$name" ya está disponible en tu sistema.',
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
    if (isFirstLote) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
      return;
    }
    Navigator.pop(
        context, isEditing ? 'updated' : 'created'); // Back to list with result
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  // ─── SEARCH LOCATION ──────────────────────────────────────────────────────
  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) return;
    try {
      final locations = await locationFromAddress(query);
      if (locations.isEmpty) {
        _showSnack('No se encontró "$query". Intenta con otro nombre.');
        return;
      }
      final loc = locations.first;
      setState(() {
        _lat = loc.latitude;
        _lng = loc.longitude;
        _locationLabel = query;
        _manualLocationCtrl.text = query;
        _editingZone = true;
      });
      _initializePolygon(loc.latitude, loc.longitude);
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(_lat!, _lng!), 15.0),
      );
    } catch (_) {
      _showSnack('No se pudo buscar esa ubicación.');
    }
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
                          : const LatLng(10.7667, -74.1833),
                      zoom: 14.0,
                    ),
                    mapType: MapType.hybrid,
                    onMapCreated: (controller) => _mapController = controller,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    // Tap solo activo cuando NO estamos editando la zona
                    onTap: _editingZone
                        ? null
                        : (LatLng location) async {
                            setState(() {
                              _lat = location.latitude;
                              _lng = location.longitude;
                              _locationLabel = 'Buscando dirección...';
                              _editingZone =
                                  true; // Habilita edición de esquinas inmediatamente
                            });
                            _initializePolygon(
                                location.latitude, location.longitude);
                            try {
                              final placemarks = await placemarkFromCoordinates(
                                  location.latitude, location.longitude);
                              if (placemarks.isNotEmpty) {
                                final place = placemarks.first;
                                setState(() {
                                  final addr =
                                      '${place.locality ?? place.subAdministrativeArea}, ${place.administrativeArea}';
                                  _locationLabel = addr;
                                  _manualLocationCtrl.text = addr;
                                });
                              }
                            } catch (_) {
                              setState(() {
                                _locationLabel = 'Ubicación en mapa';
                                _manualLocationCtrl.text =
                                    '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}';
                              });
                            }
                          },
                    markers: {
                      if (_lat != null && _lng != null)
                        Marker(
                          markerId: const MarkerId('lote_marker'),
                          position: LatLng(_lat!, _lng!),
                          infoWindow:
                              InfoWindow(title: _locationLabel ?? 'Lote'),
                        ),
                      if (_editingZone && _polygonLatLngs.isNotEmpty) ...[
                        ..._polygonLatLngs.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final latLng = entry.value;
                          return Marker(
                            markerId: MarkerId('vertex_$idx'),
                            position: latLng,
                            draggable: true,
                            anchor: const Offset(0.5, 0.5),
                            icon: _dotMarker ??
                                BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueOrange),
                            onDrag: (newLatLng) {
                              setState(() {
                                _polygonLatLngs[idx] = newLatLng;
                              });
                              _calculateAreaFromLatLngs();
                            },
                            onDragEnd: (newLatLng) {
                              setState(() {
                                _polygonLatLngs[idx] = newLatLng;
                              });
                              _calculateAreaFromLatLngs();
                            },
                          );
                        }),
                        if (_areaMarkerIcon != null)
                          Marker(
                            markerId: const MarkerId('area_marker'),
                            position: _getPolygonCentroid(),
                            anchor: const Offset(0.5, 0.5),
                            icon: _areaMarkerIcon!,
                          ),
                      ],
                    },
                    polygons: {
                      if (_polygonLatLngs.isNotEmpty)
                        Polygon(
                          polygonId: const PolygonId('lote_poly'),
                          points: _polygonLatLngs,
                          strokeColor: const Color(0xFFFF6B00),
                          strokeWidth: 3,
                          fillColor:
                              const Color(0xFFFF6B00).withValues(alpha: 0.15),
                        ),
                    },
                  ),
                ),

                // ── Buscador flotante de ubicación ─────────────────────────
                Positioned(
                  top: 12,
                  left: 16,
                  right: 16,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(14),
                    child: TextField(
                      controller: _searchCtrl,
                      textInputAction: TextInputAction.search,
                      onSubmitted: _searchLocation,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Buscar ubicación del lote...',
                        hintStyle:
                            const TextStyle(color: Colors.grey, fontSize: 14),
                        prefixIcon:
                            const Icon(Icons.search, color: AppColors.primary),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_forward,
                              color: AppColors.primary),
                          onPressed: () => _searchLocation(_searchCtrl.text),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),

                // Area is now displayed inside the polygon via _areaMarkerIcon

                // ── Instrucción y Botón X (Borrar Ubicación) ──────────────────
                if (_lat != null)
                  Positioned(
                    top: 76,
                    left: 16,
                    right: 16,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_polygonLatLngs.isNotEmpty)
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.lightGreen.shade600,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2))
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.touch_app,
                                      color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Mantén presionada una esquina para moverla',
                                      style: AppText.bodyMd(color: Colors.white)
                                          .copyWith(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          const Spacer(),
                        Container(
                          decoration: const BoxDecoration(
                            color: AppColors.errorContainer,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 2))
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close,
                                color: AppColors.onErrorContainer, size: 20),
                            tooltip: 'Borrar ubicación y área',
                            onPressed: () {
                              setState(() {
                                _lat = null;
                                _lng = null;
                                _locationLabel = null;
                                _polygonLatLngs.clear();
                                _areaController.clear();
                                _manualLocationCtrl.clear();
                                _manualMunicipioCtrl.clear();
                                _selectedMunicipioId = null;
                                _searchCtrl.clear();
                                _editingZone = false;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── Botones de control de zona flotantes ───────────────────
                if (_lat != null)
                  Positioned(
                    bottom: 12,
                    right: 16,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_polygonLatLngs.isNotEmpty) ...[
                          FloatingActionButton.small(
                            heroTag: 'zone_clear',
                            onPressed: () {
                              setState(() {
                                _polygonLatLngs.clear();
                                _editingZone = false;
                                _areaController.clear();
                              });
                              _showSnack('Zona del polígono quitada del mapa.');
                            },
                            backgroundColor: AppColors.errorContainer,
                            foregroundColor: AppColors.onErrorContainer,
                            tooltip: 'Eliminar polígono de área',
                            child: const Icon(Icons.delete_sweep),
                          ),
                          const SizedBox(width: 8),
                        ],
                        FloatingActionButton.extended(
                          heroTag: 'zone_toggle',
                          onPressed: () {
                            if (!_editingZone && _polygonLatLngs.isEmpty) {
                              _initializePolygon(_lat!, _lng!);
                            }
                            setState(() => _editingZone = !_editingZone);
                          },
                          backgroundColor: _editingZone
                              ? Colors.green.shade700
                              : const Color(0xFFFF6B00),
                          icon: Icon(
                            _editingZone
                                ? Icons.check
                                : Icons.edit_location_alt,
                            color: Colors.white,
                          ),
                          label: Text(
                            _editingZone
                                ? 'Confirmar zona'
                                : 'Definir / Editar zona',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── FORM (Draggable Bottom Sheet) ──────────────────────────
                DraggableScrollableSheet(
                  initialChildSize: 0.48,
                  minChildSize: 0.12,
                  maxChildSize: 0.9,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0, -4),
                              blurRadius: 16)
                        ],
                      ),
                      child: SingleChildScrollView(
                        controller: scrollController,
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

                            Text(
                                widget.loteToEdit != null
                                    ? 'Configurar Lote'
                                    : 'Registrar Lote',
                                style: AppText.h2()),
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
                                hintText: 'Ej: Lote Norte',
                                hintStyle:
                                    AppText.bodyMd(color: AppColors.outline),
                                prefixIcon: const Icon(Icons.landscape,
                                    color: AppColors.primary, size: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: AppColors.outlineVariant),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: AppColors.outlineVariant),
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
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.surface,
                                hintText: 'Ej: 2.5',
                                prefixIcon: const Icon(Icons.straighten,
                                    color: AppColors.primary, size: 20),
                                suffixText: 'hectáreas',
                                suffixStyle: AppText.bodyMd(
                                    color: AppColors.onSurfaceVariant),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: AppColors.outlineVariant),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: AppColors.outlineVariant),
                                ),
                                contentPadding: const EdgeInsets.all(14),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ── Municipio (Catálogo) ──────────────────────────────
                            RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: 'MUNICIPIO',
                                  style: AppText.labelCaps(),
                                ),
                                TextSpan(
                                  text: '  (opcional)',
                                  style: AppText.labelCaps().copyWith(
                                    color: AppColors.outline,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 11,
                                  ),
                                ),
                              ]),
                            ),
                            const SizedBox(height: 8),
                            Consumer<CatalogosProvider>(
                              builder: (context, provider, child) {
                                final list = provider.municipios;
                                if (provider.isLoading && list.isEmpty) {
                                  return Container(
                                    height: 56,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      border: Border.all(
                                          color: AppColors.outlineVariant),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.primary)),
                                        SizedBox(width: 10),
                                        Text('Cargando municipios...'),
                                      ],
                                    ),
                                  );
                                }
                                if (list.isEmpty) {
                                  // Sin conexión / catálogo vacío: campo manual
                                  return TextField(
                                    controller: _manualMunicipioCtrl,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppColors.surface,
                                      hintText:
                                          'Escribe el municipio manualmente...',
                                      prefixIcon: const Icon(
                                          Icons.location_city,
                                          color: AppColors.primary,
                                          size: 20),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.refresh,
                                            color: AppColors.primary, size: 20),
                                        tooltip: 'Reintentar carga',
                                        onPressed: () =>
                                            provider.cargarCatalogos(),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: AppColors.outlineVariant),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: AppColors.outlineVariant),
                                      ),
                                      contentPadding: const EdgeInsets.all(14),
                                    ),
                                  );
                                }

                                String currentNombre = '';
                                if (_selectedMunicipioId != null) {
                                  try {
                                    currentNombre = list
                                        .firstWhere(
                                            (m) => m.id == _selectedMunicipioId)
                                        .nombre;
                                  } catch (_) {}
                                }

                                return Container(
                                  height: 56,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    border: Border.all(
                                        color: AppColors.outlineVariant),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Autocomplete<Object>(
                                    key: ValueKey(
                                        'auto_mun_$_selectedMunicipioId'),
                                    initialValue:
                                        TextEditingValue(text: currentNombre),
                                    optionsBuilder:
                                        (TextEditingValue textEditingValue) {
                                      if (textEditingValue.text == '') {
                                        return list;
                                      }
                                      return list.where((m) => m.nombre
                                          .toLowerCase()
                                          .contains(textEditingValue.text
                                              .toLowerCase()));
                                    },
                                    displayStringForOption: (option) =>
                                        (option as dynamic).nombre,
                                    onSelected: (option) {
                                      setState(() {
                                        _selectedMunicipioId =
                                            (option as dynamic).id;
                                      });
                                      // Volar al municipio en el mapa
                                      _searchLocation(
                                          (option as dynamic).nombre);
                                    },
                                    fieldViewBuilder: (ctx, controller,
                                        focusNode, onSubmitted) {
                                      return TextField(
                                        controller: controller,
                                        focusNode: focusNode,
                                        decoration: InputDecoration(
                                          hintText: 'Buscar municipio...',
                                          hintStyle: AppText.bodyMd(
                                              color: AppColors.outline),
                                          prefixIcon: const Icon(
                                              Icons.location_city,
                                              color: AppColors.primary,
                                              size: 20),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 16),
                                        ),
                                      );
                                    },
                                    optionsViewBuilder:
                                        (ctx, onSelected, options) {
                                      return Align(
                                        alignment: Alignment.topLeft,
                                        child: Material(
                                          elevation: 8.0,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                80,
                                            constraints: const BoxConstraints(
                                                maxHeight: 250),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: NotificationListener<
                                                ScrollNotification>(
                                              onNotification: (notification) {
                                                if (notification
                                                    is ScrollUpdateNotification) {
                                                  SystemChannels.textInput
                                                      .invokeMethod(
                                                          'TextInput.hide');
                                                }
                                                return true; // Evita propagar el scroll al BottomSheet
                                              },
                                              child: ListView.separated(
                                                padding: EdgeInsets.zero,
                                                shrinkWrap: true,
                                                itemCount: options.length,
                                                separatorBuilder: (c, i) =>
                                                    const Divider(height: 1),
                                                itemBuilder: (ctx, index) {
                                                  final option =
                                                      options.elementAt(index);
                                                  return ListTile(
                                                    title: Text(
                                                        (option as dynamic)
                                                            .nombre,
                                                        style:
                                                            AppText.bodyMd()),
                                                    onTap: () =>
                                                        onSelected(option),
                                                  );
                                                },
                                              ),
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

                            // ── Dirección / ubicación manual ──────────────────────
                            Text('DIRECCIÓN O UBICACIÓN',
                                style: AppText.labelCaps()),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _manualLocationCtrl,
                              textCapitalization: TextCapitalization.sentences,
                              onSubmitted: (value) {
                                if (value.trim().isNotEmpty) {
                                  _searchLocation(value.trim());
                                }
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.surface,
                                hintText: 'Ej: Vereda El Carmen, Km 5 vía...',
                                prefixIcon: const Icon(
                                    Icons.edit_location_outlined,
                                    color: AppColors.primary,
                                    size: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: AppColors.outlineVariant),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: AppColors.outlineVariant),
                                ),
                                contentPadding: const EdgeInsets.all(14),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ── Tipo de Suelo ──────────────────────
                            RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: 'TIPO DE SUELO',
                                  style: AppText.labelCaps(),
                                ),
                                TextSpan(
                                  text: '  (opcional)',
                                  style: AppText.labelCaps().copyWith(
                                    color: AppColors.outline,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 11,
                                  ),
                                ),
                              ]),
                            ),
                            const SizedBox(height: 8),
                            Consumer<CatalogosProvider>(
                              builder: (context, catalogos, child) {
                                final list = catalogos.tiposSuelo;
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    border: Border.all(
                                        color: AppColors.outlineVariant),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButtonFormField<String>(
                                      initialValue: _selectedTipoSueloId,
                                      menuMaxHeight: 220,
                                      hint: Text(
                                        'Seleccionar tipo de suelo...',
                                        style: AppText.bodyMd(
                                            color: AppColors.outline),
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        icon: Icon(Icons.layers_outlined,
                                            color: AppColors.primary, size: 20),
                                      ),
                                      isExpanded: true,
                                      items: list.map((suelo) {
                                        return DropdownMenuItem<String>(
                                          value: suelo.id,
                                          child: Text(
                                            '${suelo.nombre} (${suelo.drenaje != null ? "Drenaje ${suelo.drenaje}" : ""})',
                                            style: AppText.bodyMd(),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedTipoSueloId = val;
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // ── GPS button ────────────────────────────────────────
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: OutlinedButton.icon(
                                onPressed:
                                    _loadingLocation ? null : _getLocation,
                                icon: _loadingLocation
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.primary),
                                      )
                                    : const Icon(Icons.my_location,
                                        color: AppColors.primary),
                                label: Text(
                                  _loadingLocation
                                      ? 'OBTENIENDO UBICACIÓN...'
                                      : _lat != null
                                          ? 'ACTUALIZAR UBICACIÓN'
                                          : 'USAR MI UBICACIÓN ACTUAL',
                                  style: AppText.labelCapsLg(
                                      color: AppColors.primary),
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
                              text: _saving
                                  ? 'GUARDANDO...'
                                  : (widget.loteToEdit != null
                                      ? 'GUARDAR CAMBIOS'
                                      : 'GUARDAR LOTE'),
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
      ),
    );
  }
}

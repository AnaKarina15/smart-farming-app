import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/providers/lotes_provider.dart';
import '../../data/providers/operaciones_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/offline_banner.dart';
import '../widgets/rugged_button.dart';
import '../common/agro_bottom_nav.dart';
import 'finding_success_screen.dart';
import '../../data/providers/catalogos_provider.dart';
import '../../data/services/sync_service.dart';

class FindFindingScreen extends StatefulWidget {
  final AgroTab currentTab;
  const FindFindingScreen({super.key, this.currentTab = AgroTab.home});

  @override
  State<FindFindingScreen> createState() => _FindFindingScreenState();
}

class _FindFindingScreenState extends State<FindFindingScreen> {
  String? _loteId;
  String? _loteNombre;
  String? _selectedPlagaId;
  String? _selectedPlagaNombre;
  String? _sintomasSugeridos;
  String _tipo = 'INSECTO'; // solo para la UI de tipo detección
  // Severidad en valores UI: LEVE / MEDIO / CRÍTICO
  // se convierte al enum del backend: baja / media / alta
  String _severidad = 'MEDIO';
  String? _fotoPath;
  bool _guardando = false;
  // Para el campo de plaga libre ("Otra plaga/enfermedad")
  final TextEditingController _plagaOtroCtrl = TextEditingController();
  bool _usandoPlagaOtro = false;

  /// Convierte la severidad de la UI al enum del backend.
  /// Backend acepta: baja | media | alta | critica
  String _severidadBackend() {
    switch (_severidad) {
      case 'LEVE':    return 'baja';
      case 'CRÍTICO': return 'alta';
      default:        return 'media'; // MEDIO
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LotesProvider>();
      if (!provider.hasLotes) {
        provider.init();
      }
    });
  }

  @override
  void dispose() {
    _plagaOtroCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickEvidencia() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Agregar evidencia de plaga',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.camera_alt, color: Colors.white),
                ),
                title: const Text('Tomar foto'),
                subtitle: const Text('Usar la cámara del dispositivo'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.secondary,
                  child: Icon(Icons.photo_library, color: Colors.white),
                ),
                title: const Text('Elegir de galería'),
                subtitle: const Text('Seleccionar una imagen de la galería'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              if (_fotoPath != null)
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.error,
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  title: const Text('Eliminar foto actual'),
                  onTap: () {
                    setState(() {
                      _fotoPath = null;
                    });
                    Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _fotoPath = pickedFile.path;
      });
    }
  }

  Future<void> _guardarHallazgo() async {
    final plagaOtroValido = _usandoPlagaOtro && _plagaOtroCtrl.text.trim().isNotEmpty;
    final plagaIdValido = !_usandoPlagaOtro && _selectedPlagaId != null && _selectedPlagaId != 'OTROS';

    if (_loteId == null || (!plagaIdValido && !plagaOtroValido)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _loteId == null
                ? 'Por favor selecciona un lote.'
                : 'Por favor indica la plaga o escribe su nombre.',
            style: AppText.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    final now = DateTime.now().toIso8601String();

    // Payload alineado con POST /api/v1/hallazgos (Sprint 3)
    // - NUNCA se envía userId (el backend lo toma del JWT)
    // - NUNCA se envía tipo (no existe en el schema de hallazgos)
    // - severidad debe ser el enum del backend: baja/media/alta/critica
    final data = <String, dynamic>{
      'loteId': _loteId,
      'severidad': _severidadBackend(),
      'fecha': now,
      'isPendingSync': 1,
      if (plagaIdValido) 'plagaId': _selectedPlagaId,
      if (plagaOtroValido) 'plagaOtro': _plagaOtroCtrl.text.trim(),
      if (_fotoPath != null) 'fotoPath': _fotoPath,
    };

    final navigator = Navigator.of(context);
    final lotesProv = context.read<LotesProvider>();
    final syncService = context.read<SyncService>();

    // OperacionesProvider guarda en SQLite con isPendingSync=1;
    // SyncService lo sube al backend cuando haya conexión.
    await context.read<OperacionesProvider>().crearHallazgo(data);

    try {
      syncService.syncNow(lotesProvider: lotesProv);
    } catch (_) {}

    setState(() => _guardando = false);

    if (!mounted) return;
    navigator.pushReplacement(
      MaterialPageRoute(
        builder: (_) => FindingSuccessScreen(
          lote: _loteNombre ?? '',
          findingType: plagaOtroValido
              ? _plagaOtroCtrl.text.trim()
              : (_selectedPlagaNombre ?? _severidad),
          currentTab: widget.currentTab,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lotesProvider = context.watch<LotesProvider>();
    final lotes = lotesProvider.lotes;

    // Auto-seleccionar primer lote si no hay ninguno seleccionado
    if (_loteId == null && lotes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _loteId = lotes.first.id;
            _loteNombre = lotes.first.nombre;
          });
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: OfflineBanner()),
            const SizedBox(height: 16),
            Text(
              'REGISTRAR HALLAZGO',
              style: AppText.labelCaps(color: AppColors.primary),
            ),
            const SizedBox(height: 5),
            const Divider(color: AppColors.outlineVariant),
            const SizedBox(height: 24),
            _label('LOTE'),
            // ── Dropdown conectado al LotesProvider ──────────
            if (lotesProvider.isLoading && lotes.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (lotes.isEmpty)
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  border: Border.all(color: AppColors.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sin lotes registrados',
                    style: AppText.bodyMd(color: AppColors.onSurfaceVariant),
                  ),
                ),
              )
            else
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  border: Border.all(color: AppColors.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _loteId,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.onSurfaceVariant),
                    items: lotes
                        .map((l) => DropdownMenuItem(
                              value: l.id,
                              child: Text(l.nombre),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      final lote = lotes.firstWhere((l) => l.id == v);
                      setState(() {
                        _loteId = v;
                        _loteNombre = lote.nombre;
                      });
                    },
                  ),
                ),
              ),
            const SizedBox(height: 24),
            _label('PLAGA IDENTIFICADA'),
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                border: Border.all(color: AppColors.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Consumer<CatalogosProvider>(
                builder: (context, provider, child) {
                  final list = provider.plagas;
                  if (_selectedPlagaId == null && list.isNotEmpty) {
                    _selectedPlagaId = list.first.id;
                    _selectedPlagaNombre = list.first.nombre;
                    _tipo = list.first.tipo ?? 'INSECTO';
                    _severidad = list.first.severidadTipica ?? 'MEDIO';
                    _sintomasSugeridos = list.first.sintomas;
                  }

                  return DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPlagaId,
                      isExpanded: true,
                      menuMaxHeight: 300,
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: AppColors.onSurfaceVariant),
                      items: [
                        ...list.map((p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(p.nombre),
                            )),
                        const DropdownMenuItem(
                          value: 'OTROS',
                          child: Text('Otra plaga/enfermedad...'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() {
                          _selectedPlagaId = v;
                          if (v != 'OTROS') {
                            _usandoPlagaOtro = false;
                            final p = list.firstWhere((p) => p.id == v);
                            _selectedPlagaNombre = p.nombre;
                            _tipo = p.tipo ?? 'INSECTO';
                            _severidad = p.severidadTipica ?? 'MEDIO';
                            _sintomasSugeridos = p.sintomas;
                          } else {
                            _usandoPlagaOtro = true;
                            _sintomasSugeridos = null;
                            _selectedPlagaNombre = null;
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            // Campo de texto libre cuando se selecciona "Otra plaga"
            if (_usandoPlagaOtro) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _plagaOtroCtrl,
                decoration: InputDecoration(
                  hintText: 'Escribe el nombre de la plaga o enfermedad',
                  hintStyle: AppText.bodyMd(color: AppColors.outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ],
            if (_sintomasSugeridos != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        color: Color(0xFF1B5E20), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Síntomas típicos: $_sintomasSugeridos',
                        style: AppText.bodyMd(color: const Color(0xFF1B5E20)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (_selectedPlagaId == 'OTROS' || _selectedPlagaId == null) ...[
              _label('TIPO DETECTADO'),
              Row(
                children: [
                  Expanded(child: _tipoOption('INSECTO', Icons.bug_report)),
                  const SizedBox(width: 12),
                  Expanded(child: _tipoOption('ENFERMEDAD', Icons.coronavirus)),
                  const SizedBox(width: 12),
                  Expanded(child: _tipoOption('MALEZA', Icons.grass)),
                ],
              ),
              const SizedBox(height: 24),
            ],
            _label('SEVERIDAD'),
            Row(
              children: [
                Expanded(
                    child: _severidadOption('LEVE', const Color(0xFFC8E6C9),
                        const Color(0xFF2E7D32))),
                const SizedBox(width: 12),
                Expanded(
                    child: _severidadOption('MEDIO', const Color(0xFFFFF59D),
                        const Color(0xFFF57F17))),
                const SizedBox(width: 12),
                Expanded(
                    child: _severidadOption('CRÍTICO', const Color(0xFFFFCDD2),
                        const Color(0xFFC62828))),
              ],
            ),
            const SizedBox(height: 24),
            _label('EVIDENCIA'),
            GestureDetector(
              onTap: _pickEvidencia,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _fotoPath != null ? AppColors.primary : AppColors.outlineVariant,
                    width: _fotoPath != null ? 2 : 1,
                  ),
                ),
                child: Stack(
                  children: [
                    if (_fotoPath == null) ...[
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _DashedRectPainter(color: AppColors.outline),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.camera_alt_outlined,
                              color: AppColors.onSurfaceVariant,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'TOMAR FOTO / SUBIR EVIDENCIA',
                              style: AppText.labelCaps(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(_fotoPath!),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _fotoPath = null;
                            });
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.black.withValues(alpha: 0.6),
                            radius: 16,
                            child: const Icon(Icons.close, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.edit, color: Colors.white, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                'TAP PARA CAMBIAR',
                                style: AppText.labelCaps(color: Colors.white).copyWith(fontSize: 9),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            RuggedButton(
              text: _guardando ? 'GUARDANDO...' : 'GUARDAR',
              onPressed: _guardando ? () {} : _guardarHallazgo,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: AgroBottomNav(
        current: widget.currentTab,
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: AppText.labelCaps()),
      );

  Widget _tipoOption(String value, IconData icon) {
    final isSelected = _tipo == value;
    return GestureDetector(
      onTap: () => setState(() => _tipo = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primary : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppText.labelCaps(
                      color: isSelected ? Colors.white : AppColors.primary)
                  .copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _severidadOption(String value, Color bgColor, Color textColor) {
    final isSelected = _severidad == value;
    return GestureDetector(
      onTap: () => setState(() => _severidad = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? bgColor : bgColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: isSelected ? textColor : Colors.transparent),
        ),
        child: Center(
          child: Text(
            value,
            style: AppText.labelCaps(
                color:
                    isSelected ? textColor : textColor.withValues(alpha: 0.5)),
          ),
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  _DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

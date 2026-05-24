import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../widgets/custom_app_bar.dart';
import '../common/agro_bottom_nav.dart';
import '../widgets/offline_banner.dart';
import '../widgets/rugged_button.dart';
import 'package:provider/provider.dart';
import '../../core/storage/database_helper.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/lotes_provider.dart';
import 'evaluation_success_screen.dart';

class EvaluationScreen extends StatefulWidget {
  final String loteName;
  final String? plagueName;
  final String? treatment;
  final String? treatmentTime;
  final AgroTab currentTab;

  const EvaluationScreen({
    super.key,
    required this.loteName,
    this.plagueName,
    this.treatment,
    this.treatmentTime,
    this.currentTab = AgroTab.home,
  });

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  String _estadoActual = 'Estable';
  final TextEditingController _observationsController = TextEditingController();
  bool _guardando = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (photo != null) {
        setState(() {
          _imageFile = File(photo.path);
        });
      }
    } catch (e) {
      debugPrint("Error al tomar foto: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasTreatment = widget.treatment != null && widget.treatment!.isNotEmpty;
    final titleText = widget.plagueName != null ? '${widget.loteName} - ${widget.plagueName}' : widget.loteName;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: OfflineBanner()),
            const SizedBox(height: 16),
            Text(
              hasTreatment ? 'Registrar Evaluación' : 'Registrar Observación',
              style: AppText.h2(color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              titleText,
              style: AppText.bodyLg(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),

            if (hasTreatment) ...[
              // Card 1: Tratamiento
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.science, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TRATAMIENTO APLICADO\nHACE ${widget.treatmentTime ?? ""}',
                            style: AppText.labelCaps(
                                color: AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.treatment!,
                            style: AppText.bodyLg(color: AppColors.onBackground)
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Form container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('ESTADO ACTUAL'),
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
                        value: _estadoActual,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: AppColors.onSurfaceVariant),
                        items: ['Estable', 'Mejorando', 'Empeorando']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _estadoActual = v ?? _estadoActual),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Observations
                  _label('OBSERVACIONES (OPCIONAL)'),
                  TextField(
                    controller: _observationsController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceContainerLowest,
                      hintText: 'Escriba aquí los detalles...',
                      hintStyle: AppText.bodyMd(color: AppColors.outline),
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
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Photo picker
                  _label('NUEVA FOTOGRAFÍA'),
                  GestureDetector(
                    onTap: _takePhoto,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: _imageFile == null ? 32 : 0),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        border: Border.all(
                            color: AppColors.primary,
                            width: 1,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: _imageFile != null
                          ? Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Image.file(
                                  _imageFile!,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel, color: Colors.white, size: 30),
                                  onPressed: () {
                                    setState(() {
                                      _imageFile = null;
                                    });
                                  },
                                )
                              ],
                            )
                          : Center(
                              child: Column(
                                children: [
                                  const Icon(Icons.camera_alt,
                                      color: AppColors.primary, size: 32),
                                  const SizedBox(height: 8),
                                  Text('TOMAR FOTO',
                                      style: AppText.labelCaps(color: AppColors.primary)),
                                ],
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            RuggedButton(
              text: _guardando ? 'GUARDANDO...' : (hasTreatment ? 'GUARDAR EVALUACIÓN' : 'GUARDAR OBSERVACIÓN'),
              icon: Icons.save,
              onPressed: _guardando ? () {} : () async {
                setState(() => _guardando = true);

                final lotesProvider = context.read<LotesProvider>();
                String loteId = 'unknown';
                if (lotesProvider.lotes.isNotEmpty) {
                  final found = lotesProvider.lotes.where((l) => l.nombre == widget.loteName).toList();
                  if (found.isNotEmpty) {
                    loteId = found.first.id;
                  }
                }

                final user = context.read<AuthProvider>().currentUser;
                final userId = user?.id ?? 'unknown';
                final id = 'obs_${DateTime.now().millisecondsSinceEpoch}';
                final now = DateTime.now().toIso8601String();

                await DatabaseHelper.instance.insert(DatabaseHelper.tableObservaciones, {
                  'id': id,
                  'loteId': loteId,
                  'loteNombre': widget.loteName,
                  'descripcion': _observationsController.text,
                  'fotoPath': _imageFile?.path,
                  'tipo': _estadoActual,
                  'fecha': now,
                  'userId': userId,
                  'createdAt': now,
                  'isPendingSync': 1,
                });

                if (!context.mounted) return;
                setState(() => _guardando = false);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EvaluationSuccessScreen(
                      loteName: widget.loteName,
                      plagueName: widget.plagueName ?? '',
                      isControlled: _estadoActual != 'Empeorando', // Logica simple para la pantalla de éxito
                      currentTab: widget.currentTab,
                    ),
                  ),
                );
              },
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
        child: Text(text, style: AppText.labelCaps(color: AppColors.onSurfaceVariant)),
      );
}

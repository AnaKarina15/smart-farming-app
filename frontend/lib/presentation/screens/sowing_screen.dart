import 'package:flutter/material.dart';
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
import 'sowing_success_screen.dart';
import 'package:provider/provider.dart';
import '../../core/storage/database_helper.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/lotes_provider.dart';
import '../../data/models/lote_model.dart';
import 'terrain_status_screen.dart';

class SowingScreen extends StatefulWidget {
  final String? fixedLote;
  final AgroTab currentTab;

  const SowingScreen({
    super.key,
    this.fixedLote,
    this.currentTab = AgroTab.home,
  });

  @override
  State<SowingScreen> createState() => _SowingScreenState();
}

class _SowingScreenState extends State<SowingScreen> {
  String _crop = 'Maíz';
  String? _loteId;
  String? _loteNombre;
  final TextEditingController _dateController = TextEditingController(
    text:
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
  );
  final TextEditingController _otherCropController = TextEditingController();
  bool _guardando = false;

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
    _dateController.dispose();
    _otherCropController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lotesProvider = context.watch<LotesProvider>();
    final lotes = lotesProvider.lotes;

    if (_loteId == null && lotes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            if (widget.fixedLote != null) {
              final found = lotes.where((l) => l.nombre == widget.fixedLote).toList();
              if (found.isNotEmpty) {
                _loteId = found.first.id;
                _loteNombre = found.first.nombre;
              } else {
                _loteId = lotes.first.id;
                _loteNombre = lotes.first.nombre;
              }
            } else {
              _loteId = lotes.first.id;
              _loteNombre = lotes.first.nombre;
            }
          });
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBack: true),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Registrar Nueva Siembra', style: AppText.h1()),
                  const SizedBox(height: 5),
                  Text(
                    'Complete los detalles del lote.',
                    style: AppText.bodyMd(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 10),
                  Text('SELECCIONAR CULTIVO', style: AppText.labelCaps()),
                  const SizedBox(height: 8),
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
                        value: _crop,
                        isExpanded: true,
                        icon: const Icon(Icons.expand_more,
                            color: AppColors.onSurfaceVariant),
                        items: ['Maíz', 'Banano', 'Café', 'Otro']
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => _crop = v ?? _crop),
                      ),
                    ),
                  ),
                  if (_crop == 'Otro') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _otherCropController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surfaceContainerLowest,
                        hintText: 'Especifique el cultivo',
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
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text('FECHA DE SIEMBRA', style: AppText.labelCaps()),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceContainerLowest,
                      hintText: 'Seleccione la fecha',
                      suffixIcon: const Icon(Icons.calendar_today,
                          color: AppColors.primary),
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
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _dateController.text =
                              "${picked.day}/${picked.month}/${picked.year}";
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Text('LOTE ASIGNADO', style: AppText.labelCaps()),
                  const SizedBox(height: 8),
                  if (lotesProvider.isLoading && lotes.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else if (lotes.isEmpty)
                    Text('Sin lotes', style: AppText.bodyMd())
                  else
                    _selector(lotes),
                  const SizedBox(height: 24),
                  Text('ESTADO PREVIO', style: AppText.labelCaps()),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      if (_loteNombre == null) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TerrainStatusScreen(
                              lote: _loteNombre!, currentTab: widget.currentTab),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        border: Border.all(
                          color: AppColors.outlineVariant,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.terrain,
                              color: AppColors.onPrimaryContainer,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Estado del Terreno',
                                  style: AppText.bodyLg().copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.outline,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  RuggedButton(
                    text: _guardando ? 'GUARDANDO...' : 'GUARDAR CULTIVO',
                    icon: Icons.save,
                    onPressed: _guardando ? () {} : () async {
                      if (_loteId == null) return;
                      setState(() => _guardando = true);
                      
                      final finalCrop = _crop == 'Otro' &&
                              _otherCropController.text.isNotEmpty
                          ? _otherCropController.text
                          : _crop;
                          
                      final user = context.read<AuthProvider>().currentUser;
                      final userId = user?.id ?? 'unknown';
                      final id = 'siembra_${DateTime.now().millisecondsSinceEpoch}';
                      final now = DateTime.now().toIso8601String();

                      await DatabaseHelper.instance.insert(DatabaseHelper.tableSiembras, {
                        'id': id,
                        'loteId': _loteId,
                        'loteNombre': _loteNombre,
                        'cultivo': finalCrop,
                        'fecha': _dateController.text,
                        'userId': userId,
                        'createdAt': now,
                        'isPendingSync': 1,
                      });

                      if (!mounted) return;
                      setState(() => _guardando = false);
                      
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SowingSuccessScreen(
                              lote: _loteNombre ?? '',
                              crop: finalCrop,
                              currentTab: widget.currentTab),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
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

  Widget _selector(List<LoteModel> lotes) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.outlineVariant, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.map, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _loteId,
                isExpanded: true,
                icon: const Icon(
                  Icons.expand_more,
                  color: AppColors.onSurfaceVariant,
                ),
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
        ],
      ),
    );
  }
}

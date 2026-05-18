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
import '../../data/providers/catalogos_provider.dart';

class SowingScreen extends StatefulWidget {
  final String? fixedLote;
  final AgroTab currentTab;
  final String? idToEdit;

  const SowingScreen({
    super.key,
    this.fixedLote,
    this.currentTab = AgroTab.home,
    this.idToEdit,
  });

  @override
  State<SowingScreen> createState() => _SowingScreenState();
}

class _SowingScreenState extends State<SowingScreen> {
  String? _selectedCultivoId;
  String? _selectedCultivoNombre;
  String? _loteId;
  String? _loteNombre;
  final TextEditingController _dateController = TextEditingController(
    text:
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
  );
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LotesProvider>();
      if (!provider.hasLotes) {
        provider.init();
      }
      if (widget.idToEdit != null) {
        _loadEditData();
      }
    });
  }

  Future<void> _loadEditData() async {
    final rows = await DatabaseHelper.instance.queryWhere(
      DatabaseHelper.tableSiembras, 'id = ?', [widget.idToEdit!]);
    if (rows.isNotEmpty && mounted) {
      final data = rows.first;
      setState(() {
        _loteId = data['loteId'];
        _selectedCultivoId = data['cultivoId'];
        // _selectedCultivoNombre se auto-cargará desde el catálogo
      });
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
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
              final found =
                  lotes.where((l) => l.nombre == widget.fixedLote).toList();
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
                    child: Consumer<CatalogosProvider>(
                      builder: (context, provider, child) {
                        final list = provider.cultivos;
                        if (list.isEmpty) {
                          return Center(
                            child: Text('Cargando catálogo...',
                                style:
                                    AppText.bodyMd(color: AppColors.outline)),
                          );
                        }

                        return Autocomplete<Object>(
                          initialValue: TextEditingValue(
                              text: _selectedCultivoNombre ?? ''),
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text == '') return list;
                            return list.where((c) => c.nombre
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase()));
                          },
                          displayStringForOption: (option) =>
                              (option as dynamic).nombre,
                          onSelected: (option) {
                            setState(() {
                              _selectedCultivoId = (option as dynamic).id;
                              _selectedCultivoNombre =
                                  (option as dynamic).nombre;
                            });
                          },
                          fieldViewBuilder:
                              (ctx, controller, focusNode, onSubmitted) {
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                hintText: 'Escribe el cultivo...',
                                hintStyle:
                                    AppText.bodyMd(color: AppColors.outline),
                                prefixIcon: const Icon(Icons.search,
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
                                  width: MediaQuery.of(context).size.width - 80,
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
                                        title: Text((option as dynamic).nombre,
                                            style: AppText.bodyMd()),
                                        onTap: () => onSelected(option),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
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
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              datePickerTheme: DatePickerThemeData(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            child: Transform.scale(
                              scale: 0.85, // Reducir el tamaño un 15%
                              child: child!,
                            ),
                          );
                        },
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
                  if (_loteId != null && lotes.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('TIPO DE SUELO DEL LOTE', style: AppText.labelCaps()),
                    const SizedBox(height: 8),
                    Consumer<CatalogosProvider>(
                      builder: (context, catProvider, child) {
                        try {
                          final lote = lotes.firstWhere((l) => l.id == _loteId);
                          final tipoId = lote.tipoSueloId;
                          final tipoSuelo = catProvider.tiposSuelo
                              .where((ts) => ts.id == tipoId)
                              .firstOrNull;

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.outlineVariant),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.layers_outlined,
                                    color: AppColors.primary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tipoSuelo?.nombre ?? 'Suelo no especificado',
                                        style: AppText.bodyLg()
                                            .copyWith(fontWeight: FontWeight.w600),
                                      ),
                                      if (tipoSuelo?.descripcion != null)
                                        Text(
                                          tipoSuelo!.descripcion!,
                                          style: AppText.bodyMd(
                                              color: AppColors.onSurfaceVariant),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        } catch (e) {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text('ESTADO PREVIO', style: AppText.labelCaps()),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      if (_loteNombre == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              lotes.isEmpty
                                  ? 'Por favor, agrega un lote primero'
                                  : 'Por favor, selecciona un lote primero',
                              style: AppText.bodyMd(color: Colors.white)
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TerrainStatusScreen(
                              lote: _loteNombre!,
                              currentTab: widget.currentTab),
                        ),
                      );
                    },
                    child: Opacity(
                      opacity: _loteNombre == null ? 0.6 : 1.0,
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
                                  if (_loteNombre != null)
                                    Text(
                                      'Analizar condición de $_loteNombre',
                                      style: AppText.bodyMd(
                                          color: AppColors.outline),
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
                  ),
                  const SizedBox(height: 24),
                  RuggedButton(
                    text: _guardando ? 'GUARDANDO...' : 'GUARDAR CULTIVO',
                    icon: Icons.save,
                    onPressed: _guardando
                        ? () {}
                        : () async {
                            if (_loteId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    lotes.isEmpty
                                        ? 'Por favor, agrega un lote primero'
                                        : 'Por favor, selecciona un lote primero',
                                    style: AppText.bodyMd(color: Colors.white)
                                        .copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  backgroundColor: AppColors.error,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin:
                                      const EdgeInsets.fromLTRB(24, 0, 24, 100),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              return;
                            }
                            setState(() => _guardando = true);

                            final finalCropNombre =
                                _selectedCultivoNombre ?? 'Desconocido';

                            final user =
                                context.read<AuthProvider>().currentUser;
                            final userId = user?.id ?? 'unknown';
                            final id = widget.idToEdit ?? 'siembra_${DateTime.now().millisecondsSinceEpoch}';
                            final now = DateTime.now().toIso8601String();

                            final data = {
                              'id': id,
                              'loteId': _loteId,
                              'loteNombre': _loteNombre,
                              'cultivo': finalCropNombre,
                              'cultivoId': _selectedCultivoId,
                              'fecha': _dateController.text,
                              'userId': userId,
                              'isPendingSync': 1,
                            };

                            if (widget.idToEdit != null) {
                              data['updatedAt'] = now;
                              await DatabaseHelper.instance.update(
                                  DatabaseHelper.tableSiembras, data,
                                  'id = ?', [id]);
                            } else {
                              data['createdAt'] = now;
                              await DatabaseHelper.instance.insert(
                                  DatabaseHelper.tableSiembras, data);
                            }

                            if (!context.mounted) return;
                            setState(() => _guardando = false);

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SowingSuccessScreen(
                                    lote: _loteNombre ?? '',
                                    crop: finalCropNombre,
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

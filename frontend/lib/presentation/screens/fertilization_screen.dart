import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../common/agro_bottom_nav.dart';
import '../widgets/offline_banner.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/rugged_button.dart';
import 'home_screen.dart';
import 'map_onboarding_screen.dart';
import 'profile_screen.dart';
import 'tasks_screen.dart';
import 'package:provider/provider.dart';
import '../../core/storage/database_helper.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/lotes_provider.dart';
import '../../data/models/lote_model.dart';
import 'fertilization_success_screen.dart';
import '../../data/providers/catalogos_provider.dart';

class FertilizationScreen extends StatefulWidget {
  final AgroTab currentTab;
  final String? fixedLote;

  const FertilizationScreen({
    super.key,
    this.currentTab = AgroTab.tareas,
    this.fixedLote,
  });

  @override
  State<FertilizationScreen> createState() => _FertilizationScreenState();
}

class _FertilizationScreenState extends State<FertilizationScreen> {
  String? _selectedFertId;
  String? _selectedFertNombre;
  int _amount = 0;
  String _unit = 'KG';
  String? _loteId;
  String? _loteNombre;
  final _amountController = TextEditingController();
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = _amount.toString();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LotesProvider>();
      if (!provider.hasLotes) {
        provider.init();
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _updateAmountFromText() {
    final parsed = int.tryParse(_amountController.text);
    if (parsed != null && parsed >= 0) {
      setState(() => _amount = parsed);
    }
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
                  Text('Registro de Fertilización', style: AppText.h1()),
                  const SizedBox(height: 5),
                  Text('SELECCIONAR FERTILIZANTE', style: AppText.labelCaps()),
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
                        final list = provider.fertilizantes;
                        if (list.isEmpty) {
                          return Center(
                            child: Text('Cargando catálogo...',
                                style:
                                    AppText.bodyMd(color: AppColors.outline)),
                          );
                        }

                        return Autocomplete<Object>(
                          initialValue:
                              TextEditingValue(text: _selectedFertNombre ?? ''),
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text == '') return list;
                            return list.where((f) => f.nombre
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase()));
                          },
                          displayStringForOption: (option) =>
                              (option as dynamic).nombre,
                          onSelected: (option) {
                            setState(() {
                              _selectedFertId = (option as dynamic).id;
                              _selectedFertNombre = (option as dynamic).nombre;
                            });
                          },
                          fieldViewBuilder:
                              (ctx, controller, focusNode, onSubmitted) {
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                hintText: 'Escribe el fertilizante...',
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
                  const SizedBox(height: 20),
                  Text('UNIDAD DE MEDIDA', style: AppText.labelCaps()),
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
                        value: _unit,
                        isExpanded: true,
                        icon: const Icon(Icons.expand_more,
                            color: AppColors.onSurfaceVariant),
                        items: [
                          const DropdownMenuItem(
                              value: 'KG',
                              child:
                                  Text('Kilogramos (kg) — Sólido/Granulado')),
                          const DropdownMenuItem(
                              value: 'L', child: Text('Litros (L) — Líquido')),
                          const DropdownMenuItem(
                              value: 'g',
                              child: Text('Gramos (g) — Concentrado')),
                          const DropdownMenuItem(
                              value: 'ml',
                              child: Text('Mililitros (ml) — Soluble')),
                        ],
                        onChanged: (v) => setState(() => _unit = v ?? _unit),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('CANTIDAD APLICADA', style: AppText.labelCaps()),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _circleBtn(
                        Icons.remove,
                        () {
                          setState(() {
                            if (_amount >= 1) {
                              _amount -= 1;
                              _amountController.text = _amount.toString();
                            }
                          });
                        },
                        AppColors.surfaceContainer,
                        AppColors.onSurface,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            border: Border.all(
                                color: AppColors.outlineVariant, width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: AppText.h1(),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                  onChanged: (_) => _updateAmountFromText(),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _unit,
                                style: AppText.bodyMd(
                                    color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _circleBtn(
                        Icons.add,
                        () {
                          setState(() {
                            _amount += 1;
                            _amountController.text = _amount.toString();
                          });
                        },
                        AppColors.primaryContainer,
                        AppColors.onPrimaryContainer,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('SELECCIONAR LOTE', style: AppText.labelCaps()),
                  const SizedBox(height: 12),
                  if (lotesProvider.isLoading && lotes.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else if (lotes.isEmpty)
                    Text('Sin lotes', style: AppText.bodyMd())
                  else if (widget.fixedLote != null && _loteNombre != null)
                    Container(
                      height: 56,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        border: Border.all(
                            color: AppColors.outlineVariant, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(_loteNombre!, style: AppText.bodyMd()),
                    )
                  else
                    _selector(lotes),
                  const SizedBox(height: 12),
                  RuggedButton(
                    text: _guardando ? 'GUARDANDO...' : 'GUARDAR REGISTRO',
                    icon: Icons.save,
                    onPressed: _guardando
                        ? () {}
                        : () async {
                            if (_loteId == null) return;
                            setState(() => _guardando = true);

                            final finalFertNombre =
                                _selectedFertNombre ?? 'Desconocido';

                            final user =
                                context.read<AuthProvider>().currentUser;
                            final userId = user?.id ?? 'unknown';
                            final id =
                                'fert_${DateTime.now().millisecondsSinceEpoch}';
                            final now = DateTime.now().toIso8601String();

                            await DatabaseHelper.instance
                                .insert(DatabaseHelper.tableFertilizacion, {
                              'id': id,
                              'loteId': _loteId,
                              'loteNombre': _loteNombre,
                              'tipoFertilizante': _selectedFertId,
                              'fertilizanteId': _selectedFertId,
                              'nombre': finalFertNombre,
                              'dosis': _amount,
                              'unidad': _unit,
                              'metodoAplicacion': null,
                              'fecha': now,
                              'observaciones': null,
                              'userId': userId,
                              'createdAt': now,
                              'isPendingSync': 1,
                            });

                            if (!context.mounted) return;
                            setState(() => _guardando = false);

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FertilizationSuccessScreen(
                                  lote: _loteNombre ?? '',
                                  fertilizer: finalFertNombre,
                                  amount: _amount,
                                  unit: _unit,
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

  Widget _circleBtn(IconData icon, VoidCallback onTap, Color bg, Color fg) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bg,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, color: fg, size: 24),
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
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _loteId,
          isExpanded: true,
          icon:
              const Icon(Icons.expand_more, color: AppColors.onSurfaceVariant),
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
    );
  }
}

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
import 'irrigation_success_screen.dart';

class IrrigationScreen extends StatefulWidget {
  final AgroTab currentTab;
  final String? fixedLote;
  final String? idToEdit;

  const IrrigationScreen({
    super.key,
    this.currentTab = AgroTab.tareas,
    this.fixedLote,
    this.idToEdit,
  });

  @override
  State<IrrigationScreen> createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends State<IrrigationScreen> {
  int _liters = 0;
  String? _loteId;
  String? _loteNombre;
  String? _cultivoActual;
  DateTime? _ultimoRiego;
  int? _litrosRecomendados;
  late TextEditingController _litersController;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _litersController = TextEditingController(text: _liters.toString());
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
      DatabaseHelper.tableRiego, 'id = ?', [widget.idToEdit!]);
    if (rows.isNotEmpty && mounted) {
      final data = rows.first;
      setState(() {
        _loteId = data['loteId'];
        _liters = data['cantidadLitros'] as int? ?? 0;
        _litersController.text = _liters.toString();
        _loteNombre = data['loteNombre'];
      });
      _loadSuggestionData(data['loteId'] as String?);
    }
  }

  /// Carga el último riego y cultivo actual del lote para la sugerencia.
  Future<void> _loadSuggestionData(String? loteId) async {
    if (loteId == null) return;
    final db = DatabaseHelper.instance;

    // Último riego de este lote
    final riegos = await db.queryWhere(
      DatabaseHelper.tableRiego, 'loteId = ?', [loteId]);
    DateTime? ultimo;
    if (riegos.isNotEmpty) {
      riegos.sort((a, b) => (b['fecha'] as String).compareTo(a['fecha'] as String));
      ultimo = DateTime.tryParse(riegos.first['fecha'] as String? ?? '');
    }

    // Cultivo actual del lote
    final lotesRows = await db.queryWhere(
      DatabaseHelper.tableLotes, 'id = ?', [loteId]);
    String? cultivo;
    if (lotesRows.isNotEmpty) {
      cultivo = lotesRows.first['cultivoActual'] as String?;
    }

    // Calcular litros recomendados según días desde último riego
    int recomendado = 20;
    if (ultimo != null) {
      final dias = DateTime.now().difference(ultimo).inDays;
      if (dias >= 5) {
        recomendado = 40;
      } else if (dias >= 3) {
        recomendado = 25;
      } else {
        recomendado = 15;
      }
    }

    if (mounted) {
      setState(() {
        _ultimoRiego = ultimo;
        _cultivoActual = cultivo;
        _litrosRecomendados = recomendado;
        // Pre-llenar el stepper con la cantidad recomendada si está en 0
        if (_liters == 0) {
          _liters = recomendado;
          _litersController.text = recomendado.toString();
        }
      });
    }
  }

  @override
  void dispose() {
    _litersController.dispose();
    super.dispose();
  }

  void _updateLitersFromText() {
    final parsed = int.tryParse(_litersController.text);
    if (parsed != null && parsed >= 0) {
      setState(() => _liters = parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lotesProvider = context.watch<LotesProvider>();
    final lotes = lotesProvider.lotes;

    if (_loteId == null && lotes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          String? newId;
          String? newNombre;
          if (widget.fixedLote != null) {
            final found = lotes.where((l) => l.nombre == widget.fixedLote).toList();
            if (found.isNotEmpty) {
              newId = found.first.id;
              newNombre = found.first.nombre;
            } else {
              newId = lotes.first.id;
              newNombre = lotes.first.nombre;
            }
          } else {
            newId = lotes.first.id;
            newNombre = lotes.first.nombre;
          }
          setState(() {
            _loteId = newId;
            _loteNombre = newNombre;
          });
          _loadSuggestionData(newId);
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: OfflineBanner()),
            const SizedBox(height: 5),
            Text('Registrar Riego', style: AppText.h2()),
            const SizedBox(height: 5),

            // Suggestion card dinámica
            Builder(builder: (context) {
              final loteNombre = _loteNombre ?? 'el lote seleccionado';
              final litros = _litrosRecomendados ?? 20;
              String diasTexto;
              if (_ultimoRiego == null) {
                diasTexto = 'Sin registros previos de riego';
              } else {
                final dias = DateTime.now().difference(_ultimoRiego!).inDays;
                if (dias == 0) {
                  diasTexto = 'Regado hoy';
                } else if (dias == 1) {
                  diasTexto = 'Último riego: ayer';
                } else {
                  diasTexto = 'Último riego: hace $dias días';
                }
              }
              final cultivoTexto = (_cultivoActual != null && _cultivoActual!.isNotEmpty)
                  ? ' para tu cultivo de ${_cultivoActual!.toLowerCase()}'
                  : '';

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant, width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.water_drop, color: AppColors.secondary, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sugerencia de riego',
                            style: AppText.bodyMd(
                              color: AppColors.onSecondaryContainer,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Aplicar ${litros}L en $loteNombre$cultivoTexto.',
                            style: AppText.bodyMd(color: AppColors.onSecondaryContainer),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            diasTexto,
                            style: AppText.bodyMd(
                              color: AppColors.onSecondaryContainer,
                            ).copyWith(fontSize: 12, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),

            // Lote selector
            Text('SELECCIONAR LOTE', style: AppText.labelCaps()),
            const SizedBox(height: 8),
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
                  border: Border.all(color: AppColors.outlineVariant, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.centerLeft,
                child: Text(_loteNombre!, style: AppText.bodyMd()),
              )
            else
              _selector(lotes),
            const SizedBox(height: 24),

            // Cantidad stepper
            Text('CANTIDAD APLICADA (LITROS)', style: AppText.labelCaps()),
            const SizedBox(height: 8),
            Row(
              children: [
                _stepBtn(Icons.remove, () {
                  setState(() {
                    if (_liters >= 1) {
                      _liters -= 1;
                      _litersController.text = _liters.toString();
                    }
                  });
                }),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      border: Border.all(
                        color: AppColors.outlineVariant,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _litersController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: AppText.h2(color: AppColors.primary),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (_) => _updateLitersFromText(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _stepBtn(Icons.add, () {
                  setState(() {
                    _liters += 1;
                    _litersController.text = _liters.toString();
                  });
                }),
              ],
            ),

            const SizedBox(height: 24),

            // Context info
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    'ÚLTIMO RIEGO',
                    _ultimoRiego == null
                        ? 'Sin registros'
                        : () {
                            final dias = DateTime.now().difference(_ultimoRiego!).inDays;
                            if (dias == 0) return 'Hoy';
                            if (dias == 1) return 'Ayer';
                            return 'Hace $dias días';
                          }(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: _statCard('ESTADO SUELO', 'Sin datos')),
              ],
            ),
            const SizedBox(height: 32),
            RuggedButton(
              text: _guardando ? 'GUARDANDO...' : 'CONFIRMAR RIEGO',
              icon: Icons.check_circle,
              onPressed: _guardando
                  ? () {}
                  : () async {
                      if (_loteId == null || _liters <= 0) {
                        if (_liters <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Por favor, indica una cantidad de agua mayor a 0 litros.'),
                              backgroundColor: AppColors.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                        return;
                      }
                      setState(() => _guardando = true);

                      final user = context.read<AuthProvider>().currentUser;
                      final userId = user?.id ?? 'unknown';
                      final id = widget.idToEdit ?? 'riego_${DateTime.now().millisecondsSinceEpoch}';
                      final now = DateTime.now().toIso8601String();

                      final data = {
                        'id': id,
                        'loteId': _loteId,
                        'loteNombre': _loteNombre,
                        'tipo': 'Manual',
                        'duracionMinutos': null,
                        'cantidadLitros': _liters,
                        'fecha': now,
                        'isPendingSync': 1,
                        'createdBy': userId,
                      };

                      if (widget.idToEdit != null) {
                        data['updatedAt'] = now;
                        await DatabaseHelper.instance.update(
                          DatabaseHelper.tableRiego, data,
                          'id = ?', [id]);
                      } else {
                        data['createdAt'] = now;
                        await DatabaseHelper.instance.insert(
                          DatabaseHelper.tableRiego, data);
                      }

                      if (!context.mounted) return;
                      setState(() => _guardando = false);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => IrrigationSuccessScreen(
                            lote: _loteNombre ?? '',
                            liters: _liters,
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
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          border: Border.all(color: AppColors.outlineVariant, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.onSurface, size: 22),
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.outlineVariant, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.labelCaps()),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppText.bodyLg().copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

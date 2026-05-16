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

  const IrrigationScreen({
    super.key,
    this.currentTab = AgroTab.tareas,
    this.fixedLote,
  });

  @override
  State<IrrigationScreen> createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends State<IrrigationScreen> {
  int _liters = 0;
  String? _loteId;
  String? _loteNombre;
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
    });
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: OfflineBanner()),
            const SizedBox(height: 5),
            Text('Registrar Riego', style: AppText.h2()),
            const SizedBox(height: 5),

            // Suggestion
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant, width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info, color: AppColors.secondary, size: 22),
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
                          'Aplicar 20L en Lote 1 para optimizar el rendimiento del suelo hoy.',
                          style: AppText.bodyMd(
                            color: AppColors.onSecondaryContainer,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sugerencia calculada localmente',
                          style: AppText.bodyMd(
                            color: AppColors.onSecondaryContainer,
                          ).copyWith(fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
                Expanded(child: _statCard('ÚLTIMO RIEGO', 'Hace 2 días')),
                const SizedBox(width: 16),
                Expanded(child: _statCard('ESTADO SUELO', 'Seco')),
              ],
            ),
            const SizedBox(height: 32),
            RuggedButton(
              text: _guardando ? 'GUARDANDO...' : 'CONFIRMAR RIEGO',
              icon: Icons.check_circle,
              onPressed: _guardando
                  ? () {}
                  : () async {
                      if (_loteId == null) return;
                      setState(() => _guardando = true);

                      final user = context.read<AuthProvider>().currentUser;
                      final userId = user?.id ?? 'unknown';
                      final id =
                          'riego_${DateTime.now().millisecondsSinceEpoch}';
                      final now = DateTime.now().toIso8601String();

                      await DatabaseHelper.instance
                          .insert(DatabaseHelper.tableRiego, {
                        'id': id,
                        'loteId': _loteId,
                        'loteNombre': _loteNombre,
                        'tipo': 'Manual',
                        'duracionMinutos': null,
                        'cantidadLitros': _liters,
                        'fecha': now,
                        'humedad': null,
                        'observaciones': null,
                        'userId': userId,
                        'createdAt': now,
                        'isPendingSync': 1,
                      });

                      if (!mounted) return;
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

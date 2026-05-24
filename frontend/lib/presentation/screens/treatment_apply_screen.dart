import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../common/agro_bottom_nav.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/rugged_button.dart';
import 'treatment_success_screen.dart';
import 'package:provider/provider.dart';
import '../../core/storage/database_helper.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/lotes_provider.dart';
import '../../data/services/sync_service.dart';

class TreatmentApplyScreen extends StatefulWidget {
  final String? alertLoteName;
  final String? alertPlagueName;
  final AgroTab currentTab;

  const TreatmentApplyScreen({
    super.key,
    this.alertLoteName,
    this.alertPlagueName,
    this.currentTab = AgroTab.tareas,
  });

  @override
  State<TreatmentApplyScreen> createState() => _TreatmentApplyScreenState();
}

class _TreatmentApplyScreenState extends State<TreatmentApplyScreen> {
  String? _loteId;
  String? _loteNombre;
  String _unidad = 'L/ha';
  String _metodo = 'Mochila Pulverizadora';
  bool _guardando = false;
  final _insumoCtrl = TextEditingController();
  final _dosisCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _insumoCtrl.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LotesProvider>();
      if (!provider.hasLotes) {
        provider.init();
      }
    });
  }

  @override
  void dispose() {
    _insumoCtrl.dispose();
    _dosisCtrl.dispose();
    _obsCtrl.dispose();
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
            if (widget.alertLoteName != null) {
              final found =
                  lotes.where((l) => l.nombre == widget.alertLoteName).toList();
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'REGISTRAR TRATAMIENTO',
                textAlign: TextAlign.center,
                style: AppText.labelCaps(color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 5),
            const Divider(color: AppColors.outlineVariant),
            const SizedBox(height: 24),
            if (widget.alertLoteName != null) ...[
              // Yellow alert banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warningContainer,
                  border: Border.all(color: const Color(0xFFEAB308), width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning,
                        color: AppColors.onWarningContainer, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tratando alerta: ${widget.alertLoteName}',
                        style:
                            AppText.bodyLg(color: AppColors.onWarningContainer)
                                .copyWith(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ] else ...[
              _label('LOTE'),
              if (lotesProvider.isLoading && lotes.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (lotes.isEmpty)
                Text('Sin lotes', style: AppText.bodyMd())
              else
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    border:
                        Border.all(color: AppColors.outlineVariant, width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _loteId,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down,
                          color: AppColors.onSurfaceVariant),
                      items: lotes
                          .map((l) => DropdownMenuItem(
                              value: l.id, child: Text(l.nombre)))
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
              const SizedBox(height: 16),
            ],
            _label('INSUMO QUÍMICO'),
            _buildInsumoPicker(),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('DOSIS'),
                      _input(_dosisCtrl, '0.0', keyboard: TextInputType.number),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('UNIDAD'),
                      _dropdown(
                        value: _unidad,
                        items: const [
                          'L/ha',
                          'kg/ha',
                          'ml/L',
                          'g/planta',
                          'ml/planta',
                          'kg/lote',
                        ],
                        onChanged: (v) =>
                            setState(() => _unidad = v ?? _unidad),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _label('MÉTODO DE APLICACIÓN'),
            _buildMethodPicker(),
            const SizedBox(height: 16),
            _label('OBSERVACIONES'),
            const SizedBox(height: 8),
            TextField(
              controller: _obsCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                hintText: 'Condiciones climáticas, estado fenológico...',
                hintStyle: AppText.bodyMd(color: AppColors.outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 32),
            RuggedButton(
              text: _guardando ? 'GUARDANDO...' : 'REGISTRAR',
              icon: Icons.check_circle,
              onPressed: _guardando
                  ? () {}
                  : () async {
                      if (_loteId == null || _insumoCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Por favor, completa todos los campos requeridos (Insumo y Lote).',
                                style: AppText.bodyMd(color: Colors.white)
                                    .copyWith(fontWeight: FontWeight.w600)),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      setState(() => _guardando = true);

                      final navigator = Navigator.of(context);
                      final lotesProv = context.read<LotesProvider>();
                      final syncService = context.read<SyncService>();
                      final user = context.read<AuthProvider>().currentUser;
                      final userId = user?.id ?? 'unknown';
                      final id =
                          'trat_${DateTime.now().millisecondsSinceEpoch}';
                      final now = DateTime.now().toIso8601String();

                      await DatabaseHelper.instance
                          .insert(DatabaseHelper.tableTratamientos, {
                        'id': id,
                        'hallazgoId': null,
                        'loteId': _loteId,
                        'loteNombre': _loteNombre,
                        'producto': _insumoCtrl.text,
                        'dosis': double.tryParse(_dosisCtrl.text) ?? 0.0,
                        'unidad': _unidad,
                        'metodoAplicacion': _metodo,
                        'fecha': now,
                        'observaciones': _obsCtrl.text,
                        'userId': userId,
                        'createdAt': now,
                        'isPendingSync': 1,
                      });

                      try {
                        syncService.syncNow(lotesProvider: lotesProv);
                      } catch (_) {}

                      if (!mounted) return;
                      setState(() => _guardando = false);

                      navigator.pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => TreatmentSuccessScreen(
                            lote: _loteNombre ?? '',
                            metodo: _metodo,
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
        child: Text(text, style: AppText.labelCaps()),
      );

  Widget _input(TextEditingController c, String hint,
      {TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        hintText: hint,
        hintStyle: AppText.bodyMd(color: AppColors.outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _dropdown({
    String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? hint,
    double? menuMaxHeight = 250,
  }) {
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
          value: value != null && value.isNotEmpty ? value : null,
          hint: hint != null ? Text(hint, style: AppText.bodyMd(color: AppColors.outline)) : null,
          isExpanded: true,
          menuMaxHeight: menuMaxHeight,
          icon: const Icon(Icons.arrow_drop_down,
              color: AppColors.onSurfaceVariant),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildMethodPicker() {
    // La lista de métodos de aplicación está definida aquí mismo:
    return _dropdown(
      value: _metodo,
      menuMaxHeight: 220,
      items: const [
        'Mochila Pulverizadora',
        'Tractor Pulverizador',
        'Riego con fertirriego',
        'Aplicación localizada',
      ],
      onChanged: (v) {
        if (v != null) setState(() => _metodo = v);
      },
    );
  }

  // ---------- Insumo químico picker ----------
  Widget _buildInsumoPicker() {
    final suggestions = const [
      'Mancozeb',
      'Carbendazim',
      'Triazoles',
      'Clorpirifos',
      'Imidacloprid',
      'Lambda-cyhalotrina',
      'Glifosato',
      'Paraquat',
      'Atrazina',
      'Cobre (oxicloruro, hidróxido)',
      'Estreptomicina',
    ];
    return _dropdown(
      value: _insumoCtrl.text,
      hint: 'Selecciona insumo',
      items: suggestions,
      onChanged: (v) {
        if (v != null) setState(() => _insumoCtrl.text = v);
      },
    );
  }
}

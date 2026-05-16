import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../common/agro_bottom_nav.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/rugged_button.dart';
import 'treatment_success_screen.dart';
import 'home_screen.dart';
import 'map_onboarding_screen.dart';
import 'profile_screen.dart';
import 'tasks_screen.dart';

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
  late String _lote;
  String _unidad = 'L/ha';
  String _metodo = 'Mochila Pulverizadora';
  final _insumoCtrl = TextEditingController();
  final _dosisCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _lote = widget.alertLoteName ?? 'Lote 1 — Sector Norte';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Registrar tratamiento',
                textAlign: TextAlign.center,
                style: AppText.h1(),
              ),
            ),
            const SizedBox(height: 5),
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
              _dropdown(
                value: _lote,
                items: const [
                  'Lote 1 — Sector Norte',
                  'Lote 2 — Ladera Este',
                  'Lote 3 — Valle Sur',
                ],
                onChanged: (v) => setState(() => _lote = v ?? _lote),
              ),
              const SizedBox(height: 16),
            ],
            _label('INSUMO QUÍMICO'),
            _input(_insumoCtrl, 'Ej. Glifosato 48%'),
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
                        items: const ['L/ha', 'kg/ha', 'ml/L'],
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
            _dropdown(
              value: _metodo,
              items: const [
                'Mochila Pulverizadora',
                'Tractor Pulverizador',
                'Aplicación Aérea',
              ],
              onChanged: (v) => setState(() => _metodo = v ?? _metodo),
            ),
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
              text: 'REGISTRAR',
              icon: Icons.check_circle,
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => TreatmentSuccessScreen(
                    lote: _lote,
                    metodo: _metodo,
                    currentTab: widget.currentTab,
                  ),
                ),
              ),
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
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
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
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down,
              color: AppColors.onSurfaceVariant),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/rugged_button.dart';
import '../common/agro_bottom_nav.dart';
import 'home_screen.dart';
import 'map_onboarding_screen.dart';
import 'profile_screen.dart';
import 'tasks_screen.dart';
import 'package:provider/provider.dart';
import '../../core/storage/database_helper.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/lotes_provider.dart';
import 'observation_success_screen.dart';

class RegisterObservationScreen extends StatefulWidget {
  final AgroTab currentTab;
  final String loteName;

  const RegisterObservationScreen({
    super.key,
    this.currentTab = AgroTab.home,
    required this.loteName,
  });

  @override
  State<RegisterObservationScreen> createState() =>
      _RegisterObservationScreenState();
}

class _RegisterObservationScreenState extends State<RegisterObservationScreen> {
  String _estadoActual = 'Estable';
  final TextEditingController _notasController = TextEditingController();
  bool _guardando = false;

  @override
  void dispose() {
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFC8E6C9), // Light green
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: Color(0xFF2E7D32), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'MONITOREANDO: ${widget.loteName.toUpperCase()}',
                    style: AppText.labelCaps(color: const Color(0xFF2E7D32)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'REGISTRAR\nOBSERVACIÓN',
              style: AppText.h1(color: AppColors.primary)
                  .copyWith(fontSize: 32, height: 1.1),
            ),
            const SizedBox(height: 5),
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
            _label('NOTAS DE CAMPO'),
            TextField(
              controller: _notasController,
              maxLines: 5,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                hintText: 'Escribe aquí los detalles...',
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
            ),
            const SizedBox(height: 24),
            _label('NUEVA FOTOGRAFÍA'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                border: Border.all(
                    color: AppColors.primary,
                    width: 1,
                    style: BorderStyle
                        .solid), // In a real app we'd use dashed border
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
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
            const SizedBox(height: 48),
            RuggedButton(
              text: _guardando ? 'GUARDANDO...' : 'GUARDAR',
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
                  'descripcion': _notasController.text,
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
                    builder: (_) => ObservationSuccessScreen(
                      loteName: widget.loteName,
                      estadoActual: _estadoActual,
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

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: AppText.labelCaps(color: AppColors.primary)),
      );
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/storage/database_helper.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/lotes_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/offline_banner.dart';
import '../widgets/rugged_button.dart';
import '../common/agro_bottom_nav.dart';
import 'finding_success_screen.dart';
import 'home_screen.dart';
import 'map_onboarding_screen.dart';
import 'profile_screen.dart';
import 'tasks_screen.dart';

class FindFindingScreen extends StatefulWidget {
  final AgroTab currentTab;
  const FindFindingScreen({super.key, this.currentTab = AgroTab.home});

  @override
  State<FindFindingScreen> createState() => _FindFindingScreenState();
}

class _FindFindingScreenState extends State<FindFindingScreen> {
  String? _loteId;
  String? _loteNombre;
  String _tipo = 'INSECTO';
  String _severidad = 'MEDIO';
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    // Cargar lotes si aún no están cargados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LotesProvider>();
      if (!provider.hasLotes) {
        provider.init();
      }
    });
  }

  Future<void> _guardarHallazgo() async {
    if (_loteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un lote')),
      );
      return;
    }

    setState(() => _guardando = true);

    final user = context.read<AuthProvider>().currentUser;
    final userId = user?.id ?? 'unknown';
    final id = 'hallazgo_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now().toIso8601String();

    await DatabaseHelper.instance.insert(DatabaseHelper.tableHallazgos, {
      'id': id,
      'loteId': _loteId,
      'loteNombre': _loteNombre,
      'tipo': _tipo,
      'severidad': _severidad,
      'descripcion': null,
      'fotoPath': null,
      'fecha': now,
      'userId': userId,
      'createdAt': now,
      'isPendingSync': 1,
    });

    setState(() => _guardando = false);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => FindingSuccessScreen(
          lote: _loteNombre ?? '',
          findingType: _tipo,
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
            _label('TIPO'),
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _DashedRectPainter(color: AppColors.outline),
                    ),
                  ),
                  Center(
                    child: Column(
                      children: [
                        const Icon(Icons.camera_alt_outlined,
                            color: AppColors.onSurfaceVariant, size: 32),
                        const SizedBox(height: 8),
                        Text('TOMAR FOTO',
                            style: AppText.labelCaps(
                                color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
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
          color: isSelected ? bgColor : bgColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: isSelected ? textColor : Colors.transparent),
        ),
        child: Center(
          child: Text(
            value,
            style: AppText.labelCaps(
                color: isSelected ? textColor : textColor.withOpacity(0.5)),
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

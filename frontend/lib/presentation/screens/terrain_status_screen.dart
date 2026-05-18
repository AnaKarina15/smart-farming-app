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
import 'terrain_success_screen.dart';
import '../../data/providers/catalogos_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/lotes_provider.dart';
import '../../core/storage/database_helper.dart';
import 'package:provider/provider.dart';
import '../../data/services/sync_service.dart';

class TerrainStatusScreen extends StatefulWidget {
  final String? lote;
  final String? loteId;
  final String? siembraId;
  final String? idToEdit;
  final bool? isPreviousStateOfSiembra;
  final AgroTab currentTab;

  const TerrainStatusScreen({
    super.key,
    this.lote,
    this.loteId,
    this.siembraId,
    this.idToEdit,
    this.isPreviousStateOfSiembra,
    this.currentTab = AgroTab.home,
  });

  @override
  State<TerrainStatusScreen> createState() => _TerrainStatusScreenState();
}

class _TerrainStatusScreenState extends State<TerrainStatusScreen> {
  String? _selectedStatus;
  String? _selectedSueloId;
  String? _recomendaciones;
  final TextEditingController _notesController = TextEditingController();
  bool _hasSowing = false;
  bool _loadingSowingStatus = true;
  String? _selectedLoteId;
  String? _selectedLoteNombre;

  bool get _isPrevio => widget.isPreviousStateOfSiembra == true ||
      (_selectedStatus != null && ['limpio', 'con maleza', 'arado', 'adecuado'].contains(_selectedStatus!.toLowerCase()));

  @override
  void initState() {
    super.initState();
    _selectedLoteId = widget.loteId;
    _selectedLoteNombre = widget.lote;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<LotesProvider>();
      if (!provider.hasLotes) {
        provider.init();
      }
      if (widget.idToEdit != null) {
        _loadEditData();
      }
    });

    _checkSowingStatus();
  }

  Future<void> _loadEditData() async {
    final rows = await DatabaseHelper.instance.queryWhere(
      DatabaseHelper.tableEstadoTerreno,
      'id = ?',
      [widget.idToEdit!],
    );
    if (rows.isNotEmpty && mounted) {
      final data = rows.first;
      setState(() {
        _selectedLoteId = data['loteId'] as String?;
        _selectedLoteNombre = data['loteNombre'] as String?;
        _selectedStatus = data['estado'] as String?;
        _selectedSueloId = data['tipoSueloId'] as String?;
        _notesController.text = data['notas'] as String? ?? '';
      });
      
      final estado = data['estado'] as String? ?? '';
      final isInitial4 = ['limpio', 'con maleza', 'arado', 'adecuado'].contains(estado.toLowerCase());
      if (isInitial4) {
        setState(() {
          _hasSowing = false;
          _loadingSowingStatus = false;
        });
      } else {
        _checkSowingStatus();
      }
    }
  }

  void _onLoteSelected(String? loteId, String? loteNombre) {
    setState(() {
      _selectedLoteId = loteId;
      _selectedLoteNombre = loteNombre;
      _loadingSowingStatus = true;
      _selectedStatus = null;
    });
    _checkSowingStatus();
  }

  Future<void> _checkSowingStatus() async {
    if (widget.isPreviousStateOfSiembra == true) {
      if (mounted) {
        setState(() {
          _hasSowing = false;
          _loadingSowingStatus = false;
        });
      }
      return;
    }

    if (widget.siembraId != null) {
      try {
        final db = DatabaseHelper.instance;
        final rows = await db.queryWhere(
          DatabaseHelper.tableSiembras,
          'id = ?',
          [widget.siembraId!],
        );
        if (mounted) {
          setState(() {
            _hasSowing = rows.isNotEmpty;
            _loadingSowingStatus = false;
          });
        }
        return;
      } catch (_) {}
    }

    final currentLoteId = _selectedLoteId;
    final currentLoteNombre = _selectedLoteNombre;

    if (currentLoteId == null && currentLoteNombre == null) {
      if (mounted) {
        setState(() {
          _hasSowing = false;
          _loadingSowingStatus = false;
        });
      }
      return;
    }

    try {
      final db = DatabaseHelper.instance;
      List<Map<String, dynamic>> rows = [];
      if (currentLoteId != null) {
        rows = await db.queryWhere(
          DatabaseHelper.tableSiembras,
          'loteId = ?',
          [currentLoteId],
        );
      } else if (currentLoteNombre != null) {
        rows = await db.queryWhere(
          DatabaseHelper.tableSiembras,
          'loteNombre = ?',
          [currentLoteNombre],
        );
      }
      if (!mounted) return;
      final provider = context.read<LotesProvider>();
      final matchingLotes = provider.lotes.where(
        (l) => l.id == currentLoteId || l.nombre == currentLoteNombre,
      );
      final hasActiveCrop = matchingLotes.isNotEmpty &&
          matchingLotes.first.cultivoActual != null &&
          matchingLotes.first.cultivoActual!.isNotEmpty;

      if (mounted) {
        setState(() {
          _hasSowing = hasActiveCrop && rows.isNotEmpty;
          _loadingSowingStatus = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingSowingStatus = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.idToEdit != null
                  ? (_isPrevio ? 'Editar estado del terreno (Previo)' : 'Editar estado del terreno (Después)')
                  : (_isPrevio ? 'Estado del terreno (Previo)' : 'Estado del terreno'),
              style: AppText.h2(color: AppColors.onSurface),
            ),
            const SizedBox(height: 5),
            Text(
              'Seleccione la condición actual del lote asignado.',
              style: AppText.bodyMd(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 20),

            // Lote Display or Selector
            if (widget.lote != null && widget.lote!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.landscape, color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LOTE SELECCIONADO',
                            style: AppText.labelCaps(color: AppColors.primary).copyWith(fontSize: 10),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.lote!,
                            style: AppText.bodyLg().copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Text('SELECCIONAR LOTE',
                  style: AppText.labelCaps(color: AppColors.onSurface)),
              const SizedBox(height: 8),
              Consumer<LotesProvider>(
                builder: (context, provider, child) {
                  final lotes = provider.lotes;
                  if (provider.isLoading && lotes.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (lotes.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Text(
                        'No tienes lotes registrados. Registra un lote para continuar.',
                        style: AppText.bodyMd(color: AppColors.error),
                      ),
                    );
                  }
                  return Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      border: Border.all(color: AppColors.outlineVariant),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedLoteId,
                        isExpanded: true,
                        hint: Text(
                          'Selecciona un lote...',
                          style: AppText.bodyMd(color: AppColors.outline),
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: AppColors.onSurfaceVariant),
                        items: lotes.map((l) {
                          return DropdownMenuItem(
                            value: l.id,
                            child: Text(l.nombre),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val == null) return;
                          final selected = lotes.firstWhere((l) => l.id == val);
                          _onLoteSelected(selected.id, selected.nombre);
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 20),
            
            if (_loadingSowingStatus)
              const Center(child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              ))
            else if (_hasSowing)
              // Grid 2x3 de estados del terreno (para después de siembra)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.2,
                children: [
                  _statusCard('ESTABLE', Icons.check_circle_outline),
                  _statusCard('CON MALEZA', Icons.grass),
                  _statusCard('COMPACTADO', Icons.layers),
                  _statusCard('EROSIONADO', Icons.landscape),
                  _statusCard('ENCHARCADO', Icons.water),
                  _statusCard('PEDREGOSO', Icons.grid_on),
                ],
              )
            else
              // Grid 2x2 de estados del terreno (para antes de siembra / sin siembra)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.2,
                children: [
                  _statusCard('LIMPIO', Icons.eco_outlined),
                  _statusCard('CON MALEZA', Icons.grass),
                  _statusCard('ARADO', Icons.agriculture),
                  _statusCard('ADECUADO', Icons.checklist_rtl),
                ],
              ),
            const SizedBox(height: 20),
            Text('CARACTERIZACIÓN DEL SUELO',
                style: AppText.labelCaps(color: AppColors.onSurface)),
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
                  final list = provider.tiposSuelo;

                  return DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSueloId,
                      menuMaxHeight: 220,
                      isExpanded: true,
                      hint: Text(
                        'Seleccionar tipo de suelo...',
                        style: AppText.bodyMd(color: AppColors.outline),
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: AppColors.onSurfaceVariant),
                      items: list.map((s) {
                        return DropdownMenuItem(
                          value: s.id,
                          child: Text(s.nombre),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() {
                          _selectedSueloId = v;
                          _recomendaciones = list
                              .firstWhere((s) => s.id == v)
                              .cultivosRecomendados;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            if (_recomendaciones != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cultivos recomendados: $_recomendaciones',
                        style: AppText.bodyMd(color: AppColors.primary)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text('NOTAS ADICIONALES',
                style: AppText.labelCaps(color: AppColors.onSurface)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                hintText: 'Observaciones del terreno...',
                hintStyle: AppText.bodyMd(color: AppColors.outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.outlineVariant),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 25),
            RuggedButton(
              text: widget.idToEdit != null ? 'ACTUALIZAR ESTADO' : 'GUARDAR ESTADO',
              icon: Icons.save,
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                final authProvider = context.read<AuthProvider>();
                final lotesProvider = context.read<LotesProvider>();
                final syncService = context.read<SyncService>();

                if (_selectedLoteNombre == null || _selectedLoteNombre!.isEmpty) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Por favor selecciona un lote.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                if (_selectedStatus == null) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content:
                          Text('Por favor selecciona el estado del terreno.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                // Guardar en SQLite
                final user = authProvider.currentUser;
                final now = DateTime.now().toIso8601String();
                final id = widget.idToEdit ?? 'terreno_${DateTime.now().millisecondsSinceEpoch}';
                
                final data = {
                  'id': id,
                  'loteId': _selectedLoteId ?? _selectedLoteNombre!,
                  'loteNombre': _selectedLoteNombre!,
                  if (widget.siembraId != null) 'siembraId': widget.siembraId,
                  'estado': _selectedStatus!,
                  if (_selectedSueloId != null) 'tipoSueloId': _selectedSueloId,
                  'notas': _notesController.text.trim().isNotEmpty
                      ? _notesController.text.trim()
                      : null,
                  'userId': user?.id ?? 'unknown',
                  'isPendingSync': 1,
                };

                if (widget.idToEdit != null) {
                  await DatabaseHelper.instance.update(
                    DatabaseHelper.tableEstadoTerreno,
                    data,
                    'id = ?',
                    [id],
                  );
                } else {
                  data['createdAt'] = now;
                  await DatabaseHelper.instance.insert(
                    DatabaseHelper.tableEstadoTerreno,
                    data,
                  );
                }

                // Sincronizar en segundo plano de inmediato
                try {
                  syncService.syncNow(lotesProvider: lotesProvider);
                } catch (_) {}

                navigator.pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => TerrainSuccessScreen(
                      lote: _selectedLoteNombre!,
                      status: _selectedStatus!,
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

  Widget _statusCard(String label, IconData icon) {
    final isSelected = _selectedStatus == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2E5D42)
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected
                  ? const Color(0xFF2E5D42)
                  : AppColors.outlineVariant),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : AppColors.onSurface,
                size: 20),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: AppText.labelCaps(
                        color: isSelected ? Colors.white : AppColors.onSurface)
                    .copyWith(fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../widgets/custom_app_bar.dart';
import '../common/agro_bottom_nav.dart';
import '../../core/storage/database_helper.dart';
import 'package:provider/provider.dart';
import '../../data/providers/lotes_provider.dart';
import '../../data/providers/operaciones_provider.dart';

class PhytoHistoryScreen extends StatefulWidget {
  final AgroTab currentTab;
  const PhytoHistoryScreen({super.key, this.currentTab = AgroTab.home});

  @override
  State<PhytoHistoryScreen> createState() => _PhytoHistoryScreenState();
}

class _PhytoHistoryScreenState extends State<PhytoHistoryScreen> {
  String _selectedFilter = 'TODOS';
  bool _isLoading = true;
  List<Map<String, dynamic>> _allItems = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final lotesIds = context.read<LotesProvider>().lotes.map((l) => l.id).toList();
      if (lotesIds.isNotEmpty && mounted) {
        await context.read<OperacionesProvider>().sincronizarTodasLasOperaciones(lotesIds);
      }
    } catch (_) {}

    final db = DatabaseHelper.instance;
    final hallazgos = await db.queryAllRows(DatabaseHelper.tableHallazgos);
    final tratamientos = await db.queryAllRows(DatabaseHelper.tableTratamientos);
    final plagas = await db.queryAllRows(DatabaseHelper.tableCatPlagas);

    final Map<String, String> plagaNames = {
      for (var p in plagas) p['id'] as String: p['nombre'] as String
    };

    List<Map<String, dynamic>> temp = [];

    for (var h in hallazgos) {
      String plagaName = h['plagaOtro']?.toString() ?? '';
      if (h['plagaId'] != null) {
        plagaName = plagaNames[h['plagaId']] ?? plagaName;
      }
      if (plagaName.isEmpty) plagaName = h['tipo']?.toString() ?? 'Desconocido';

      temp.add({
        'type': 'HALLAZGO',
        'id': h['id'],
        'fecha': h['fecha'],
        'loteNombre': h['loteNombre'],
        'plagaName': plagaName,
        'severidad': h['severidad'],
        'descripcion': h['descripcion'] ?? '',
      });
    }

    for (var t in tratamientos) {
      temp.add({
        'type': 'TRATAMIENTO',
        'id': t['id'],
        'fecha': t['fecha'],
        'loteNombre': t['loteNombre'],
        'producto': t['producto'],
        'metodoAplicacion': t['metodoAplicacion'],
        'dosis': t['dosis'],
        'unidad': t['unidad'],
        'observaciones': t['observaciones'] ?? '',
      });
    }

    temp.sort((a, b) {
      final dtA = DateTime.tryParse(a['fecha'] as String? ?? '') ?? DateTime.now();
      final dtB = DateTime.tryParse(b['fecha'] as String? ?? '') ?? DateTime.now();
      return dtB.compareTo(dtA);
    });

    if (mounted) {
      setState(() {
        _allItems = temp;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredItems {
    if (_selectedFilter == 'TODOS') return _allItems;
    if (_selectedFilter == 'PLAGAS') {
      return _allItems.where((i) => i['type'] == 'HALLAZGO').toList();
    }
    if (_selectedFilter == 'TRATAMIENTOS') {
      return _allItems.where((i) => i['type'] == 'TRATAMIENTO').toList();
    }
    return _allItems;
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text('HISTORIAL DE GESTIÓN FITOSANITARIA',
                style: AppText.labelCaps(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 24),

            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterPill('TODOS'),
                  const SizedBox(width: 8),
                  _filterPill('PLAGAS'),
                  const SizedBox(width: 8),
                  _filterPill('TRATAMIENTOS'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Timeline
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text('No hay registros en esta categoría.',
                      style: AppText.bodyMd(color: AppColors.outline)),
                ),
              )
            else
              Stack(
                children: [
                  Positioned(
                    left: 7,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 1,
                      color: AppColors.outlineVariant,
                    ),
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (ctx, index) {
                      final item = items[index];
                      final isLast = index == items.length - 1;
                      
                      final dt = DateTime.tryParse(item['fecha'] as String? ?? '') ?? DateTime.now();
                      final dateStr = DateFormat('dd MMM yyyy - hh:mm a').format(dt).toUpperCase();

                      if (item['type'] == 'HALLAZGO') {
                        return _timelineItem(
                          dotColor: AppColors.error,
                          dateStr: dateStr,
                          icon: Icons.bug_report,
                          iconColor: AppColors.error,
                          title: 'Detección: ${item['plagaName']}',
                          description: 'Lote: ${item['loteNombre']}\nSeveridad: ${item['severidad']}\n${item['descripcion']}',
                          isLast: isLast,
                        );
                      } else {
                        return _timelineItem(
                          dotColor: AppColors.primary,
                          dateStr: dateStr,
                          icon: Icons.vaccines,
                          iconColor: AppColors.primary,
                          title: 'Tratamiento: ${item['producto']}',
                          description: 'Lote: ${item['loteNombre']}\nVía: ${item['metodoAplicacion']} - Dosis: ${item['dosis']} ${item['unidad']}\n${item['observaciones']}',
                          isLast: isLast,
                        );
                      }
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
      bottomNavigationBar: AgroBottomNav(
        current: widget.currentTab,
      ),
    );
  }

  Widget _filterPill(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primary : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppText.labelCaps(
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant),
        ),
      ),
    );
  }

  Widget _timelineItem({
    required Color dotColor,
    required String dateStr,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 16),
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.background, width: 2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(dateStr,
                            style: AppText.labelCaps(
                                color: AppColors.onSurfaceVariant)),
                      ),
                      Icon(icon, color: iconColor, size: 20),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(title, style: AppText.h3()),
                  const SizedBox(height: 8),
                  Text(description,
                      style: AppText.bodyMd(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

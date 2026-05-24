import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../common/agro_bottom_nav.dart';
import '../widgets/offline_banner.dart';
import '../widgets/custom_app_bar.dart';
import '../../core/storage/database_helper.dart';
import 'package:intl/intl.dart';
import 'irrigation_screen.dart';
import 'sowing_screen.dart';
import 'terrain_status_screen.dart';
import 'package:provider/provider.dart';
import '../../data/providers/lotes_provider.dart';
import '../../data/providers/operaciones_provider.dart';
enum SyncStatus { syncing, local, completed }

class _HistoryItem {
  final String id;
  final String table;
  final String title;
  final String loteNombre;
  final String type;
  final DateTime date;
  final SyncStatus status;
  final IconData icon;
  final Color iconBg;
  final Color iconFg;

  _HistoryItem({
    required this.id,
    required this.table,
    required this.title,
    required this.loteNombre,
    required this.type,
    required this.date,
    required this.status,
    required this.icon,
    required this.iconBg,
    required this.iconFg,
  });
}

class GlobalHistoryScreen extends StatefulWidget {
  const GlobalHistoryScreen({super.key});

  @override
  State<GlobalHistoryScreen> createState() => _GlobalHistoryScreenState();
}

class _GlobalHistoryScreenState extends State<GlobalHistoryScreen> {
  bool _isLoading = true;
  List<_HistoryItem> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final db = await DatabaseHelper.instance.database;
    final List<_HistoryItem> items = [];
    final lotesProvider = context.read<LotesProvider>();

    String getLoteNombre(String? loteId) {
      if (loteId == null) return 'Lote Desconocido';
      final lote = lotesProvider.lotes.where((l) => l.id == loteId).firstOrNull;
      return lote?.nombre ?? 'Lote Desconocido';
    }

    // Sincronizar con el backend antes de leer SQLite
    try {
      final lotesIds = lotesProvider.lotes.map((l) => l.id).toList();
      if (lotesIds.isNotEmpty && mounted) {
        await context.read<OperacionesProvider>().sincronizarTodasLasOperaciones(lotesIds);
      }
    } catch (_) {}

    final siembras = await db.query(DatabaseHelper.tableSiembras);
    for (var s in siembras) {
      try {
        items.add(_HistoryItem(
          id: s['id'] as String,
          table: DatabaseHelper.tableSiembras,
          title: 'Siembra: ${s['cultivo'] ?? 'Desconocido'}',
          loteNombre: getLoteNombre(s['loteId'] as String?),
          type: 'siembra',
          date: DateTime.parse(s['createdAt'] as String),
          status: (s['isPendingSync'] as int) == 1 ? SyncStatus.local : SyncStatus.completed,
          icon: Icons.agriculture,
          iconBg: AppColors.tertiaryContainer,
          iconFg: AppColors.onTertiaryContainer,
        ));
      } catch (e) {
        debugPrint('Error parsing siembra: $e');
      }
    }

    // 2. Riego (y Humedad)
    final riegos = await db.query(DatabaseHelper.tableRiego);
    for (var r in riegos) {
      final tipo = r['tipo'] as String? ?? '';
      final isHumedad = tipo.contains('Humedad');
      items.add(_HistoryItem(
        id: r['id'] as String,
        table: DatabaseHelper.tableRiego,
        title: isHumedad ? 'Registro Humedad' : 'Riego: ${r['tipo']}',
        loteNombre: getLoteNombre(r['loteId'] as String?),
        type: isHumedad ? 'humedad' : 'riego',
        date: DateTime.parse(r['createdAt'] as String),
        status: (r['isPendingSync'] as int) == 1 ? SyncStatus.local : SyncStatus.completed,
        icon: isHumedad ? Icons.water_drop_outlined : Icons.water_drop,
        iconBg: AppColors.secondaryContainer,
        iconFg: AppColors.onSecondaryContainer,
      ));
    }

    // 3. Fertilización
    final ferts = await db.query(DatabaseHelper.tableFertilizacion);
    for (var f in ferts) {
      items.add(_HistoryItem(
        id: f['id'] as String,
        table: DatabaseHelper.tableFertilizacion,
        title: 'Fertilización: ${f['fertilizante'] ?? 'Desconocido'}',
        loteNombre: getLoteNombre(f['loteId'] as String?),
        type: 'fertilizacion',
        date: DateTime.parse(f['createdAt'] as String),
        status: (f['isPendingSync'] as int) == 1 ? SyncStatus.local : SyncStatus.completed,
        icon: Icons.science,
        iconBg: AppColors.primaryContainer,
        iconFg: AppColors.onPrimaryContainer,
      ));
    }

    // 4. Plagas y Enfermedades (Hallazgos)
    final plagas = await db.query(DatabaseHelper.tableHallazgos);
    for (var p in plagas) {
      items.add(_HistoryItem(
        id: p['id'] as String,
        table: DatabaseHelper.tableHallazgos,
        title: 'Hallazgo: ${p['tipo'] ?? 'Desconocido'}',
        loteNombre: getLoteNombre(p['loteId'] as String?),
        type: 'plaga',
        date: DateTime.parse(p['createdAt'] as String),
        status: (p['isPendingSync'] as int) == 1 ? SyncStatus.local : SyncStatus.completed,
        icon: Icons.bug_report,
        iconBg: AppColors.errorContainer,
        iconFg: AppColors.onErrorContainer,
      ));
    }

    // 5. Tratamientos
    final trat = await db.query(DatabaseHelper.tableTratamientos);
    for (var t in trat) {
      items.add(_HistoryItem(
        id: t['id'] as String,
        table: DatabaseHelper.tableTratamientos,
        title: 'Tratamiento: ${t['producto'] ?? 'Desconocido'}',
        loteNombre: getLoteNombre(t['loteId'] as String?),
        type: 'tratamiento',
        date: DateTime.parse(t['createdAt'] as String),
        status: (t['isPendingSync'] as int) == 1 ? SyncStatus.local : SyncStatus.completed,
        icon: Icons.vaccines,
        iconBg: AppColors.primaryContainer,
        iconFg: AppColors.onPrimaryContainer,
      ));
    }

    // 6. Observaciones
    final obs = await db.query(DatabaseHelper.tableObservaciones);
    for (var o in obs) {
      items.add(_HistoryItem(
        id: o['id'] as String,
        table: DatabaseHelper.tableObservaciones,
        title: 'Observación de Campo',
        loteNombre: getLoteNombre(o['loteId'] as String?),
        type: 'observacion',
        date: DateTime.parse(o['createdAt'] as String),
        status: (o['isPendingSync'] as int) == 1 ? SyncStatus.local : SyncStatus.completed,
        icon: Icons.note_alt,
        iconBg: AppColors.surfaceVariant,
        iconFg: AppColors.onSurfaceVariant,
      ));
    }

    // 7. Estado del Terreno
    try {
      final terrenos = await db.query(DatabaseHelper.tableEstadoTerreno);
      for (var t in terrenos) {
        final estado = t['estado'] as String;
        final siembraId = t['siembraId'] as String?;
        final isPrevio = siembraId == null || 
            ['limpio', 'con maleza', 'arado', 'adecuado'].contains(estado.toLowerCase());
        final title = isPrevio ? 'Terreno (Previo): $estado' : 'Terreno (Después): $estado';

        items.add(_HistoryItem(
          id: t['id'] as String,
          table: DatabaseHelper.tableEstadoTerreno,
          title: title,
          loteNombre: getLoteNombre(t['loteId'] as String?),
          type: 'terreno',
          date: DateTime.parse(t['createdAt'] as String),
          status: (t['isPendingSync'] as int) == 1 ? SyncStatus.local : SyncStatus.completed,
          icon: Icons.landscape,
          iconBg: AppColors.secondaryContainer,
          iconFg: AppColors.secondary,
        ));
      }
    } catch (_) {}

    // Sort descending (newest first)
    items.sort((a, b) => b.date.compareTo(a.date));

    if (mounted) {
      setState(() {
        _history = items;
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    
    if (diff.inMinutes < 1) return 'Hace un momento';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) {
      return diff.inHours == 1 ? 'Hace 1 hora' : 'Hace ${diff.inHours} horas';
    }
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    if (diff.inDays < 14) return 'Hace una semana';
    
    return DateFormat('dd/MM/yyyy').format(d);
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
            const OfflineBanner(),
            const SizedBox(height: 16),
            Text('Historial Global', style: AppText.h2()),
            const SizedBox(height: 16),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_history.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text('No hay registros para este lote.',
                      style: AppText.bodyMd(color: AppColors.outline)),
                ),
              )
            else
              ..._history.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _activityCard(
                  id: item.id,
                  table: item.table,
                  icon: item.icon,
                  iconBg: item.iconBg,
                  iconFg: item.iconFg,
                  title: item.title,
                  loteNombre: item.loteNombre,
                  time: _formatDate(item.date),
                  status: item.status,
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _activityCard({
    required String id,
    required String table,
    required IconData icon,
    required Color iconBg,
    required Color iconFg,
    required String title,
    required String loteNombre,
    required String time,
    required SyncStatus status,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.outlineVariant, width: 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconFg, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppText.bodyMd().copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _badge(status),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  loteNombre,
                  style: AppText.bodyMd(color: AppColors.primary).copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      time,
                      style: AppText.bodyMd(
                        color: AppColors.onSurfaceVariant,
                      ).copyWith(fontSize: 13),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: AppColors.outline, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          if (table == DatabaseHelper.tableRiego) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => IrrigationScreen(idToEdit: id, currentTab: AgroTab.home)));
                          } else if (table == DatabaseHelper.tableSiembras) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => SowingScreen(idToEdit: id, currentTab: AgroTab.home)));
                          } else if (table == DatabaseHelper.tableEstadoTerreno) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => TerrainStatusScreen(idToEdit: id, currentTab: AgroTab.home)));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Edición para este proceso disponible próximamente')),
                            );
                          }
                        } else if (value == 'delete') {
                          final messenger = ScaffoldMessenger.of(context);
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmar Eliminación'),
                              content: Text('¿Estás seguro que deseas eliminar el registro de "$title"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('CANCELAR'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('ELIMINAR', style: TextStyle(color: AppColors.error)),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            final db = await DatabaseHelper.instance.database;
                            await db.delete(table, where: 'id = ?', whereArgs: [id]);
                            if (table == DatabaseHelper.tableSiembras) {
                              await db.delete(
                                DatabaseHelper.tableEstadoTerreno,
                                where: 'siembraId = ?',
                                whereArgs: [id],
                              );
                              try {
                                final sRow = await db.query(DatabaseHelper.tableSiembras, where: 'id = ?', whereArgs: [id]);
                                if (sRow.isNotEmpty) {
                                  final loteId = sRow.first['loteId'] as String;
                                  await db.update(
                                    DatabaseHelper.tableLotes,
                                    {'cultivoActual': null, 'cultivoActualId': null},
                                    where: 'id = ?',
                                    whereArgs: [loteId],
                                  );
                                  if (mounted) {
                                    context.read<LotesProvider>().init();
                                  }
                                }
                              } catch (_) {}
                            }
                            _loadHistory();
                            
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('El registro "$title" fue eliminado exitosamente.'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 20),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                              SizedBox(width: 8),
                              Text('Eliminar', style: TextStyle(color: AppColors.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(SyncStatus status) {
    late Color bg;
    late Color fg;
    late IconData icon;
    late String label;
    switch (status) {
      case SyncStatus.syncing:
        bg = AppColors.primaryContainer.withValues(alpha: 0.2);
        fg = AppColors.primary;
        icon = Icons.sync;
        label = 'Sincronizando';
        break;
      case SyncStatus.local:
        bg = AppColors.surfaceVariant;
        fg = AppColors.onSurfaceVariant;
        icon = Icons.cloud_off;
        label = 'Local';
        break;
      case SyncStatus.completed:
        bg = AppColors.secondaryContainer.withValues(alpha: 0.5);
        fg = AppColors.secondary;
        icon = Icons.cloud_done;
        label = 'Completado';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label.toUpperCase(),
            style: AppText.labelCaps(color: fg).copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

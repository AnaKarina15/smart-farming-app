import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/models/recomendacion_model.dart';
import '../../data/providers/recomendaciones_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../common/agro_bottom_nav.dart';
import 'treatment_apply_screen.dart';
import 'evaluation_screen.dart';

class ActiveAlertsScreen extends StatefulWidget {
  final AgroTab currentTab;
  final String? loteId;
  const ActiveAlertsScreen({
    super.key,
    this.currentTab = AgroTab.home,
    this.loteId,
  });

  @override
  State<ActiveAlertsScreen> createState() => _ActiveAlertsScreenState();
}

class _ActiveAlertsScreenState extends State<ActiveAlertsScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar recomendaciones del sistema experto si hay loteId
    if (widget.loteId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context
            .read<RecomendacionesProvider>()
            .cargarParaLote(widget.loteId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final recProvider = context.watch<RecomendacionesProvider>();
    final alertas = recProvider.recomendacionesCriticas;
    final isLoading = recProvider.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBack: true),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Alertas Activas',
                      style: AppText.h1(color: AppColors.primary)),
                  if (recProvider.error != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.wifi_off,
                              size: 16, color: AppColors.secondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              recProvider.error!,
                              style:
                                  AppText.bodyMd(color: AppColors.secondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (alertas.isEmpty && widget.loteId != null)
                    _buildEmptyState()
                  else if (alertas.isEmpty)
                    // Sin loteId: mostrar placeholder hasta que se seleccione un lote
                    _buildNoLoteState()
                  else
                    ...alertas.map((rec) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _alertCardFromRecomendacion(context, rec),
                        )),
                ],
              ),
            ),
      bottomNavigationBar: AgroBottomNav(
        current: widget.currentTab,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            const Icon(Icons.check_circle_outline,
                size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('¡Sin alertas activas!',
                style: AppText.h2(color: AppColors.onSurface)),
            const SizedBox(height: 8),
            Text(
              'El sistema experto no detecta problemas críticos en este lote.',
              style: AppText.bodyMd(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoLoteState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            const Icon(Icons.agriculture_outlined,
                size: 64, color: AppColors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('Selecciona un lote',
                style: AppText.h2(color: AppColors.onSurface)),
            const SizedBox(height: 8),
            Text(
              'Ingresa a un lote para ver las recomendaciones del sistema experto.',
              style: AppText.bodyMd(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _alertCardFromRecomendacion(
      BuildContext context, Recomendacion rec) {
    final priorityColor = _colorForPrioridad(rec.prioridad);
    final bgColor = priorityColor.withOpacity(0.07);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: priorityColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge de tipo de recomendación
          if (rec.tipoRecomendacion.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                rec.tipoRecomendacion.toUpperCase(),
                style: AppText.labelCaps(color: Colors.white)
                    .copyWith(fontSize: 10),
              ),
            ),
          const SizedBox(height: 12),
          Text(rec.nombre, style: AppText.h2()),
          const SizedBox(height: 8),
          Text(
            rec.accionSugerida,
            style: AppText.bodyMd(color: AppColors.onSurfaceVariant),
          ),
          if (rec.productoSugerido != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.science_outlined,
                    size: 16, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  '${rec.productoSugerido}'
                  '${rec.dosisRecomendada != null ? ' — ${rec.dosisRecomendada} ${rec.unidadRecomendada ?? ''}' : ''}',
                  style: AppText.bodyMd(color: AppColors.onSurfaceVariant)
                      .copyWith(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ],
          if (rec.fuenteCientifica != null) ...[
            const SizedBox(height: 4),
            Text(
              '📚 ${rec.fuenteCientifica}',
              style: AppText.bodyMd(color: AppColors.onSurfaceVariant)
                  .copyWith(fontSize: 11),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(color: AppColors.outlineVariant),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: priorityColor, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    rec.prioridadLabel,
                    style: AppText.labelCaps(color: priorityColor),
                  ),
                ],
              ),
              if (rec.motivoMatch != null)
                Flexible(
                  child: Text(
                    rec.motivoMatch!,
                    style:
                        AppText.labelCaps(color: AppColors.onSurfaceVariant)
                            .copyWith(fontSize: 10),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: priorityColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => _onAplicar(context, rec),
                  child: Text(
                    'APLICAR',
                    style: AppText.labelCaps(color: Colors.white)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: priorityColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => _onDescartar(context, rec),
                  child: Text(
                    'DESCARTAR',
                    style: AppText.labelCaps(color: priorityColor)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _colorForPrioridad(int prioridad) {
    switch (prioridad) {
      case 5:
        return const Color(0xFF7C3AED); // morado — crítica
      case 4:
        return AppColors.error; // rojo — alta
      case 3:
        return const Color(0xFFF97316); // naranja — media
      case 2:
        return const Color(0xFFEAB308); // amarillo — baja
      default:
        return AppColors.primary; // verde — mínima
    }
  }

  Future<void> _onAplicar(BuildContext context, Recomendacion rec) async {
    // Navegar a pantalla de tratamiento si hay loteId
    if (widget.loteId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TreatmentApplyScreen(
            alertLoteName: widget.loteId!,
            alertPlagueName: rec.nombre,
            currentTab: widget.currentTab,
          ),
        ),
      );
    } else {
      // Registrar decisión directamente
      final provider = context.read<RecomendacionesProvider>();
      await provider.registrarDecision(
        reglaId: rec.reglaId,
        loteId: provider.loteIdActual ?? '',
        decision: 'aplicar',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recomendación marcada como aplicada')),
        );
      }
    }
  }

  Future<void> _onDescartar(BuildContext context, Recomendacion rec) async {
    final provider = context.read<RecomendacionesProvider>();
    await provider.registrarDecision(
      reglaId: rec.reglaId,
      loteId: provider.loteIdActual ?? '',
      decision: 'descartar',
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recomendación descartada')),
      );
    }
  }
}

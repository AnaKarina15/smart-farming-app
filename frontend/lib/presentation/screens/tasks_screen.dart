import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/providers/tareas_provider.dart';
import '../common/agro_bottom_nav.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/offline_banner.dart';
import 'home_screen.dart';
import 'map_onboarding_screen.dart';
import 'profile_screen.dart';
import 'irrigation_screen.dart';
import 'evaluation_screen.dart';
import 'fertilization_screen.dart';
import 'treatment_apply_screen.dart';
import 'register_observation_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TareasProvider>().cargarTareas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tareasProvider = context.watch<TareasProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<TareasProvider>().cargarTareas();
        },
        child: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(
            overscroll: false, // Desactiva por completo el efecto de overscroll stretch
          ),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const OfflineBanner(),
              Text(
                'Sugerencias y Alertas del Sistema',
                style: AppText.h2(color: AppColors.onSurface),
              ),
              const SizedBox(height: 10),
  
              // ── Estado de carga ──────────────────────────
              if (tareasProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
  
              // ── Sin lotes o sin tareas ───────────────────
              else if (!tareasProvider.hasTareas)
                _EmptyTareas()
  
              // ── Lista de tareas dinámicas ────────────────
              else
                ...tareasProvider.tareas.map((tarea) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildTaskCard(context, tarea),
                  );
                }),
            ],
          ),
        ),
      ),
    ),
      bottomNavigationBar: AgroBottomNav(
        current: AgroTab.tareas,
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
          }
        },
      ),
    );
  }

  /// Construye una tarjeta de tarea con la apariencia correcta según el tipo.
  Widget _buildTaskCard(BuildContext context, TareaItem tarea) {
    switch (tarea.tipo) {
      case TareaTipo.riego:
        return _TaskCard(
          icon: Icons.water_drop,
          iconColor: AppColors.onPrimary,
          iconBgColor: AppColors.primary,
          cardColor: AppColors.secondaryContainer,
          title: tarea.titulo,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: AppText.bodyMd(color: AppColors.onSecondaryContainer),
                  children: [
                    TextSpan(
                        text: '${tarea.loteNombre}: ',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: tarea.descripcion.replaceFirst('${tarea.loteNombre}: ', '')),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  style: AppText.bodyMd(color: AppColors.onSecondaryContainer),
                  children: [
                    const TextSpan(
                        text: 'Motivo: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: tarea.motivo),
                  ],
                ),
              ),
            ],
          ),
          actionLabel: tarea.accionLabel,
          onAction: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => IrrigationScreen(
                fixedLote: tarea.loteNombre,
                currentTab: AgroTab.tareas,
              ),
            ),
          ),
          footer: Text(
            _prioridadLabel(tarea.prioridad),
            style: AppText.bodyMd(color: AppColors.onSecondaryContainer)
                .copyWith(fontSize: 13, fontStyle: FontStyle.italic),
          ),
        );

      case TareaTipo.evaluacion:
        return _TaskCard(
          icon: Icons.bug_report,
          iconColor: AppColors.onPrimary,
          iconBgColor: AppColors.primary,
          cardColor: AppColors.errorContainer,
          title: tarea.titulo,
          content: RichText(
            text: TextSpan(
              style: AppText.bodyMd(color: AppColors.onErrorContainer),
              children: [
                TextSpan(
                    text: '${tarea.loteNombre}: ',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: tarea.descripcion.replaceFirst('${tarea.loteNombre}: ', '')),
              ],
            ),
          ),
          actionLabel: tarea.accionLabel,
          onAction: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EvaluationScreen(
                loteName: tarea.loteNombre,
                plagueName: tarea.plagaNombre ?? 'Plaga detectada',
                treatment: tarea.productoTratamiento ?? 'Tratamiento aplicado',
                treatmentTime: tarea.tiempoTratamiento ?? '24H',
                currentTab: AgroTab.tareas,
              ),
            ),
          ),
        );

      case TareaTipo.tratamiento:
        return _TaskCard(
          icon: Icons.healing,
          iconColor: AppColors.onPrimary,
          iconBgColor: AppColors.primary,
          cardColor: const Color(0xFFFFF3E0),
          title: tarea.titulo,
          content: RichText(
            text: TextSpan(
              style: AppText.bodyMd(color: const Color(0xFFE65100)),
              children: [
                TextSpan(
                    text: '${tarea.loteNombre}: ',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: tarea.descripcion.replaceFirst('${tarea.loteNombre}: ', '')),
              ],
            ),
          ),
          actionLabel: tarea.accionLabel,
          onAction: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TreatmentApplyScreen(
                alertLoteName: tarea.loteNombre,
                alertPlagueName: tarea.plagaNombre ?? '',
                currentTab: AgroTab.tareas,
              ),
            ),
          ),
        );

      case TareaTipo.fertilizacion:
        return _TaskCard(
          icon: Icons.science,
          iconColor: AppColors.onPrimary,
          iconBgColor: AppColors.primary,
          cardColor: const Color(0xFFE8F5E9),
          title: tarea.titulo,
          content: RichText(
            text: TextSpan(
              style: AppText.bodyMd(color: const Color(0xFF1B5E20)),
              children: [
                TextSpan(
                    text: '${tarea.loteNombre}: ',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: tarea.descripcion.replaceFirst('${tarea.loteNombre}: ', '')),
              ],
            ),
          ),
          actionLabel: tarea.accionLabel,
          onAction: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FertilizationScreen(
                fixedLote: tarea.loteNombre,
                currentTab: AgroTab.tareas,
              ),
            ),
          ),
          footer: Text(
            tarea.motivo,
            style: AppText.bodyMd(color: const Color(0xFF1B5E20))
                .copyWith(fontSize: 13, fontStyle: FontStyle.italic),
          ),
        );

      case TareaTipo.observacion:
        return _TaskCard(
          icon: Icons.note_add,
          iconColor: AppColors.onPrimary,
          iconBgColor: AppColors.primary,
          cardColor: AppColors.surfaceVariant,
          title: tarea.titulo,
          content: RichText(
            text: TextSpan(
              style: AppText.bodyMd(color: AppColors.onSurfaceVariant),
              children: [
                TextSpan(
                    text: '${tarea.loteNombre}: ',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: tarea.descripcion.replaceFirst('${tarea.loteNombre}: ', '')),
              ],
            ),
          ),
          actionLabel: tarea.accionLabel,
          onAction: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RegisterObservationScreen(
                loteName: tarea.loteNombre,
                currentTab: AgroTab.tareas,
              ),
            ),
          ),
          footer: Text(
            tarea.motivo,
            style: AppText.bodyMd(color: AppColors.onSurfaceVariant)
                .copyWith(fontSize: 13, fontStyle: FontStyle.italic),
          ),
        );

      case TareaTipo.hallazgo:
        return _TaskCard(
          icon: Icons.pest_control,
          iconColor: AppColors.onPrimary,
          iconBgColor: AppColors.primary,
          cardColor: AppColors.errorContainer,
          title: tarea.titulo,
          content: RichText(
            text: TextSpan(
              style: AppText.bodyMd(color: AppColors.onErrorContainer),
              children: [
                TextSpan(
                    text: '${tarea.loteNombre}: ',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: tarea.descripcion.replaceFirst('${tarea.loteNombre}: ', '')),
              ],
            ),
          ),
          actionLabel: tarea.accionLabel,
          onAction: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TreatmentApplyScreen(
                alertLoteName: tarea.loteNombre,
                alertPlagueName: tarea.plagaNombre ?? '',
                currentTab: AgroTab.tareas,
              ),
            ),
          ),
        );
    }
  }

  String _prioridadLabel(TareaPrioridad p) {
    switch (p) {
      case TareaPrioridad.alta:
        return 'Prioridad alta';
      case TareaPrioridad.media:
        return 'Prioridad media';
      case TareaPrioridad.baja:
        return 'Calculado con datos locales';
    }
  }
}

// ── Widget de estado vacío ──────────────────────────────────

class _EmptyTareas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: AppColors.primaryFixed,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '¡Todo al día!',
            style: AppText.h3(color: AppColors.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'No tienes tareas pendientes en este momento.\nSigue monitoreando tus lotes.',
            style: AppText.bodyMd(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── _TaskCard (sin cambios en la estructura) ────────────────

class _TaskCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final Color cardColor;
  final String title;
  final Widget content;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? footer;

  const _TaskCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.cardColor,
    required this.title,
    required this.content,
    this.actionLabel,
    this.onAction,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppText.h3(color: AppColors.primary)
                            .copyWith(fontSize: 22)),
                    const SizedBox(height: 8),
                    content,
                  ],
                ),
              ),
            ],
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999)),
                ),
                child: Text(
                  actionLabel!,
                  style: AppText.labelCapsLg(color: AppColors.onPrimary),
                ),
              ),
            ),
          ],
          if (footer != null) ...[
            const SizedBox(height: 8),
            footer!,
          ]
        ],
      ),
    );
  }
}

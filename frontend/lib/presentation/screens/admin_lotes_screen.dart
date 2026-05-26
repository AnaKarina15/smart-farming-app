import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/lote_admin.dart';
import '../../data/providers/admin_provider.dart';
import '../widgets/admin_widgets.dart';
import '../widgets/custom_app_bar.dart';

class AdminLotesScreen extends StatefulWidget {
  const AdminLotesScreen({super.key});

  @override
  State<AdminLotesScreen> createState() => _AdminLotesScreenState();
}

class _AdminLotesScreenState extends State<AdminLotesScreen> {
  final _searchCtrl = TextEditingController();
  String? _filtroCultivo;
  String? _filtroEstado;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().cargarTodosLotes();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AK.bg,
      appBar: const CustomAppBar(),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          final lotes = _filtrar(provider.lotes);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Encabezado ───────────────────────────────────────────
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestión Global de Lotes',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AK.text,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Vista de supervisión: todos los lotes de todos los productores.',
                      style: TextStyle(
                          fontSize: 12, color: AK.subtext, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ─── Stats rápidas ────────────────────────────────────────
              if (provider.lotes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _StatRow(
                        label: 'TOTAL DE LOTES',
                        valor: '${provider.lotes.length}',
                        icono: Icons.grid_view,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 8),
                      _StatRow(
                        label: 'CON ALERTAS',
                        valor:
                            '${provider.lotes.where((l) => l.estado?.toLowerCase() == 'afectado').length}',
                        icono: Icons.warning_amber_rounded,
                        color: AK.error,
                        colorFondo: const Color(0xFFFFEBEE),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              // ─── Filtros ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Búsqueda
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre de lote...',
                        hintStyle:
                            const TextStyle(color: AK.inactive, fontSize: 13),
                        prefixIcon: const Icon(Icons.search,
                            color: AK.inactive, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AK.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AK.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _DropdownFiltro(
                            hint: 'Cultivo',
                            valor: _filtroCultivo,
                            opciones: _cultivosUnicos(provider.lotes),
                            onChanged: (v) =>
                                setState(() => _filtroCultivo = v),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DropdownFiltro(
                            hint: 'Estado',
                            valor: _filtroEstado,
                            opciones: const [
                              'Saludable',
                              'Afectado',
                              'Cosechado'
                            ],
                            onChanged: (v) => setState(() => _filtroEstado = v),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ─── Lista ────────────────────────────────────────────────
              Expanded(
                child: provider.cargando && provider.lotes.isEmpty
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: AppColors.primary),
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () => provider.cargarTodosLotes(),
                        child: lotes.isEmpty
                            ? const Center(
                                child: Text(
                                  'No hay lotes registrados.',
                                  style: TextStyle(color: AK.subtext),
                                ),
                              )
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 100),
                                itemCount: lotes.length,
                                itemBuilder: (_, i) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _TarjetaLote(lote: lotes[i]),
                                ),
                              ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<LoteAdmin> _filtrar(List<LoteAdmin> todos) {
    var lista = todos;
    if (_searchCtrl.text.isNotEmpty) {
      final q = _searchCtrl.text.toLowerCase();
      lista = lista
          .where((l) =>
              l.nombre.toLowerCase().contains(q) ||
              (l.propietarioId?.toLowerCase().contains(q) ?? false))
          .toList();
    }
    if (_filtroCultivo != null) {
      lista = lista
          .where(
              (l) => l.cultivo?.toLowerCase() == _filtroCultivo!.toLowerCase())
          .toList();
    }
    if (_filtroEstado != null) {
      lista = lista
          .where((l) =>
              l.estadoHumanizado.toLowerCase() == _filtroEstado!.toLowerCase())
          .toList();
    }
    return lista;
  }

  List<String> _cultivosUnicos(List<LoteAdmin> lotes) => lotes
      .map((l) => l.cultivo ?? '')
      .where((c) => c.isNotEmpty)
      .toSet()
      .toList();
}

// ─────────────────────────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  final String label;
  final String valor;
  final IconData icono;
  final Color color;
  final Color? colorFondo;
  const _StatRow({
    required this.label,
    required this.valor,
    required this.icono,
    required this.color,
    this.colorFondo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorFondo ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorFondo != null ? color.withValues(alpha: 0.3) : AK.border,
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: 0.8,
                  )),
              Text(valor,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: color,
                    height: 1.1,
                  )),
            ],
          ),
          const Spacer(),
          Icon(icono, color: color, size: 28),
        ],
      ),
    );
  }
}

class _DropdownFiltro extends StatelessWidget {
  final String hint;
  final String? valor;
  final List<String> opciones;
  final ValueChanged<String?> onChanged;
  const _DropdownFiltro({
    required this.hint,
    required this.valor,
    required this.opciones,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final String displayLabel = valor ?? hint;
    final bool hasSelection = valor != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;

        return PopupMenuButton<String?>(
          onSelected: onChanged,
          position: PopupMenuPosition.under,
          constraints: BoxConstraints(
            minWidth: width,
            maxWidth: width,
          ),
          surfaceTintColor: Colors.white,
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AK.border),
          ),
          offset: const Offset(0, 4),
          itemBuilder: (context) => [
            const PopupMenuItem<String?>(
              value: null,
              child: Text('Todos', style: TextStyle(fontSize: 13)),
            ),
            ...opciones.map((o) => PopupMenuItem<String?>(
                  value: o,
                  child: Text(o, style: const TextStyle(fontSize: 13)),
                )),
          ],
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AK.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayLabel,
                    style: TextStyle(
                      color: hasSelection ? AK.text : AK.subtext,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AK.subtext,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TarjetaLote extends StatelessWidget {
  final LoteAdmin lote;
  const _TarjetaLote({required this.lote});

  @override
  Widget build(BuildContext context) {
    final estadoColor = _colorEstado(lote.estado);
    final estadoBg = _bgEstado(lote.estado);
    final propietarioLabel = lote.propietarioNombre?.trim().isNotEmpty == true
        ? lote.propietarioNombre!.trim()
        : lote.propietarioId;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AK.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen placeholder con badge de estado
          Stack(
            children: [
              Container(
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: Center(
                  child: Icon(Icons.agriculture,
                      size: 36,
                      color: AppColors.primary.withValues(alpha: 0.4)),
                ),
              ),
              if (lote.estado != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: estadoBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      lote.estadoHumanizado.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: estadoColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        lote.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AK.text,
                        ),
                      ),
                    ),
                    const Icon(Icons.more_vert, color: AK.subtext, size: 20),
                  ],
                ),
                if (propietarioLabel != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Propietario: $propietarioLabel',
                      style: const TextStyle(fontSize: 11, color: AK.subtext),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _PillInfo(
                        label: 'CULTIVO',
                        valor: lote.cultivo ?? 'N/A',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PillInfo(
                        label: 'SUPERFICIE',
                        valor: '${lote.superficie.toStringAsFixed(1)} ha',
                      ),
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

  static Color _colorEstado(String? e) {
    switch (e?.toLowerCase()) {
      case 'saludable':
        return const Color(0xFF2E7D32);
      case 'afectado':
        return AK.error;
      case 'cosechado':
        return const Color(0xFF795548);
      default:
        return AK.subtext;
    }
  }

  static Color _bgEstado(String? e) {
    switch (e?.toLowerCase()) {
      case 'saludable':
        return const Color(0xFFE8F5E9);
      case 'afectado':
        return const Color(0xFFFFEBEE);
      case 'cosechado':
        return const Color(0xFFEFEBE9);
      default:
        return AK.bg;
    }
  }
}

class _PillInfo extends StatelessWidget {
  final String label;
  final String valor;
  const _PillInfo({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 10,
              color: AK.subtext,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            )),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            valor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

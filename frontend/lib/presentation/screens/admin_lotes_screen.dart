import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/admin_provider.dart';
import '../../data/models/lote_admin.dart';
import '../widgets/admin_widgets.dart';

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
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        leading: const Icon(Icons.menu, color: AdminColors.textPrimary),
        title: const Text(
          'AgroField',
          style: TextStyle(
            color: AdminColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AdminColors.primary,
            child: const Icon(Icons.person, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          final lotes = _filtrarLotes(provider.lotes);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Encabezado ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Gestión Global de Lotes',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AdminColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Vista de supervisión para el administrador que muestra todos los lotes de todos los productores registrados en la plataforma.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AdminColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ─── Tarjetas de stats ───────────────────────────────────────
              if (!provider.cargando || provider.lotes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _TarjetaStat(
                        label: 'TOTAL DE LOTES',
                        valor: '${provider.lotes.length}',
                        icono: Icons.grid_view,
                        color: AdminColors.primary,
                      ),
                      const SizedBox(height: 8),
                      _TarjetaStat(
                        label: 'LOTES ACTIVOS',
                        valor: '${provider.lotes.where((l) => l.estado?.toLowerCase() != 'cosechado').length}',
                        icono: Icons.check_circle_outline,
                        color: AdminColors.accent,
                      ),
                      const SizedBox(height: 8),
                      _TarjetaStat(
                        label: 'CON ALERTAS',
                        valor: '${provider.lotes.where((l) => l.estado?.toLowerCase() == 'afectado').length}',
                        icono: Icons.warning_amber_rounded,
                        color: AdminColors.error,
                        colorFondo: AdminColors.errorLight,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // ─── Filtros ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Búsqueda
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre de lote o ID de...',
                        hintStyle:
                            const TextStyle(color: AdminColors.inactive, fontSize: 13),
                        prefixIcon: const Icon(Icons.search,
                            color: AdminColors.inactive, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AdminColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AdminColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AdminColors.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
                            onChanged: (v) => setState(() => _filtroCultivo = v),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DropdownFiltro(
                            hint: 'Estado',
                            valor: _filtroEstado,
                            opciones: const ['Saludable', 'Afectado', 'Cosechado'],
                            onChanged: (v) => setState(() => _filtroEstado = v),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ─── Lista de lotes ──────────────────────────────────────────
              Expanded(
                child: provider.cargando && provider.lotes.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(color: AdminColors.primary),
                      )
                    : RefreshIndicator(
                        color: AdminColors.primary,
                        onRefresh: () => provider.cargarTodosLotes(),
                        child: lotes.isEmpty
                            ? const Center(
                                child: Text(
                                  'No hay lotes registrados.',
                                  style: TextStyle(color: AdminColors.textSecondary),
                                ),
                              )
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 100),
                                itemCount: lotes.length + 1,
                                itemBuilder: (_, i) {
                                  if (i == lotes.length) {
                                    return _BotonRegistrarLote();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _TarjetaLote(lote: lotes[i]),
                                  );
                                },
                              ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AdminColors.primary,
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  List<LoteAdmin> _filtrarLotes(List<LoteAdmin> todos) {
    var lista = todos;
    if (_searchCtrl.text.isNotEmpty) {
      final q = _searchCtrl.text.toLowerCase();
      lista = lista.where((l) =>
          l.nombre.toLowerCase().contains(q) ||
          (l.propietarioId?.toLowerCase().contains(q) ?? false)).toList();
    }
    if (_filtroCultivo != null) {
      lista = lista.where((l) =>
          l.cultivo?.toLowerCase() == _filtroCultivo!.toLowerCase()).toList();
    }
    if (_filtroEstado != null) {
      lista = lista.where((l) =>
          l.estadoHumanizado.toLowerCase() == _filtroEstado!.toLowerCase()).toList();
    }
    return lista;
  }

  List<String> _cultivosUnicos(List<LoteAdmin> lotes) {
    return lotes
        .map((l) => l.cultivo ?? '')
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _TarjetaStat extends StatelessWidget {
  final String label;
  final String valor;
  final IconData icono;
  final Color color;
  final Color? colorFondo;

  const _TarjetaStat({
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
          color: colorFondo != null ? color.withOpacity(0.3) : AdminColors.border,
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                valor,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: color,
                  height: 1.1,
                ),
              ),
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
    return DropdownButtonFormField<String>(
      value: valor,
      hint: Text(hint, style: const TextStyle(color: AdminColors.textSecondary, fontSize: 13)),
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text('Todos', style: const TextStyle(fontSize: 13)),
        ),
        ...opciones.map(
          (o) => DropdownMenuItem<String>(value: o, child: Text(o, style: const TextStyle(fontSize: 13))),
        ),
      ],
      onChanged: onChanged,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AdminColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AdminColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AdminColors.primary, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
      isExpanded: true,
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AdminColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen placeholder (verde con badge de estado)
          Stack(
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: AdminColors.primary.withOpacity(0.15),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: Center(
                  child: Icon(
                    Icons.agriculture,
                    size: 40,
                    color: AdminColors.primary.withOpacity(0.4),
                  ),
                ),
              ),
              if (lote.estado != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

          // Info del lote
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
                          color: AdminColors.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(Icons.more_vert, color: AdminColors.textSecondary, size: 20),
                  ],
                ),
                if (lote.propietarioId != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'ID Propietario: ${lote.propietarioId}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AdminColors.textSecondary,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _PillInfo(label: 'CULTIVO', valor: lote.cultivo ?? 'N/A'),
                    const SizedBox(width: 12),
                    _PillInfo(
                      label: 'SUPERFICIE',
                      valor: '${lote.superficie.toStringAsFixed(1)} ha',
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

  Color _colorEstado(String? estado) {
    switch (estado?.toLowerCase()) {
      case 'saludable':
        return AdminColors.estadoSaludable;
      case 'afectado':
        return AdminColors.estadoAfectado;
      case 'cosechado':
        return AdminColors.estadoCosechado;
      default:
        return AdminColors.textSecondary;
    }
  }

  Color _bgEstado(String? estado) {
    switch (estado?.toLowerCase()) {
      case 'saludable':
        return AdminColors.estadoSaludableBg;
      case 'afectado':
        return AdminColors.estadoAfectadoBg;
      case 'cosechado':
        return AdminColors.estadoCosechadoBg;
      default:
        return AdminColors.background;
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AdminColors.textSecondary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AdminColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            valor,
            style: const TextStyle(
              fontSize: 12,
              color: AdminColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _BotonRegistrarLote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(top: 4, bottom: 20),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AdminColors.border, style: BorderStyle.solid),
        ),
        child: const Column(
          children: [
            Icon(Icons.add, color: AdminColors.textSecondary, size: 28),
            SizedBox(height: 4),
            Text(
              'Registrar Nuevo Lote',
              style: TextStyle(
                fontSize: 13,
                color: AdminColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
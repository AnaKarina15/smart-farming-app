import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/admin_provider.dart';
import '../../data/models/usuario_admin.dart';
import '../widgets/admin_widgets.dart';
import 'admin_detalle_usuario_screen.dart';
import 'admin_crear_usuario_screen.dart';

class AdminUsuariosScreen extends StatefulWidget {
  const AdminUsuariosScreen({super.key});

  @override
  State<AdminUsuariosScreen> createState() => _AdminUsuariosScreenState();
}

class _AdminUsuariosScreenState extends State<AdminUsuariosScreen> {
  final _searchController = TextEditingController();
  String? _rolSeleccionado; // null = Todos
  bool? _activoSeleccionado; // null = ambos

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().cargarUsuarios();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
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
        titleSpacing: 20,
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AdminColors.primary,
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            const Text(
              'AgroField',
              style: TextStyle(
                color: AdminColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AdminColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Encabezado ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Usuarios del Sistema',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AdminColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Gestiona accesos y roles de la plataforma.',
                  style: TextStyle(fontSize: 13, color: AdminColors.textSecondary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ─── Panel de filtros ─────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AdminColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Búsqueda
                TextField(
                  controller: _searchController,
                  onChanged: (v) => context.read<AdminProvider>().setBusqueda(v),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o email...',
                    hintStyle: const TextStyle(color: AdminColors.inactive, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: AdminColors.inactive, size: 20),
                    suffixIcon: const Icon(Icons.tune, color: AdminColors.textSecondary, size: 20),
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
                    fillColor: AdminColors.background,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),

                const SizedBox(height: 12),

                // Filtro rol
                const Text(
                  'Rol',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AdminColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _ChipFiltro(
                        label: 'Todos',
                        seleccionado: _rolSeleccionado == null,
                        onTap: () => _setRol(null),
                      ),
                      const SizedBox(width: 6),
                      _ChipFiltro(
                        label: 'Productores',
                        seleccionado: _rolSeleccionado == 'pequeno_productor',
                        onTap: () => _setRol('pequeno_productor'),
                      ),
                      const SizedBox(width: 6),
                      _ChipFiltro(
                        label: 'Trabajadores',
                        seleccionado: _rolSeleccionado == 'trabajador',
                        onTap: () => _setRol('trabajador'),
                      ),
                      const SizedBox(width: 6),
                      _ChipFiltro(
                        label: 'Gestores',
                        seleccionado: _rolSeleccionado == 'gestor',
                        onTap: () => _setRol('gestor'),
                      ),
                      const SizedBox(width: 6),
                      _ChipFiltro(
                        label: 'Admins',
                        seleccionado: _rolSeleccionado == 'administrador',
                        onTap: () => _setRol('administrador'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Filtro estado
                const Text(
                  'Estado',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AdminColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _ChipFiltro(
                      label: 'Activo',
                      seleccionado: _activoSeleccionado == true,
                      onTap: () => _setActivo(true),
                    ),
                    const SizedBox(width: 6),
                    _ChipFiltro(
                      label: 'Inactivo',
                      seleccionado: _activoSeleccionado == false,
                      onTap: () => _setActivo(false),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Toggle eliminados
                Consumer<AdminProvider>(
                  builder: (_, provider, __) => Row(
                    children: [
                      const Text(
                        'Ver eliminados',
                        style: TextStyle(fontSize: 13, color: AdminColors.textPrimary),
                      ),
                      const Spacer(),
                      Switch(
                        value: provider.verEliminados,
                        onChanged: (v) => provider.setVerEliminados(v),
                        activeColor: AdminColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ─── Lista ────────────────────────────────────────────────────────
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (_, provider, __) {
                if (provider.cargando && provider.usuarios.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AdminColors.primary),
                  );
                }
                if (provider.usuarios.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay usuarios que coincidan.',
                      style: TextStyle(color: AdminColors.textSecondary),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: provider.usuarios.length + (provider.hayMasPaginas ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    if (i == provider.usuarios.length) {
                      return _PaginacionControles(provider: provider);
                    }
                    return _TarjetaUsuario(usuario: provider.usuarios[i]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AdminColors.primary,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminCrearUsuarioScreen()),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _setRol(String? rol) {
    setState(() => _rolSeleccionado = _rolSeleccionado == rol ? null : rol);
    context.read<AdminProvider>().setFiltroRol(_rolSeleccionado);
  }

  void _setActivo(bool? valor) {
    setState(() => _activoSeleccionado = _activoSeleccionado == valor ? null : valor);
    context.read<AdminProvider>().setFiltroActivo(_activoSeleccionado);
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ChipFiltro extends StatelessWidget {
  final String label;
  final bool seleccionado;
  final VoidCallback onTap;

  const _ChipFiltro({
    required this.label,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: seleccionado ? AdminColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: seleccionado ? AdminColors.primary : AdminColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: seleccionado ? FontWeight.w700 : FontWeight.w400,
            color: seleccionado ? Colors.white : AdminColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _TarjetaUsuario extends StatelessWidget {
  final UsuarioAdmin usuario;

  const _TarjetaUsuario({required this.usuario});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdminDetalleUsuarioScreen(usuarioId: usuario.id),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AdminColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AvatarIniciales(
                  iniciales: usuario.iniciales,
                  role: usuario.role,
                  radio: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usuario.nombreCompleto,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                      Text(
                        usuario.email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AdminColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                RolChip(role: usuario.role),
                const SizedBox(width: 8),
                PuntoEstado(activo: usuario.activo, eliminado: usuario.estaEliminado),
                const Spacer(),
                // Botón editar
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminDetalleUsuarioScreen(usuarioId: usuario.id),
                    ),
                  ),
                  child: const Icon(Icons.edit_outlined, size: 20, color: AdminColors.textSecondary),
                ),
                const SizedBox(width: 12),
                // Menú contextual
                GestureDetector(
                  onTap: () => _mostrarMenu(context),
                  child: const Icon(Icons.more_vert, size: 20, color: AdminColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarMenu(BuildContext context) {
    final provider = context.read<AdminProvider>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility_outlined, color: AdminColors.primary),
              title: const Text('Ver detalle'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminDetalleUsuarioScreen(usuarioId: usuario.id),
                  ),
                );
              },
            ),
            if (usuario.estaEliminado)
              ListTile(
                leading: const Icon(Icons.restore, color: AdminColors.accent),
                title: const Text('Restaurar usuario'),
                onTap: () {
                  Navigator.pop(context);
                  provider.restaurarUsuario(usuario.id);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AdminColors.error),
                title: const Text('Eliminar usuario', style: TextStyle(color: AdminColors.error)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmarEliminar(context, provider);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, AdminProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text(
          '¿Eliminar a ${usuario.nombreCompleto}? Su información se conservará pero ya no podrá acceder.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.error),
            onPressed: () {
              Navigator.pop(context);
              provider.eliminarUsuario(usuario.id);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _PaginacionControles extends StatelessWidget {
  final AdminProvider provider;

  const _PaginacionControles({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: provider.paginaActual > 0 ? provider.paginaAnterior : null,
            color: AdminColors.primary,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AdminColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${provider.paginaActual + 1}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: provider.hayMasPaginas ? provider.paginaSiguiente : null,
            color: AdminColors.primary,
          ),
        ],
      ),
    );
  }
}
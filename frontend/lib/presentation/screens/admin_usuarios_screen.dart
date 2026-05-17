import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/usuario_admin.dart';
import '../../data/providers/admin_provider.dart';
import '../widgets/admin_widgets.dart';
import '../widgets/custom_app_bar.dart';
import 'admin_detalle_usuario_screen.dart';
import 'admin_crear_usuario_screen.dart';

class AdminUsuariosScreen extends StatefulWidget {
  const AdminUsuariosScreen({super.key});

  @override
  State<AdminUsuariosScreen> createState() => _AdminUsuariosScreenState();
}

class _AdminUsuariosScreenState extends State<AdminUsuariosScreen> {
  final _searchController = TextEditingController();
  String? _rolSeleccionado;
  bool?   _activoSeleccionado;

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
      backgroundColor: AK.bg,
      appBar: const CustomAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Encabezado ─────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Usuarios del Sistema',
                  style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w800, color: AK.text,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Gestiona accesos y roles de la plataforma.',
                  style: TextStyle(fontSize: 13, color: AK.subtext),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ─── Panel de filtros ────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AK.border),
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
                    hintStyle: const TextStyle(color: AK.inactive, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: AK.inactive, size: 20),
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
                      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    filled: true,
                    fillColor: AK.bg,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),

                const SizedBox(height: 12),

                // Chips de rol
                const Text('Rol', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AK.text)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChipFiltro(label: 'Todos',       seleccionado: _rolSeleccionado == null,                onTap: () => _setRol(null)),
                      const SizedBox(width: 6),
                      ChipFiltro(label: 'Productores', seleccionado: _rolSeleccionado == 'pequeno_productor', onTap: () => _setRol('pequeno_productor')),
                      const SizedBox(width: 6),
                      ChipFiltro(label: 'Trabajadores',seleccionado: _rolSeleccionado == 'trabajador',        onTap: () => _setRol('trabajador')),
                      const SizedBox(width: 6),
                      ChipFiltro(label: 'Gestores',    seleccionado: _rolSeleccionado == 'gestor',            onTap: () => _setRol('gestor')),
                      const SizedBox(width: 6),
                      ChipFiltro(label: 'Admins',      seleccionado: _rolSeleccionado == 'administrador',     onTap: () => _setRol('administrador')),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Chips de estado
                const Text('Estado', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AK.text)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ChipFiltro(label: 'Activo',   seleccionado: _activoSeleccionado == true,  onTap: () => _setActivo(true)),
                    const SizedBox(width: 6),
                    ChipFiltro(label: 'Inactivo', seleccionado: _activoSeleccionado == false, onTap: () => _setActivo(false)),
                  ],
                ),

                const SizedBox(height: 12),

                // Toggle eliminados
                Consumer<AdminProvider>(
                  builder: (_, prov, __) => Row(
                    children: [
                      const Text('Ver eliminados', style: TextStyle(fontSize: 13, color: AK.text)),
                      const Spacer(),
                      Switch(
                        value: prov.verEliminados,
                        onChanged: prov.setVerEliminados,
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ─── Lista ──────────────────────────────────────────────────────
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (_, prov, __) {
                if (prov.cargando && prov.usuarios.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (prov.usuarios.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay usuarios que coincidan.',
                      style: TextStyle(color: AK.subtext),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: prov.usuarios.length + (prov.hayMasPaginas ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    if (i == prov.usuarios.length) {
                      return _PaginacionControles(provider: prov);
                    }
                    return _TarjetaUsuario(usuario: prov.usuarios[i]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
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

  void _setActivo(bool valor) {
    setState(() => _activoSeleccionado = _activoSeleccionado == valor ? null : valor);
    context.read<AdminProvider>().setFiltroActivo(_activoSeleccionado);
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _TarjetaUsuario extends StatelessWidget {
  final UsuarioAdmin usuario;
  const _TarjetaUsuario({required this.usuario});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _irADetalle(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AK.border),
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
                          fontWeight: FontWeight.w700, fontSize: 15, color: AK.text,
                        ),
                      ),
                      Text(
                        usuario.email,
                        style: const TextStyle(fontSize: 12, color: AK.subtext),
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
                GestureDetector(
                  onTap: () => _irADetalle(context),
                  child: const Icon(Icons.edit_outlined, size: 20, color: AK.subtext),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _mostrarMenu(context),
                  child: const Icon(Icons.more_vert, size: 20, color: AK.subtext),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _irADetalle(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminDetalleUsuarioScreen(usuarioId: usuario.id),
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
              leading: Icon(Icons.visibility_outlined, color: AppColors.primary),
              title: const Text('Ver detalle'),
              onTap: () { Navigator.pop(context); _irADetalle(context); },
            ),
            if (usuario.estaEliminado)
              ListTile(
                leading: const Icon(Icons.restore, color: AK.accent),
                title: const Text('Restaurar usuario'),
                onTap: () {
                  Navigator.pop(context);
                  provider.restaurarUsuario(usuario.id);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AK.error),
                title: const Text('Eliminar usuario',
                    style: TextStyle(color: AK.error)),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AK.error),
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
            color: AppColors.primary,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
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
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
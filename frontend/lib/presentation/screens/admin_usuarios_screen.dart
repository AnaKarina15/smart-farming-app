import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/usuario_admin.dart';
import '../../data/providers/admin_provider.dart';
import '../widgets/admin_widgets.dart';
import '../widgets/custom_app_bar.dart';
import 'admin_detalle_usuario_screen.dart';
import 'admin_crear_usuario_screen.dart';
import 'admin_editar_usuario_screen.dart';

class AdminUsuariosScreen extends StatefulWidget {
  const AdminUsuariosScreen({super.key});

  @override
  State<AdminUsuariosScreen> createState() => _AdminUsuariosScreenState();
}

class _AdminUsuariosScreenState extends State<AdminUsuariosScreen> {
  final _searchController = TextEditingController();
  bool _mostrarFiltros = true;

  final Set<String> _rolesSeleccionados = {
    'pequeno_productor',
    'trabajador',
    'gestor',
    'administrador'
  };
  final Set<bool> _estadosSeleccionados = {true, false};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _actualizarFiltros();
      context.read<AdminProvider>().cargarUsuarios();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _actualizarFiltros() {
    final prov = context.read<AdminProvider>();
    prov.setFiltroRoles(Set.from(_rolesSeleccionados));
    prov.setFiltroEstados(Set.from(_estadosSeleccionados));
  }

  void _onRolTap(String? rol) {
    setState(() {
      const allRoles = [
        'pequeno_productor',
        'trabajador',
        'gestor',
        'administrador'
      ];
      if (rol == null) {
        // Tapped "Todos"
        if (_rolesSeleccionados.length == allRoles.length) {
          // Keep at least one active to avoid empty lists!
          _rolesSeleccionados.clear();
          _rolesSeleccionados.add('pequeno_productor');
        } else {
          // "Al seleccionar 'Todos', se marcan todas las categorías en verde."
          _rolesSeleccionados.addAll(allRoles);
        }
      } else {
        // Tapped specific role
        if (_rolesSeleccionados.contains(rol)) {
          // Only remove if we have more than one active category
          if (_rolesSeleccionados.length > 1) {
            _rolesSeleccionados.remove(rol);
          }
        } else {
          _rolesSeleccionados.add(rol);
        }
      }
      _actualizarFiltros();
    });
  }

  void _onEstadoTap(bool estado) {
    setState(() {
      if (_estadosSeleccionados.contains(estado)) {
        // Only remove if we have more than one active category
        if (_estadosSeleccionados.length > 1) {
          _estadosSeleccionados.remove(estado);
        }
      } else {
        _estadosSeleccionados.add(estado);
      }
      _actualizarFiltros();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AdminProvider>();

    // Si todos los filtros están en su estado activo por defecto
    final bool todosActivos = _rolesSeleccionados.length == 4 &&
        _estadosSeleccionados.length == 2 &&
        !prov.verEliminados;

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
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AK.text,
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
                // Búsqueda con botón de filtros
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) =>
                            context.read<AdminProvider>().setBusqueda(v),
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre o email...',
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
                            borderSide: BorderSide(
                                color: AppColors.primary, width: 1.5),
                          ),
                          filled: true,
                          fillColor: AK.bg,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _mostrarFiltros = !_mostrarFiltros;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: todosActivos
                              ? Colors.white
                              : AppColors.secondaryContainer,
                          border: Border.all(color: AK.border),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.tune,
                          color: todosActivos
                              ? AK.subtext
                              : AppColors.onSecondaryContainer,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  sizeCurve: Curves.easeInOut,
                  firstCurve: Curves.easeInOut,
                  secondCurve: Curves.easeInOut,
                  firstChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),

                      // Chips de rol
                      const Text('Rol',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AK.text)),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ChipFiltro(
                              label: 'Todos',
                              seleccionado: _rolesSeleccionados.length == 4,
                              onTap: () => _onRolTap(null),
                            ),
                            const SizedBox(width: 6),
                            ChipFiltro(
                              label: 'Productores',
                              seleccionado: _rolesSeleccionados
                                  .contains('pequeno_productor'),
                              onTap: () => _onRolTap('pequeno_productor'),
                            ),
                            const SizedBox(width: 6),
                            ChipFiltro(
                              label: 'Trabajadores',
                              seleccionado:
                                  _rolesSeleccionados.contains('trabajador'),
                              onTap: () => _onRolTap('trabajador'),
                            ),
                            const SizedBox(width: 6),
                            ChipFiltro(
                              label: 'Gestores',
                              seleccionado:
                                  _rolesSeleccionados.contains('gestor'),
                              onTap: () => _onRolTap('gestor'),
                            ),
                            const SizedBox(width: 6),
                            ChipFiltro(
                              label: 'Admins',
                              seleccionado:
                                  _rolesSeleccionados.contains('administrador'),
                              onTap: () => _onRolTap('administrador'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Chips de estado
                      const Text('Estado',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AK.text)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ChipFiltro(
                            label: 'Activo',
                            seleccionado: _estadosSeleccionados.contains(true),
                            onTap: () => _onEstadoTap(true),
                          ),
                          const SizedBox(width: 6),
                          ChipFiltro(
                            label: 'Inactivo',
                            seleccionado: _estadosSeleccionados.contains(false),
                            onTap: () => _onEstadoTap(false),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Toggle eliminados
                      Consumer<AdminProvider>(
                        builder: (_, prov, __) => Row(
                          children: [
                            const Text('Ver eliminados',
                                style: TextStyle(fontSize: 13, color: AK.text)),
                            const Spacer(),
                            Switch(
                              value: prov.verEliminados,
                              onChanged: prov.setVerEliminados,
                              activeThumbColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  secondChild:
                      const SizedBox(width: double.infinity, height: 0),
                  crossFadeState: _mostrarFiltros
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
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
                if (prov.error != null && prov.usuarios.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Error: ${prov.error}',
                        style: const TextStyle(color: AK.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
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
                  itemCount:
                      prov.usuarios.length + (prov.hayMasPaginas ? 1 : 0),
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
}

// ─────────────────────────────────────────────────────────────────────────────

class _TarjetaUsuario extends StatelessWidget {
  final UsuarioAdmin usuario;
  final bool estatica;

  const _TarjetaUsuario({
    required this.usuario,
    this.estatica = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
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
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AK.text,
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
              PuntoEstado(
                  activo: usuario.activo, eliminado: usuario.estaEliminado),
              const Spacer(),
              if (estatica) ...[
                const Icon(Icons.edit_outlined, size: 20, color: AK.subtext),
                const SizedBox(width: 12),
                const Icon(Icons.more_vert, size: 20, color: AK.subtext),
              ] else ...[
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AdminEditarUsuarioScreen(usuarioId: usuario.id),
                      ),
                    );
                    if (!context.mounted) return;
                    context.read<AdminProvider>().cargarUsuarios();
                  },
                  child: const Icon(Icons.edit_outlined,
                      size: 20, color: AK.subtext),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _mostrarMenuDestacado(context),
                  child:
                      const Icon(Icons.more_vert, size: 20, color: AK.subtext),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    if (estatica) return cardContent;

    return GestureDetector(
      onTap: () => _irADetalle(context),
      child: cardContent,
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

  void _mostrarMenuDestacado(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar menú',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (ctx, anim1, anim2) {
        return Stack(
          children: [
            // Tarjeta clonada encima de la barrera oscura
            Positioned(
              left: position.dx,
              top: position.dy,
              width: size.width,
              child: Material(
                color: Colors.transparent,
                child: _TarjetaUsuario(usuario: usuario, estatica: true),
              ),
            ),

            // Opciones del menú flotante alineadas debajo de la tarjeta
            Positioned(
              left: position.dx + size.width - 170,
              top: position.dy + size.height + 6,
              width: 160,
              child: FadeTransition(
                opacity: anim1,
                child: Material(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AK.border),
                  ),
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(Icons.visibility_outlined,
                              color: AppColors.primary, size: 18),
                          title: const Text('Ver detalle',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AK.text)),
                          dense: true,
                          onTap: () {
                            Navigator.pop(ctx);
                            _irADetalle(context);
                          },
                        ),
                        const Divider(height: 1, color: AK.border),
                        if (usuario.estaEliminado)
                          ListTile(
                            leading: const Icon(Icons.restore,
                                color: AK.accent, size: 18),
                            title: const Text('Restaurar',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AK.text)),
                            dense: true,
                            onTap: () {
                              Navigator.pop(ctx);
                              context
                                  .read<AdminProvider>()
                                  .restaurarUsuario(usuario.id);
                            },
                          )
                        else
                          ListTile(
                            leading: const Icon(Icons.delete_outline,
                                color: AK.error, size: 18),
                            title: const Text('Eliminar',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AK.error)),
                            dense: true,
                            onTap: () {
                              Navigator.pop(ctx);
                              _confirmarEliminar(
                                  context, context.read<AdminProvider>());
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AK.error),
            onPressed: () {
              Navigator.pop(context);
              provider.eliminarUsuario(usuario.id);
            },
            child:
                const Text('Eliminar', style: TextStyle(color: Colors.white)),
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
            onPressed:
                provider.paginaActual > 0 ? provider.paginaAnterior : null,
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
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700),
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

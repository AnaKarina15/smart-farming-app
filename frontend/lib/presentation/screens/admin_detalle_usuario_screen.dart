import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/providers/admin_provider.dart';
import '../widgets/admin_widgets.dart';
import 'admin_editar_usuario_screen.dart';

class AdminDetalleUsuarioScreen extends StatefulWidget {
  final String usuarioId;

  const AdminDetalleUsuarioScreen({super.key, required this.usuarioId});

  @override
  State<AdminDetalleUsuarioScreen> createState() => _AdminDetalleUsuarioScreenState();
}

class _AdminDetalleUsuarioScreenState extends State<AdminDetalleUsuarioScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().cargarUsuario(widget.usuarioId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      appBar: AppBar(
        backgroundColor: AdminColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AdminColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            // Logo
            Image.asset('assets/images/logo.png', height: 24, errorBuilder: (_, __, ___) =>
              const Icon(Icons.eco, color: AdminColors.primary, size: 24)),
            const SizedBox(width: 6),
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
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          if (provider.cargando && provider.usuarioDetalle == null) {
            return const Center(
              child: CircularProgressIndicator(color: AdminColors.primary),
            );
          }
          final u = provider.usuarioDetalle;
          if (u == null) {
            return const Center(child: Text('Usuario no encontrado.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Encabezado ─────────────────────────────────────────────
                const Text(
                  'Detalle de Usuario',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AdminColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),

                // ─── Avatar + nombre ─────────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      AvatarIniciales(
                        iniciales: u.iniciales,
                        role: u.role,
                        radio: 40,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        u.nombreCompleto,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AdminColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AdminColors.background,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AdminColors.border),
                        ),
                        child: Text(
                          u.roleHumanizado,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AdminColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ─── Información Personal ─────────────────────────────────────
                _Seccion(
                  icono: Icons.badge_outlined,
                  titulo: 'Información Personal',
                  children: [
                    _FilaInfo(label: 'EMAIL', valor: u.email),
                    const Divider(color: AdminColors.border, height: 1),
                    _FilaInfo(label: 'TELÉFONO', valor: u.telefono ?? 'No registrado'),
                    const Divider(color: AdminColors.border, height: 1),
                    _FilaInfo(label: 'ROL', valor: u.roleHumanizado),
                  ],
                ),

                const SizedBox(height: 14),

                // ─── Estado de cuenta ──────────────────────────────────────────
                _Seccion(
                  icono: Icons.bar_chart_outlined,
                  titulo: 'Estado de Cuenta',
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'ESTADO',
                              style: TextStyle(
                                fontSize: 11,
                                color: AdminColors.textSecondary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          PuntoEstado(activo: u.activo, eliminado: u.estaEliminado),
                        ],
                      ),
                    ),
                    const Divider(color: AdminColors.border, height: 1),
                    _FilaInfo(
                      label: 'ÚLTIMO ACCESO',
                      valor: u.ultimoAcceso != null
                          ? _formatearFecha(u.ultimoAcceso!)
                          : 'Nunca',
                    ),
                    if (u.mustChangePassword) ...[
                      const Divider(color: AdminColors.border, height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'CAMBIO DE CLAVE',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AdminColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: AdminColors.warning,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Requerido',
                              style: TextStyle(
                                color: AdminColors.warning,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.info_outline,
                              size: 16,
                              color: AdminColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 24),

                // ─── Acciones de gestión ──────────────────────────────────────
                const Text(
                  'Acciones de Gestión',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AdminColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Editar
                _BotonAccion(
                  icono: Icons.edit_outlined,
                  label: 'Editar Usuario',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminEditarUsuarioScreen(usuarioId: u.id),
                    ),
                  ).then((_) => context.read<AdminProvider>().cargarUsuario(u.id)),
                ),
                const SizedBox(height: 10),

                // Resetear contraseña
                _BotonAccion(
                  icono: Icons.lock_reset,
                  label: 'Resetear Contraseña',
                  onTap: () => _mostrarModalResetPassword(context, provider, u.id),
                ),
                const SizedBox(height: 10),

                // Eliminar / Restaurar
                if (u.estaEliminado)
                  _BotonAccion(
                    icono: Icons.restore,
                    label: 'Restaurar Usuario',
                    color: AdminColors.accent,
                    textColor: Colors.white,
                    onTap: () async {
                      final ok = await provider.restaurarUsuario(u.id);
                      if (ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Usuario restaurado correctamente.')),
                        );
                        Navigator.pop(context);
                      }
                    },
                  )
                else
                  _BotonAccion(
                    icono: Icons.delete_outline,
                    label: 'Eliminar Usuario',
                    color: AdminColors.error,
                    textColor: Colors.white,
                    onTap: () => _confirmarEliminar(context, provider, u.id, u.nombreCompleto),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _mostrarModalResetPassword(BuildContext context, AdminProvider provider, String userId) {
    final ctrl = TextEditingController();
    bool obscure = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Resetear Contraseña',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'El usuario deberá cambiarla en su próximo ingreso.',
                style: TextStyle(color: AdminColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              AdminTextField(
                controller: ctrl,
                label: 'Nueva contraseña temporal',
                obscureText: obscure,
                suffixIcon: IconButton(
                  icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setModal(() => obscure = !obscure),
                ),
              ),
              const SizedBox(height: 8),
              // Generar aleatoria
              TextButton.icon(
                onPressed: () {
                  final auto = _generarPassword();
                  ctrl.text = auto;
                  setModal(() => obscure = false);
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Generar contraseña automática'),
                style: TextButton.styleFrom(foregroundColor: AdminColors.primary),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (ctrl.text.trim().isEmpty) return;
                    Navigator.pop(ctx);
                    final ok = await provider.resetearPassword(userId, ctrl.text.trim());
                    if (ok && context.mounted) {
                      _mostrarPasswordCopiada(context, ctrl.text.trim());
                    }
                  },
                  child: const Text(
                    'Aplicar Reset',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarPasswordCopiada(BuildContext context, String password) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Contraseña reseteada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Comunica esta contraseña al usuario:'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AdminColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AdminColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      password,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: AdminColors.primary),
                    onPressed: () => Clipboard.setData(ClipboardData(text: password)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(
      BuildContext context, AdminProvider provider, String id, String nombre) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text(
          '¿Eliminar a $nombre? Su información se conservará pero ya no podrá acceder.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.error),
            onPressed: () async {
              Navigator.pop(context);
              final ok = await provider.eliminarUsuario(id);
              if (ok && context.mounted) Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  String _generarPassword() {
    const chars = 'ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789!@#\$';
    final rand = DateTime.now().microsecondsSinceEpoch;
    return List.generate(10, (i) => chars[(rand * (i + 7)) % chars.length]).join();
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Seccion extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final List<Widget> children;

  const _Seccion({
    required this.icono,
    required this.titulo,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(icono, size: 20, color: AdminColors.textPrimary),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AdminColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AdminColors.border, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _FilaInfo extends StatelessWidget {
  final String label;
  final String valor;

  const _FilaInfo({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AdminColors.textSecondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 14,
                color: AdminColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BotonAccion extends StatelessWidget {
  final IconData icono;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;

  const _BotonAccion({
    required this.icono,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
    this.textColor = AdminColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icono, color: textColor, size: 18),
        label: Text(
          label,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          side: BorderSide(
            color: color == Colors.white ? AdminColors.border : Colors.transparent,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onTap,
      ),
    );
  }
}
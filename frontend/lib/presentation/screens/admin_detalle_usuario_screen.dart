import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers/admin_provider.dart';
import '../widgets/admin_widgets.dart';
import 'admin_editar_usuario_screen.dart';

class AdminDetalleUsuarioScreen extends StatefulWidget {
  final String usuarioId;
  const AdminDetalleUsuarioScreen({super.key, required this.usuarioId});

  @override
  State<AdminDetalleUsuarioScreen> createState() =>
      _AdminDetalleUsuarioScreenState();
}

class _AdminDetalleUsuarioScreenState
    extends State<AdminDetalleUsuarioScreen> {
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
      backgroundColor: AK.bg,
      appBar: AppBar(
        backgroundColor: AK.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AK.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'AgroField',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          if (provider.cargando && provider.usuarioDetalle == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
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
                // Título
                const Text(
                  'Detalle de Usuario',
                  style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w800, color: AK.text,
                  ),
                ),
                const SizedBox(height: 20),

                // ─── Avatar + nombre ────────────────────────────────────────
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
                          fontSize: 20, fontWeight: FontWeight.w800, color: AK.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AK.bg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AK.border),
                        ),
                        child: Text(
                          u.roleHumanizado,
                          style: const TextStyle(
                              fontSize: 13, color: AK.subtext),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ─── Información Personal ───────────────────────────────────
                SeccionCard(
                  icono: Icons.badge_outlined,
                  titulo: 'Información Personal',
                  children: [
                    FilaInfo(label: 'EMAIL',    valor: u.email),
                    const Divider(color: AK.border, height: 1),
                    FilaInfo(label: 'TELÉFONO', valor: u.telefono ?? 'No registrado'),
                    const Divider(color: AK.border, height: 1),
                    FilaInfo(label: 'ROL',      valor: u.roleHumanizado),
                  ],
                ),

                const SizedBox(height: 14),

                // ─── Estado de Cuenta ───────────────────────────────────────
                SeccionCard(
                  icono: Icons.bar_chart_outlined,
                  titulo: 'Estado de Cuenta',
                  children: [
                    // Estado activo
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'ESTADO',
                              style: TextStyle(
                                fontSize: 11, color: AK.subtext,
                                fontWeight: FontWeight.w700, letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          PuntoEstado(
                              activo: u.activo,
                              eliminado: u.estaEliminado),
                        ],
                      ),
                    ),
                    const Divider(color: AK.border, height: 1),

                    // Último acceso
                    FilaInfo(
                      label: 'ÚLTIMO ACCESO',
                      valor: u.ultimoAcceso != null
                          ? _formatearFecha(u.ultimoAcceso!)
                          : 'Nunca',
                    ),

                    // mustChangePassword
                    if (u.mustChangePassword) ...[
                      const Divider(color: AK.border, height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: const [
                            Expanded(
                              child: Text(
                                'CAMBIO DE CLAVE',
                                style: TextStyle(
                                  fontSize: 11, color: AK.subtext,
                                  fontWeight: FontWeight.w700, letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            Icon(Icons.warning_amber_rounded,
                                color: AK.warning, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Requerido',
                              style: TextStyle(
                                color: AK.warning,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.info_outline, size: 16, color: AK.subtext),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 24),

                // ─── Acciones ───────────────────────────────────────────────
                const Text(
                  'Acciones de Gestión',
                  style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: AK.text,
                  ),
                ),
                const SizedBox(height: 12),

                BotonAccion(
                  icono: Icons.edit_outlined,
                  label: 'Editar Usuario',
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AdminEditarUsuarioScreen(usuarioId: u.id),
                      ),
                    );
                    if (!context.mounted) return;
                    context.read<AdminProvider>().cargarUsuario(u.id);
                  },
                ),
                const SizedBox(height: 10),

                BotonAccion(
                  icono: Icons.lock_reset,
                  label: 'Resetear Contraseña',
                  onTap: () =>
                      _mostrarModalReset(context, provider, u.id),
                ),
                const SizedBox(height: 10),

                if (u.estaEliminado)
                  BotonAccion(
                    icono: Icons.restore,
                    label: 'Restaurar Usuario',
                    color: AK.accent,
                    textColor: Colors.white,
                    onTap: () async {
                      final ok =
                          await provider.restaurarUsuario(u.id);
                      if (ok && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Usuario restaurado correctamente.')),
                        );
                        Navigator.pop(context);
                      }
                    },
                  )
                else
                  BotonAccion(
                    icono: Icons.delete_outline,
                    label: 'Eliminar Usuario',
                    color: AK.error,
                    textColor: Colors.white,
                    onTap: () => _confirmarEliminar(
                        context, provider, u.id, u.nombreCompleto),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Modales ────────────────────────────────────────────────────────────────

  void _mostrarModalReset(
      BuildContext context, AdminProvider provider, String userId) {
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
              24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
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
                style: TextStyle(color: AK.subtext, fontSize: 13),
              ),
              const SizedBox(height: 16),
              AdminTextField(
                controller: ctrl,
                label: 'Nueva contraseña temporal',
                obscureText: obscure,
                suffixIcon: IconButton(
                  icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () =>
                      setModal(() => obscure = !obscure),
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  ctrl.text = _generarPassword();
                  setModal(() => obscure = false);
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Generar automáticamente'),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary),
              ),
              const SizedBox(height: 16),
              BotonGuardar(
                label: 'Aplicar Reset',
                cargando: false,
                onPressed: () async {
                  if (ctrl.text.trim().isEmpty) return;
                  final pass = ctrl.text.trim();
                  Navigator.pop(ctx);
                  final ok =
                      await provider.resetearPassword(userId, pass);
                  if (ok && context.mounted) {
                    _mostrarPasswordCopiada(context, pass);
                  }
                },
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
                color: AK.bg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AK.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      password,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: 1.2),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, color: AppColors.primary),
                    onPressed: () =>
                        Clipboard.setData(ClipboardData(text: password)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, AdminProvider provider,
      String id, String nombre) {
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
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AK.error),
            onPressed: () async {
              Navigator.pop(context);
              final ok = await provider.eliminarUsuario(id);
              if (ok && context.mounted) Navigator.pop(context);
            },
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  String _formatearFecha(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  String _generarPassword() {
    const chars =
        'ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789!@#\$';
    final seed = DateTime.now().microsecondsSinceEpoch;
    return List.generate(
        10, (i) => chars[(seed * (i + 7)) % chars.length]).join();
  }
}
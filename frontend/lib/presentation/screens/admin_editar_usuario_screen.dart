import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers/admin_provider.dart';
import '../widgets/admin_widgets.dart';

class AdminEditarUsuarioScreen extends StatefulWidget {
  final String usuarioId;
  const AdminEditarUsuarioScreen({super.key, required this.usuarioId});

  @override
  State<AdminEditarUsuarioScreen> createState() =>
      _AdminEditarUsuarioScreenState();
}

class _AdminEditarUsuarioScreenState
    extends State<AdminEditarUsuarioScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _nombreCtrl   = TextEditingController();
  final _telefonoCtrl = TextEditingController();

  String? _rolSeleccionado;
  bool    _activo         = true;
  bool    _inicializado   = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<AdminProvider>();
      // Reutilizar detalle ya cargado o pedir al backend
      if (provider.usuarioDetalle?.id != widget.usuarioId) {
        await provider.cargarUsuario(widget.usuarioId);
      }
      final u = provider.usuarioDetalle;
      if (u != null && mounted) {
        setState(() {
          _nombreCtrl.text   = u.nombreCompleto;
          _telefonoCtrl.text = u.telefono ?? '';
          _rolSeleccionado   = u.role;
          _activo            = u.activo;
          _inicializado      = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
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
            color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 18,
          ),
        ),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          if (!_inicializado) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Editar Usuario',
                    style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w800, color: AK.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Modifica los detalles del usuario y gestiona sus permisos de acceso.',
                    style: TextStyle(fontSize: 13, color: AK.subtext),
                  ),

                  const SizedBox(height: 28),

                  // Nombre
                  AdminTextField(
                    controller: _nombreCtrl,
                    label: 'Nombre Completo',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Ingresa el nombre'
                            : null,
                  ),

                  const SizedBox(height: 16),

                  // Teléfono
                  AdminTextField(
                    controller: _telefonoCtrl,
                    label: 'Teléfono',
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 16),

                  // Rol
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SELECCIONAR ROL',
                        style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700,
                          color: AK.subtext, letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownRol(
                        valor: _rolSeleccionado,
                        onChanged: (v) =>
                            setState(() => _rolSeleccionado = v),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Estado de cuenta (toggle)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AK.border),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Estado de Cuenta',
                              style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600,
                                color: AK.text,
                              ),
                            ),
                            Text(
                              _activo ? 'ACTIVO' : 'INACTIVO',
                              style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700,
                                color: _activo ? AK.accent : AK.inactive,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Switch(
                          value: _activo,
                          onChanged: (v) => setState(() => _activo = v),
                          activeThumbColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  if (provider.error != null)
                    ErrorBanner(mensaje: provider.error!),

                  BotonGuardar(
                    cargando: provider.cargando,
                    onPressed: _guardar,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AdminProvider>();
    final ok = await provider.editarUsuario(
      widget.usuarioId,
      nombreCompleto: _nombreCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim().isEmpty
          ? null
          : _telefonoCtrl.text.trim(),
      role:   _rolSeleccionado,
      activo: _activo,
    );

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Usuario actualizado correctamente.'),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.pop(context);
    }
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/admin_provider.dart';
import '../widgets/admin_widgets.dart';

class AdminEditarUsuarioScreen extends StatefulWidget {
  final String usuarioId;

  const AdminEditarUsuarioScreen({super.key, required this.usuarioId});

  @override
  State<AdminEditarUsuarioScreen> createState() => _AdminEditarUsuarioScreenState();
}

class _AdminEditarUsuarioScreenState extends State<AdminEditarUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();

  String? _rolSeleccionado;
  bool _activo = true;
  bool _inicializado = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<AdminProvider>();
      // Si no tenemos detalle cargado, lo cargamos
      if (provider.usuarioDetalle?.id != widget.usuarioId) {
        await provider.cargarUsuario(widget.usuarioId);
      }
      final u = provider.usuarioDetalle;
      if (u != null && mounted) {
        setState(() {
          _nombreCtrl.text = u.nombreCompleto;
          _telefonoCtrl.text = u.telefono ?? '';
          _rolSeleccionado = u.role;
          _activo = u.activo;
          _inicializado = true;
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
            CircleAvatar(
              radius: 16,
              backgroundColor: AdminColors.primary.withOpacity(0.1),
              child: const Icon(Icons.person, color: AdminColors.primary, size: 18),
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
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          if (!_inicializado || (provider.cargando && !_inicializado)) {
            return const Center(
              child: CircularProgressIndicator(color: AdminColors.primary),
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
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Modifica los detalles del usuario y gestiona sus permisos de acceso.',
                    style: TextStyle(fontSize: 13, color: AdminColors.textSecondary),
                  ),

                  const SizedBox(height: 28),

                  // Nombre
                  AdminTextField(
                    controller: _nombreCtrl,
                    label: 'Nombre Completo',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Ingresa el nombre' : null,
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
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AdminColors.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownRol(
                        valor: _rolSeleccionado,
                        onChanged: (v) => setState(() => _rolSeleccionado = v),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Estado activo
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AdminColors.border),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Estado de Cuenta',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AdminColors.textPrimary,
                              ),
                            ),
                            Text(
                              _activo ? 'ACTIVO' : 'INACTIVO',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _activo ? AdminColors.accent : AdminColors.inactive,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Switch(
                          value: _activo,
                          onChanged: (v) => setState(() => _activo = v),
                          activeColor: AdminColors.primary,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Error
                  if (provider.error != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AdminColors.errorLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AdminColors.error.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AdminColors.error, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.error!,
                              style: const TextStyle(
                                  color: AdminColors.error, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Botón guardar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AdminColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: provider.cargando ? null : _guardar,
                      child: provider.cargando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Guardar Cambios',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                    ),
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
      telefono: _telefonoCtrl.text.trim().isEmpty ? null : _telefonoCtrl.text.trim(),
      role: _rolSeleccionado,
      activo: _activo,
    );

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario actualizado correctamente.'),
          backgroundColor: AdminColors.primary,
        ),
      );
      Navigator.pop(context);
    }
  }
}
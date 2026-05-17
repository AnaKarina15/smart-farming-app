import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers/admin_provider.dart';
import '../widgets/admin_widgets.dart';

class AdminCrearUsuarioScreen extends StatefulWidget {
  const AdminCrearUsuarioScreen({super.key});

  @override
  State<AdminCrearUsuarioScreen> createState() =>
      _AdminCrearUsuarioScreenState();
}

class _AdminCrearUsuarioScreenState
    extends State<AdminCrearUsuarioScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _nombreCtrl    = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _telefonoCtrl  = TextEditingController();
  final _passwordCtrl  = TextEditingController();

  String? _rolSeleccionado;
  bool    _obscurePass = true;
  // Para disparar la validación del campo rol manualmente
  bool    _intentoGuardar = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _telefonoCtrl.dispose();
    _passwordCtrl.dispose();
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
        builder: (context, provider, _) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Crear Usuario',
                  style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w800, color: AK.text,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Complete los datos para dar de alta un nuevo perfil en el sistema.',
                  style: TextStyle(fontSize: 13, color: AK.subtext),
                ),

                const SizedBox(height: 24),

                AdminTextField(
                  controller: _nombreCtrl,
                  label: 'Nombre Completo',
                  hint: 'Ej. Juan Pérez',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Ingresa el nombre completo' : null,
                ),

                const SizedBox(height: 16),

                AdminTextField(
                  controller: _emailCtrl,
                  label: 'Correo Electrónico',
                  hint: 'juan.perez@agrofield.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Ingresa el correo';
                    if (!v.contains('@')) return 'Correo inválido';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                AdminTextField(
                  controller: _telefonoCtrl,
                  label: 'Teléfono (Opcional)',
                  hint: '+57 300 123 4567',
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 16),

                // ─── Rol ─────────────────────────────────────────────────
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
                      onChanged: (v) => setState(() {
                        _rolSeleccionado = v;
                        _intentoGuardar = false;
                      }),
                    ),
                    if (_intentoGuardar && _rolSeleccionado == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 6, left: 12),
                        child: Text(
                          'Selecciona un rol',
                          style: TextStyle(color: AK.error, fontSize: 12),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                AdminTextField(
                  controller: _passwordCtrl,
                  label: 'Contraseña Temporal',
                  obscureText: _obscurePass,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePass ? Icons.visibility_off : Icons.visibility,
                      color: AK.subtext,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePass = !_obscurePass),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'Ingresa una contraseña temporal';
                    if (v.length < 8) return 'Mínimo 8 caracteres';
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                if (provider.error != null)
                  ErrorBanner(
                    mensaje: provider.error!,
                    onDismiss: provider.limpiarError,
                  ),

                BotonGuardar(
                  label: 'CREAR USUARIO',
                  cargando: provider.cargando,
                  onPressed: _crear,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _crear() async {
    setState(() => _intentoGuardar = true);
    if (!_formKey.currentState!.validate()) return;
    if (_rolSeleccionado == null) return;

    final provider = context.read<AdminProvider>();
    final ok = await provider.crearUsuario(
      nombreCompleto: _nombreCtrl.text.trim(),
      email:          _emailCtrl.text.trim(),
      password:       _passwordCtrl.text,
      role:           _rolSeleccionado!,
      telefono:       _telefonoCtrl.text.trim().isEmpty
          ? null
          : _telefonoCtrl.text.trim(),
    );

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Usuario creado correctamente.'),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.pop(context);
    }
  }
}
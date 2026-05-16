import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/admin_provider.dart';
import '../widgets/admin_widgets.dart';

class AdminCrearUsuarioScreen extends StatefulWidget {
  const AdminCrearUsuarioScreen({super.key});

  @override
  State<AdminCrearUsuarioScreen> createState() => _AdminCrearUsuarioScreenState();
}

class _AdminCrearUsuarioScreenState extends State<AdminCrearUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  String? _rolSeleccionado;
  bool _obscurePassword = true;

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
            const Icon(Icons.eco, color: AdminColors.primary, size: 22),
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
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Crear Usuario',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AdminColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Complete los datos para dar de alta un nuevo perfil en el sistema.',
                    style: TextStyle(fontSize: 13, color: AdminColors.textSecondary),
                  ),

                  const SizedBox(height: 24),

                  // Nombre
                  AdminTextField(
                    controller: _nombreCtrl,
                    label: 'Nombre Completo',
                    hint: 'Ej. Juan Pérez',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Ingresa el nombre completo'
                        : null,
                  ),

                  const SizedBox(height: 16),

                  // Email
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

                  // Teléfono (opcional)
                  AdminTextField(
                    controller: _telefonoCtrl,
                    label: 'Teléfono (Opcional)',
                    hint: '+54 9 11 1234 5678',
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
                      if (_rolSeleccionado == null && _formKey.currentState != null)
                        const Padding(
                          padding: EdgeInsets.only(top: 6, left: 12),
                          child: Text(
                            'Selecciona un rol',
                            style: TextStyle(color: AdminColors.error, fontSize: 12),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Contraseña temporal
                  AdminTextField(
                    controller: _passwordCtrl,
                    label: 'Contraseña Temporal',
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AdminColors.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Ingresa una contraseña temporal';
                      if (v.length < 8) return 'Mínimo 8 caracteres';
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  // Error del provider
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
                          GestureDetector(
                            onTap: provider.limpiarError,
                            child: const Icon(Icons.close, size: 16, color: AdminColors.error),
                          ),
                        ],
                      ),
                    ),

                  // Botón crear
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
                      onPressed: provider.cargando ? null : _crear,
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
                              'CREAR USUARIO',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
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

  Future<void> _crear() async {
    if (!_formKey.currentState!.validate()) return;
    if (_rolSeleccionado == null) {
      setState(() {}); // fuerza rebuild para mostrar error de rol
      return;
    }

    final provider = context.read<AdminProvider>();
    final ok = await provider.crearUsuario(
      nombreCompleto: _nombreCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      role: _rolSeleccionado!,
      telefono: _telefonoCtrl.text.trim().isEmpty ? null : _telefonoCtrl.text.trim(),
    );

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario creado correctamente.'),
          backgroundColor: AdminColors.primary,
        ),
      );
      Navigator.pop(context);
    }
  }
}
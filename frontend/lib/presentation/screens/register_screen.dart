import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/providers/auth_provider.dart';
import '../widgets/rugged_button.dart';
import '../widgets/rugged_text_field.dart';
import 'login_screen.dart';
import 'registration_success_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailAuthError;
  String? _generalAuthError;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    setState(() {
      _emailAuthError = null;
      _generalAuthError = null;
    });

    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.register(
        nombreCompleto: _nameController.text.trim(),
        email: _emailController.text.trim(),
        telefono: _phoneController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RegistrationSuccessScreen()),
        );
      } else {
        setState(() {
          final errorStr = (authProvider.errorMessage ?? '').toLowerCase();

          if (errorStr.contains('conexi') ||
              errorStr.contains('servidor') ||
              errorStr.contains('internet')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Sin conexión al servidor. Verifica tu internet.',
                  style: AppText.bodyMd(color: AppColors.onError),
                ),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (errorStr.contains('correo') ||
              errorStr.contains('email') ||
              errorStr.contains('existe') ||
              errorStr.contains('recurso') ||
              errorStr.contains('uso') ||
              errorStr.contains('already') ||
              errorStr.contains('conflict') ||
              errorStr.contains('duplicado') ||
              errorStr.contains('registrado')) {
            _emailAuthError = 'Este correo ya está registrado.';
          } else {
            _generalAuthError = 'Error al crear cuenta. Verifica tus datos.';
          }
        });
        _formKey.currentState!.validate();
        authProvider.clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                  height:
                      24), // Ajustado para dar un buen margen superior sin la flecha
              Center(
                child: Text(
                  'Bienvenido a Agrofield',
                  style: AppText.h2(color: AppColors.onSurface),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Regístrate para empezar a gestionar tus cultivos',
                  style: AppText.bodyMd(color: AppColors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('NOMBRE COMPLETO', style: AppText.labelCaps()),
                    const SizedBox(height: 8),
                    RuggedTextField(
                      controller: _nameController,
                      hintText: 'Ej: Juan Pérez',
                      prefixIcon: Icons.person_outline,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Ingresa tu nombre' : null,
                    ),
                    const SizedBox(height: 20),
                    Text('CORREO ELECTRÓNICO', style: AppText.labelCaps()),
                    const SizedBox(height: 8),
                    RuggedTextField(
                      controller: _emailController,
                      hintText: 'tu@correo.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) {
                        if (_emailAuthError != null ||
                            _generalAuthError != null) {
                          setState(() {
                            _emailAuthError = null;
                            _generalAuthError = null;
                          });
                          _formKey.currentState!.validate();
                        }
                      },
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingresa tu correo';
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v)) {
                          return 'Formato de correo incorrecto';
                        }
                        if (_emailAuthError != null) return _emailAuthError;
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Text('TELÉFONO', style: AppText.labelCaps()),
                    const SizedBox(height: 8),
                    RuggedTextField(
                      controller: _phoneController,
                      hintText: '300 000 0000',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Ingresa tu teléfono'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    Text('CONTRASEÑA', style: AppText.labelCaps()),
                    const SizedBox(height: 8),
                    RuggedTextField(
                      controller: _passwordController,
                      hintText: 'Mínimo 8 caracteres',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.onSurfaceVariant,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      onChanged: (_) {
                        if (_emailAuthError != null ||
                            _generalAuthError != null) {
                          setState(() {
                            _emailAuthError = null;
                            _generalAuthError = null;
                          });
                          _formKey.currentState!.validate();
                        }
                      },
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Ingresa una contraseña';
                        }
                        if (v.length < 8) return 'Mínimo 8 caracteres';
                        if (_generalAuthError != null) return _generalAuthError;
                        return null;
                      },
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          // Aquí colocas la acción para abrir el link o una nueva pantalla
                          print("Abriendo términos y condiciones...");
                        },
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: AppText.bodyMd(
                                    color: AppColors.onSurfaceVariant)
                                .copyWith(fontSize: 12),
                            children: [
                              const TextSpan(
                                  text: 'Al registrarte aceptas los '),
                              TextSpan(
                                text: 'términos y condiciones.',
                                style: TextStyle(
                                  color: AppColors
                                      .primary, // Color diferente para el link
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration
                                      .underline, // Subrayado opcional
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                        : RuggedButton(
                            text: 'CREAR CUENTA',
                            onPressed: _handleRegister,
                          ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        ),
                        child: RichText(
                          text: TextSpan(
                            text: '¿Ya tienes cuenta? ',
                            style: AppText.bodyMd(
                              color: AppColors.onSurfaceVariant,
                            ),
                            children: [
                              TextSpan(
                                text: 'Inicia sesión',
                                style: AppText.bodyMd(
                                  color: AppColors.primary,
                                ).copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
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
  String? _phoneAuthError;
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
      _phoneAuthError = null;
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
          final rawMsg = authProvider.errorMessage ??
              'Error al crear cuenta. Verifica tus datos.';
          final errorStr = rawMsg.toLowerCase();

          if (errorStr.contains('conexi') || errorStr.contains('internet')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Sin conexión al servidor. Verifica tu internet.',
                  style: AppText.bodyMd(color: AppColors.onError),
                ),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (errorStr.contains('tardando') ||
              errorStr.contains('tiempo') ||
              errorStr.contains('timeout')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'El servidor está despertando. Espera unos segundos e intenta de nuevo.',
                  style: AppText.bodyMd(color: AppColors.onError),
                ),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (errorStr.contains('correo') ||
              errorStr.contains('email')) {
            _emailAuthError = rawMsg;
          } else if (errorStr.contains('teléfono') ||
              errorStr.contains('telefono')) {
            _phoneAuthError = rawMsg;
          } else {
            _generalAuthError = rawMsg;
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
              const SizedBox(height: 8),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.onSurface,
                  size: 28,
                ),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryContainer,
                  ),
                  child: const Icon(
                    Icons.eco,
                    color: AppColors.onPrimaryContainer,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Bienvenido a ',
                    style: AppText.h2(color: AppColors.onSurface),
                    children: [
                      TextSpan(
                        text: 'AGROFIELD',
                        style: AppText.h2(
                          color: AppColors.primary,
                        ).copyWith(
                            letterSpacing: 2.4, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'Regístrate para empezar a gestionar tus cultivos',
                  style: AppText.bodyMd(color: AppColors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
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
                      textCapitalization: TextCapitalization.words,
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
                      onChanged: (_) {
                        if (_phoneAuthError != null ||
                            _generalAuthError != null) {
                          setState(() {
                            _phoneAuthError = null;
                            _generalAuthError = null;
                          });
                          _formKey.currentState!.validate();
                        }
                      },
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Ingresa tu teléfono';
                        }
                        if (_phoneAuthError != null) return _phoneAuthError;
                        return null;
                      },
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
                    const SizedBox(height: 8),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          // Aquí colocas la acción para abrir el link o una nueva pantalla
                          debugPrint("Abriendo términos y condiciones...");
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
                    const SizedBox(height: 15),
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
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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

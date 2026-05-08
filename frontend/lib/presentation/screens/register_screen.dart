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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ?? 'Error desconocido',
              style: GoogleFonts.lexend(color: AppColors.onError),
            ),
            backgroundColor: AppColors.error,
          ),
        );
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
              const SizedBox(height: 16),
              Text('Crear cuenta', style: AppText.h2()),
              const SizedBox(height: 8),
              Text(
                'Regístrate para empezar a gestionar tus cultivos',
                style: AppText.bodyMd(color: AppColors.onSurfaceVariant),
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
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Ingresa tu correo' : null,
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
                      obscureText: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Ingresa una contraseña';
                        }
                        if (v.length < 8) return 'Mínimo 8 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
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

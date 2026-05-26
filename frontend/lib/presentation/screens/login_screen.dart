import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/lotes_provider.dart';
import '../widgets/rugged_button.dart';
import '../widgets/rugged_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'lotes_list_screen.dart';
import 'admin_panel_screen.dart';
import 'change_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailAuthError;
  String? _passwordAuthError;
  String? _generalAuthError;
  bool _obscurePassword = true;

  Future<Widget> _resolveProducerDestination(
      LotesProvider lotesProvider) async {
    final prefs = await SharedPreferences.getInstance();
    var hasLotes = prefs.getBool('has_lotes') ?? lotesProvider.hasLotes;

    try {
      await lotesProvider.init().timeout(const Duration(seconds: 8));
      hasLotes = lotesProvider.hasLotes;
      unawaited(prefs.setBool('has_lotes', hasLotes));
    } catch (_) {
      unawaited(prefs.setBool('has_lotes', hasLotes));
    }

    return hasLotes ? const HomeScreen() : const LotesListScreen();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() {
      _emailAuthError = null;
      _passwordAuthError = null;
      _generalAuthError = null;
    });

    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      if (success) {
        final user = authProvider.currentUser;

        // Sprint 1: Manejo de mustChangePassword
        if (user != null && user.mustChangePassword) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const ChangePasswordScreen(),
            ),
          );
          return;
        }

        if (user != null && user.role == 'administrador') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminPanelScreen(),
            ),
          );
        } else {
          final lotesProvider = context.read<LotesProvider>();
          final destination = await _resolveProducerDestination(lotesProvider);

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => destination),
          );
        }
      } else {
        setState(() {
          final rawError = authProvider.errorMessage?.trim();
          final errorStr = (rawError ?? '').toLowerCase();

          if (errorStr.contains('conexi') ||
              errorStr.contains('internet') ||
              errorStr.contains('tiempo') ||
              errorStr.contains('timeout')) {
            _generalAuthError =
                'No se pudo conectar con el servidor. Intenta de nuevo en unos segundos.';
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
              errorStr.contains('usuario') ||
              errorStr.contains('not found')) {
            _emailAuthError = 'Correo no registrado';
          } else if (errorStr.contains('contraseña') ||
              errorStr.contains('password') ||
              errorStr.contains('credencial') ||
              errorStr.contains('invalid') ||
              errorStr.contains('incorrect')) {
            _passwordAuthError = 'Contraseña incorrecta';
            _generalAuthError = 'Correo o contraseña incorrectos.';
          } else {
            _passwordAuthError = 'Correo o contraseña incorrectos';
            _generalAuthError = rawError == null || rawError.isEmpty
                ? _passwordAuthError
                : rawError;
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
              const SizedBox(height: 32),
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
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'AGROFIELD',
                  style: AppText.h2(
                    color: AppColors.primary,
                  ).copyWith(letterSpacing: 2.4, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Text(
                  'Iniciar sesión',
                  style: AppText.h2(color: AppColors.onSurface),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Ingresa con tu correo y contraseña',
                  style: AppText.bodyMd(color: AppColors.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CORREO ELECTRÓNICO', style: AppText.labelCaps()),
                    const SizedBox(height: 8),
                    RuggedTextField(
                      controller: _emailController,
                      hintText: 'tu@correo.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) {
                        if (_emailAuthError != null ||
                            _passwordAuthError != null ||
                            _generalAuthError != null) {
                          setState(() {
                            _emailAuthError = null;
                            _passwordAuthError = null;
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
                    Text('CONTRASEÑA', style: AppText.labelCaps()),
                    const SizedBox(height: 8),
                    RuggedTextField(
                      controller: _passwordController,
                      hintText: '••••••••',
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
                            _passwordAuthError != null ||
                            _generalAuthError != null) {
                          setState(() {
                            _emailAuthError = null;
                            _passwordAuthError = null;
                            _generalAuthError = null;
                          });
                          _formKey.currentState!.validate();
                        }
                      },
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Ingresa tu contraseña';
                        }
                        if (_passwordAuthError != null) {
                          return _passwordAuthError;
                        }
                        return null;
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: const Text('Recuperar contraseña'),
                              content: const Text(
                                'Para recuperar tu contraseña, contacta al administrador del sistema. Él podrá restablecer tu acceso.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: Text(
                                    'Entendido',
                                    style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: AppText.bodyMd(color: AppColors.primary)
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_generalAuthError != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.error),
                        ),
                        child: Text(
                          _generalAuthError!,
                          style: AppText.bodyMd(
                            color: AppColors.onErrorContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                        : RuggedButton(
                            text: 'INGRESAR',
                            onPressed: _handleLogin,
                            icon: Icons.login,
                          ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        ),
                        child: RichText(
                          text: TextSpan(
                            text: '¿No tienes cuenta? ',
                            style: AppText.bodyMd(
                              color: AppColors.onSurfaceVariant,
                            ),
                            children: [
                              TextSpan(
                                text: 'Regístrate',
                                style: AppText.bodyMd(
                                  color: AppColors.primary,
                                ).copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
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

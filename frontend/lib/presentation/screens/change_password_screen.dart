import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../data/providers/lotes_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../widgets/rugged_button.dart';
import '../widgets/rugged_text_field.dart';
import 'home_screen.dart';
import 'lotes_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pantalla de cambio de contraseña forzado.
///
/// Se muestra cuando el backend indica que el usuario debe cambiar
/// su contraseña antes de acceder al sistema (mustChangePassword = true).
class ChangePasswordScreen extends StatefulWidget {
  final bool requireCurrentPassword;

  const ChangePasswordScreen({
    super.key,
    this.requireCurrentPassword = false,
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.changePassword(
        currentPassword: widget.requireCurrentPassword
            ? _currentPasswordController.text
            : null,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      if (!mounted) return;
      if (!success) {
        final msg =
            authProvider.errorMessage ?? 'Error al cambiar la contraseña';
        setState(() {
          _errorMsg = msg;
          _isLoading = false;
        });
        authProvider.clearError();
        return;
      }

      if (widget.requireCurrentPassword) {
        Navigator.pop(context, true);
        return;
      }

      // Navegar según si ya existen lotes tras cambio exitoso.
      final lotesProvider = context.read<LotesProvider>();
      await lotesProvider.init().timeout(
            const Duration(seconds: 8),
            onTimeout: () {},
          );

      final prefs = await SharedPreferences.getInstance();
      final hasLotes = lotesProvider.hasLotes;
      await prefs.setBool('has_lotes', hasLotes);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              hasLotes ? const HomeScreen() : const LotesListScreen(),
        ),
      );
    } catch (_) {
      setState(() {
        _errorMsg = 'Error de conexión. Inténtalo de nuevo.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryContainer,
                  ),
                  child: const Icon(
                    Icons.lock_reset,
                    color: AppColors.onPrimaryContainer,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.requireCurrentPassword
                    ? 'Cambiar contraseña'
                    : 'Cambio de contraseña requerido',
                style: AppText.h2(color: AppColors.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.requireCurrentPassword
                    ? 'Ingresa tu contraseña actual y define una nueva.'
                    : 'Por seguridad, debes establecer una nueva contraseña antes de continuar.',
                style: AppText.bodyMd(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_errorMsg != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMsg!,
                          style: AppText.bodyMd(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.requireCurrentPassword) ...[
                      Text('CONTRASEÑA ACTUAL', style: AppText.labelCaps()),
                      const SizedBox(height: 8),
                      RuggedTextField(
                        controller: _currentPasswordController,
                        hintText: 'Tu contraseña actual',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscureCurrent,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureCurrent
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.onSurfaceVariant,
                          ),
                          onPressed: () => setState(
                            () => _obscureCurrent = !_obscureCurrent,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Ingresa tu contraseña actual';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                    Text('NUEVA CONTRASEÑA', style: AppText.labelCaps()),
                    const SizedBox(height: 8),
                    RuggedTextField(
                      controller: _newPasswordController,
                      hintText: 'Mínimo 8 caracteres',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscureNew,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNew
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.onSurfaceVariant,
                        ),
                        onPressed: () =>
                            setState(() => _obscureNew = !_obscureNew),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Ingresa la nueva contraseña';
                        }
                        if (v.length < 8) {
                          return 'Mínimo 8 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Text('CONFIRMAR CONTRASEÑA', style: AppText.labelCaps()),
                    const SizedBox(height: 8),
                    RuggedTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Repite la nueva contraseña',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscureConfirm,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.onSurfaceVariant,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Confirma tu nueva contraseña';
                        }
                        if (v != _newPasswordController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          )
                        : RuggedButton(
                            text: 'CAMBIAR CONTRASEÑA',
                            onPressed: _handleChangePassword,
                            icon: Icons.check_circle_outline,
                          ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          final authProvider = context.read<AuthProvider>();
                          authProvider.logout();
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        },
                        child: Text(
                          'Cerrar sesión',
                          style: AppText.bodyMd(
                            color: AppColors.onSurfaceVariant,
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

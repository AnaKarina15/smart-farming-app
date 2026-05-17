import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

// ─── Colores semánticos del panel admin ──────────────────────────────────────
// Se definen aquí como constantes locales para no duplicar AppColors.
// El verde primario (AppColors.primary) se reutiliza directamente.

const Color _kError    = Color(0xFFD32F2F);
const Color _kErrorBg  = Color(0xFFFFEBEE);
const Color _kWarning  = Color(0xFFFF8F00);
const Color _kAccent   = Color(0xFF4CAF50);
const Color _kInactive = Color(0xFF9E9E9E);
const Color _kBorder   = Color(0xFFE5E7EB);
const Color _kBg       = Color(0xFFF5F5F0);
const Color _kText     = Color(0xFF1A1A1A);
const Color _kSubtext  = Color(0xFF6B7280);

// Expuestos para que las pantallas los usen sin redefinir
class AK {
  AK._();
  static Color get primary   => AppColors.primary;
  static const Color error   = _kError;
  static const Color errorBg = _kErrorBg;
  static const Color warning = _kWarning;
  static const Color accent  = _kAccent;
  static const Color inactive = _kInactive;
  static const Color border  = _kBorder;
  static const Color bg      = _kBg;
  static const Color text    = _kText;
  static const Color subtext = _kSubtext;
}

// ─── Chip de rol ─────────────────────────────────────────────────────────────

class RolChip extends StatelessWidget {
  final String role;
  final bool small;
  const RolChip({super.key, required this.role, this.small = false});

  @override
  Widget build(BuildContext context) {
    final fontSize  = small ? 10.0 : 11.0;
    final padding   = small
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 4);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _colorRol(role),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        labelRol(role),
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  static Color _colorRol(String r) {
    switch (r) {
      case 'administrador':    return _kError;
      case 'gestor':           return AppColors.primary;
      case 'pequeno_productor': return const Color(0xFF1A7A52);
      case 'trabajador':       return _kInactive;
      default:                 return _kInactive;
    }
  }

  static String labelRol(String r) {
    switch (r) {
      case 'administrador':    return 'Admin';
      case 'pequeno_productor': return 'Productor';
      case 'trabajador':       return 'Trabajador';
      case 'gestor':           return 'Gestor';
      default:                 return r;
    }
  }
}

// ─── Avatar con iniciales ─────────────────────────────────────────────────────

class AvatarIniciales extends StatelessWidget {
  final String iniciales;
  final String role;
  final double radio;
  const AvatarIniciales({
    super.key,
    required this.iniciales,
    required this.role,
    this.radio = 24,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radio,
      backgroundColor: _fondo(role),
      child: Text(
        iniciales,
        style: TextStyle(
          color: _texto(role),
          fontWeight: FontWeight.bold,
          fontSize: radio * 0.6,
        ),
      ),
    );
  }

  static Color _fondo(String r) {
    switch (r) {
      case 'administrador':    return const Color(0xFFFFEBEE);
      case 'gestor':           return const Color(0xFFE8F5E9);
      case 'pequeno_productor': return const Color(0xFFE3F2FD);
      default:                 return const Color(0xFFF5F5F5);
    }
  }

  static Color _texto(String r) {
    switch (r) {
      case 'administrador':    return _kError;
      case 'gestor':           return AppColors.primary;
      case 'pequeno_productor': return const Color(0xFF1565C0);
      default:                 return _kInactive;
    }
  }
}

// ─── Punto de estado ──────────────────────────────────────────────────────────

class PuntoEstado extends StatelessWidget {
  final bool activo;
  final bool eliminado;
  const PuntoEstado({super.key, required this.activo, this.eliminado = false});

  @override
  Widget build(BuildContext context) {
    final color = eliminado ? _kError : activo ? _kAccent : _kInactive;
    final label = eliminado ? 'Eliminado' : activo ? 'Activo' : 'Inactivo';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ─── Dropdown de rol ──────────────────────────────────────────────────────────

class DropdownRol extends StatelessWidget {
  final String? valor;
  final ValueChanged<String?> onChanged;
  final bool incluirAdmin;
  const DropdownRol({
    super.key,
    required this.valor,
    required this.onChanged,
    this.incluirAdmin = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: valor,
      hint: const Text('Seleccione un rol...'),
      items: [
        const DropdownMenuItem(value: 'pequeno_productor', child: Text('Pequeño Productor')),
        const DropdownMenuItem(value: 'trabajador',        child: Text('Trabajador')),
        const DropdownMenuItem(value: 'gestor',            child: Text('Gestor')),
        if (incluirAdmin)
          const DropdownMenuItem(value: 'administrador',  child: Text('Administrador')),
      ],
      onChanged: onChanged,
      decoration: _inputDeco(),
    );
  }
}

// ─── Campo de texto admin ─────────────────────────────────────────────────────

class AdminTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int? maxLines;

  const AdminTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700,
            color: _kSubtext, letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 15, color: _kText),
          decoration: _inputDeco(hint: hint, suffixIcon: suffixIcon),
        ),
      ],
    );
  }
}

// ─── Bottom nav del panel admin ───────────────────────────────────────────────

class AdminBottomNav extends StatelessWidget {
  final int indiceActivo;
  final ValueChanged<int> onTap;
  const AdminBottomNav({super.key, required this.indiceActivo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: indiceActivo,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: _kSubtext,
      backgroundColor: Colors.white,
      elevation: 8,
      selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard),
          label: 'Panel',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people),
          label: 'Usuarios',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_outlined), activeIcon: Icon(Icons.grid_view),
          label: 'Lotes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}

// ─── Chip de filtro ───────────────────────────────────────────────────────────

class ChipFiltro extends StatelessWidget {
  final String label;
  final bool seleccionado;
  final VoidCallback onTap;
  const ChipFiltro({
    super.key,
    required this.label,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: seleccionado ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: seleccionado ? AppColors.primary : _kBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: seleccionado ? FontWeight.w700 : FontWeight.w400,
            color: seleccionado ? Colors.white : _kSubtext,
          ),
        ),
      ),
    );
  }
}

// ─── Botón de acción (en detalle usuario) ─────────────────────────────────────

class BotonAccion extends StatelessWidget {
  final IconData icono;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;
  const BotonAccion({
    super.key,
    required this.icono,
    required this.label,
    required this.onTap,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg   = color ?? Colors.white;
    final fg   = textColor ?? _kText;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icono, color: fg, size: 18),
        label: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          side: BorderSide(color: bg == Colors.white ? _kBorder : Colors.transparent),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onTap,
      ),
    );
  }
}

// ─── Sección con borde ────────────────────────────────────────────────────────

class SeccionCard extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final List<Widget> children;
  const SeccionCard({
    super.key,
    required this.icono,
    required this.titulo,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(icono, size: 20, color: _kText),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: _kText,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: _kBorder, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

// ─── Fila de info (label + valor) ────────────────────────────────────────────

class FilaInfo extends StatelessWidget {
  final String label;
  final String valor;
  const FilaInfo({super.key, required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11, color: _kSubtext,
                fontWeight: FontWeight.w700, letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(valor, style: const TextStyle(fontSize: 14, color: _kText)),
          ),
        ],
      ),
    );
  }
}

// ─── Banner de error inline ───────────────────────────────────────────────────

class ErrorBanner extends StatelessWidget {
  final String mensaje;
  final VoidCallback? onDismiss;
  const ErrorBanner({super.key, required this.mensaje, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kErrorBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kError.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: _kError, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(mensaje, style: const TextStyle(color: _kError, fontSize: 13)),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(Icons.close, size: 16, color: _kError),
            ),
        ],
      ),
    );
  }
}

// ─── Vista de error con reintento ────────────────────────────────────────────

class ErrorView extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintentar;
  const ErrorView({super.key, required this.mensaje, required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: _kError, size: 48),
            const SizedBox(height: 12),
            Text(mensaje,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _kSubtext)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onReintentar,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Botón de guardar con loading ─────────────────────────────────────────────

class BotonGuardar extends StatelessWidget {
  final String label;
  final bool cargando;
  final VoidCallback? onPressed;
  final Color? color;
  const BotonGuardar({
    super.key,
    this.label = 'Guardar Cambios',
    required this.cargando,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: cargando ? null : onPressed,
        child: cargando
            ? const SizedBox(
                height: 20, width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16,
                ),
              ),
      ),
    );
  }
}

// ─── Helper privado: InputDecoration compartida ───────────────────────────────

InputDecoration _inputDeco({String? hint, Widget? suffixIcon}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: _kInactive),
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _kBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _kBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _kError),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
import 'package:flutter/material.dart';

/// Paleta de colores del panel admin — se basa en AppColors del proyecto.
class AdminColors {
  AdminColors._();

  static const Color primary = Color(0xFF0F5238);
  static const Color primaryLight = Color(0xFF1A7A52);
  static const Color accent = Color(0xFF4CAF50);
  static const Color background = Color(0xFFF5F5F0);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFFF8F00);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color inactive = Color(0xFF9E9E9E);

  // Chips de rol
  static const Color chipGestor = Color(0xFF0F5238);
  static const Color chipProductor = Color(0xFF1A7A52);
  static const Color chipTrabajador = Color(0xFF9E9E9E);
  static const Color chipAdmin = Color(0xFFD32F2F);

  // Estados lotes
  static const Color estadoSaludable = Color(0xFF2E7D32);
  static const Color estadoSaludableBg = Color(0xFFE8F5E9);
  static const Color estadoAfectado = Color(0xFFD32F2F);
  static const Color estadoAfectadoBg = Color(0xFFFFEBEE);
  static const Color estadoCosechado = Color(0xFF795548);
  static const Color estadoCosechadoBg = Color(0xFFEFEBE9);
}

/// Chip de rol con color según el tipo
class RolChip extends StatelessWidget {
  final String role;
  final bool small;

  const RolChip({super.key, required this.role, this.small = false});

  @override
  Widget build(BuildContext context) {
    final color = _colorRol(role);
    final label = _labelRol(role);
    final fontSize = small ? 10.0 : 11.0;
    final padding = small
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 4);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Color _colorRol(String role) {
    switch (role) {
      case 'administrador':
        return AdminColors.chipAdmin;
      case 'gestor':
        return AdminColors.chipGestor;
      case 'pequeno_productor':
        return AdminColors.chipProductor;
      case 'trabajador':
        return AdminColors.chipTrabajador;
      default:
        return AdminColors.textSecondary;
    }
  }

  String _labelRol(String role) {
    switch (role) {
      case 'administrador':
        return 'Admin';
      case 'pequeno_productor':
        return 'Productor';
      case 'trabajador':
        return 'Trabajador';
      case 'gestor':
        return 'Gestor';
      default:
        return role;
    }
  }
}

/// Avatar con iniciales
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
      backgroundColor: _colorFondo(role),
      child: Text(
        iniciales,
        style: TextStyle(
          color: _colorTexto(role),
          fontWeight: FontWeight.bold,
          fontSize: radio * 0.6,
        ),
      ),
    );
  }

  Color _colorFondo(String role) {
    switch (role) {
      case 'administrador':
        return const Color(0xFFFFEBEE);
      case 'gestor':
        return const Color(0xFFE8F5E9);
      case 'pequeno_productor':
        return const Color(0xFFE3F2FD);
      case 'trabajador':
        return const Color(0xFFF5F5F5);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  Color _colorTexto(String role) {
    switch (role) {
      case 'administrador':
        return AdminColors.chipAdmin;
      case 'gestor':
        return AdminColors.primary;
      case 'pequeno_productor':
        return const Color(0xFF1565C0);
      default:
        return AdminColors.textSecondary;
    }
  }
}

/// Punto de estado (activo/inactivo)
class PuntoEstado extends StatelessWidget {
  final bool activo;
  final bool eliminado;

  const PuntoEstado({super.key, required this.activo, this.eliminado = false});

  @override
  Widget build(BuildContext context) {
    final color = eliminado
        ? AdminColors.error
        : activo
            ? AdminColors.accent
            : AdminColors.inactive;
    final label = eliminado ? 'Eliminado' : activo ? 'Activo' : 'Inactivo';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Dropdown de rol para formularios
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
    final opciones = [
      const DropdownMenuItem(value: 'pequeno_productor', child: Text('Pequeño Productor')),
      const DropdownMenuItem(value: 'trabajador', child: Text('Trabajador')),
      const DropdownMenuItem(value: 'gestor', child: Text('Gestor')),
      if (incluirAdmin)
        const DropdownMenuItem(value: 'administrador', child: Text('Administrador')),
    ];

    return DropdownButtonFormField<String>(
      value: valor,
      items: opciones,
      onChanged: onChanged,
      hint: const Text('Seleccione un rol...'),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminColors.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

/// Campo de texto estilo AgroField admin
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
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AdminColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 15,
            color: AdminColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AdminColors.inactive),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AdminColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AdminColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AdminColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AdminColors.error),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

/// Bottom nav bar del panel admin
class AdminBottomNav extends StatelessWidget {
  final int indiceActivo;
  final ValueChanged<int> onTap;

  const AdminBottomNav({
    super.key,
    required this.indiceActivo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: indiceActivo,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AdminColors.primary,
      unselectedItemColor: AdminColors.textSecondary,
      backgroundColor: Colors.white,
      elevation: 8,
      selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Panel',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people),
          label: 'Usuarios',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_outlined),
          activeIcon: Icon(Icons.grid_view),
          label: 'Lotes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Ajustes',
        ),
      ],
    );
  }
}
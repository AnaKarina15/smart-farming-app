import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/admin_provider.dart';
import '../widgets/admin_widgets.dart';
import 'admin_dashboard_screen.dart';
import 'admin_usuarios_screen.dart';
import 'admin_lotes_screen.dart';
import 'profile_screen.dart';

/// Scaffold raíz del panel administrador.
/// Índice 3 → ProfileScreen (la misma pantalla que usan todos los roles).
class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _indice = 0;

  // IndexedStack: mantiene el estado de cada pestaña viva
  static const List<Widget> _pantallas = [
    AdminDashboardScreen(),
    AdminUsuariosScreen(),
    AdminLotesScreen(),
    ProfileScreen(),   // ← pantalla de perfil compartida con todos los roles
  ];

  @override
  void initState() {
    super.initState();
    // Pre-cargar stats del dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().cargarStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _indice,
        children: _pantallas,
      ),
      bottomNavigationBar: AdminBottomNav(
        indiceActivo: _indice,
        onTap: (i) => setState(() => _indice = i),
      ),
    );
  }
}
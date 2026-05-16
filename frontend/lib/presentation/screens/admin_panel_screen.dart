import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/admin_provider.dart';
import '../widgets/admin_widgets.dart';
import 'admin_dashboard_screen.dart';
import 'admin_usuarios_screen.dart';
import 'admin_lotes_screen.dart';
// Importar la pantalla de perfil/ajustes existente del proyecto
// import '../../../presentation/screens/profile_screen.dart';

/// Scaffold raíz del panel administrador con bottom nav.
/// La pestaña "Ajustes" reutiliza la pantalla de perfil existente.
class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _indice = 0;

  // Las pantallas se crean una sola vez (IndexedStack)
  late final List<Widget> _pantallas;

  @override
  void initState() {
    super.initState();
    _pantallas = const [
      AdminDashboardScreen(),
      AdminUsuariosScreen(),
      AdminLotesScreen(),
      // ProfileScreen(), // <-- descomenta y ajusta el import cuando integres
      _AjustesPlaceholder(),
    ];

    // Cargar stats del dashboard al iniciar
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

/// Placeholder temporal — reemplazar con ProfileScreen() real del proyecto
class _AjustesPlaceholder extends StatelessWidget {
  const _AjustesPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Aquí va ProfileScreen()\n(pantalla de ajustes existente)',
        textAlign: TextAlign.center,
        style: TextStyle(color: AdminColors.textSecondary),
      ),
    );
  }
}
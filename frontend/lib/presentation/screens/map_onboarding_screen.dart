import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/rugged_button.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class MapOnboardingScreen extends StatefulWidget {
  const MapOnboardingScreen({super.key});

  @override
  State<MapOnboardingScreen> createState() => _MapOnboardingScreenState();
}

class _MapOnboardingScreenState extends State<MapOnboardingScreen> {
  int _selectedIndex = 1; // Seleccionado "Mapa" por defecto

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const _MapOnboardingView(),
      const Center(child: Text('Tareas (Próximamente)')),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.primary, width: 2)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textGrey,
          selectedLabelStyle: GoogleFonts.lexend(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          unselectedLabelStyle: GoogleFonts.lexend(
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Lotes',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.assignment_outlined,
              ), // Ícono de tareas (libreta)
              activeIcon: Icon(Icons.assignment),
              label: 'Tareas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Ajustes',
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }
}

class _MapOnboardingView extends StatelessWidget {
  const _MapOnboardingView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Encabezado Fotográfico (Tercio superior)
        Expanded(
          flex: 1,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                'https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=1000',
                fit: BoxFit.cover,
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Agrofield',
                      style: GoogleFonts.lexend(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Contenido Principal (Dos tercios inferiores)
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  Text(
                    '¡COMENCEMOS A\nMAPEAR TU\nCULTIVO!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Para recibir recomendaciones de riego\ny alertas de plagas, necesitamos\nsaber dónde está tu terreno.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const Spacer(),
                  RuggedButton(
                    text: 'REGISTRAR MI PRIMER LOTE',
                    icon: Icons.add,
                    onPressed: () {
                      // TODO: Navigate to register lot screen or map view
                    },
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to main dashboard
                    },
                    child: Text(
                      'Explorar la app y registrar más tarde desde la\npestaña Lotes (+)',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

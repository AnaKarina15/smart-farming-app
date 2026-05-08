import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/rugged_button.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.network(
            'https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=1000', // Placeholder
            fit: BoxFit.cover,
            color: Colors.black.withValues(alpha: 0.5),
            colorBlendMode: BlendMode.darken,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // Logo Placeholder
                  const Icon(
                    Icons.eco_outlined,
                    size: 80,
                    color: AppColors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Smart Farming',
                    style: GoogleFonts.lexend(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Gestiona tu cultivo, incluso sin\ninternet',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: AppColors.white,
                    ),
                  ),
                  const Spacer(),
                  RuggedButton(
                    text: 'INICIAR SESIÓN',
                    backgroundColor: AppColors.primary,
                    textColor: AppColors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  RuggedButton(
                    text: 'CREAR CUENTA NUEVA',
                    backgroundColor:
                        Colors.black, // Darker or black based on design
                    textColor: AppColors.white,
                    isOutlined: true,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

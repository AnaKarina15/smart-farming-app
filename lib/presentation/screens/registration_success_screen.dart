import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'map_onboarding_screen.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  const RegistrationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Smart Farming',
          style: GoogleFonts.lexend(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFC0EDD4), // primary-fixed
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: const Icon(Icons.person, color: AppColors.primary, size: 24),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(color: AppColors.primary, height: 2.0),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Success Icon
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFFC0EDD4), // primary-fixed
                  border: Border.all(color: AppColors.primary, width: 4),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.primary,
                      offset: Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(Icons.check_circle, color: AppColors.primary, size: 48),
              ),
              const SizedBox(height: 32),
              
              // Titles & Copy
              Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.primary, width: 2)),
                ),
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  '¡BIENVENIDO A\nSMART FARMING!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 28,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tu cuenta ha sido creada exitosamente. Ya puedes empezar a registrar tus lotes y actividades',
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  color: const Color(0xFF414844), // on-surface-variant
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.primary, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.primary,
                      offset: Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.badge_outlined, color: AppColors.primary),
                        const SizedBox(width: 16),
                        Text(
                          'USUARIO: JUAN PÉREZ',
                          style: GoogleFonts.lexend(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.verified_outlined, color: AppColors.primary),
                        const SizedBox(width: 16),
                        Text(
                          'ESTADO: CUENTA ACTIVA',
                          style: GoogleFonts.lexend(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Feature Image
              Container(
                width: double.infinity,
                height: 192,
                decoration: BoxDecoration(
                  color: const Color(0xFFC0EDD4),
                  border: Border.all(color: AppColors.primary, width: 4),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.primary,
                      offset: Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                  image: const DecorationImage(
                    image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCTJGCEi16aUTDw3teJYYIG4o1sxhol2vxdeCDJd_xTonNe12Xf1kwbshQ25TtdlrWtlRcQjf1jwF9dTVqHu1tyjOt6u5S7TfEBN9pj9aRcwZZlN1gyXHmJZdWvkNY4gZj2fKmnxNlRKM9M2x--gjPXGDZOM4ROQ29HS6R_mNK7AM-xsv_0nRQcjbocYWRLFNyyNxlBsP3KuhDLKcX8mj7LaEVo1rnPVG4XYxIHCN3svc1Hz144HJM-1Nl4V5xfFKi41FQgiNCpX4p3'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Primary Action
              Container(
                width: double.infinity,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  border: Border.all(color: AppColors.primary, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.primary,
                      offset: Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MapOnboardingScreen()),
                      );
                    },
                    child: Center(
                      child: Text(
                        'COMENZAR',
                        style: GoogleFonts.lexend(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

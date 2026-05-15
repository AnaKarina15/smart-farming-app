import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers/auth_provider.dart';
import '../widgets/custom_app_bar.dart';
import 'map_onboarding_screen.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  const RegistrationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener el nombre del usuario actualmente logueado
    final currentUser = context.watch<AuthProvider>().currentUser;
    final nombreUsuario =
        currentUser?.nombreCompleto.toUpperCase() ?? 'USUARIO';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                  height:
                      10), // matching py-lg which is 48px, but appbar also takes space
              // Success Icon
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.primaryFixedDim,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.primary,
                  size: 48,
                ),
              ),
              const SizedBox(height: 10),

              // Titles & Copy
              Text(
                '¡BIENVENIDO A AGROFIELD!',
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 32,
                  height: 1.2,
                  letterSpacing: 32 * 0.01,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Tu cuenta ha sido creada exitosamente. Ya puedes empezar a registrar tus lotes y actividades',
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  height: 1.6,
                  letterSpacing: 16 * 0.02,
                ),
              ),
              const SizedBox(height: 12),

              // Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.badge,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.lexend(
                                color: AppColors.onSurface,
                                fontSize: 12,
                                letterSpacing: 12 * 0.08,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'USUARIO: ',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                TextSpan(
                                  text: nombreUsuario,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.verified,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.lexend(
                              color: AppColors.onSurface,
                              fontSize: 12,
                              letterSpacing: 12 * 0.08,
                            ),
                            children: const [
                              TextSpan(
                                text: 'ESTADO: ',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              TextSpan(
                                text: 'CUENTA ACTIVA',
                                style: TextStyle(fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Feature Image
              Container(
                width: double.infinity,
                height: 192,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCTJGCEi16aUTDw3teJYYIG4o1sxhol2vxdeCDJd_xTonNe12Xf1kwbshQ25TtdlrWtlRcQjf1jwF9dTVqHu1tyjOt6u5S7TfEBN9pj9aRcwZZlN1gyXHmJZdWvkNY4gZj2fKmnxNlRKM9M2x--gjPXGDZOM4ROQ29HS6R_mNK7AM-xsv_0nRQcjbocYWRLFNyyNxlBsP3KuhDLKcX8mj7LaEVo1rnPVG4XYxIHCN3svc1Hz144HJM-1Nl4V5xfFKi41FQgiNCpX4p3',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Primary Action
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MapOnboardingScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'COMENZAR',
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 18 * 0.02,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

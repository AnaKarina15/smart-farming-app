import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/custom_app_bar.dart';
import 'home_screen.dart'; // For OfflineStatusBanner
import 'map_onboarding_screen.dart'; // Navigate back to main flow

class IrrigationSuccessScreen extends StatelessWidget {
  final int waterAmount;

  const IrrigationSuccessScreen({super.key, required this.waterAmount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          const OfflineStatusBanner(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Success State Graphic
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC1ECD4), // primary-fixed
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: const Color(0xFF1B4332), width: 4), // primary-container
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF1B4332), // primary-container
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '¡RIEGO REGISTRADO!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      color: AppColors.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'La información se guardó en el celular y se sincronizará cuando tengas internet.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lexend(
                      color: const Color(0xFF414844), // on-surface-variant
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Summary Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: const Color(0xFF717973), width: 2), // outline
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.inventory_2_outlined, color: Color(0xFF006399)), // secondary
                            const SizedBox(width: 12),
                            Text(
                              'RESUMEN DE REGISTRO',
                              style: GoogleFonts.lexend(
                                color: const Color(0xFF717973), // outline
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Ubicación',
                          style: GoogleFonts.lexend(
                            color: const Color(0xFF414844),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lote 1',
                          style: GoogleFonts.lexend(
                            color: const Color(0xFF181A2E), // on-surface
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(height: 2, color: const Color(0xFFC1C8C2)), // outline-variant
                        const SizedBox(height: 16),
                        Text(
                          'Agua Aplicada',
                          style: GoogleFonts.lexend(
                            color: const Color(0xFF414844),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$waterAmount Litros',
                          style: GoogleFonts.lexend(
                            color: const Color(0xFF006399), // secondary
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Contextual Image
                  Container(
                    width: double.infinity,
                    height: 128,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: const Color(0xFF717973), width: 2),
                      image: const DecorationImage(
                        image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCKotQei6Tgu8PwjA0OeocNyMfVetdhhYzSm8b5DGzZP385f42kOsTtDj-25We9bEPSXVFqdXY_TPW3kSElfuvEJ-OZP1Aj-41v83e2dpQxjTuFqlnAS37NUH8sN_GwfaLo6qU6OuWGZF_c1QBPwz77yTc0VR-r1qbHSGLrWNWBsQroA03usnhNdyBFGYTBLkwyIwBjrSesB18evxiLAvtwpC3HLbD604UBsZq3YMm3hShQFv5DKo_4jqu80MkmMUVFt01buo8TM0d-'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // Normally this would navigate back to the main map or home.
                        // Let's pop back to the MapOnboardingScreen (which handles tabs).
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const MapOnboardingScreen()),
                          (route) => false,
                        );
                      },
                      child: Text(
                        'IR A MIS LOTES',
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

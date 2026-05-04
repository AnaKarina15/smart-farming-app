import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/custom_app_bar.dart';
import 'home_screen.dart'; // For OfflineStatusBanner

class PhytosanitaryScreen extends StatelessWidget {
  const PhytosanitaryScreen({super.key});

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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GESTIÓN FITOSANITARIA',
                    style: GoogleFonts.lexend(
                      color: AppColors.primary,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Administra la sanidad vegetal de tus lotes',
                    style: GoogleFonts.lexend(
                      color: const Color(0xFF414844), // on-surface-variant
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 1. Registrar Hallazgo
                  _buildActionCard(
                    context: context,
                    icon: Icons.pest_control,
                    title: 'REGISTRAR HALLAZGO',
                    subtitle: 'Reporta nuevas plagas o enfermedades',
                    backgroundColor: const Color(0xFFFFDAD6), // error-container
                    onTap: () {
                      // Navigate to Register finding
                    },
                  ),
                  const SizedBox(height: 16),

                  // 2. Alertas Activas
                  _buildActionCard(
                    context: context,
                    icon: Icons.warning,
                    title: 'ALERTAS ACTIVAS',
                    subtitle: '2 alertas críticas detectadas',
                    backgroundColor: Colors.white, // surface
                    badgeCount: 2,
                    onTap: () {
                      // Navigate to active alerts
                    },
                  ),
                  const SizedBox(height: 16),

                  // 3. Aplicar Tratamiento
                  _buildActionCard(
                    context: context,
                    icon: Icons.vaccines,
                    title: 'APLICAR TRATAMIENTO',
                    subtitle: 'Ejecutar acciones correctivas',
                    backgroundColor: Colors.white,
                    onTap: () {
                      // Navigate to apply treatment
                    },
                  ),
                  const SizedBox(height: 16),

                  // 4. Historial
                  _buildActionCard(
                    context: context,
                    icon: Icons.history,
                    title: 'HISTORIAL',
                    subtitle: 'Consulta registros anteriores',
                    backgroundColor: Colors.white,
                    onTap: () {
                      // Navigate to history
                    },
                  ),
                  
                  const SizedBox(height: 48), // Padding for bottom nav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color backgroundColor,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [
            BoxShadow(
              color: AppColors.primary,
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -8,
                    right: -8,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBA1A1A), // error
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          badgeCount.toString(),
                          style: GoogleFonts.lexend(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lexend(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.lexend(
                      color: const Color(0xFF414844), // on-surface-variant
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.arrow_forward, color: AppColors.primary, size: 24),
          ],
        ),
      ),
    );
  }
}

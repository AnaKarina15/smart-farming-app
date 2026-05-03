import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_farming/presentation/widgets/custom_app_bar.dart';
import '../../core/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bool hasCriticalAlert = true;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(), //
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          bottom: 16.0,
        ), // Margen sobre el bottom nav
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: const Color(0xFF006399), // secondary
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white, width: 4),
          ),
          elevation: 8,
          child: const Icon(Icons.explore, color: Colors.white, size: 32),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const OfflineStatusBanner(),
              const SizedBox(height: 32),
              if (hasCriticalAlert) ...[
                const LatestTaskCard(), // Nuestra nueva tarjeta de Próxima Tarea
                const SizedBox(height: 32),
              ],
              const QuickOperationsGrid(),
              const SizedBox(height: 32),
              const SoilStatusCard(),
              const SizedBox(
                height: 80,
              ), // Espacio extra al final para que el FAB no tape nada
            ],
          ),
        ),
      ),
    );
  }
}

class OfflineStatusBanner extends StatelessWidget {
  const OfflineStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        border: Border.all(
          color: const Color(0xFF1B4332),
          width: 2,
        ), // primary-container
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(0, 1), blurRadius: 2),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off,
            color: Color(0xFFC1ECD4),
            size: 24,
          ), // primary-fixed
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MODO OFFLINE',
                style: GoogleFonts.lexend(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Guardando en el celular',
                style: GoogleFonts.lexend(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LatestTaskCard extends StatelessWidget {
  const LatestTaskCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PRÓXIMA TAREA',
                style: GoogleFonts.lexend(
                  color: const Color(0xFF717973), // outline
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFC1ECD4), // primary-fixed
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: const Icon(
                  Icons.local_florist,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aplicar Fertilizante',
                      style: GoogleFonts.lexend(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lote 1 • Hoy, 4:00 PM',
                      style: GoogleFonts.lexend(
                        color: const Color(0xFF414844), // on-surface-variant
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class QuickOperationsGrid extends StatelessWidget {
  const QuickOperationsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OPERACIONES RÁPIDAS',
          style: GoogleFonts.lexend(
            color: const Color(0xFF717973), // outline
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        _buildOperationButton(
          icon: Icons.water_drop,
          iconBgColor: const Color(0xFF67BAFD), // secondary-container
          iconColor: const Color(0xFF004972), // on-secondary-container
          label: 'Riego',
        ),
        const SizedBox(height: 16),
        _buildOperationButton(
          icon: Icons.local_florist,
          iconBgColor: const Color(0xFFC1ECD4), // primary-fixed
          iconColor: const Color(0xFF002114), // on-primary-fixed
          label: 'Fertilización',
        ),
        const SizedBox(height: 16),
        _buildOperationButton(
          icon: Icons.calendar_month,
          iconBgColor: const Color(0xFFFFDAD4), // tertiary-fixed
          iconColor: const Color(0xFF410000), // on-tertiary-fixed
          label: 'Siembra',
        ),
      ],
    );
  }

  Widget _buildOperationButton({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String label,
  }) {
    return Container(
      height: 96,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          child: Row(
            children: [
              Container(
                width: 80,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  border: const Border(
                    right: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                child: Icon(icon, color: iconColor, size: 36),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: GoogleFonts.lexend(
                    color: AppColors.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF717973),
                size: 32,
              ),
              const SizedBox(width: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class SoilStatusCard extends StatelessWidget {
  const SoilStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F2FF), // surface-container-low
        border: Border.all(
          color: const Color(0xFFC1C8C2),
          width: 2,
        ), // outline-variant
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ESTADO DEL SUELO',
            style: GoogleFonts.lexend(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Humedad Lote 1',
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                'SECO',
                style: GoogleFonts.lexend(
                  color: const Color(0xFF006399), // secondary
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Nutrientes (Nitrógeno)',
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                'Óptimo',
                style: GoogleFonts.lexend(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFC1C8C2), width: 2),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width:
                    MediaQuery.of(context).size.width *
                    0.6, // Simulating 85% width roughly
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFC1C8C2), thickness: 2, height: 2),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Última inspección visual: Ayer',
                style: GoogleFonts.lexend(
                  color: const Color(0xFF717973),
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
              InkWell(
                onTap: () {},
                child: Container(
                  color: AppColors.primary,
                  padding: const EdgeInsets.all(8.0),
                  child: const Icon(Icons.refresh, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

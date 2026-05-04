import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/custom_app_bar.dart';
import 'home_screen.dart'; // For OfflineStatusBanner
import 'irrigation_success_screen.dart';

class IrrigationScreen extends StatefulWidget {
  const IrrigationScreen({super.key});

  @override
  State<IrrigationScreen> createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends State<IrrigationScreen> {
  int _waterAmount = 20;

  void _incrementWater() {
    setState(() {
      _waterAmount++;
    });
  }

  void _decrementWater() {
    if (_waterAmount > 0) {
      setState(() {
        _waterAmount--;
      });
    }
  }

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
                    'REGISTRAR RIEGO',
                    style: GoogleFonts.lexend(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Suggestion Section
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCDE5FF), // secondary-fixed
                      border: Border.all(color: AppColors.primary, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.primary,
                          offset: Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF006399), // secondary
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sugerencia de riego',
                                style: GoogleFonts.lexend(
                                  color: const Color(0xFF001D32), // on-secondary-fixed
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Aplicar 20L en Lote 1 para optimizar el rendimiento del suelo hoy.',
                                style: GoogleFonts.lexend(
                                  color: const Color(0xFF001D32),
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sugerencia calculada localmente',
                                style: GoogleFonts.lexend(
                                  color: const Color(0xFF001D32).withOpacity(0.8),
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Lote Selector
                  Text(
                    'SELECCIONAR LOTE',
                    style: GoogleFonts.lexend(
                      color: const Color(0xFF414844), // on-surface-variant
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Lote 1',
                          style: GoogleFonts.lexend(
                            color: AppColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Icon(Icons.expand_more, color: AppColors.primary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Cantidad Input
                  Text(
                    'CANTIDAD APLICADA (LITROS)',
                    style: GoogleFonts.lexend(
                      color: const Color(0xFF414844),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildCounterButton(
                        icon: Icons.remove,
                        onTap: _decrementWater,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.primary, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              '$_waterAmount',
                              style: GoogleFonts.lexend(
                                color: AppColors.primary,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildCounterButton(
                        icon: Icons.add,
                        onTap: _incrementWater,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Context Info
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.primary, width: 2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ÚLTIMO RIEGO',
                                style: GoogleFonts.lexend(
                                  color: const Color(0xFF717973),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Hace 2 días',
                                style: GoogleFonts.lexend(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.primary, width: 2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ESTADO SUELO',
                                style: GoogleFonts.lexend(
                                  color: const Color(0xFF717973),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Seco',
                                style: GoogleFonts.lexend(
                                  color: const Color(0xFF006399), // secondary
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B4332), // primary-container
                        foregroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        side: const BorderSide(color: AppColors.primary, width: 2),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => IrrigationSuccessScreen(
                              waterAmount: _waterAmount,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'CONFIRMAR RIEGO',
                            style: GoogleFonts.lexend(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32), // Extra padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: Icon(icon, color: AppColors.primary, size: 36),
      ),
    );
  }
}

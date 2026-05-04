import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/custom_app_bar.dart';
import 'home_screen.dart'; // For OfflineStatusBanner
import 'sowing_success_screen.dart';

class SowingScreen extends StatefulWidget {
  const SowingScreen({super.key});

  @override
  State<SowingScreen> createState() => _SowingScreenState();
}

class _SowingScreenState extends State<SowingScreen> {
  String _selectedCrop = 'Maíz';
  String _selectedLote = 'Lote Norte - Sector A1';

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
                    'REGISTRAR NUEVA SIEMBRA',
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
                    'Complete los detalles técnicos del lote.',
                    style: GoogleFonts.lexend(
                      color: const Color(0xFF414844),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Seleccionar Cultivo
                  Text(
                    'SELECCIONAR CULTIVO',
                    style: GoogleFonts.lexend(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCropOption(
                          icon: Icons.agriculture,
                          label: 'Maíz',
                          isActive: _selectedCrop == 'Maíz',
                          onTap: () => setState(() => _selectedCrop = 'Maíz'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildCropOption(
                          icon: Icons.grass, // Used grass instead of bakery_dining
                          label: 'Banano',
                          isActive: _selectedCrop == 'Banano',
                          onTap: () => setState(() => _selectedCrop = 'Banano'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildCropOption(
                          icon: Icons.energy_savings_leaf,
                          label: 'Café',
                          isActive: _selectedCrop == 'Café',
                          onTap: () => setState(() => _selectedCrop = 'Café'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Fecha Field
                  Text(
                    'FECHA DE SIEMBRA',
                    style: GoogleFonts.lexend(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFF717973), width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        const Icon(Icons.calendar_today, color: Color(0xFF717973)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '24/05/2024',
                            style: GoogleFonts.lexend(
                              fontSize: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Lote Field
                  Text(
                    'SELECCIONAR LOTE',
                    style: GoogleFonts.lexend(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFF717973), width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.map, color: Color(0xFF717973)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedLote,
                              isExpanded: true,
                              icon: const Icon(Icons.expand_more, color: Color(0xFF717973)),
                              style: GoogleFonts.lexend(
                                color: AppColors.primary,
                                fontSize: 18,
                              ),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedLote = newValue;
                                  });
                                }
                              },
                              items: <String>[
                                'Lote Norte - Sector A1',
                                'Lote Sur - Sector B2',
                                'Lote Este - Reserva'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Area Stats
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC1ECD4), // primary-fixed
                      border: Border.all(color: const Color(0xFF717973), width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          offset: Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ÁREA DISPONIBLE',
                              style: GoogleFonts.lexend(
                                color: const Color(0xFF274E3D),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '2.5 ',
                                    style: GoogleFonts.lexend(
                                      color: AppColors.primary,
                                      fontSize: 48,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'ha',
                                    style: GoogleFonts.lexend(
                                      color: AppColors.primary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.straighten,
                          size: 64,
                          color: const Color(0xFF1B4332).withOpacity(0.2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SowingSuccessScreen(
                              crop: _selectedCrop,
                              lote: _selectedLote.split(' - ')[0],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFF0F172A), width: 4)),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.save, size: 24, color: Colors.white),
                            const SizedBox(width: 12),
                            Text(
                              'GUARDAR SIEMBRA',
                              style: GoogleFonts.lexend(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60), // padding for bottom nav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropOption({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFC1ECD4) : Colors.white,
          border: Border.all(
            color: isActive ? const Color(0xFF1B4332) : const Color(0xFF717973),
            width: isActive ? 4 : 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : const Color(0xFF717973),
              size: 36,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.lexend(
                color: isActive ? AppColors.primary : const Color(0xFF717973),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

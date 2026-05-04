import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/custom_app_bar.dart';
import 'home_screen.dart'; // For OfflineStatusBanner
import 'fertilization_success_screen.dart';

class FertilizationScreen extends StatefulWidget {
  const FertilizationScreen({super.key});

  @override
  State<FertilizationScreen> createState() => _FertilizationScreenState();
}

class _FertilizationScreenState extends State<FertilizationScreen> {
  String _selectedFertilizer = 'Nitrógeno';
  int _amount = 450;
  String _selectedLote = 'Lote 1 - Sector Norte';

  void _incrementAmount() {
    setState(() {
      _amount += 10;
    });
  }

  void _decrementAmount() {
    if (_amount >= 10) {
      setState(() {
        _amount -= 10;
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
                    'REGISTRAR FERTILIZACIÓN',
                    style: GoogleFonts.lexend(
                      color: AppColors.primary,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Seleccionar Fertilizante
                  Text(
                    'SELECCIONAR FERTILIZANTE',
                    style: GoogleFonts.lexend(
                      color: const Color(0xFF717973), // outline
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFertilizerOption(
                          icon: Icons.science,
                          label: 'Nitrógeno',
                          isActive: _selectedFertilizer == 'Nitrógeno',
                          onTap: () =>
                              setState(() => _selectedFertilizer = 'Nitrógeno'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFertilizerOption(
                          icon: Icons.water_drop,
                          label: 'Fósforo',
                          isActive: _selectedFertilizer == 'Fósforo',
                          onTap: () =>
                              setState(() => _selectedFertilizer = 'Fósforo'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFertilizerOption(
                          icon: Icons.eco,
                          label: 'Orgánico',
                          isActive: _selectedFertilizer == 'Orgánico',
                          onTap: () =>
                              setState(() => _selectedFertilizer = 'Orgánico'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Cantidad Aplicada
                  Row(
                    children: [
                      const Text('💡'),
                      const SizedBox(width: 4),
                      Text(
                        'Dosis sugerida por el sistema: 400 KG',
                        style: GoogleFonts.lexend(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'CANTIDAD APLICADA',
                    style: GoogleFonts.lexend(
                      color: const Color(0xFF717973),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: InkWell(
                                  onTap: _decrementAmount,
                                  child: const Center(
                                    child: Icon(
                                      Icons.remove,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                              Container(width: 2, color: AppColors.primary),
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        '$_amount',
                                        style: GoogleFonts.lexend(
                                          color: AppColors.primary,
                                          fontSize: 32,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.only(left: 8),
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            left: BorderSide(
                                              color: Color(0xFFE2E8F0),
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'KG',
                                          style: GoogleFonts.lexend(
                                            color: AppColors.primary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(width: 2, color: AppColors.primary),
                              Expanded(
                                flex: 1,
                                child: InkWell(
                                  onTap: _incrementAmount,
                                  child: const Center(
                                    child: Icon(
                                      Icons.add,
                                      color: AppColors.primary,
                                      size: 24,
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
                  const SizedBox(height: 32),

                  // Seleccionar Lote
                  Text(
                    'SELECCIONAR LOTE',
                    style: GoogleFonts.lexend(
                      color: const Color(0xFF717973),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
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
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedLote,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.expand_more,
                          color: AppColors.primary,
                        ),
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
                        items:
                            <String>[
                              'Lote 1 - Sector Norte',
                              'Lote 2 - Ladera Este',
                              'Lote 3 - Valle Sur',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                      ),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        side: const BorderSide(
                          color: Color(0xFF0F172A),
                          width: 0,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FertilizationSuccessScreen(
                              amount: _amount,
                              fertilizer: _selectedFertilizer,
                              lote: _selectedLote.split(' - ')[0],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFF0F172A),
                              width: 4,
                            ),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.save,
                              size: 24,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'GUARDAR REGISTRO',
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
                  const SizedBox(height: 100), // padding for bottom nav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFertilizerOption({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFC1ECD4) : Colors.white,
            border: Border.all(
              color: isActive
                  ? const Color(0xFF1B4332)
                  : const Color(0xFF717973),
              width: isActive ? 4 : 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? AppColors.primary : const Color(0xFF717973),
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.lexend(
                  color: isActive ? AppColors.primary : const Color(0xFF717973),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

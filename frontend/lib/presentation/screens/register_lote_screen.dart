import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../common/agro_bottom_nav.dart';
import '../widgets/rugged_button.dart';

class RegisterLoteScreen extends StatefulWidget {
  const RegisterLoteScreen({super.key});

  @override
  State<RegisterLoteScreen> createState() => _RegisterLoteScreenState();
}

class _RegisterLoteScreenState extends State<RegisterLoteScreen> {
  final _nameController = TextEditingController(text: 'Lote Sur');

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Registrar Lote', style: AppText.h3()),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Map background (placeholder)
          Container(
            color: AppColors.surfaceContainer,
            child: Center(
              child: Icon(
                Icons.map,
                size: 200,
                color: AppColors.outline.withValues(alpha: 0.3),
              ),
            ),
          ),
          // Polygon overlay
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 200),
              width: 200,
              height: 200,
              child: CustomPaint(painter: _PolygonPainter()),
            ),
          ),
          // Bottom sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, -8),
                    blurRadius: 24,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.outlineVariant,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Detalles del Lote', style: AppText.h2()),
                    const SizedBox(height: 24),
                    Text('NOMBRE DEL LOTE', style: AppText.labelCaps()),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.outlineVariant,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.outlineVariant,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.straighten,
                            color: AppColors.onSecondaryContainer,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'ÁREA CALCULADA: 2.1 HECTÁREAS',
                            style: AppText.labelCaps(
                              color: AppColors.onSecondaryContainer,
                            ).copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.my_location,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          'USAR MI UBICACIÓN ACTUAL',
                          style: AppText.labelCapsLg(color: AppColors.primary),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                          shape: const StadiumBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    RuggedButton(
                      text: 'GUARDAR LOTE',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AgroBottomNav(current: AgroTab.lotes),
    );
  }
}

class _PolygonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path()
      ..moveTo(size.width * 0.25, size.height * 0.25)
      ..lineTo(size.width * 0.80, size.height * 0.15)
      ..lineTo(size.width * 0.90, size.height * 0.75)
      ..lineTo(size.width * 0.20, size.height * 0.85)
      ..close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Handles
    final handle = Paint()..color = Colors.white;
    final handleStroke = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final points = [
      Offset(size.width * 0.25, size.height * 0.25),
      Offset(size.width * 0.80, size.height * 0.15),
      Offset(size.width * 0.90, size.height * 0.75),
      Offset(size.width * 0.20, size.height * 0.85),
    ];
    for (final p in points) {
      canvas.drawCircle(p, 8, handle);
      canvas.drawCircle(p, 8, handleStroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

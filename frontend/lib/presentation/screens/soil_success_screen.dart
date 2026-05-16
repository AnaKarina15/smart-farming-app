import 'package:flutter/material.dart';
import '../widgets/success_scaffold.dart';
import '../common/agro_bottom_nav.dart';
import 'home_screen.dart';

class SoilSuccessScreen extends StatelessWidget {
  final String lote;
  final String perception;
  final AgroTab currentTab;

  const SoilSuccessScreen({
    super.key,
    required this.lote,
    required this.perception,
    this.currentTab = AgroTab.home,
  });

  @override
  Widget build(BuildContext context) {
    return SuccessScaffold(
      title: '¡Percepción Guardada!',
      onlineSubtitle: 'La información se ha registrado y sincronizado correctamente en tu cuenta.',
      offlineSubtitle: 'La información se guardó en el celular y se sincronizará cuando tengas internet.',
      location: lote,
      detailLabel: 'Estado del Suelo',
      detailValue: perception,
      detailIcon: Icons.water_drop,
      primaryButtonText: 'VOLVER AL INICIO',
      onPrimaryPressed: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      ),
    );
  }
}

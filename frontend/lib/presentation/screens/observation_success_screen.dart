import 'package:flutter/material.dart';
import '../widgets/success_scaffold.dart';
import '../common/agro_bottom_nav.dart';
import 'home_screen.dart';

class ObservationSuccessScreen extends StatelessWidget {
  final String loteName;
  final String estadoActual;
  final AgroTab currentTab;

  const ObservationSuccessScreen({
    super.key,
    required this.loteName,
    required this.estadoActual,
    this.currentTab = AgroTab.home,
  });

  @override
  Widget build(BuildContext context) {
    return SuccessScaffold(
      title: '¡Observación Registrada!',
      onlineSubtitle: 'La información se ha registrado y sincronizado correctamente en tu cuenta.',
      offlineSubtitle: 'La información se guardó en el celular y se sincronizará cuando tengas internet.',
      location: loteName,
      detailLabel: 'Estado Actual',
      detailValue: estadoActual,
      detailIcon: Icons.visibility,
      primaryButtonText: 'VOLVER AL INICIO',
      onPrimaryPressed: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      ),
    );
  }
}

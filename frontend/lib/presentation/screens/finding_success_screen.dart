import 'package:flutter/material.dart';
import '../widgets/success_scaffold.dart';
import '../common/agro_bottom_nav.dart';
import 'home_screen.dart';

class FindingSuccessScreen extends StatelessWidget {
  final String lote;
  final String findingType;
  final AgroTab currentTab;

  const FindingSuccessScreen({
    super.key,
    required this.lote,
    required this.findingType,
    this.currentTab = AgroTab.home,
  });

  @override
  Widget build(BuildContext context) {
    return SuccessScaffold(
      title: '¡Hallazgo Registrado!',
      onlineSubtitle: 'La información se ha registrado y sincronizado correctamente en tu cuenta.',
      offlineSubtitle: 'La información se guardó en el celular y se sincronizará cuando tengas internet.',
      location: lote,
      detailLabel: 'Tipo de Hallazgo',
      detailValue: findingType,
      detailIcon: Icons.bug_report,
      primaryButtonText: 'VOLVER AL INICIO',
      onPrimaryPressed: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      ),
    );
  }
}

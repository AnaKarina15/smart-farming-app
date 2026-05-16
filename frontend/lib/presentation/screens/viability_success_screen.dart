import 'package:flutter/material.dart';
import '../widgets/success_scaffold.dart';
import '../common/agro_bottom_nav.dart';

class ViabilitySuccessScreen extends StatelessWidget {
  final String lote;
  final int viability;
  final String quality;
  final AgroTab currentTab;

  const ViabilitySuccessScreen({
    super.key,
    required this.lote,
    required this.viability,
    required this.quality,
    this.currentTab = AgroTab.home,
  });

  @override
  Widget build(BuildContext context) {
    return SuccessScaffold(
      title: '¡Viabilidad Registrada!',
      onlineSubtitle: 'La información se ha registrado y sincronizado correctamente en tu cuenta.',
      offlineSubtitle: 'La información se guardó en el celular y se sincronizará cuando tengas internet.',
      location: lote,
      detailLabel: 'Porcentaje y Calidad',
      detailValue: '$viability% - $quality',
      detailIcon: Icons.verified,
      currentTab: currentTab,
    );
  }
}

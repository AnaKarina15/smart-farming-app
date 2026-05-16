import 'package:flutter/material.dart';
import '../widgets/success_scaffold.dart';
import '../common/agro_bottom_nav.dart';

class TerrainSuccessScreen extends StatelessWidget {
  final String lote;
  final String status;
  final AgroTab currentTab;

  const TerrainSuccessScreen({
    super.key,
    required this.lote,
    required this.status,
    this.currentTab = AgroTab.home,
  });

  @override
  Widget build(BuildContext context) {
    return SuccessScaffold(
      title: '¡Estado Guardado!',
      onlineSubtitle: 'La información se ha registrado y sincronizado correctamente en tu cuenta.',
      offlineSubtitle: 'La información se guardó en el celular y se sincronizará cuando tengas internet.',
      location: lote,
      detailLabel: 'Condición',
      detailValue: status,
      detailIcon: Icons.analytics,
      currentTab: currentTab,
    );
  }
}

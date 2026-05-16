import 'package:flutter/material.dart';
import '../widgets/success_scaffold.dart';
import '../common/agro_bottom_nav.dart';
class SowingSuccessScreen extends StatelessWidget {
  final String lote;
  final String crop;
  final AgroTab currentTab;

  const SowingSuccessScreen({
    super.key,
    this.lote = 'Lote Norte',
    this.crop = 'Maíz',
    this.currentTab = AgroTab.home,
  });

  @override
  Widget build(BuildContext context) {
    return SuccessScaffold(
      title: '¡Siembra Registrada!',
      onlineSubtitle:
          'La información se ha registrado y sincronizado correctamente en tu cuenta.',
      offlineSubtitle:
          'La información se guardó en el celular y se sincronizará cuando tengas internet.',
      location: lote,
      detailLabel: 'Cultivo',
      detailValue: '$crop (2.5 hec)',
      detailIcon: Icons.grass,
      currentTab: currentTab,
    );
  }
}

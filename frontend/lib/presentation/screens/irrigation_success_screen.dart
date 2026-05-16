import 'package:flutter/material.dart';
import '../widgets/success_scaffold.dart';
import '../common/agro_bottom_nav.dart';

class IrrigationSuccessScreen extends StatelessWidget {
  final String lote;
  final int liters;
  final AgroTab currentTab;

  const IrrigationSuccessScreen({
    super.key,
    this.lote = 'Lote 1',
    this.liters = 20,
    this.currentTab = AgroTab.home,
  });

  @override
  Widget build(BuildContext context) {
    return SuccessScaffold(
      title: '¡Riego Registrado!',
      onlineSubtitle:
          'La información se ha registrado y sincronizado correctamente en tu cuenta.',
      offlineSubtitle:
          'La información se guardó en el celular y se sincronizará cuando tengas internet.',
      location: lote,
      detailLabel: 'Agua Aplicada',
      detailValue: '$liters Litros',
      detailIcon: Icons.water_drop,
      currentTab: currentTab,
    );
  }
}

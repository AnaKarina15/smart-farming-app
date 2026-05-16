import 'package:flutter/material.dart';
import '../widgets/success_scaffold.dart';
import '../common/agro_bottom_nav.dart';

class TreatmentSuccessScreen extends StatelessWidget {
  final String lote;
  final String metodo;
  final AgroTab currentTab;

  const TreatmentSuccessScreen({
    super.key,
    this.lote = 'Lote 1 - Sector Norte',
    this.metodo = 'Control Biológico',
    this.currentTab = AgroTab.home,
  });

  @override
  Widget build(BuildContext context) {
    return SuccessScaffold(
      title: '¡Tratamiento Registrado!',
      onlineSubtitle: 'La información se ha registrado y sincronizado correctamente en tu cuenta.',
      offlineSubtitle: 'La información se guardó en el celular y se sincronizará cuando tengas internet.',
      location: lote,
      detailLabel: 'Método Aplicado',
      detailValue: metodo,
      detailIcon: Icons.vaccines,
      currentTab: currentTab,
    );
  }
}

import 'package:flutter/material.dart';
import '../widgets/success_scaffold.dart';
import '../common/agro_bottom_nav.dart';

class EvaluationSuccessScreen extends StatelessWidget {
  final String loteName;
  final String plagueName;
  final bool isControlled;
  final AgroTab currentTab;

  const EvaluationSuccessScreen({
    super.key,
    required this.loteName,
    required this.plagueName,
    required this.isControlled,
    this.currentTab = AgroTab.home,
  });

  @override
  Widget build(BuildContext context) {
    return SuccessScaffold(
      title: '¡Evaluación Registrada!',
      onlineSubtitle: 'La información se ha registrado y sincronizado correctamente en tu cuenta.',
      offlineSubtitle: 'La información se guardó en el celular y se sincronizará cuando tengas internet.',
      location: loteName,
      detailLabel: 'Plaga Evaluada',
      detailValue: '$plagueName (${isControlled ? "Controlada" : "En Seguimiento"})',
      detailIcon: Icons.assignment_turned_in,
      currentTab: currentTab,
    );
  }
}

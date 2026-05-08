import 'package:flutter/material.dart';
import '../common/success_scaffold.dart';
import 'lote_history_screen.dart';

class IrrigationSuccessScreen extends StatelessWidget {
  final String lote;
  final int liters;

  const IrrigationSuccessScreen({
    super.key,
    this.lote = 'Lote 1',
    this.liters = 20,
  });

  @override
  Widget build(BuildContext context) {
    return SuccessScaffold(
      title: '¡Riego Registrado!',
      subtitle:
          'La información se guardó en el celular y se sincronizará cuando tengas internet.',
      location: lote,
      detailLabel: 'Agua Aplicada',
      detailValue: '$liters Litros',
      detailIcon: Icons.water_drop,
      fallbackIcon: Icons.water_drop,
      primaryButtonText: 'VER HISTORIAL DEL LOTE',
      onPrimaryPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoteHistoryScreen(loteName: lote)),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../common/offline_banner.dart';
import '../common/success_scaffold.dart';
import 'lote_history_screen.dart';

class SowingSuccessScreen extends StatelessWidget {
  final String lote;
  final String crop;

  const SowingSuccessScreen({
    super.key,
    this.lote = 'Lote Norte',
    this.crop = 'Maíz',
  });

  @override
  Widget build(BuildContext context) {
    return SuccessScaffold(
      title: '¡Siembra Registrada!',
      subtitle:
          'La información se guardó en el celular y se sincronizará cuando tengas internet.',
      location: lote,
      detailLabel: 'Cultivo',
      detailValue: '$crop (2.5 ha)',
      detailIcon: Icons.grass,
      fallbackIcon: Icons.agriculture,
      bannerStyle: OfflineBannerStyle.surface,
      primaryButtonText: 'VER HISTORIAL DEL LOTE',
      onPrimaryPressed: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoteHistoryScreen(loteName: lote)),
      ),
    );
  }
}

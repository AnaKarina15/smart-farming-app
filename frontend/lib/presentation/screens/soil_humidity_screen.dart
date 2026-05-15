import 'package:flutter/material.dart';
import '../common/agro_bottom_nav.dart';

class SoilHumidityScreen extends StatelessWidget {
  final AgroTab currentTab;
  const SoilHumidityScreen({super.key, this.currentTab = AgroTab.tareas});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Humedad del Suelo')),
      body: const Center(child: Text('Humedad del Suelo Screen')),
      bottomNavigationBar: AgroBottomNav(current: currentTab),
    );
  }
}

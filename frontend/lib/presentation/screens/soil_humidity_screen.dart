import 'package:flutter/material.dart';

class SoilHumidityScreen extends StatelessWidget {
  const SoilHumidityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Humedad del Suelo')),
      body: const Center(child: Text('Humedad del Suelo Screen')),
    );
  }
}

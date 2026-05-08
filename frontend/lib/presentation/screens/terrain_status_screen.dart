import 'package:flutter/material.dart';

class TerrainStatusScreen extends StatelessWidget {
  const TerrainStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estado del Terreno')),
      body: const Center(child: Text('Terrain Status Screen')),
    );
  }
}
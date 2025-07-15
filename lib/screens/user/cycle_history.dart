import 'package:flutter/material.dart';

class CycleHistoryScreen extends StatelessWidget {
  const CycleHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Siklus'),
      ),
      body: const Center(
        child: Text('Ini adalah halaman riwayat siklus'),
      ),
    );
  }
}

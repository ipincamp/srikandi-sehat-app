import 'package:flutter/material.dart';

class TrackerScreen extends StatelessWidget {
  const TrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pelacak Siklus')),
      body: const Center(
        child: Text('Konten Pelacak Siklus Akan Hadir di Sini!'),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edukasi')),
      body: const Center(child: Text('Temukan Artikel Edukasi di Sini!')),
    );
  }
}

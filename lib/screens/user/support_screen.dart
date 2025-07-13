import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dukungan')),
      body: const Center(child: Text('Butuh Bantuan? Hubungi Ahli Kami!')),
    );
  }
}

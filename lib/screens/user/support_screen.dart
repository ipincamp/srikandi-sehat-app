import 'package:flutter/material.dart';
import 'package:srikandi_sehat_app/widgets/notification_icon_button.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: const Text('Dukungan', style: TextStyle(color: Colors.white)),
        actions: [NotificationIconButton()],
      ),
      body: const Center(child: Text('Butuh Bantuan? Hubungi Ahli Kami!')),
    );
  }
}

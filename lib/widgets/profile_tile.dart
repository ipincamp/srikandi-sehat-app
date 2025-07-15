import 'package:flutter/material.dart';

class ProfileTile extends StatelessWidget {
  final String? name;
  final String? email;
  final VoidCallback? onTap;
  final double avatarRadius;
  final Color avatarColor;

  const ProfileTile({
    super.key,
    required this.name,
    required this.email,
    this.onTap,
    this.avatarRadius = 30,
    this.avatarColor = const Color(0xFFF48FB1), // pink[200] default
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: avatarRadius,
        backgroundColor: avatarColor,
        child: const Icon(Icons.person, color: Colors.white, size: 32),
      ),
      title: Text(
        name ?? 'Loading...',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(email ?? ''),
      onTap: onTap,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/provider/auth_provider.dart';
import 'package:srikandi_sehat_app/widgets/custom_alert.dart';
import 'package:srikandi_sehat_app/widgets/custom_popup.dart';

class LogoutTile extends StatelessWidget {
  const LogoutTile({super.key});

  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.logout(context);

    if (success) {
      CustomAlert.show(context, 'Berhasil logout', type: AlertType.success);
      await Future.delayed(const Duration(milliseconds: 700));
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      if (authProvider.errorMessage.isNotEmpty) {
        CustomAlert.show(context, authProvider.errorMessage,
            type: AlertType.error);
      }
    }
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final bool? confirmed = await CustomConfirmationPopup.show(
      context,
      title: 'Konfirmasi Logout',
      message: 'Apakah Anda yakin ingin keluar dari aplikasi?',
      confirmText: 'Ya',
      cancelText: 'Batal',
      confirmColor: Colors.red,
      icon: Icons.logout,
    );

    if (confirmed == true) {
      await _logout(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.red.withOpacity(0.2),
        child: const Icon(Icons.logout, color: Colors.red),
      ),
      title: const Text('Logout'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _showLogoutConfirmation(context),
    );
  }
}

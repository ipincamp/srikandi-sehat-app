import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/user_profile_provider.dart';
import 'package:app/widgets/custom_alert.dart';
import 'package:app/widgets/profile_tile.dart';
import 'package:app/widgets/custom_popup.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _name;
  String? _email;
  // String? _role;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadProfile);
  }

  Future<void> _loadProfile({bool forceRefresh = false}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.loadUserData(); // Ambil data dasar dari AuthProvider
      // Jika perlu data profil lengkap:
      // await profileProvider.loadProfile(context, forceRefresh: forceRefresh);
      if (mounted) {
        setState(() {
          _name = authProvider.name;
          _email = authProvider.email;
          // _role = profileProvider.role; // Ambil role dari UserProfileProvider
        });
      }
    } catch (e) {
      if (mounted) {
        CustomAlert.show(context, 'Gagal memuat profil', type: AlertType.error);
      }
    } finally {
      if (mounted) setState(() {});
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

  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider = Provider.of<UserProfileProvider>(
      context,
      listen: false,
    );

    try {
      await profileProvider.clearCache(); // Clear cache profil
      final success = await authProvider.logout(context);

      if (success) {
        CustomAlert.show(context, 'Berhasil logout', type: AlertType.success);
        await Future.delayed(const Duration(milliseconds: 700));
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      } else {
        if (authProvider.errorMessage.isNotEmpty && context.mounted) {
          CustomAlert.show(
            context,
            authProvider.errorMessage,
            type: AlertType.error,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        CustomAlert.show(
          context,
          'Error saat logout: $e',
          type: AlertType.error,
        );
      }
    }
  }

  Widget buildListTile({
    required IconData icon,
    required String label,
    required Color color,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(label),
      // trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final role = authProvider.role;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          ProfileTile(
            name: _name,
            email: _email,
            role: role,
            /*
            onIconTap: () {
              // arahkan ke EditProfile atau lainnya
            },
            */
          ),

          const Divider(),

          // buildListTile(
          const Spacer(),

          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text('App ver 1.0', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLogoutConfirmation(context),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        tooltip: 'Logout',
        child: const Icon(Icons.logout),
      ),
      // Atur posisi FAB ke pojok kanan bawah
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

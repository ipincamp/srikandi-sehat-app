import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/provider/auth_provider.dart';
import 'package:srikandi_sehat_app/provider/profile_provider.dart';
import 'package:srikandi_sehat_app/widgets/custom_alert.dart';
import 'package:srikandi_sehat_app/widgets/custom_popup.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _name;
  String? _email;
  String? _role;
  bool _isLoading = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadProfile);
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final userProvider = Provider.of<ProfileProvider>(context, listen: false);

    try {
      final profile = await userProvider.getProfile();
      if (profile != null && mounted) {
        setState(() {
          _name = profile['name'];
          _email = profile['email'];
          _role = profile['role'];
        });
      }
    } catch (e) {
      CustomAlert.show(context, 'Gagal memuat profil', type: AlertType.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.logout();
    if (success) {
      CustomAlert.show(context, 'Berhasil logout', type: AlertType.success);
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    } else {
      CustomAlert.show(context, authProvider.errorMessage,
          type: AlertType.error);
    }
  }

  Future<void> _showLogoutConfirmation() async {
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
      _logout();
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
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.pink[200],
              child: const Icon(Icons.person, color: Colors.white, size: 32),
            ),
            title: Text(_name ?? 'Loading...',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(_email ?? ''),
            // trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          const Divider(),
          // buildListTile(

          //   icon: Icons.dark_mode,
          //   label: 'Dark Mode',
          //   color: Colors.black,
          //   trailing: Switch(
          //     value: _isDarkMode,
          //     onChanged: (val) => setState(() => _isDarkMode = val),
          //   ),
          // ),
          if (_role != 'admin') ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Profile',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            buildListTile(
              icon: Icons.person,
              label: 'Edit Profile',
              color: Colors.orange,
              onTap: () => {Navigator.pushNamed(context, '/edit-profile')},
            ),
            buildListTile(
              icon: Icons.vpn_key,
              label: 'Change Password',
              color: Colors.blue,
              onTap: () => {Navigator.pushNamed(context, '/change-password')},
            ),
            buildListTile(
              icon: Icons.notifications,
              label: 'Notifications',
              color: Colors.green,
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (val) => setState(() => _notificationsEnabled = val),
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/dashboard');
                },
                icon: const Icon(Icons.dashboard),
                label: const Text('Ke Dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],

          const Spacer(),
          buildListTile(
            icon: Icons.logout,
            label: 'Logout',
            color: Colors.red,
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showLogoutConfirmation,
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text('App ver 2.0.1', style: TextStyle(color: Colors.grey)),
          )
        ],
      ),
    );
  }
}

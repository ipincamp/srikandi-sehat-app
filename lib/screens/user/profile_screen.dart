import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/provider/user_profile_provider.dart';
import 'package:srikandi_sehat_app/widgets/custom_alert.dart';
import 'package:srikandi_sehat_app/widgets/logout_tile.dart';
import 'package:srikandi_sehat_app/widgets/profile_tile.dart';

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
    final userProvider =
        Provider.of<UserProfileProvider>(context, listen: false);

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
          ProfileTile(
            name: _name,
            email: _email,
            onIconTap: () => Navigator.pushNamed(context, '/detail-profile'),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Profile',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          buildListTile(
            icon: Icons.history,
            label: 'Riwayat Siklus',
            color: Colors.pinkAccent,
            onTap: () => {Navigator.pushNamed(context, '/cycle-history')},
          ),
          buildListTile(
            icon: Icons.person,
            label: 'Ubah Profil',
            color: Colors.orange,
            onTap: () => {Navigator.pushNamed(context, '/edit-profile')},
          ),
          buildListTile(
            icon: Icons.vpn_key,
            label: 'Ubah Kata Sandi',
            color: Colors.blue,
            onTap: () => {Navigator.pushNamed(context, '/change-password')},
          ),
          // buildListTile(
          //   icon: Icons.notifications,
          //   label: 'Notifications',
          //   color: Colors.green,
          //   trailing: Switch(
          //     value: _notificationsEnabled,
          //     onChanged: (val) => setState(() => _notificationsEnabled = val),
          //   ),
          // ),
          const Spacer(),
          const LogoutTile(),
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text('App ver 1.0', style: TextStyle(color: Colors.grey)),
          )
        ],
      ),
    );
  }
}

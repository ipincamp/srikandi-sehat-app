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
  bool _isLoading = false;
  bool _notificationsEnabled = true;

  String? _name;
  String? _email;
  // String? _role;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      _loadProfile,
    );
  }

  Future<void> _loadProfile({bool forceRefresh = false}) async {
    setState(() => _isLoading = true);
    final userProvider =
        Provider.of<UserProfileProvider>(context, listen: false);

    try {
      await userProvider.getProfile(forceRefresh: forceRefresh);
    } catch (e) {
      if (mounted) {
        CustomAlert.show(context, 'Gagal memuat profil', type: AlertType.error);
      }
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
      // trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProfileProvider>(context);
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
            name: userProvider.name,
            email: userProvider.email,
            onIconTap: () {
              // arahkan ke EditProfile atau lainnya
            },
          ),

          const Divider(),
          // buildListTile(

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

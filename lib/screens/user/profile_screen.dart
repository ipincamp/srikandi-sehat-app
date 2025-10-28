import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/widgets/custom_alert.dart';
import 'package:app/widgets/notification_icon_button.dart';
import 'package:app/widgets/profile_tile.dart';
import 'package:app/provider/user_profile_provider.dart';
import 'package:app/widgets/custom_popup.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _name;
  String? _email;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    final userProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await userProvider.loadUserData();
      if (mounted) {
        setState(() {
          _name = userProvider.name;
          _email = userProvider.email;
        });
      }
    } catch (e) {
      CustomAlert.show(context, 'Gagral memuat profil', type: AlertType.error);
    } finally {}
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
      // Clear profile cache terlebih dahulu
      await profileProvider.clearCache();

      // Lakukan logout
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
          // Tambah cek mounted
          CustomAlert.show(
            context,
            authProvider.errorMessage,
            type: AlertType.error,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        // Tambah cek mounted
        CustomAlert.show(
          context,
          'Error saat logout: $e',
          type: AlertType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.pink,
        actions: [NotificationIconButton()],
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            // Pastikan Column mengisi setidaknya tinggi layar
            minHeight:
                MediaQuery.of(context).size.height -
                (Scaffold.of(context).appBarMaxHeight ??
                    kToolbarHeight) - // Tinggi AppBar
                MediaQuery.of(context).padding.top - // Tinggi Status bar
                kBottomNavigationBarHeight - // Perkiraan tinggi Bottom Nav Bar
                MediaQuery.of(
                  context,
                ).padding.bottom, // Tinggi area bawah (jika ada notch/gestures)
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                const SizedBox(height: 16),
                ProfileTile(
                  name: _name,
                  email: _email,
                  onIconTap: () =>
                      Navigator.pushNamed(context, '/detail-profile'),
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Profile',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                buildListTile(
                  icon: Icons.book,
                  label: 'Riwayat Gejala',
                  color: Colors.red,
                  onTap: () => {
                    Navigator.pushNamed(context, '/symptom-history'),
                  },
                ),
                buildListTile(
                  icon: Icons.history,
                  label: 'Riwayat Menstruasi',
                  color: Colors.pinkAccent,
                  onTap: () => {
                    Navigator.pushNamed(context, '/menstrual-history'),
                  },
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
                  onTap: () => {
                    Navigator.pushNamed(context, '/change-password'),
                  },
                ),
                /*
                buildListTile(
                  icon: Icons.notifications,
                  label: 'Notifications',
                  color: Colors.green,
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (val) => setState(() => _notificationsEnabled = val),
                  ),
                ),
                */
                buildListTile(
                  icon: Icons.info_outline,
                  label: 'Tentang Aplikasi',
                  color: Colors.teal,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Tentang Aplikasi'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // syarat ketentuan dan kebijakan privasi
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Tutup dialog
                                Navigator.pushNamed(context, '/tos');
                              },
                              child: const Text('Syarat Ketentuan'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Tutup dialog
                                Navigator.pushNamed(context, '/privacy');
                              },
                              child: const Text('Kebijakan Privasi'),
                            ),
                            const SizedBox(height: 10),
                            // versi aplikasi
                            const Text('Versi Aplikasi: 1.0.0'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Tutup'),
                          ),
                        ],
                      ),
                    );
                    if (kDebugMode) {
                      debugPrint('Navigasi ke halaman Tentang Aplikasi');
                    }
                  },
                ),

                // ✅ Checkbox Persetujuan
                /*
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Wrap(
                      alignment:
                          WrapAlignment.center, // penting agar Wrap juga center
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/tos'),
                          child: const Text(
                            'Syarat Ketentuan',
                            style: TextStyle(
                              color: Colors.pink,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Text(' dan '),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/privacy'),
                          child: const Text(
                            'Kebijakan Privasi',
                            style: TextStyle(
                              color: Colors.pink,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const LogoutTile(),
                */
                const Spacer(),

                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'App ver 1.0',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLogoutConfirmation(context), // Panggil konfirmasi
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

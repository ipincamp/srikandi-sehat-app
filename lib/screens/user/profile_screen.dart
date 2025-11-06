import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/widgets/custom_alert.dart';
import 'package:app/widgets/profile_tile.dart';
import 'package:app/widgets/logout_tile.dart';

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

  // --- Fungsi _showLogoutConfirmation dan _logout dipindahkan ke LogoutTile ---
  // --- Anda bisa menghapusnya jika sudah ada di LogoutTile ---
  // --- Tapi jika LogoutTile memanggilnya dari sini, biarkan saja ---
  // --- Berdasarkan file logout_tile.dart, fungsi ini sudah ada di sana ---
  // --- Jadi kita HAPUS fungsi _showLogoutConfirmation dan _logout dari SINI ---

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight:
              MediaQuery.of(context).size.height -
              kToolbarHeight - // Tinggi AppBar
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
                onTap: () => {Navigator.pushNamed(context, '/symptom-history')},
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
                onTap: () => {Navigator.pushNamed(context, '/change-password')},
              ),
              if (!authProvider.isEmailVerified)
                buildListTile(
                  icon: Icons.mark_email_read,
                  label: 'Verifikasi Email',
                  color: Colors.cyan,
                  trailing: authProvider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: authProvider.isLoading
                      ? null
                      : () async {
                          // Ambil provider (listen: false) untuk aksi
                          final auth = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );

                          // 1. Panggil API untuk kirim email
                          final success = await auth.resendVerificationEmail(
                            context,
                          );

                          // 2. Jika kirim email sukses, navigasi ke halaman OTP
                          if (success && mounted) {
                            Navigator.pushNamed(context, '/verify-otp');
                          }
                          // Alert sukses/gagal sudah di-handle di dalam resendVerificationEmail
                        },
                ),
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

              const Spacer(),

              const LogoutTile(),

              const Padding(
                padding: EdgeInsets.only(bottom: 16, top: 16),
                child: Text(
                  'App ver 1.0',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

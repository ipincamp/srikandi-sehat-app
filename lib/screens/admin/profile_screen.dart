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

  // --- 2. HAPUS FUNGSI _showLogoutConfirmation ---
  // (Fungsi ini sudah ada di dalam LogoutTile)

  // --- 3. HAPUS FUNGSI _logout ---
  // (Fungsi ini sudah ada di dalam LogoutTile)

  // --- 4. HAPUS FUNGSI buildListTile ---
  // (Fungsi ini tidak digunakan di halaman admin)

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

          // --- 5. UBAH BAGIAN INI ---
          const Spacer(), // Dorong ke bawah

          const LogoutTile(), // Tambahkan LogoutTile di sini

          const Padding(
            padding: EdgeInsets.only(bottom: 16, top: 16),
            child: Text('App ver 1.0', style: TextStyle(color: Colors.grey)),
          ),
          // --- AKHIR PERUBAHAN ---
        ],
      ),
      // --- 6. HAPUS floatingActionButton ---
      // --- 7. HAPUS floatingActionButtonLocation ---
    );
  }
}

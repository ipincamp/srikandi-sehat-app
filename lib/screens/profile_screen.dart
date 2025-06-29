import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/provider/auth_provider.dart';
import 'package:srikandi_sehat_app/provider/user_provider.dart';
import 'package:srikandi_sehat_app/widgets/custom_alert.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _name;
  String? _email;
  String? _role;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadProfile); // aman karena dipanggil setelah build
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.logout();

    if (success) {
      CustomAlert.show(
        context,
        'Berhasil logout',
        type: AlertType.success,
      );
      await Future.delayed(const Duration(milliseconds: 750));
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      CustomAlert.show(
        context,
        authProvider.errorMessage,
        type: AlertType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _isLoading
                ? const CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.grey,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.pink[100],
                    child:
                        Icon(Icons.person, size: 56, color: Colors.pink[400]),
                  ),
            const SizedBox(height: 24),
            _isLoading
                ? Container(
                    height: 18,
                    width: 120,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.only(bottom: 8),
                  )
                : Text(
                    _name ?? 'Nama Pengguna',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
            _isLoading
                ? Container(
                    height: 14,
                    width: 180,
                    color: Colors.grey[200],
                    margin: const EdgeInsets.only(bottom: 8),
                  )
                : Text(
                    _email ?? '',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
            const SizedBox(height: 8),
            if (_role != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _role == 'admin' ? Colors.red[100] : Colors.blue[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _role!.toUpperCase(),
                  style: TextStyle(
                    color:
                        _role == 'admin' ? Colors.red[800] : Colors.blue[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: _logout,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

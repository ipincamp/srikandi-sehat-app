import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:app/core/auth/auth_guard.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/health_provider.dart';
import 'package:app/screens/splash/maintenance_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthWrapper extends StatefulWidget {
  // final dynamic initialAuthState;
  final Widget adminChild;
  final Widget userChild;
  final Widget guestChild;

  const AuthWrapper({
    super.key,
    // required this.initialAuthState,
    required this.adminChild,
    required this.userChild,
    required this.guestChild,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with RouteAware {
  @override
  void initState() {
    super.initState();
    // Cek token setelah frame pertama selesai dibangun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndSyncTokenAfterLogin();
    });
  }

  Future<void> _checkAndSyncTokenAfterLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn && mounted) {
      // Pastikan user logged in dan widget masih ada
      if (kDebugMode) {
        debugPrint("AuthWrapper: User logged in, checking FCM token sync...");
      }
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.updateFcmToken();
    }
  }

  @override
  Widget build(BuildContext context) {
    final healthProvider = Provider.of<HealthProvider>(context);

    if (healthProvider.isMaintenance) {
      return const MaintenanceScreen();
    }

    /*
    return FutureBuilder(
      future: AuthGuard.isValidSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isValidSession = snapshot.data ?? false;
        if (!isValidSession) return widget.guestChild;

        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final role = authProvider.role;

        if (role == 'admin') return widget.adminChild;
        if (role == 'user') return widget.userChild;

        return widget.guestChild;
      },
    );
    */
    final authProvider = Provider.of<AuthProvider>(context);

    // 1. Cek jika user login (berdasarkan authToken dari provider)
    if (authProvider.authToken == null) {
      return widget.guestChild; // Tidak login, tampilkan LoginScreen
    }

    // 2. User login. Cek role dan status verifikasi
    if (authProvider.role == 'user' && !authProvider.isEmailVerified) {
      // User login, TAPI BELUM verifikasi.
      // Arahkan ke OTP screen.
      // Menggunakan addPostFrameCallback agar navigasi terjadi setelah build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/verify-otp');
      });
      // Tampilkan loading sementara
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 3. User sudah terverifikasi ATAU adalah admin
    if (authProvider.role == 'admin') {
      return widget.adminChild;
    }

    if (authProvider.role == 'user') {
      // (Implisit: isEmailVerified == true)
      return widget.userChild;
    }

    // 4. Fallback (seharusnya tidak terjadi jika login/load benar)
    return widget.guestChild;
  }
}

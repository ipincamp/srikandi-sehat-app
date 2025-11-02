import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:app/core/auth/auth_guard.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/health_provider.dart';
import 'package:app/screens/splash/maintenance_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:app/utils/logger.dart';

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
    if (kDebugMode) {
      AppLogger.info('AuthWrapper', 'Initializing...');
    }
    // Cek token setelah frame pertama selesai dibangun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndSyncTokenAfterLogin();
    });
  }

  Future<void> _checkAndSyncTokenAfterLogin() async {
    if (kDebugMode) {
      AppLogger.startSection('AuthWrapper - Check FCM Token', emoji: '🔔');
    }
    
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn && mounted) {
      // Pastikan user logged in dan widget masih ada
      if (kDebugMode) {
        AppLogger.info('AuthWrapper', 'User logged in, syncing FCM token');
      }
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.updateFcmToken();
      
      if (kDebugMode) {
        AppLogger.success('AuthWrapper', 'FCM token sync completed');
        AppLogger.endSection();
      }
    } else {
      if (kDebugMode) {
        AppLogger.info('AuthWrapper', 'User not logged in, skipping FCM sync');
        AppLogger.endSection();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final healthProvider = Provider.of<HealthProvider>(context);

    if (healthProvider.isMaintenance) {
      if (kDebugMode) {
        AppLogger.warning('AuthWrapper', 'App is in maintenance mode');
      }
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
      if (kDebugMode) {
        AppLogger.info('AuthWrapper', 'No auth token - showing guest screen');
      }
      return widget.guestChild; // Tidak login, tampilkan LoginScreen
    }

    // 2. User login. Cek role dan status verifikasi
    if (authProvider.role == 'user' && !authProvider.isEmailVerified) {
      // User login, TAPI BELUM verifikasi.
      // Arahkan ke OTP screen.
      if (kDebugMode) {
        AppLogger.warning('AuthWrapper', 'User not verified - redirecting to OTP');
      }
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
      if (kDebugMode) {
        AppLogger.success('AuthWrapper', 'Admin authenticated - showing admin screen');
      }
      return widget.adminChild;
    }

    if (authProvider.role == 'user') {
      // (Implisit: isEmailVerified == true)
      if (kDebugMode) {
        AppLogger.success('AuthWrapper', 'User authenticated - showing user screen');
      }
      return widget.userChild;
    }

    // 4. Fallback (seharusnya tidak terjadi jika login/load benar)
    if (kDebugMode) {
      AppLogger.warning('AuthWrapper', 'Fallback to guest screen - unexpected state');
    }
    return widget.guestChild;
  }
}

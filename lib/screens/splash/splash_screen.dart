import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:app/provider/health_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const SplashScreen({super.key, required this.onInitializationComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // bool _isChecking = true;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 🎯 [SplashScreen] Screen initialized');
      debugPrint('│ 🔄 Requesting notification permission...');
    }
    // Panggil fungsi untuk minta izin saat halaman ini dibuka
    _requestNotificationPermission();
  }

  // Fungsi untuk meminta izin notifikasi
  void _requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    if (kDebugMode) {
      debugPrint('│ 🔔 Requesting Firebase notification permission...');
    }

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        debugPrint('│ ✅ User granted permission');
        debugPrint('└─────────────────────────────────────────');
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        debugPrint('│ ⚠️ User granted provisional permission');
        debugPrint('└─────────────────────────────────────────');
      }
    } else {
      if (kDebugMode) {
        debugPrint('│ ❌ User declined or has not accepted permission');
        debugPrint('│ 📊 Status: ${settings.authorizationStatus}');
        debugPrint('└─────────────────────────────────────────');
      }
    }
  }

  /*
  Future<void> _startSplash() async {
    try {
      // Tunggu durasi GIF selesai diputar
      await Future.delayed(const Duration(seconds: 3));

      final healthProvider = Provider.of<HealthProvider>(
        context,
        listen: false,
      );

      // Cek status kesehatan server dengan timeout
      await healthProvider.checkHealth().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          // Jika timeout, anggap server offline tapi lanjutkan ke app
          if (mounted) {
            setState(() {
              // _isChecking = false;
              _statusMessage =
                  'Tidak dapat terhubung ke server, melanjutkan ke aplikasi...';
            });
          }
          return;
        },
      );

      if (mounted) {
        setState(() {
          // _isChecking = false;
        });

        // Beri delay kecil sebelum navigasi
        await Future.delayed(const Duration(milliseconds: 500));

        if (healthProvider.isMaintenance) {
          _statusMessage =
              'Server dalam pemeliharaan, mengarahkan ke maintenance screen...';
          Navigator.pushReplacementNamed(context, '/maintenance');
        } else if (healthProvider.hasError) {
          // Jika ada error tapi bukan maintenance, lanjutkan ke app
          _statusMessage = 'Ada masalah koneksi, melanjutkan ke aplikasi...';
          widget.onInitializationComplete();
        } else {
          // Server OK, lanjutkan normal
          _statusMessage = 'Server OK, melanjutkan...';
          widget.onInitializationComplete();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // _isChecking = false;
          _statusMessage = 'Terjadi kesalahan, melanjutkan ke aplikasi...';
        });

        // Jika ada error, tetap lanjutkan ke app (jangan blokir user)
        await Future.delayed(const Duration(seconds: 1));
        widget.onInitializationComplete();
      }
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    // Kunci orientasi & sembunyikan status bar opsional
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/animations/splash.gif',
              fit: BoxFit.contain,
              width: 250,
            ),
            const SizedBox(height: 20),
            // if (_isChecking)
            //   const Column(
            //     children: [
            //       CircularProgressIndicator(
            //         valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
            //       ),
            //       SizedBox(height: 10),
            //       Text(
            //         'Memeriksa status server...',
            //         style: TextStyle(fontSize: 12, color: Colors.grey),
            //       ),
            //     ],
            //   ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _statusMessage!,
                style: TextStyle(
                  color:
                      _statusMessage!.contains('masalah') ||
                          _statusMessage!.contains('kesalahan') ||
                          _statusMessage!.contains('tidak dapat')
                      ? Colors.orange
                      : Colors.green,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/provider/health_provider.dart';
import 'package:srikandi_sehat_app/screens/splash/maintenance_screen.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const SplashScreen({super.key, required this.onInitializationComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startSplash();
  }

  Future<void> _startSplash() async {
    // Tunggu durasi GIF selesai diputar (misalnya 3 detik)
    await Future.delayed(const Duration(seconds: 3));

    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    await healthProvider.checkHealth();

    if (healthProvider.isMaintenance) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MaintenanceScreen()),
        );
      }
    } else {
      widget.onInitializationComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kunci orientasi & sembunyikan status bar opsional
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/animations/splash.gif',
          fit: BoxFit.contain,
          width: 250,
        ),
      ),
    );
  }
}

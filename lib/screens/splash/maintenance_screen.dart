import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/health_provider.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startChecking();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _manualCheckStatus(showSnackbar: false);
    });
  }

  void _startChecking() {
    _timer?.cancel();
    final provider = Provider.of<HealthProvider>(context, listen: false);
    _timer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (!mounted) {
        _timer?.cancel();
        return;
      }
      await provider.checkHealth();
      // Jika TIDAK maintenance DAN TIDAK ada error saat pengecekan
      if (!provider.isMaintenance && !provider.hasError && mounted) {
        _timer?.cancel();
        Navigator.pushReplacementNamed(context, '/');
      }
    });
  }

  Future<void> _manualCheckStatus({bool showSnackbar = true}) async {
    if (!mounted) return;

    final provider = Provider.of<HealthProvider>(context, listen: false);
    await provider.checkHealth();

    if (!mounted) return;

    // Jika TIDAK maintenance DAN TIDAK ada error saat pengecekan
    if (!provider.isMaintenance && !provider.hasError) {
      _timer?.cancel();
      Navigator.pushReplacementNamed(context, '/');
    } else if (showSnackbar) {
      // Tampilkan feedback jika masih maintenance atau error
      /*
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.hasError
                ? 'Masih belum bisa terhubung ke server. Coba lagi nanti.'
                : 'Server masih dalam pemeliharaan. Coba lagi nanti.',
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: provider.hasError ? Colors.red : Colors.orange,
        ),
      );
      */
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _exitApp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Keluar Aplikasi'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog dulu
                // Keluar dari aplikasi
                SystemNavigator.pop();
              },
              child: const Text('Keluar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HealthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.construction, size: 100, color: Colors.pink),
                const SizedBox(height: 24),
                const Text(
                  'Sistem Sedang Maintenance',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  // Tampilkan pesan error spesifik jika ada dari HealthProvider
                  provider.hasError
                      ? 'Tidak dapat menghubungi server saat ini.'
                      : 'Kami sedang melakukan perawatan sistem.\nSilakan coba lagi nanti.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                Text(
                  'Terakhir diperiksa: ${provider.lastCheckedAt != null ? provider.lastCheckedAt!.toLocal().toString().substring(11, 19) : '-'}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // Tombol Cek Status Kembali
                ElevatedButton.icon(
                  // Panggil fungsi _manualCheckStatus saat ditekan
                  onPressed: () => _manualCheckStatus(showSnackbar: true),
                  icon:
                      provider
                          .isLoading
                      ? Container(
                          width: 20,
                          height: 20,
                          padding: const EdgeInsets.all(2.0),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(
                    provider.isLoading ? 'Mengecek...' : 'Cek Status Kembali',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Tombol Keluar Aplikasi
                ElevatedButton.icon(
                  onPressed: _exitApp,
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('Keluar Aplikasi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

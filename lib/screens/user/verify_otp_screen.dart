import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/widgets/custom_button.dart';
import 'package:app/widgets/custom_popup.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  Timer? _timer;
  int _cooldownSeconds = 0;
  bool _isCooldownActive = false;
  final String _cooldownPrefKey = 'otpCooldownEndTime';

  @override
  void initState() {
    super.initState();
    _loadCooldown();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadCooldown() async {
    final prefs = await SharedPreferences.getInstance();
    final endTimeMs = prefs.getInt(_cooldownPrefKey);

    if (endTimeMs == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (endTimeMs > now) {
      final remainingSeconds = ((endTimeMs - now) / 1000).ceil();
      _setCooldown(remainingSeconds);
    }
  }

  Future<void> _setCooldown(int seconds) async {
    if (seconds <= 0) return;

    final endTime = DateTime.now().add(Duration(seconds: seconds));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cooldownPrefKey, endTime.millisecondsSinceEpoch);

    setState(() {
      _cooldownSeconds = seconds;
      _isCooldownActive = true;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel(); // Batalkan timer lama jika ada
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds > 0) {
        if (mounted) {
          setState(() {
            _cooldownSeconds--;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isCooldownActive = false;
          });
        }
        timer.cancel();
      }
    });
  }

  int _parseSecondsFromError(String message) {
    int totalSeconds = 0;
    try {
      // "Harap tunggu 13 menit 52 detik lagi..."
      final minMatch = RegExp(r'(\d+)\s+menit').firstMatch(message);
      final secMatch = RegExp(r'(\d+)\s+detik').firstMatch(message);

      if (minMatch != null) {
        totalSeconds += int.parse(minMatch.group(1)!) * 60;
      }
      if (secMatch != null) {
        totalSeconds += int.parse(secMatch.group(1)!);
      }
      // Tambahkan 1 detik buffer
      return totalSeconds > 0 ? totalSeconds + 1 : 0;
    } catch (e) {
      return 0; // Gagal parsing, jangan set cooldown
    }
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  Future<void> _handleResend() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resendVerificationEmail(
      context,
      showAlert: true,
    );

    if (success) {
      // Jika sukses (200 OK), backend memulai cooldown 15 menit
      _setCooldown(900); // 15 menit = 900 detik
    } else {
      // Cek apakah errornya adalah 429 (Too Many Requests)
      final errorMessage = authProvider.errorMessage;
      if (errorMessage.contains("Harap tunggu")) {
        final remainingSeconds = _parseSecondsFromError(errorMessage);
        if (remainingSeconds > 0) {
          _setCooldown(remainingSeconds);
        }
      }
      // Jika error lain, provider sudah menampilkannya via _showErrorAlert
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Tampilkan konfirmasi terlebih dahulu
    final bool? confirmed = await CustomConfirmationPopup.show(
      context,
      title: 'Konfirmasi Logout',
      message: 'Apakah Anda yakin ingin keluar dan kembali ke halaman login?',
      confirmText: 'Ya, Logout',
      cancelText: 'Batal',
      confirmColor: Colors.red,
      icon: Icons.logout,
    );

    // Jika pengguna tidak menekan "Ya, Logout", hentikan fungsi
    if (confirmed != true) {
      return;
    }

    // Jika dikonfirmasi, lanjutkan proses logout
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout(context);
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  Future<void> _submitOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final otp = _otpController.text;

    final success = await authProvider.submitOtp(otp, context);

    if (success && mounted) {
      // --- UBAH NAVIGASI DI SINI ---
      // Jika sukses, arahkan ke halaman utama (/main)
      // AuthWrapper akan otomatis mengarahkan ke user.MainScreen
      // karena isEmailVerified di provider sudah true.
      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      // HAPUS: Navigator.of(context).pop();
      // --- AKHIR PERUBAHAN ---
    }
    // Jika gagal, alert akan ditampilkan oleh provider
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final email = authProvider.email ?? 'email Anda';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Email'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mark_email_read_outlined,
                size: 80,
                color: Colors.pink[400],
              ),
              const SizedBox(height: 24),
              Text(
                'Masukkan Kode Verifikasi',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Kami telah mengirimkan 6 digit kode OTP ke $email. Silakan periksa kotak masuk Anda.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _otpController,
                decoration: InputDecoration(
                  labelText: 'Kode OTP 6 Digit',
                  hintText: '123456',
                  counterText: "", // Sembunyikan counter
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.pink, width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submitOtp(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'OTP tidak boleh kosong';
                  }
                  if (value.length != 6) {
                    return 'OTP harus 6 digit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: 'Verifikasi Sekarang',
                onPressed: _submitOtp,
                isLoading:
                    authProvider.isLoading &&
                    !_isCooldownActive, // Hanya loading submit
                fullWidth: true,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: (_isCooldownActive || authProvider.isLoading)
                    ? null // Nonaktifkan jika sedang cooldown ATAU sedang loading submit
                    : _handleResend,
                child: _isCooldownActive
                    ? Text(
                        'Kirim Ulang Kode dalam (${_formatDuration(_cooldownSeconds)})',
                      )
                    : const Text('Kirim Ulang Kode?'),
              ),
              TextButton(
                onPressed: authProvider.isLoading
                    ? null
                    : () => _handleLogout(context),
                style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

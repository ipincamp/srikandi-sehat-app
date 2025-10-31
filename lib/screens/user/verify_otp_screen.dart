import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/widgets/custom_button.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _submitOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final otp = _otpController.text;

    final success = await authProvider.submitOtp(otp, context);

    if (success && mounted) {
      // Jika berhasil, kembali ke halaman profil
      // AuthProvider akan memberitahu halaman profil untuk refresh
      Navigator.of(context).pop();
    }
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
                isLoading: authProvider.isLoading,
                fullWidth: true,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: authProvider.isLoading
                    ? null
                    : () async {
                        // Kirim ulang email
                        await authProvider.resendVerificationEmail(
                          context,
                          showAlert: true,
                        );
                      },
                child: const Text('Kirim Ulang Kode?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

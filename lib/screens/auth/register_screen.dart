import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/auth/notification_service.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/widgets/custom_alert.dart';
import 'package:app/widgets/custom_button.dart';
import 'package:app/widgets/custom_form.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isAggreeToTerms = false;
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isAggreeToTerms) {
      CustomAlert.show(
        context,
        'Anda harus menyetujui Terms of Service dan Privacy Policy terlebih dahulu.',
        type: AlertType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Get FCM Token
      final notificationService = NotificationService();
      final fcmToken = await notificationService.getFCMToken();

      if (fcmToken == null) {
        if (!mounted) return;
        CustomAlert.show(
          context,
          'Tidak bisa mendapatkan token notifikasi. Registrasi dibatalkan.',
          type: AlertType.error,
        );
        setState(() => _isLoading = false);
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;

      // 2. Pass FCM Token to the register method
      final success = await authProvider.register(
        name,
        email,
        password,
        confirmPassword,
        fcmToken,
        context,
      );

      // --- SIMPLIFIED LOGIC ---
      if (success) {
        // Only show a "processing" message.
        // The notification service will handle the final result and navigation.
        if (!mounted) return;
        CustomAlert.show(
          context,
          'Pendaftaran sedang diproses, Anda akan menerima notifikasi jika sudah selesai.',
          type: AlertType.info,
          duration: const Duration(seconds: 4),
        );
        Navigator.pushReplacementNamed(context, '/login');
        // DO NOT NAVIGATE HERE ANYMORE
      } else {
        // Show error from API if the request itself failed (e.g., email already exists)
        if (!mounted) return;
        CustomAlert.show(
          context,
          authProvider.errorMessage,
          type: AlertType.error,
          duration: const Duration(milliseconds: 2000),
        );
      }
    } catch (e) {
      if (!mounted) return;
      CustomAlert.show(
        context,
        'Terjadi kesalahan: ${e.toString()}',
        type: AlertType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'REGISTER',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // const SizedBox(height: 0),
                Image.asset(
                  'assets/images/srikandisehat-logo.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Menjadi remaja sehat dan cerdas,',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    height: 1.2,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.pinkAccent,
                  ),
                ),
                const Text(
                  'dalam memahami menstruasi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    height: 1.2,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.pinkAccent,
                  ),
                ),
                const SizedBox(height: 30),

                // Name Field
                CustomFormField(
                  label: 'Nama Lengkap',
                  placeholder: 'Masukkan nama lengkap',
                  controller: _nameController,
                  type: CustomFormFieldType.text,
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    if (value.trim().length < 2) {
                      return 'Nama minimal 2 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email Field
                CustomFormField(
                  label: 'Email',
                  placeholder: 'email@example.com',
                  controller: _emailController,
                  type: CustomFormFieldType.email,
                  prefixIcon: Icons.email,
                ),
                const SizedBox(height: 16),

                // Password Field
                CustomFormField(
                  label: 'Password',
                  placeholder: 'Masukkan password',
                  controller: _passwordController,
                  type: CustomFormFieldType.password,
                  prefixIcon: Icons.lock,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password Field
                CustomFormField(
                  label: 'Konfirmasi Password',
                  placeholder: 'Ulangi password',
                  controller: _confirmPasswordController,
                  type: CustomFormFieldType.password,
                  prefixIcon: Icons.lock_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konfirmasi password tidak boleh kosong';
                    }
                    if (value != _passwordController.text) {
                      return 'Password tidak cocok';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ✅ Checkbox Persetujuan
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _isAggreeToTerms,
                      activeColor: Colors.pink,
                      onChanged: (value) {
                        setState(() {
                          _isAggreeToTerms = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Wrap(
                        children: [
                          const Text('Saya menyetujui '),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/tos'),
                            child: const Text(
                              'Syarat Ketentuan',
                              style: TextStyle(
                                color: Colors.pink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Text(' dan '),
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/privacy'),
                            child: const Text(
                              'Kebijakan Privasi',
                              style: TextStyle(
                                color: Colors.pink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Register Button
                _isLoading
                    ? const SizedBox(
                        height: 50,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.pink,
                            ),
                          ),
                        ),
                      )
                    : CustomButton(
                        label: 'REGISTER',
                        textSize: 16,
                        fullWidth: true,
                        isFullRounded: true,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        onPressed: _register,
                      ),
                const SizedBox(height: 20),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    GestureDetector(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.pink,
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('Login'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

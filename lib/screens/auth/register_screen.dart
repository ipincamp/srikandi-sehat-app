import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart'; // <-- DIHAPUS
import 'package:provider/provider.dart';
import 'package:app/core/auth/notification_service.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/widgets/custom_alert.dart';
import 'package:app/widgets/custom_button.dart';
import 'package:app/widgets/custom_form.dart';
import 'package:app/widgets/custom_popup.dart';

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
  bool _isGoogleLoading = false;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 📝 [RegisterScreen] Screen initialized');
      debugPrint('└─────────────────────────────────────────');
    }
  }

  @override
  void dispose() {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 📝 [RegisterScreen] Screen disposed');
      debugPrint('└─────────────────────────────────────────');
    }
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 📝 [RegisterScreen] Registration started');
      debugPrint('│ 👤 Name: ${_nameController.text.trim()}');
      debugPrint('│ 📧 Email: ${_emailController.text.trim()}');
    }

    if (!_formKey.currentState!.validate()) {
      if (kDebugMode) {
        debugPrint('│ ❌ Form validation failed');
        debugPrint('└─────────────────────────────────────────');
      }
      return;
    }

    if (!_isAggreeToTerms) {
      if (kDebugMode) {
        debugPrint('│ ❌ Terms not agreed');
        debugPrint('└─────────────────────────────────────────');
      }
      CustomAlert.show(
        context,
        'Anda harus menyetujui Terms of Service dan Privacy Policy terlebih dahulu.',
        type: AlertType.warning,
      );
      return;
    }

    if (kDebugMode) {
      debugPrint('│ ✅ Validation passed');
    }

    setState(() => _isLoading = true);

    try {
      if (kDebugMode) {
        debugPrint('│ 🔔 Getting FCM token...');
      }

      final notificationService = NotificationService();
      final fcmToken = await notificationService.getFCMToken();

      if (fcmToken == null) {
        if (kDebugMode) {
          debugPrint('│ ❌ FCM token is null');
          debugPrint('└─────────────────────────────────────────');
        }
        if (!mounted) return;
        CustomAlert.show(
          context,
          'Tidak bisa mendapatkan token notifikasi. Registrasi dibatalkan.',
          type: AlertType.error,
        );
        setState(() => _isLoading = false);
        return;
      }

      if (kDebugMode) {
        debugPrint('│ ✅ FCM token obtained');
        debugPrint('│ 📡 Calling register provider...');
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;

      final success = await authProvider.register(
        name,
        email,
        password,
        confirmPassword,
        fcmToken,
        context,
      );

      if (success) {
        if (kDebugMode) {
          debugPrint('│ ✅ Registration successful');
          debugPrint('│ 🔄 Navigating to OTP verification');
          debugPrint('└─────────────────────────────────────────');
        }
        if (!mounted) return;
        await CustomConfirmationPopup.show(
          context,
          title: 'Registrasi Berhasil',
          message: authProvider.errorMessage,
          confirmText: 'Mengerti',
          confirmColor: Colors.green,
          icon: Icons.check_circle,
          singleButton: true,
        );
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/verify-otp');
        }
      } else {
        if (kDebugMode) {
          debugPrint('│ ❌ Registration failed');
          debugPrint('│ 💬 Error: ${authProvider.errorMessage}');
          debugPrint('└─────────────────────────────────────────');
        }
        if (!mounted) return;
        CustomAlert.show(
          context,
          authProvider.errorMessage,
          type: AlertType.error,
          duration: const Duration(milliseconds: 2500),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('│ ❌ Exception caught!');
        debugPrint('│ 🔴 Type: ${e.runtimeType}');
        debugPrint('│ 💬 Message: ${e.toString()}');
        debugPrint('└─────────────────────────────────────────');
      }
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

  Future<void> _handleGoogleRegister() async {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 📝 [RegisterScreen] Google register started');
    }

    if (!_isAggreeToTerms) {
      if (kDebugMode) {
        debugPrint('│ ❌ Terms not agreed');
        debugPrint('└─────────────────────────────────────────');
      }
      CustomAlert.show(
        context,
        'Anda harus menyetujui Terms of Service dan Privacy Policy terlebih dahulu.',
        type: AlertType.warning,
      );
      return;
    }

    setState(() => _isGoogleLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.handleGoogleSignIn(context);

    if (success) {
      final role = authProvider.role;

      if (kDebugMode) {
        debugPrint('│ ✅ Google register successful');
        debugPrint('│ 🎭 Role: $role');
      }

      if (!mounted) return;

      CustomAlert.show(
        context,
        'Login Google berhasil!',
        type: AlertType.success,
      );

      await Future.delayed(const Duration(seconds: 1));

      if (role == 'user') {
        if (kDebugMode) {
          debugPrint('│ 🔄 Navigating to user main screen');
          debugPrint('└─────────────────────────────────────────');
        }
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      } else if (role == 'admin') {
        if (kDebugMode) {
          debugPrint('│ 🔄 Navigating to admin screen');
          debugPrint('└─────────────────────────────────────────');
        }
        Navigator.pushNamedAndRemoveUntil(context, '/admin', (route) => false);
      } else {
        if (kDebugMode) {
          debugPrint('│ ❌ Unknown role: $role');
          debugPrint('└─────────────────────────────────────────');
        }
        CustomAlert.show(
          context,
          'Role tidak dikenali: $role',
          type: AlertType.error,
        );
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } else {
      if (kDebugMode) {
        debugPrint('│ ❌ Google register failed');
        debugPrint('│ 💬 Error: ${authProvider.errorMessage}');
        debugPrint('└─────────────────────────────────────────');
      }
    }
    if (mounted) {
      setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoading = authProvider.isLoading || _isGoogleLoading;

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
                CustomFormField(
                  label: 'Email',
                  placeholder: 'email@example.com',
                  controller: _emailController,
                  type: CustomFormFieldType.email,
                  prefixIcon: Icons.email,
                ),
                const SizedBox(height: 16),
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
                        onPressed: isLoading ? null : _register,
                      ),
                const SizedBox(height: 20),
                _buildOrDivider(),
                const SizedBox(height: 20),
                _isGoogleLoading
                    ? const SizedBox(
                        height: 50,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : OutlinedButton.icon(
                        icon: Image.asset(
                          'assets/images/google-logo.png',
                          width: 24,
                          height: 24,
                        ),
                        label: const Text(
                          'Daftar dengan Google',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 0),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        onPressed: isLoading ? null : _handleGoogleRegister,
                      ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    GestureDetector(
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/login',
                                );
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

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'ATAU',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }
}

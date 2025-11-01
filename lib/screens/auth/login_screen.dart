import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart'; // <-- DIHAPUS
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/widgets/custom_alert.dart';
import 'package:app/widgets/custom_button.dart';
import 'package:app/widgets/custom_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final loginProvider = Provider.of<AuthProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      CustomAlert.show(
        context,
        'Email dan password tidak boleh kosong',
        type: AlertType.warning,
      );
      return;
    }

    final success = await loginProvider.login(email, password, context);

    if (success) {
      await loginProvider.updateFcmToken();

      final role = loginProvider.role;
      final isVerified = loginProvider.isEmailVerified;

      if (!mounted) return;

      CustomAlert.show(context, 'Login berhasil!', type: AlertType.success);

      await Future.delayed(const Duration(seconds: 1));

      if (role == 'user' && !isVerified) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/verify-otp',
          (route) => false,
        );
      } else if (role == 'user') {
        await prefs.setBool('showLoginModal', true);
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      } else if (role == 'admin') {
        Navigator.pushNamedAndRemoveUntil(context, '/admin', (route) => false);
      } else {
        CustomAlert.show(
          context,
          'Role tidak dikenali: $role',
          type: AlertType.error,
        );
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } else {
      CustomAlert.show(
        context,
        loginProvider.errorMessage,
        type: AlertType.error,
      );
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isGoogleLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();

    final success = await authProvider.handleGoogleSignIn(context);

    if (success) {
      final role = authProvider.role;
      final isVerified = authProvider.isEmailVerified;

      if (!mounted) return;

      CustomAlert.show(
        context,
        'Login Google berhasil!',
        type: AlertType.success,
      );

      await Future.delayed(const Duration(seconds: 1));

      if (role == 'user' && !isVerified) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/verify-otp',
          (route) => false,
        );
      } else if (role == 'user') {
        await prefs.setBool('showLoginModal', true);
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      } else if (role == 'admin') {
        Navigator.pushNamedAndRemoveUntil(context, '/admin', (route) => false);
      } else {
        CustomAlert.show(
          context,
          'Role tidak dikenali: $role',
          type: AlertType.error,
        );
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
    if (mounted) {
      setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<AuthProvider>(context);
    final isLoading = loginProvider.isLoading || _isGoogleLoading;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'LOGIN',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Image.asset(
                'assets/images/srikandisehat-logo.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 20),
              const Text(
                'Menjadi remaja sehat dan cerdas,',
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1.2,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFFFF4081),
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
              const SizedBox(height: 50),
              CustomFormField(
                label: 'Email',
                placeholder: 'email@example.com',
                controller: _emailController,
                isEmail: true,
              ),
              const SizedBox(height: 16),
              CustomFormField(
                label: 'Password',
                placeholder: 'Masukkan password',
                controller: _passwordController,
                type: CustomFormFieldType.password,
                isPassword: true,
                validatePasswordComplexity: false,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (!isLoading) {
                    _login();
                  }
                },
              ),
              const SizedBox(height: 20),
              loginProvider.isLoading
                  ? const CircularProgressIndicator()
                  : CustomButton(
                      label: 'LOGIN',
                      textSize: 16,
                      fullWidth: true,
                      isFullRounded: true,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      onPressed: isLoading ? null : _login,
                    ),
              const SizedBox(height: 20),
              _buildOrDivider(),
              const SizedBox(height: 20),
              _isGoogleLoading
                  ? const CircularProgressIndicator()
                  : OutlinedButton.icon(
                      icon: Image.asset(
                        // <-- DIGANTI
                        'assets/images/google-logo.png', // <-- DIGANTI
                        width: 24,
                        height: 24,
                      ),
                      label: const Text(
                        'Lanjutkan dengan Google',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        // fullWidth: true,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade300, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      onPressed: isLoading ? null : _handleGoogleLogin,
                    ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Belum punya akun? ',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  GestureDetector(
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.pushReplacementNamed(
                                context,
                                '/register',
                              );
                            },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.pink,
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('Register'),
                    ),
                  ),
                ],
              ),
            ],
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

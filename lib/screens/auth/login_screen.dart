import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikandi_sehat_app/provider/auth_provider.dart';
import 'package:srikandi_sehat_app/widgets/custom_alert.dart';
import 'package:srikandi_sehat_app/widgets/custom_button.dart';
import 'package:srikandi_sehat_app/widgets/custom_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final loginProvider = Provider.of<AuthProvider>(context, listen: false);

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

    final success = await loginProvider.login(email, password);
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');
    await prefs.setBool('showLoginModal', true);

    if (success) {
      if (role == 'admin') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/admin',
          (route) => false,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      }
      CustomAlert.show(
        context,
        'Login berhasil!',
        type: AlertType.success,
      );
    } else {
      CustomAlert.show(
        context,
        loginProvider.errorMessage,
        type: AlertType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<AuthProvider>(context);

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
                    color: Colors.pinkAccent),
              ),
              const Text(
                'dalam memahami menstruasi',
                textAlign: TextAlign.center,
                style: TextStyle(
                    height: 1.2,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.pinkAccent),
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
                      onPressed: _login,
                    ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Belum punya akun? ',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/register');
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
}

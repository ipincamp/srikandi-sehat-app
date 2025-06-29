import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/provider/auth_provider.dart';
import 'package:srikandi_sehat_app/screens/auth/login_screen.dart';
import 'package:srikandi_sehat_app/widgets/custom_alert.dart';
import 'package:srikandi_sehat_app/widgets/custom_button.dart';
import 'package:srikandi_sehat_app/widgets/custom_form.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _register() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      CustomAlert.show(
        context,
        'Wajib mengisi semua field',
        type: AlertType.warning,
      );
      return;
    }

    if (password != confirmPassword) {
      CustomAlert.show(
        context,
        'Password tidak cocok',
        type: AlertType.warning,
      );
      return;
    }

    final success =
        await authProvider.register(name, email, password, confirmPassword);

    if (success) {
      if (!mounted) return;
      CustomAlert.show(
        context,
        'Akun Berhasil dibuat!',
        type: AlertType.success,
      );
      await Future.delayed(const Duration(milliseconds: 750));
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      CustomAlert.show(
        context,
        authProvider.errorMessage,
        type: AlertType.error,
        duration: const Duration(milliseconds: 1500),
      );
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              CircleAvatar(
                radius: 80,
                backgroundColor: Colors.pink[100],
                child: Icon(Icons.bloodtype_sharp,
                    size: 56, color: Colors.pink[400]),
              ),
              const SizedBox(height: 20),
              CustomFormField(
                label: 'Nama',
                placeholder: 'Masukkan nama lengkap',
                controller: _nameController,
              ),
              const SizedBox(height: 16),
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
                isPassword: true,
              ),
              const SizedBox(height: 16),
              CustomFormField(
                label: 'Konfirmasi Password',
                placeholder: 'Ulangi password',
                controller: _confirmPasswordController,
                isPassword: true,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : CustomButton(
                      label: 'REGISTER',
                      textSize: 16,
                      fullWidth: true,
                      isFullRounded: true,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      onPressed: _register,
                    ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Sudah punya akun? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

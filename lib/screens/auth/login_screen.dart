import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

    if (success) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/main',
        (route) => false, // Menghapus semua route sebelumnya
      ); // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const MainScreen()),
      // );
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
              CircleAvatar(
                radius: 80,
                backgroundColor: Colors.pink[100],
                child: Icon(Icons.bloodtype_sharp,
                    size: 56, color: Colors.pink[400]),
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
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/register');
                },
                child: const Text('Belum punya akun? Daftar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/provider/user_provider.dart';
import 'package:srikandi_sehat_app/widgets/custom_alert.dart';
import 'package:srikandi_sehat_app/widgets/custom_button.dart';
import 'package:srikandi_sehat_app/widgets/custom_form.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _submitChange() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final oldPass = _oldPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      CustomAlert.show(context, 'Semua field wajib diisi',
          type: AlertType.warning);
      return;
    }

    if (newPass != confirmPass) {
      CustomAlert.show(context, 'Konfirmasi password tidak cocok',
          type: AlertType.error);
      return;
    }

    setState(() => _isLoading = true);
    final success =
        await userProvider.changePassword(oldPass, newPass, confirmPass);

    setState(() => _isLoading = false);

    if (success) {
      if (!mounted) return;
      CustomAlert.show(
          context, 'Password berhasil diubah, Silakan login kembali',
          type: AlertType.success);
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      await Future.delayed(const Duration(milliseconds: 4000));
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    } else {
      CustomAlert.show(context, userProvider.errorMessage,
          type: AlertType.error);
    }
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Password'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomFormField(
              label: 'Password Lama',
              placeholder: 'Masukkan password lama',
              controller: _oldPasswordController,
              isPassword: true,
            ),
            const SizedBox(height: 16),
            CustomFormField(
              label: 'Password Baru',
              placeholder: 'Masukkan password baru',
              controller: _newPasswordController,
              isPassword: true,
            ),
            const SizedBox(height: 16),
            CustomFormField(
              label: 'Konfirmasi Password Baru',
              placeholder: 'Ulangi password baru',
              controller: _confirmPasswordController,
              isPassword: true,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : CustomButton(
                    label: 'Simpan Perubahan',
                    onPressed: _submitChange,
                    fullWidth: true,
                    isFullRounded: true,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
          ],
        ),
      ),
    );
  }
}

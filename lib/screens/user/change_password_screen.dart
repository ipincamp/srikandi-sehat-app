import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikandi_sehat_app/provider/password_provider.dart';
import 'package:srikandi_sehat_app/widgets/custom_alert.dart';
import 'package:srikandi_sehat_app/widgets/custom_button.dart';
import 'package:srikandi_sehat_app/widgets/custom_form.dart';
import 'package:srikandi_sehat_app/widgets/custom_popup.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _submitChange() async {
    // Validate form first
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userProvider = Provider.of<PasswordProvider>(context, listen: false);

    final oldPass = _oldPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (newPass != confirmPass) {
      CustomAlert.show(
        context,
        'Konfirmasi password tidak cocok',
        type: AlertType.error,
      );
      return;
    }

    setState(() => _isLoading = true);
    final success = await userProvider.changePassword(
      oldPass,
      newPass,
      confirmPass,
    );

    setState(() => _isLoading = false);

    if (success) {
      if (!mounted) return;

      final confirmed = await CustomConfirmationPopup.show(
        context,
        title: 'Password Berhasil Diubah',
        message: 'Anda harus login ulang untuk melanjutkan.',
        icon: Icons.lock_reset,
        confirmColor: Colors.green,
        confirmText: 'Ya',
        singleButton: true, // ← Tambahkan ini
      );

      if (confirmed == true && mounted) {
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        final prefs = await SharedPreferences.getInstance();
        await prefs.clear(); // ← tambahkan ini

        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      CustomAlert.show(
        context,
        userProvider.errorMessage,
        type: AlertType.error,
      );
    }
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != _newPasswordController.text) {
      return 'Konfirmasi password tidak cocok';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password baru tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
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
      appBar: AppBar(title: const Text('Ubah Password'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomFormField(
                label: 'Password Lama',
                placeholder: 'Masukkan password lama',
                controller: _oldPasswordController,
                type: CustomFormFieldType.password,
              ),
              const SizedBox(height: 16),
              CustomFormField(
                label: 'Password Baru',
                placeholder: 'Masukkan password baru',
                controller: _newPasswordController,
                type: CustomFormFieldType.password,
                validator: _validateNewPassword,
              ),
              const SizedBox(height: 16),
              CustomFormField(
                label: 'Konfirmasi Password Baru',
                placeholder: 'Ulangi password baru',
                controller: _confirmPasswordController,
                type: CustomFormFieldType.password,
                validator: _validateConfirmPassword,
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
      ),
    );
  }
}

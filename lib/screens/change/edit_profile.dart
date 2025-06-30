import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/provider/user_provider.dart';
import 'package:srikandi_sehat_app/widgets/custom_alert.dart';
import 'package:srikandi_sehat_app/widgets/custom_button.dart';
import 'package:srikandi_sehat_app/widgets/custom_form.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _nameController.text = userProvider.name ?? '';
    _emailController.text = userProvider.email ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final success = await userProvider.updateProfile(
      _nameController.text,
      _emailController.text,
      _addressController.text,
      _phoneController.text,
      _dobController.text,
      _heightController.text,
      _weightController.text,
    );

    setState(() => _isLoading = false);

    if (success) {
      if (!mounted) return;
      CustomAlert.show(context, 'Profil berhasil diperbarui',
          type: AlertType.success);
      Navigator.pop(context);
    } else {
      CustomAlert.show(context, userProvider.errorMessage,
          type: AlertType.error);
    }
  }

  Future<bool> _confirmCancel() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Batalkan Perubahan?'),
            content:
                const Text('Apakah Anda yakin ingin membatalkan perubahan?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Tidak'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Ya'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final cancel = await _confirmCancel();
        return cancel;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profil'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final cancel = await _confirmCancel();
              if (cancel && mounted) Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CustomFormField(
                    label: 'Nama',
                    controller: _nameController,
                    placeholder: '',
                  ),
                  const SizedBox(height: 16),
                  CustomFormField(
                    placeholder: 'Masukkan email',
                    label: 'Email',
                    controller: _emailController,
                    isEmail: true,
                  ),
                  const SizedBox(height: 16),
                  CustomFormField(
                    placeholder: 'Masukkan alamat',
                    label: 'Alamat',
                    controller: _addressController,
                  ),
                  const SizedBox(height: 16),
                  CustomFormField(
                    placeholder: 'Masukkan No. HP',
                    label: 'No. HP',
                    controller: _phoneController,
                  ),
                  const SizedBox(height: 16),
                  CustomFormField(
                      placeholder: 'DD/MM/YYYY',
                      label: 'Tanggal Lahir',
                      controller: _dobController),
                  const SizedBox(height: 16),
                  CustomFormField(
                      placeholder: 'Masukkan tinggi badan',
                      label: 'Tinggi Badan (cm)',
                      controller: _heightController),
                  const SizedBox(height: 16),
                  CustomFormField(
                    placeholder: 'Masukkan berat badan',
                    label: 'Berat Badan (kg)',
                    controller: _weightController,
                  ),
                  const SizedBox(height: 32),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                label: 'Simpan',
                                onPressed: _saveProfile,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomButton(
                                label: 'Batal',
                                backgroundColor:
                                    Colors.grey[300] ?? Colors.grey,
                                textColor: Colors.black,
                                onPressed: () async {
                                  final cancel = await _confirmCancel();
                                  if (cancel && mounted) Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

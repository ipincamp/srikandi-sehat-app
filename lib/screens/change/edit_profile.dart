import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/provider/user_provider.dart';
import 'package:srikandi_sehat_app/widgets/custom_alert.dart';
import 'package:srikandi_sehat_app/widgets/custom_button.dart';
import 'package:srikandi_sehat_app/widgets/custom_form.dart';
import 'package:srikandi_sehat_app/widgets/custom_popup.dart';

// ... import tetap sama

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _provinceController = TextEditingController();
  final _districtController = TextEditingController();
  final _subDistrictController = TextEditingController();
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
    _phoneController.dispose();
    _provinceController.dispose();
    _districtController.dispose();
    _subDistrictController.dispose();
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
      '', // alamat tidak dipakai lagi
      _phoneController.text,
      _dobController.text,
      _heightController.text,
      _weightController.text,
      province: _provinceController.text,
      district: _districtController.text,
      subDistrict: _subDistrictController.text,
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

  Future<bool> _showLogoutConfirmation() async {
    return await CustomConfirmationPopup.show(
          context,
          title: 'Konfirmasi Batal',
          message: 'Apakah Anda yakin ingin membatalkan pengeditan?',
          confirmText: 'Ya',
          cancelText: 'Batal',
          icon: Icons.cancel,
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => await _showLogoutConfirmation(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final cancel = await _showLogoutConfirmation();
              if (cancel && mounted) Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Info
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
                    placeholder: 'Masukkan No. HP',
                    label: 'No. HP',
                    controller: _phoneController,
                    type: CustomFormFieldType.number,
                  ),
                  const SizedBox(height: 32),

                  // User Address
                  const Text(
                    'User Address',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomFormField(
                    label: 'Province',
                    controller: _provinceController,
                    type: CustomFormFieldType.dropdown,
                    items: const [
                      'Jawa Barat',
                      'DKI Jakarta',
                      'Sumatera Utara'
                    ],
                    placeholder: '',
                  ),
                  const SizedBox(height: 16),
                  CustomFormField(
                    label: 'District',
                    controller: _districtController,
                    type: CustomFormFieldType.dropdown,
                    items: const ['Kota Bandung', 'Kab. Bekasi', 'Medan'],
                    placeholder: '',
                  ),
                  const SizedBox(height: 16),
                  CustomFormField(
                    label: 'Sub District',
                    controller: _subDistrictController,
                    type: CustomFormFieldType.dropdown,
                    items: const ['Cicendo', 'Tambun', 'Medan Johor'],
                    placeholder: '',
                  ),
                  const SizedBox(height: 32),

                  // Personal Info
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomFormField(
                    placeholder: 'DD/MM/YYYY',
                    label: 'Tanggal Lahir',
                    type: CustomFormFieldType.date,
                    controller: _dobController,
                  ),
                  const SizedBox(height: 16),
                  CustomFormField(
                    placeholder: 'Masukkan tinggi badan',
                    label: 'Tinggi Badan (cm)',
                    controller: _heightController,
                    type: CustomFormFieldType.number,
                  ),
                  const SizedBox(height: 16),
                  CustomFormField(
                    placeholder: 'Masukkan berat badan',
                    label: 'Berat Badan (kg)',
                    controller: _weightController,
                    type: CustomFormFieldType.number,
                  ),
                  const SizedBox(height: 32),

                  // Buttons
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                label: 'Batal',
                                backgroundColor:
                                    Colors.grey[300] ?? Colors.grey,
                                textColor: Colors.black,
                                onPressed: () async {
                                  final cancel =
                                      await _showLogoutConfirmation();
                                  if (cancel && mounted) Navigator.pop(context);
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomButton(
                                label: 'Simpan',
                                onPressed: _saveProfile,
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

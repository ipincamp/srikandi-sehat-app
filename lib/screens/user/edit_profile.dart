import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/models/village_model.dart';
import 'package:srikandi_sehat_app/provider/profile_change_provider.dart';
import 'package:srikandi_sehat_app/provider/district_provider.dart';
import 'package:srikandi_sehat_app/provider/user_profile_provider.dart';
import 'package:srikandi_sehat_app/provider/village_provider.dart';
import 'package:srikandi_sehat_app/utils/string_extentions.dart';
import 'package:srikandi_sehat_app/widgets/custom_alert.dart';
import 'package:srikandi_sehat_app/widgets/custom_button.dart';
import 'package:srikandi_sehat_app/widgets/custom_form.dart' hide DropdownItem;
import 'package:srikandi_sehat_app/widgets/custom_popup.dart';
import 'package:srikandi_sehat_app/utils/user_calc.dart';
import 'package:srikandi_sehat_app/widgets/searchable_dropdown_field.dart';
import 'package:srikandi_sehat_app/widgets/title_section_divider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Ganti semua deklarasi controller Anda dengan ini
  final _formKey = GlobalKey<FormState>();

// Controllers for all form fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _districtController = TextEditingController();
  final _villageController = TextEditingController();
  final _dobController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _eduNowController = TextEditingController();
  final _eduParentController = TextEditingController();
  final _internetAccessController = TextEditingController();
  final _firstHaidController = TextEditingController();
  final _jobParentController = TextEditingController();

// Controllers for derived fields
  final _ageController = TextEditingController();
  final _imtController = TextEditingController();
  final _villageClassificationController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Panggil fetchDistricts dan loadInitialData
      context.read<DistrictProvider>().fetchDistricts();
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final userProfileProvider = context.read<UserProfileProvider>();
    final profileChangeProvider = context.read<ProfileChangeProvider>();
    // Sekarang semua data ada di UserProfileProvider
    _nameController.text = userProfileProvider.name ?? '';
    _emailController.text = userProfileProvider.email ?? '';
    _phoneController.text = profileChangeProvider.phone ?? '';
    _dobController.text = profileChangeProvider.dob ?? '';
    _heightController.text = profileChangeProvider.height?.toString() ?? '';
    _weightController.text = profileChangeProvider.weight?.toString() ?? '';
    _districtController.text = profileChangeProvider.districtCode ?? '';
    _villageController.text = profileChangeProvider.villageCode ?? '';
    _eduNowController.text = profileChangeProvider.eduNow ?? '';
    _eduParentController.text = profileChangeProvider.eduParent ?? '';
    _internetAccessController.text = profileChangeProvider.internetAccess ?? '';
    _firstHaidController.text = profileChangeProvider.firstHaid ?? '';
    _jobParentController.text = profileChangeProvider.jobParent ?? '';

    if (_districtController.text.isNotEmpty) {
      context.read<VillageProvider>().fetchVillages(_districtController.text);
    }

    if (_dobController.text.isNotEmpty) _onDOBChanged();
    if (_heightController.text.isNotEmpty &&
        _weightController.text.isNotEmpty) {
      _onHeightWeightChanged();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _districtController.dispose();
    _villageController.dispose();
    _villageClassificationController.dispose();

    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _eduNowController.dispose();
    _eduParentController.dispose();
    _internetAccessController.dispose();
    _firstHaidController.dispose();
    _jobParentController.dispose();
    _ageController.dispose();
    _imtController.dispose();
    super.dispose();
  }

  void _handleDistrictChanged(String? value) {
    _onDistrictChanged(value);
  }

  // void _handleVillageChanged(String? value) {
  //   _onVillageChanged(value);
  // }

  /// Handler saat kecamatan dipilih
  Future<void> _onDistrictChanged(String? value) async {
    if (value == null || value.isEmpty) return;

    _districtController.text = value;
    _villageController.clear();
    _villageClassificationController.clear();

    final villageProvider = context.read<VillageProvider>();
    await villageProvider.fetchVillages(value);

    // Jika user sudah pernah memilih desa sebelumnya, update classification-nya
    final selectedVillage =
        villageProvider.villages.cast<Village?>().firstWhere(
              (v) => v?.code == _villageController.text,
              orElse: () => null,
            );

    if (selectedVillage != null) {
      _villageClassificationController.text =
          selectedVillage.classification.capitalizeWords();
    }
  }

  /// Handler saat desa dipilih
  void _onVillageChanged(String? value) {
    _villageController.text = value ?? '';

    final villages = context.read<VillageProvider>().villages;
    final village = villages.cast<Village?>().firstWhere(
          (v) => v?.code == value,
          orElse: () => null,
        );

    if (village != null) {
      _villageClassificationController.text =
          village.classification.capitalizeWords(); // "Desa" atau "Kota"
    } else {
      _villageClassificationController.clear();
    }
  }

  void _onHeightWeightChanged() {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);
    if (height != null && weight != null && height > 0) {
      final imtValue = calculateIMT(height, weight);
      if (imtValue == null) return;
      final category = getIMTCategory(imtValue);
      _imtController.text = '${imtValue.toStringAsFixed(1)} ($category)';
    } else {
      _imtController.text = '-';
    }
  }

  void _onDOBChanged() {
    final age = calculateAgeFromString(_dobController.text);
    _ageController.text = age != null ? '$age tahun' : '-';
  }

  String _formatDateForAPI(String date) {
    if (date.isEmpty || !date.contains('/')) return '';
    try {
      final parts = date.split('/');
      return '${parts[2]}-${parts[1]}-${parts[0]}'; // YYYY-MM-DD
    } catch (e) {
      return '';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Sesuaikan dengan nama provider yang benar untuk update profil
    final profileProvider = context.read<UserProfileProvider>();
    final Map<String, dynamic> payload = {
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'address': _villageController.text,
      'birthdate': _formatDateForAPI(_dobController.text),
      'tb_cm': int.tryParse(_heightController.text) ?? 0,
      'bb_kg': double.tryParse(_weightController.text) ?? 0,
      'edu_now': _eduNowController.text,
      'edu_parent': _eduParentController.text,
      'inet_access': _internetAccessController.text,
      'first_haid': _firstHaidController.text,
      'job_parent': _jobParentController.text,
    };

    // --- TAMBAHKAN BLOK INI UNTUK DEBUGGING ---
    // Untuk mencetak JSON dengan format yang rapi (pretty print)
    const jsonEncoder = JsonEncoder.withIndent('  ');
    final prettyJson = jsonEncoder.convert(payload);
    debugPrint("✅ Payload yang akan dikirim:\n$prettyJson");
    // ------------------------------------------

    // Gunakan arsitektur provider yang sudah dipisah
    final profileChangeProvider = context.read<ProfileChangeProvider>();
    final success = await profileChangeProvider.getProfile(payload);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // Panggil getProfile dari UserProfileProvider untuk refresh data di seluruh app
      await context.read<UserProfileProvider>().getProfile();
      if (mounted) {
        CustomAlert.show(context, 'Profil berhasil diperbarui',
            type: AlertType.success);
        Navigator.pop(context);
      }
    } else {
      // CustomAlert.show(context, profileProvider.errorMessage,
      //     type: AlertType.error);
      print(profileProvider.errorMessage);
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
    final districtProvider = Provider.of<DistrictProvider>(context);
    final districtItems = districtProvider.districts
        .map(
            (e) => DropdownItem(value: e.code, label: e.name.capitalizeWords()))
        .toList();

    final villageItems = context
        .watch<VillageProvider>()
        .villages
        .map(
            (v) => DropdownItem(value: v.code, label: v.name.capitalizeWords()))
        .toList();
    const educationList = [
      'Tidak Sekolah',
      'SD/MI',
      'SMP/MTs',
      'SMA/MA',
      'D1/D2/D3',
      'S1/S2/S3'
    ];
    // ignore: deprecated_member_use
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
                    enabled: false,
                  ),
                  const SizedBox(height: 16),
                  CustomFormField(
                    placeholder: 'Masukkan email',
                    label: 'Email',
                    controller: _emailController,
                    isEmail: true,
                    enabled: false,
                  ),
                  const SizedBox(height: 16),
                  CustomFormField(
                    placeholder: 'Contoh : 08123456789',
                    label: 'No. HP',
                    controller: _phoneController,
                    type: CustomFormFieldType.number,
                  ),
                  const SectionDivider(
                    title: 'Alamat Domisili',
                    topSpacing: 24,
                    bottomSpacing: 20,
                    textSize: 18,
                    textColor: Colors.black,
                    lineColor: Color.fromARGB(255, 255, 161, 192),
                  ),
                  const SizedBox(height: 16),
                  SearchableDropdownField(
                    label: 'Kecamatan',
                    placeholder: 'Pilih kecamatan',
                    controller: _districtController,
                    items: districtItems,
                    onChanged: _handleDistrictChanged,
                  ),
                  const SizedBox(height: 16),
                  SearchableDropdownField(
                    label: 'Desa/Kelurahan',
                    placeholder: 'Pilih desa atau kelurahan',
                    controller: _villageController,
                    items: villageItems,
                    onChanged: _onVillageChanged,
                    enabled: _districtController.text.isNotEmpty,
                  ),
                  const SizedBox(height: 16),
                  CustomFormField(
                    label: 'Klasifikasi Wilayah',
                    controller: _villageClassificationController,
                    enabled: false,
                    placeholder: '-',
                  ),

                  const SectionDivider(
                    title: 'Informasi Pribadi',
                    topSpacing: 24,
                    bottomSpacing: 20,
                    textSize: 18,
                    textColor: Colors.black,
                    lineColor: Color.fromARGB(255, 255, 161, 192),
                  ),
                  CustomFormField(
                    placeholder: 'Hari-Bulan-Tahun',
                    label: 'Tanggal Lahir',
                    type: CustomFormFieldType.date,
                    controller: _dobController,
                    onChanged: (_) => _onDOBChanged(),
                  ),
                  const SizedBox(height: 16),
                  CustomFormField(
                    placeholder: 'Masukkan tinggi badan',
                    label: 'Tinggi Badan (cm)',
                    controller: _heightController,
                    type: CustomFormFieldType.number,
                    onChanged: (_) => _onHeightWeightChanged(),
                  ),
                  const SizedBox(height: 16),
                  CustomFormField(
                    placeholder: 'Masukkan berat badan',
                    label: 'Berat Badan (kg)',
                    controller: _weightController,
                    type: CustomFormFieldType.number,
                    onChanged: (_) => _onHeightWeightChanged(),
                  ),
                  const SizedBox(height: 16),
                  // if (_imt.isNotEmpty)
                  CustomFormField(
                    label: 'IMT',
                    controller: _imtController,
                    enabled: false,
                    placeholder: '-',
                  ),

                  const SizedBox(height: 16),

                  CustomFormField(
                    placeholder: 'Masukkan umur pertama haid',
                    label: 'Umur Pertama Haid',
                    type: CustomFormFieldType.number,
                    controller: _firstHaidController,
                    minValue: 9,
                    maxValue: 30,
                  ),
                  const SizedBox(height: 16),

                  CustomFormField(
                      placeholder: 'Pilih Pendidikan Sekarang',
                      label: 'Pendidikan Sekarang',
                      controller: _eduNowController,
                      type: CustomFormFieldType.dropdown,
                      items: educationList),
                  const SizedBox(height: 16),

                  CustomFormField(
                    placeholder: 'Pilih akses internet',
                    label: 'Akses Internet',
                    controller: _internetAccessController,
                    type: CustomFormFieldType.dropdown,
                    items: const [
                      'Jaringan Selular',
                      'Jaringan Wifi',
                    ],
                  ),
                  const SectionDivider(
                    title: 'Data Orang Tua',
                    topSpacing: 24,
                    bottomSpacing: 20,
                    textSize: 18,
                    textColor: Colors.black,
                    lineColor: Color.fromARGB(255, 255, 161, 192),
                  ),

                  CustomFormField(
                    placeholder: 'Pilih Pendidikan Orang Tua',
                    label: 'Riwayat Pendidikan Orang Tua',
                    controller: _eduParentController,
                    type: CustomFormFieldType.dropdown,
                    items: educationList,
                  ),
                  const SizedBox(height: 16),
                  CustomFormField(
                    placeholder: 'Pekerjaan Orang Tua',
                    label: 'Pekerjaan Orang Tua',
                    controller: _jobParentController,
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
                  const SizedBox(width: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

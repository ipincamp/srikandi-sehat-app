import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/models/district_model.dart';
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
  final _formKey = GlobalKey<FormState>();

  // Controllers
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

  // Derived fields
  final _ageController = TextEditingController();
  final _imtController = TextEditingController();
  final _villageClassificationController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DistrictProvider>().fetchDistricts();
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final userProfileProvider = context.read<UserProfileProvider>();
    final profileChangeProvider = context.read<ProfileChangeProvider>();

    _nameController.text = userProfileProvider.name ?? '';
    _emailController.text = userProfileProvider.email ?? '';
    _phoneController.text = profileChangeProvider.phone ?? '';
    _dobController.text = profileChangeProvider.dob ?? '';
    _heightController.text = profileChangeProvider.height?.toString() ?? '';
    _weightController.text = profileChangeProvider.weight?.toString() ?? '';
    _districtController.text = profileChangeProvider.districtName ?? '';
    _villageController.text = profileChangeProvider.villageName ?? '';
    _eduNowController.text = profileChangeProvider.eduNow ?? '';
    _eduParentController.text = profileChangeProvider.eduParent ?? '';
    _internetAccessController.text = profileChangeProvider.internetAccess ?? '';
    _firstHaidController.text = profileChangeProvider.firstHaid ?? '';
    _jobParentController.text = profileChangeProvider.jobParent ?? '';

    if (profileChangeProvider.districtCode != null) {
      context
          .read<VillageProvider>()
          .fetchVillages(profileChangeProvider.districtCode!);
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

  Future<void> _onDistrictChanged(String? districtCode) async {
    if (districtCode == null || districtCode.isEmpty) return;

    final districtProvider = context.read<DistrictProvider>();
    final selectedDistrict = districtProvider.districts.firstWhere(
      (d) => d.code == districtCode,
      orElse: () => District(code: '', name: ''),
    );

    _districtController.text = selectedDistrict.name;
    _villageController.clear();
    _villageClassificationController.clear();

    final villageProvider = context.read<VillageProvider>();
    await villageProvider.fetchVillages(districtCode);

    // Update profile change provider
    context.read<ProfileChangeProvider>().setDistrictCode(districtCode);
    context
        .read<ProfileChangeProvider>()
        .setDistrictName(selectedDistrict.name);
  }

  void _onVillageChanged(String? villageCode) {
    if (villageCode == null || villageCode.isEmpty) return;

    final villageProvider = context.read<VillageProvider>();
    final selectedVillage = villageProvider.villages.firstWhere(
      (v) => v.code == villageCode,
      orElse: () => Village(code: '', name: '', classification: ''),
    );

    _villageController.text = selectedVillage.name;
    _villageClassificationController.text =
        selectedVillage.classification.capitalizeWords();

    // Update profile change provider
    context.read<ProfileChangeProvider>().setVillageCode(villageCode);
    context.read<ProfileChangeProvider>().setVillageName(selectedVillage.name);
  }

  void _onHeightWeightChanged() {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);

    if (height != null && weight != null && height > 0) {
      final imtValue = calculateBMI(height, weight);
      if (imtValue == null) return;
      final category = classifyBMI(imtValue);
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
      return '${parts[2]}-${parts[1]}-${parts[0]}';
    } catch (e) {
      return '';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final profileChangeProvider = context.read<ProfileChangeProvider>();
    final Map<String, dynamic> payload = {
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'address': profileChangeProvider.villageCode ?? '',
      'birthdate': _formatDateForAPI(_dobController.text),
      'tb_cm': int.tryParse(_heightController.text) ?? 0,
      'bb_kg': double.tryParse(_weightController.text) ?? 0,
      'edu_now': _eduNowController.text,
      'edu_parent': _eduParentController.text,
      'inet_access': _internetAccessController.text,
      'first_haid': _firstHaidController.text,
      'job_parent': _jobParentController.text,
      // 'district': profileChangeProvider.districtCode ?? '', >>> NOT USED
    };

    final bool isSuccess = await profileChangeProvider.updateProfile(payload);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (isSuccess) {
      await context
          .read<UserProfileProvider>()
          .loadProfile(context, forceRefresh: true);
      if (mounted) {
        CustomAlert.show(
          context,
          'Profil berhasil diperbarui',
          type: AlertType.success,
        );
        Navigator.pushReplacementNamed(context, '/detail-profile');
      }
    } else {
      if (mounted) {
        CustomAlert.show(
          context,
          'Gagal memperbarui profil: ${profileChangeProvider.errorMessage}',
          type: AlertType.error,
        );
      }
    }
  }

  Future<bool> _showCancelConfirmation() async {
    return await CustomConfirmationPopup.show(
          context,
          title: 'Konfirmasi Batal',
          message: 'Apakah Anda yakin ingin membatalkan pengeditan?',
          confirmText: 'Ya',
          cancelText: 'Tidak',
          icon: Icons.warning,
          confirmColor: Colors.pink,
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final districtProvider = context.watch<DistrictProvider>();
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

    return WillPopScope(
      onWillPop: () async {
        final shouldCancel = await _showCancelConfirmation();
        if (shouldCancel && mounted) Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.pink,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              final shouldCancel = await _showCancelConfirmation();
              if (shouldCancel && mounted) Navigator.pop(context);
            },
          ),
          elevation: 0,
        ),
        body: Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Info Section
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            CustomFormField(
                              label: 'Nama',
                              controller: _nameController,
                              placeholder: '',
                              enabled: true,
                              prefixIcon: Icons.person,
                            ),
                            const SizedBox(height: 16),
                            CustomFormField(
                              label: 'Email',
                              controller: _emailController,
                              placeholder: 'Masukkan email',
                              isEmail: true,
                              enabled: false,
                              prefixIcon: Icons.email,
                            ),
                            const SizedBox(height: 16),
                            CustomFormField(
                              label: 'No. HP',
                              controller: _phoneController,
                              placeholder: 'Contoh: 08123456789',
                              type: CustomFormFieldType.number,
                              prefixIcon: Icons.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nomor HP tidak boleh kosong';
                                }
                                if (value.length < 11) {
                                  return 'Nomor HP minimal 11 digit';
                                }
                                if (value.length > 15) {
                                  return 'Nomor HP maksimal 15 digit';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Address Section
                    const SectionDivider(
                      title: 'Alamat Domisili',
                      topSpacing: 24,
                      bottomSpacing: 16,
                      textSize: 18,
                      textColor: Colors.black87,
                      lineColor: Colors.pink,
                    ),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            SearchableDropdownField(
                              label: 'Kecamatan',
                              placeholder: 'Pilih kecamatan',
                              controller: _districtController,
                              items: districtItems,
                              onChanged: _onDistrictChanged,
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
                              prefixIcon: Icons.location_city,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Personal Info Section
                    const SectionDivider(
                      title: 'Informasi Pribadi',
                      topSpacing: 24,
                      bottomSpacing: 16,
                      textSize: 18,
                      textColor: Colors.black87,
                      lineColor: Colors.pink,
                    ),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            CustomFormField(
                              label: 'Tanggal Lahir',
                              placeholder: 'Hari-Bulan-Tahun',
                              type: CustomFormFieldType.date,
                              controller: _dobController,
                              onChanged: (_) => _onDOBChanged(),
                              prefixIcon: Icons.calendar_today,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomFormField(
                                    label: 'Tinggi Badan (cm)',
                                    placeholder: 'Masukkan tinggi badan',
                                    controller: _heightController,
                                    type: CustomFormFieldType.number,
                                    onChanged: (_) => _onHeightWeightChanged(),
                                    prefixIcon: Icons.height,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: CustomFormField(
                                    label: 'Berat Badan (kg)',
                                    placeholder: 'Masukkan berat badan',
                                    controller: _weightController,
                                    type: CustomFormFieldType.number,
                                    onChanged: (_) => _onHeightWeightChanged(),
                                    prefixIcon: Icons.monitor_weight,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            CustomFormField(
                              label: 'IMT',
                              controller: _imtController,
                              enabled: false,
                              placeholder: '-',
                              prefixIcon: Icons.calculate,
                            ),
                            const SizedBox(height: 16),
                            CustomFormField(
                              label: 'Umur Pertama Haid',
                              placeholder: 'Masukkan umur pertama haid',
                              type: CustomFormFieldType.number,
                              controller: _firstHaidController,
                              minValue: 9,
                              maxValue: 30,
                              prefixIcon: Icons.female,
                            ),
                            const SizedBox(height: 16),
                            CustomFormField(
                              label: 'Pendidikan Sekarang',
                              placeholder: 'Pilih Pendidikan Sekarang',
                              controller: _eduNowController,
                              type: CustomFormFieldType.dropdown,
                              items: educationList,
                              prefixIcon: Icons.school,
                            ),
                            const SizedBox(height: 16),
                            CustomFormField(
                              label: 'Akses Internet',
                              placeholder: 'Pilih akses internet',
                              controller: _internetAccessController,
                              type: CustomFormFieldType.dropdown,
                              items: const ['wifi', 'seluler'],
                              prefixIcon: Icons.wifi,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Parent Data Section
                    const SectionDivider(
                      title: 'Data Orang Tua',
                      topSpacing: 24,
                      bottomSpacing: 16,
                      textSize: 18,
                      textColor: Colors.black87,
                      lineColor: Colors.pink,
                    ),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            CustomFormField(
                              label: 'Riwayat Pendidikan Orang Tua',
                              placeholder: 'Pilih Pendidikan Orang Tua',
                              controller: _eduParentController,
                              type: CustomFormFieldType.dropdown,
                              items: educationList,
                              prefixIcon: Icons.school,
                            ),
                            const SizedBox(height: 16),
                            CustomFormField(
                              label: 'Pekerjaan Orang Tua',
                              placeholder: 'Pekerjaan Orang Tua',
                              controller: _jobParentController,
                              prefixIcon: Icons.work,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Action Buttons
                    const SizedBox(height: 32),
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.pink),
                            ),
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  label: 'Batal',
                                  backgroundColor: Colors.grey[300]!,
                                  textColor: Colors.black,
                                  onPressed: () async {
                                    final shouldCancel =
                                        await _showCancelConfirmation();
                                    if (shouldCancel && mounted)
                                      Navigator.pop(context);
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomButton(
                                  label: 'Simpan',
                                  backgroundColor: Colors.pink,
                                  textColor: Colors.white,
                                  onPressed: _saveProfile,
                                ),
                              ),
                            ],
                          ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

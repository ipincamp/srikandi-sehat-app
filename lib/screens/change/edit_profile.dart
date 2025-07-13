import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/provider/user_provider.dart';
import 'package:srikandi_sehat_app/provider/district_provider.dart';
import 'package:srikandi_sehat_app/provider/village_provider.dart';
import 'package:srikandi_sehat_app/widgets/custom_alert.dart';
import 'package:srikandi_sehat_app/widgets/custom_button.dart';
import 'package:srikandi_sehat_app/widgets/custom_form.dart' hide DropdownItem;
import 'package:srikandi_sehat_app/widgets/custom_popup.dart';
import 'package:srikandi_sehat_app/utils/user_calc.dart';
import 'package:srikandi_sehat_app/widgets/searchable_dropdown_field.dart';

// ... import tetap sama

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String _imt = '';
  String _imtCategory = '';

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
    final userProvider = context.read<UserProvider>();

    // Sekarang semua data ada di UserProvider
    _nameController.text = userProvider.name ?? '';
    _emailController.text = userProvider.email ?? '';
    _phoneController.text = userProvider.phone ?? '';
    _dobController.text = userProvider.dob ?? '';
    _heightController.text = userProvider.height?.toString() ?? '';
    _weightController.text = userProvider.weight?.toString() ?? '';
    _districtController.text = userProvider.districtCode ?? '';
    _villageController.text = userProvider.villageCode ?? '';
    _eduNowController.text = userProvider.eduNow ?? '';
    _eduParentController.text = userProvider.eduParent ?? '';
    _internetAccessController.text = userProvider.internetAccess ?? '';
    _firstHaidController.text = userProvider.firstHaid ?? '';
    _jobParentController.text = userProvider.jobParent ?? '';

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
    // Seharusnya ProfileProvider, bukan UserProvider untuk update
    final profileProvider = context.read<UserProvider>();
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
      'first_haid': _formatDateForAPI(_firstHaidController.text),
      'job_parent': _jobParentController.text,
    };

    // Gunakan arsitektur provider yang sudah dipisah
    final success = await profileProvider.updateProfile(payload);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // Panggil getProfile dari UserProvider untuk refresh data di seluruh app
      await context.read<UserProvider>().updateProfile(payload);
      if (mounted) {
        CustomAlert.show(context, 'Profil berhasil diperbarui',
            type: AlertType.success);
        Navigator.pop(context);
      }
    } else {
      CustomAlert.show(context, profileProvider.errorMessage,
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
    final districtProvider = Provider.of<DistrictProvider>(context);
    final districtItems = districtProvider.districts
        .map((e) => DropdownItem(value: e.code, label: e.name))
        .toList();

    final villageItems = context
        .watch<VillageProvider>()
        .villages
        .map((v) => DropdownItem(value: v.code, label: v.name))
        .toList();

    // print("District items: $districtItems");
    // print("Village items: $villageItems");

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
                  // GANTI SELURUH BLOK ALAMAT DENGAN INI
// User Address
                  const Text(
                    'Alamat Pengguna',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SearchableDropdownField(
                    label: 'Kecamatan',
                    placeholder: 'Pilih kecamatan',
                    controller: _districtController,
                    items: districtItems,
                    onChanged: (value) {
                      context
                          .read<VillageProvider>()
                          .fetchVillages(value ?? '');
                      _villageController.clear();
                    },
                  ),
                  const SizedBox(height: 16),
                  SearchableDropdownField(
                    label: 'Desa/Kelurahan',
                    placeholder: 'Pilih desa atau kelurahan',
                    controller: _villageController,
                    items: villageItems,
                    enabled: _districtController.text.isNotEmpty,
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
                    controller: TextEditingController(
                        text: _imt.isNotEmpty ? '$_imt ($_imtCategory)' : '-'),
                    enabled: false,
                    placeholder: '-',
                  ),

                  const SizedBox(height: 16),

                  CustomFormField(
                    placeholder: 'Pilih Pendidikan Sekarang',
                    label: 'Riwayat Pendidikan',
                    controller: _eduNowController,
                    type: CustomFormFieldType.dropdown,
                    items: const [
                      'SD',
                      'SMP',
                      'SMA',
                      'Diploma',
                      'S1',
                      'S2',
                      'S3',
                    ],
                  ),
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
                  const SizedBox(height: 32),

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

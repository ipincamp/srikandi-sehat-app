import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srikandi_sehat_app/models/district_model.dart';
import 'package:srikandi_sehat_app/models/village_model.dart';
import 'package:srikandi_sehat_app/provider/auth_provider.dart';
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
    final userProvider = context.read<AuthProvider>();
    final profileChangeProvider = context.read<ProfileChangeProvider>();

    _nameController.text = userProvider.name ?? '';
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
      context.read<VillageProvider>().fetchVillages(
        profileChangeProvider.districtCode!,
      );
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
    context.read<ProfileChangeProvider>().setDistrictName(
      selectedDistrict.name,
    );
  }

  void _onVillageChanged(String? villageCode) {
    if (villageCode == null || villageCode.isEmpty) return;

    final villageProvider = context.read<VillageProvider>();
    final selectedVillage = villageProvider.villages.firstWhere(
      (v) => v.code == villageCode,
      orElse: () => Village(code: '', name: '', type: ''),
    );

    _villageController.text = selectedVillage.name;
    _villageClassificationController.text = selectedVillage.type
        .capitalizeWords();

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

    final profileProvider = Provider.of<ProfileChangeProvider>(
      context,
      listen: false,
    );
    await profileProvider.init();
    final payload = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'address_code': profileProvider.villageCode,
      'birthdate': _formatDateForAPI(_dobController.text),
      'tb_cm': _heightController.text.isNotEmpty
          ? int.parse(_heightController.text)
          : null,
      'bb_kg': _weightController.text.isNotEmpty
          ? double.parse(_weightController.text)
          : null,
      'edu_now': _eduNowController.text,
      'edu_parent': _eduParentController.text,
      'inet_access': _internetAccessController.text,
      'first_haid': _firstHaidController.text.isNotEmpty
          ? int.parse(_firstHaidController.text)
          : null,
      'job_parent': _jobParentController.text,
    };

    final bool isSuccess = await profileProvider.updateProfile(payload);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (isSuccess) {
      await context.read<UserProfileProvider>().loadProfile(
        context,
        forceRefresh: true,
      );
      if (mounted) {
        CustomAlert.show(
          context,
          'Profil berhasil diperbarui',
          type: AlertType.success,
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        CustomAlert.show(
          context,
          'Gagal memperbarui profil: ${profileProvider.errorMessage}',
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
          (e) => DropdownItem(value: e.code, label: e.name.capitalizeWords()),
        )
        .toList();

    final villageItems = context
        .watch<VillageProvider>()
        .villages
        .map(
          (v) => DropdownItem(value: v.code, label: v.name.capitalizeWords()),
        )
        .toList();

    const educationList = [
      'Tidak Sekolah',
      'SD',
      'SMP',
      'SMA',
      'Diploma',
      'S1',
      'S2',
      'S3',
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
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
          decoration: const BoxDecoration(color: Colors.transparent),
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
                            const SizedBox(height: 16),
                            CustomFormField(
                              label: 'Nama',
                              controller: _nameController,
                              placeholder: '',
                              enabled: true,
                              prefixIcon: Icons.person,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nama tidak boleh kosong';
                                }
                                return null;
                              },
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Kecamatan harus dipilih';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            SearchableDropdownField(
                              label: 'Desa/Kelurahan',
                              placeholder: 'Pilih desa atau kelurahan',
                              controller: _villageController,
                              items: villageItems,
                              onChanged: _onVillageChanged,
                              enabled: _districtController.text.isNotEmpty,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Desa/Kelurahan harus dipilih';
                                }
                                return null;
                              },
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Tanggal lahir tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomFormField(
                                    label: 'TB (cm)',
                                    placeholder: 'Masukkan tinggi badan',
                                    controller: _heightController,
                                    type: CustomFormFieldType.number,
                                    onChanged: (_) => _onHeightWeightChanged(),
                                    prefixIcon: Icons.height,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Tinggi badan tidak boleh kosong';
                                      }
                                      final height = double.tryParse(value);
                                      if (height == null || height < 100) {
                                        return 'Tinggi badan minimal 100 cm';
                                      }
                                      if (height > 250) {
                                        return 'Tinggi badan maksimal 250 cm';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: CustomFormField(
                                    label: 'BB (kg)',
                                    placeholder: 'Masukkan berat badan',
                                    controller: _weightController,
                                    type: CustomFormFieldType.number,
                                    onChanged: (_) => _onHeightWeightChanged(),
                                    prefixIcon: Icons.monitor_weight,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Berat badan tidak boleh kosong';
                                      }
                                      final weight = double.tryParse(value);
                                      if (weight == null || weight < 30) {
                                        return 'Berat badan minimal 30 kg';
                                      }
                                      if (weight > 200) {
                                        return 'Berat badan maksimal 200 kg';
                                      }
                                      return null;
                                    },
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Umur pertama haid tidak boleh kosong';
                                }
                                final age = int.tryParse(value);
                                if (age == null || age < 9 || age > 30) {
                                  return 'Umur pertama haid harus antara 9-30 tahun';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomFormField(
                              label: 'Pendidikan Sekarang',
                              placeholder: 'Pilih Pendidikan Sekarang',
                              controller: _eduNowController,
                              type: CustomFormFieldType.dropdown,
                              items: educationList,
                              prefixIcon: Icons.school,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Pendidikan harus dipilih';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomFormField(
                              label: 'Akses Internet',
                              placeholder: 'Pilih akses internet',
                              controller: _internetAccessController,
                              type: CustomFormFieldType.dropdown,
                              items: const ['WiFi', 'Seluler'],
                              prefixIcon: Icons.wifi,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Akses internet harus dipilih';
                                }
                                return null;
                              },
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Pendidikan orang tua harus dipilih';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomFormField(
                              label: 'Pekerjaan Orang Tua',
                              placeholder: 'Pekerjaan Orang Tua',
                              controller: _jobParentController,
                              prefixIcon: Icons.work,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Pekerjaan orang tua tidak boleh kosong';
                                }
                                return null;
                              },
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.pink,
                              ),
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

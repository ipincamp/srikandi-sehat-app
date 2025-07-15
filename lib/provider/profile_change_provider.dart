// lib/providers/user_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileChangeProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';

  // FIX: Tambahkan semua state untuk data profil
  String? _name,
      _email,
      _role,
      _phone,
      _dob,
      _districtCode,
      _villageCode,
      _eduNow,
      _eduParent,
      _internetAccess,
      _firstHaid,
      _jobParent;
  int? _height;
  double? _weight;

  // --- Getters ---
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String? get name => _name;
  String? get email => _email;
  String? get role => _role;
  String? get phone => _phone;
  String? get dob => _dob;
  int? get height => _height;
  double? get weight => _weight;
  String? get districtCode => _districtCode;
  String? get villageCode => _villageCode;
  String? get eduNow => _eduNow;
  String? get eduParent => _eduParent;
  String? get internetAccess => _internetAccess;
  String? get firstHaid => _firstHaid;
  String? get jobParent => _jobParent;

  // FIX: Hapus parameter yang tidak perlu dari signature
  Future<void> updateProfile() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final baseUrl = dotenv.env['API_URL'];
    final url = '$baseUrl/me';

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['data'] != null) {
        final user = responseData['data'];

        // FIX: Ambil semua data dari API dan simpan di state
        _name = user['name'];
        _email = user['email'];
        _role = user['role'];
        _phone = user['phone'];
        _dob = user['birthdate'];
        _height = user['tb_cm'];
        _weight = user['bb_kg'] != null
            ? double.tryParse(user['bb_kg'].toString())
            : null;
        _districtCode = user['district_code']; // Asumsi API mengembalikan ini
        _villageCode = user['address']; // address berisi village_code
        _eduNow = user['edu_now'];
        _eduParent = user['edu_parent'];
        _internetAccess = user['inet_access'];
        _firstHaid = user['first_haid'];
        _jobParent = user['job_parent'];

        // Simpan data penting ke SharedPreferences jika perlu
        await prefs.setString('name', _name ?? '');
        await prefs.setString('email', _email ?? '');
      } else {
        _errorMessage = responseData['message'] ?? 'Gagal mengambil profil.';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // TAMBAHKAN method baru ini di dalam class ProfileChangeProvider
  Future<bool> getProfile(Map<String, dynamic> profileData) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final baseUrl = dotenv.env['API_URL'];
    final url = '$baseUrl/me/profile'; // Endpoint untuk update profile

    try {
      // Menggunakan http.put untuk update
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(profileData),
      );

      debugPrint("✅ Payload: ${jsonEncode(profileData)}");
      debugPrint("🔁 Status Code: ${response.statusCode}");
      debugPrint("🔁 Response: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      } else {
        final data = jsonDecode(response.body);
        _errorMessage = data['message'] ?? 'Gagal memperbarui profil.';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

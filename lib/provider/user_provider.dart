// lib/providers/user_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  String? _name;
  String? _email;
  String? _role;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String? get name => _name;
  String? get email => _email;
  String? get role => _role;

  Future<Map<String, dynamic>?> getProfile() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final baseUrl = dotenv.env['API_URL'];
    final url = '$baseUrl/me';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['data'] != null) {
        final user = responseData['data'];

        _name = user['name'];
        _email = user['email'];
        _role = user['role'];

        await prefs.setString('name', _name ?? '');
        await prefs.setString('email', _email ?? '');
        await prefs.setString('role', _role ?? '');

        notifyListeners();

        // Kembalikan data untuk digunakan di UI
        return {
          'name': _name,
          'email': _email,
          'role': _role,
        };
      } else {
        _errorMessage = responseData['message'] ?? 'Gagal mengambil profil.';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(
      String name,
      String email,
      String address,
      String phone,
      String dateOfBirth,
      String heightCm,
      String weightKg) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final baseUrl = dotenv.env['API_URL'];
    final url = '$baseUrl/me/profile';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'address': address,
          'phone': phone,
          'date_of_birth': dateOfBirth,
          'height_cm': heightCm,
          'weight_kg': weightKg,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await prefs.setString('name', name);
        await prefs.setString('email', email);
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['message'] ?? 'Gagal memperbarui profil.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword(
      String oldPassword, String newPassword, String confirmPassword) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final baseUrl = dotenv.env['API_URL'];
    final url = '$baseUrl/me/password';

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['message'] ?? 'Gagal mengganti password.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

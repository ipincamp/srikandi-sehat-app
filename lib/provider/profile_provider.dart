import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Menggunakan Map<String, dynamic> agar lebih fleksibel seperti di screen Anda
  // Ganti metode getProfile() yang kosong dengan ini:

  Future<Map<String, dynamic>?> getProfile() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final baseUrl = dotenv.env['API_URL'];
    final url = '$baseUrl/me'; // Endpoint untuk mendapatkan data user

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // Kembalikan data user agar bisa ditangkap oleh screen
        return responseData['data'];
      } else {
        final data = jsonDecode(response.body);
        _errorMessage = data['message'] ?? 'Gagal mengambil profil.';
        return null;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

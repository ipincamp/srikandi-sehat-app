import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  String _name = '';
  String _email = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get name => _name;
  String get email => _email;

  Map<String, dynamic> _userData = {};
  Map<String, dynamic> get userData => _userData;

  Future<Map<String, dynamic>?> getProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final baseUrl = dotenv.env['API_URL'];
      final url = '$baseUrl/me';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['data'] != null) {
        final user = responseData['data'];
        _name = user['name'] ?? '';
        _email = user['email'] ?? '';
        _userData = user;
        _errorMessage = '';
        notifyListeners();
        return user;
      } else {
        _errorMessage = responseData['message'] ?? 'Gagal mengambil profil.';
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

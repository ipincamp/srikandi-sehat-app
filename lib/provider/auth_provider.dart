import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  String? _authToken;

  String? get authToken => _authToken;
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  get token => null;

  Future<bool> login(String email, String password) async {
    _authToken = dotenv.env['AUTH_TOKEN'];
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final baseUrl = dotenv.env['API_URL']; // Menggunakan API_URL dari .env
    final url = '$baseUrl/auth/login';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final data = responseData['data'] as Map<String, dynamic>;
        final user = data['user'] as Map<String, dynamic>;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        await prefs.setString('token', data['token'] ?? '');
        await prefs.setString('role', user['role'] ?? '');
        await prefs.setString('name', user['name'] ?? '');

        notifyListeners();
        return true;
      } else {
        _errorMessage = responseData['message'] ?? 'Login gagal';
        notifyListeners();
        return false;
      }
    } catch (error) {
      _errorMessage = 'Terjadi kesalahan: $error';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password,
      String confirmPassword) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final baseUrl = dotenv.env['API_URL']; // Menggunakan API_URL dari .env
    final url = '$baseUrl/auth/register';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(<String, String>{
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': confirmPassword,
        }),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201) {
        _errorMessage = 'Pendaftaran berhasil. Silakan login.';
        notifyListeners();
        return true;
      } else {
        if (responseData.containsKey('message')) {
          _errorMessage = responseData['message'];
        } else if (responseData.containsKey('errors')) {
          _errorMessage = (responseData['errors'] as Map<String, dynamic>)
              .values
              .map((e) => e.join(', '))
              .join('\n');
        } else {
          _errorMessage = 'Pendaftaran gagal.';
        }
        notifyListeners();
        return false;
      }
    } catch (error) {
      _errorMessage = 'Terjadi kesalahan: $error';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final baseUrl = dotenv.env['API_URL']; // Menggunakan API_URL dari .env
    final url = '$baseUrl/auth/logout';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await prefs.setBool('isLoggedIn', false);
        await prefs.remove('token');
        await prefs.remove('role');
        await prefs.remove('name');
        notifyListeners();
        return true;
      } else if (response.statusCode == 401) {
        // ✅ Token expired — clear & redirect
        await prefs.clear();
        notifyListeners();
        if (context.mounted) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/login', (route) => false);
        }
        return false;
      } else {
        throw Exception('Logout gagal');
      }
    } catch (error) {
      _errorMessage = 'Terjadi kesalahan: $error';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = dotenv.env['AUTH_TOKEN'];
    _authToken = prefs.getString('token');
    notifyListeners();
  }
}

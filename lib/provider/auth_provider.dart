import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  String? _authToken;
  String? _userId;
  String? _name;
  String? _email;
  String? _role;
  bool _profileComplete = false;
  String? _createdAt;

  String? get authToken => _authToken;
  String? get userId => _userId;
  String? get name => _name;
  String? get email => _email;
  String? get role => _role;
  bool get profileComplete => _profileComplete;
  String? get createdAt => _createdAt;

  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final baseUrl = dotenv.env['API_URL'];
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

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // First check if the response has the expected structure
        if (responseData == null || responseData['data'] == null) {
          _errorMessage = 'Invalid server response';
          notifyListeners();
          return false;
        }

        // Handle case where 'data' might not be a Map
        final data = responseData['data'];
        if (data is! Map<String, dynamic>) {
          _errorMessage = 'Invalid user data format';
          notifyListeners();
          return false;
        }

        // Update provider state with null checks
        _authToken = data['token']?.toString();
        _userId = data['id']?.toString();
        _name = data['name']?.toString();
        _email = data['email']?.toString();
        _role = data['role']?.toString();
        _profileComplete = data['profile_complete'] ?? false;
        _createdAt = data['created_at']?.toString();

        if (_authToken == null || _userId == null) {
          _errorMessage = 'Missing required user data';
          notifyListeners();
          return false;
        }

        // Save to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('token', _authToken!);
        await prefs.setString('userId', _userId!);
        await prefs.setString('name', _name ?? '');
        await prefs.setString('email', _email ?? '');
        await prefs.setString('role', _role ?? '');
        await prefs.setBool('profile_complete', _profileComplete);
        await prefs.setString('created_at', _createdAt ?? '');

        notifyListeners();
        return true;
      } else {
        // Handle error response
        _errorMessage =
            responseData['message']?.toString() ??
            responseData['error']?.toString() ??
            'Login failed with status ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (error) {
      _errorMessage = 'An error occurred: ${error.toString()}';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(
    String name,
    String email,
    String password,
    String confirmPassword,
    String fcmToken,
  ) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final baseUrl = dotenv.env['API_URL'];
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
          'fcm_token': fcmToken,
        }),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 202) {
        _errorMessage =
            'Registration is being processed. You will receive a notification.';
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
          _errorMessage = 'Registration failed.';
        }
        notifyListeners();
        return false;
      }
    } catch (error) {
      _errorMessage = 'An error occurred: $error';
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

    final baseUrl = dotenv.env['API_URL'];
    final url = '$baseUrl/auth/logout';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      // Clear provider state
      _authToken = null;
      _userId = null;
      _name = null;
      _email = null;
      _role = null;
      _profileComplete = false;
      _createdAt = null;

      // Clear shared preferences
      await prefs.clear();

      if (response.statusCode == 200) {
        notifyListeners();
        return true;
      } else if (response.statusCode == 401) {
        notifyListeners();
        if (context.mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
        return false;
      } else {
        throw Exception('Logout failed');
      }
    } catch (error) {
      _errorMessage = 'An error occurred: $error';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('token');
    _userId = prefs.getString('userId');
    _name = prefs.getString('name');
    _email = prefs.getString('email');
    _role = prefs.getString('role');
    _profileComplete = prefs.getBool('profile_complete') ?? false;
    _createdAt = prefs.getString('created_at');
    notifyListeners();
  }

  Future<bool> isLoggedIn() async {
    await loadUserData();
    return _authToken != null;
  }
}

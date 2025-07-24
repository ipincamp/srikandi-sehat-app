import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  Map<String, dynamic> _userData = {};
  DateTime? _lastFetched;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Map<String, dynamic> get userData => _userData;
  String get name => _userData['name'] ?? '';
  String get email => _userData['email'] ?? '';
  String? get role => _userData['role'];

  // Cache duration (5 minutes)
  static const Duration cacheDuration = Duration(minutes: 5);

  Future<Map<String, dynamic>?> getProfile({bool forceRefresh = false}) async {
    // Return cached data if it's still fresh and not forcing refresh
    if (!forceRefresh &&
        _lastFetched != null &&
        DateTime.now().difference(_lastFetched!) < cacheDuration &&
        _userData.isNotEmpty) {
      return _userData;
    }

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
        _userData = responseData['data'];
        _errorMessage = '';
        _lastFetched = DateTime.now();
        notifyListeners();
        return _userData;
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

  Future<void> clearCache() async {
    _userData = {};
    _lastFetched = null;
    notifyListeners();
  }
}

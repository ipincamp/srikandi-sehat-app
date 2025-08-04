import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikandi_sehat_app/core/network/http_client.dart';

class UserProfileProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  Map<String, dynamic> _userData = {};
  DateTime? _lastFetched;
  int? _currentCycleNumber;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Map<String, dynamic> get userData => _userData;
  String get name => _userData['name'] ?? '';
  String get email => _userData['email'] ?? '';
  String? get role => _userData['role'];
  int? get currentCycleNumber => _currentCycleNumber;

  static const Duration cacheDuration = Duration(minutes: 5);

  Future<void> loadProfile(BuildContext context,
      {bool forceRefresh = false}) async {
    if (!forceRefresh && _shouldUseCache()) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Gunakan HttpClient yang sudah memiliki auth guard
      final response = await HttpClient.get(context, 'me', body: {});

      final responseData = jsonDecode(response.body);
      print('Profile response: $responseData');

      if (response.statusCode == 200 && responseData['data'] != null) {
        _userData = responseData['data'];
        _currentCycleNumber = _userData['current_cycle_number'];
        _errorMessage = '';
        _lastFetched = DateTime.now();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('current_cycle_number', _currentCycleNumber ?? 0);

        // Update role di auth provider jika diperlukan
        if (_userData['role'] != null) {
          await prefs.setString('role', _userData['role']);
        }
      } else {
        _errorMessage = responseData['message'] ?? 'Gagal mengambil profil.';

        // Jika token tidak valid, HttpClient sudah otomatis handle redirect ke login
        // Kita hanya perlu clear data lokal
        if (response.statusCode == 401) {
          await clearProfileData();
        }
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';

      // Jika error karena unauthorized, biarkan HttpClient yang handle
      if (e.toString().contains('Unauthorized')) {
        await clearProfileData();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _shouldUseCache() {
    return _lastFetched != null &&
        DateTime.now().difference(_lastFetched!) < cacheDuration &&
        _userData.isNotEmpty;
  }

  Future<void> clearProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_cycle_number');

    _userData = {};
    _currentCycleNumber = null;
    _lastFetched = null;
    notifyListeners();
  }

  Future<void> updateProfile(
      BuildContext context, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response =
          await HttpClient.get(context, 'profile/update', body: data);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _userData = {..._userData, ...responseData['data']};
        _errorMessage = '';
        _lastFetched = DateTime.now();
      } else {
        _errorMessage = responseData['message'] ?? 'Gagal memperbarui profil.';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method untuk clear cache (jika diperlukan)
  Future<void> clearCache() async {
    _lastFetched = null;
    notifyListeners();
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/core/network/http_client.dart';

extension StringCasingExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return toLowerCase()
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }
}

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

  String get residentialCategory {
    final profileData = _userData['profile'];
    if (profileData == null || profileData['address'] == null) {
      return 'Belum diisi';
    }
    final String address = profileData['address'].toString();
    final upperCaseAddress = address.toUpperCase();

    if (upperCaseAddress.contains('(DESA)')) {
      return 'Perdesaan';
    } else if (upperCaseAddress.contains('(KOTA)')) {
      return 'Perkotaan';
    }

    return 'Tidak Terdefinisi';
  }

  String get formattedAddress {
    final profileData = _userData['profile'];
    if (profileData == null || profileData['address'] == null) {
      return 'Belum diisi';
    }

    String address = profileData['address'].toString();
    address = address.replaceAll(RegExp(r'\((.*?)\)\s*'), '');

    return address.toTitleCase();
  }

  static const Duration cacheDuration = Duration(minutes: 5);

  Future<void> loadProfile(
    BuildContext context, {
    bool forceRefresh = false,
  }) async {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 👤 [UserProfileProvider] Load profile');
      debugPrint('│ 🔄 Force Refresh: $forceRefresh');
      debugPrint('│ 📅 Last Fetched: ${_lastFetched?.toString() ?? "Never"}');
    }
    
    if (!forceRefresh && _shouldUseCache()) {
      if (kDebugMode) {
        debugPrint('│ ✅ Using cached profile data');
        debugPrint('└─────────────────────────────────────────');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('│ 📡 Fetching profile from server...');
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Gunakan HttpClient yang sudah memiliki auth guard
      final response = await HttpClient.get(context, 'me', body: {});

      if (kDebugMode) {
        debugPrint('│ 📊 Response Status: ${response.statusCode}');
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['data'] != null) {
        _userData = responseData['data'];
        _currentCycleNumber = _userData['current_cycle_number'];
        _errorMessage = '';
        _lastFetched = DateTime.now();

        if (kDebugMode) {
          debugPrint('│ ✅ Profile loaded successfully');
          debugPrint('│ 👤 Name: ${_userData['name']}');
          debugPrint('│ 📧 Email: ${_userData['email']}');
          debugPrint('│ 🎭 Role: ${_userData['role']}');
          debugPrint('│ 🔢 Current Cycle Number: $_currentCycleNumber');
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('current_cycle_number', _currentCycleNumber ?? 0);

        // Update role di auth provider jika diperlukan
        if (_userData['role'] != null) {
          await prefs.setString('role', _userData['role']);
        }

        if (kDebugMode) {
          debugPrint('│ 💾 Saved to SharedPreferences');
          debugPrint('│ ✅ Load completed successfully');
          debugPrint('└─────────────────────────────────────────');
        }
      } else {
        _errorMessage = responseData['message'] ?? 'Gagal mengambil profil.';

        if (kDebugMode) {
          debugPrint('│ ❌ Failed to load profile');
          debugPrint('│ 📊 Status: ${response.statusCode}');
          debugPrint('│ 💬 Error: $_errorMessage');
        }

        if (response.statusCode == 401) {
          if (kDebugMode) {
            debugPrint('│ 🔒 Unauthorized, clearing profile data');
          }
          await clearProfileData();
        }
        
        if (kDebugMode) {
          debugPrint('└─────────────────────────────────────────');
        }
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      
      if (kDebugMode) {
        debugPrint('│ ❌ Exception caught!');
        debugPrint('│ 🔴 Type: ${e.runtimeType}');
        debugPrint('│ 💬 Message: ${e.toString()}');
        debugPrint('└─────────────────────────────────────────');
      }

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
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await HttpClient.get(
        context,
        'profile/update',
        body: data,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _userData = {..._userData, ...responseData['data']};
        _errorMessage = '';
        _lastFetched = DateTime.now();
      } else {
        _errorMessage = responseData['message'] ?? 'Gagal memperbarui profil.';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
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

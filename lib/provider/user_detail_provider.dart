import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app/core/network/http_client.dart';
import 'package:app/models/user_detail_model.dart';

class UserDetailProvider with ChangeNotifier {
  UserDetail? _userDetail;
  bool _isLoading = false;
  String _errorMessage = '';

  UserDetail? get userDetail => _userDetail;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchUserDetail(String userId, BuildContext context) async {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 👤 [UserDetailProvider] Fetch user detail');
      debugPrint('│ 🔑 User ID: $userId');
    }

    _isLoading = true;
    _errorMessage = ''; // Reset error message
    notifyListeners();

    try {
      String endpoint = 'admin/users/$userId';

      if (kDebugMode) {
        debugPrint('│ 📡 API: $endpoint');
      }

      final response = await HttpClient.get(context, endpoint, body: {});

      if (kDebugMode) {
        debugPrint('│ 📊 Response Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        _userDetail = UserDetail.fromJson(jsonBody['data']);
        _errorMessage = ''; // Pastikan error message kosong saat success

        if (kDebugMode) {
          debugPrint('│ ✅ User detail loaded successfully');
          debugPrint('│ 👤 Name: ${_userDetail?.name}');
          debugPrint('│ 📧 Email: ${_userDetail?.email}');
          debugPrint('│ 🎭 Role: ${_userDetail?.role}');
          debugPrint('└─────────────────────────────────────────');
        }
      } else {
        _errorMessage = 'Gagal mengambil data. Status: ${response.statusCode}';

        if (kDebugMode) {
          debugPrint('│ ❌ Failed to fetch user detail');
          debugPrint('│ 💬 Error: $_errorMessage');
          debugPrint('└─────────────────────────────────────────');
        }
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';

      if (kDebugMode) {
        debugPrint('│ ❌ Exception caught!');
        debugPrint('│ 🔴 Type: ${e.runtimeType}');
        debugPrint('│ 💬 Message: ${e.toString()}');
        debugPrint('└─────────────────────────────────────────');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 👤 [UserDetailProvider] Clear data');
      debugPrint('│ 🗑️ Clearing user detail data');
      debugPrint('└─────────────────────────────────────────');
    }

    _userDetail = null;
    _errorMessage = '';
    notifyListeners();
  }
}

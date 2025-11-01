import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<bool> changePassword(
    String oldPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 🔐 [PasswordProvider] Change password');
    }
    
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final baseUrl = dotenv.env['API_URL'];
    final url = '$baseUrl/me/password';

    if (kDebugMode) {
      debugPrint('│ 🔑 Token: ${token.isNotEmpty ? "✓ (${token.length} chars)" : "✗ Missing"}');
      debugPrint('│ 🌐 API URL: $url');
      debugPrint('│ 📡 Sending password change request...');
    }

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        }),
      );

      if (kDebugMode) {
        debugPrint('│ 📊 Response Status: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          debugPrint('│ ✅ Password changed successfully');
          debugPrint('│ 💬 Message: ${data['message'] ?? "Success"}');
          debugPrint('│ ✅ Change process completed');
          debugPrint('└─────────────────────────────────────────');
        }
        return true;
      } else {
        _errorMessage = data['message'] ?? 'Gagal mengganti password.';
        
        if (kDebugMode) {
          debugPrint('│ ❌ Failed to change password');
          debugPrint('│ 📊 Status: ${response.statusCode}');
          debugPrint('│ 💬 Error: $_errorMessage');
          debugPrint('└─────────────────────────────────────────');
        }
        
        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      
      if (kDebugMode) {
        debugPrint('│ ❌ Exception caught');
        debugPrint('│ 🔥 Error type: ${e.runtimeType}');
        debugPrint('│ 💬 Error: $_errorMessage');
        debugPrint('└─────────────────────────────────────────');
      }
      
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

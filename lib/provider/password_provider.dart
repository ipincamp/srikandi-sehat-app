import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/utils/logger.dart';

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
    AppLogger.startSection('PasswordProvider - Change password', emoji: '🔐');

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final baseUrl = dotenv.env['API_URL'];
    final url = '$baseUrl/me/password';

    AppLogger.apiRequest(
      method: 'PATCH',
      endpoint: '/me/password',
      token: token,
    );

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

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        AppLogger.apiResponse(
          statusCode: response.statusCode,
          endpoint: '/me/password',
          data: data,
        );
        AppLogger.success('PasswordProvider', 'Password changed successfully');
        AppLogger.endSection(message: '✅ Change process completed');
        return true;
      } else {
        _errorMessage = data['message'] ?? 'Gagal mengganti password.';

        AppLogger.apiResponse(
          statusCode: response.statusCode,
          endpoint: '/me/password',
          errorMessage: _errorMessage,
        );
        AppLogger.endSection();

        return false;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';

      AppLogger.exception(category: 'PasswordProvider', error: e);
      AppLogger.endSection();

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

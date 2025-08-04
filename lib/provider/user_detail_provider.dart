// provider/user_detail_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:srikandi_sehat_app/models/user_detail_model.dart';

class UserDetailProvider with ChangeNotifier {
  UserDetail? _userDetail;
  bool _isLoading = false;
  String _errorMessage = '';

  UserDetail? get userDetail => _userDetail;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchUserDetail(String userId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final baseUrl = dotenv.env['API_URL'] ?? '';
      final url = '$baseUrl/users/$userId';
      print(url); 

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        _userDetail = UserDetail.fromJson(jsonBody['data']);
      } else {
        _errorMessage =
            'Gagal mengambil data pengguna. Status code: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    _userDetail = null;
    _errorMessage = '';
    notifyListeners();
  }
}

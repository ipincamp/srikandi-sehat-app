import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:srikandi_sehat_app/core/network/http_client.dart';
import 'package:srikandi_sehat_app/models/user_detail_model.dart';

class UserDetailProvider with ChangeNotifier {
  UserDetail? _userDetail;
  bool _isLoading = false;
  String _errorMessage = '';

  UserDetail? get userDetail => _userDetail;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchUserDetail(String userId, BuildContext context) async {
    _isLoading = true;
    _errorMessage = ''; // Reset error message
    notifyListeners();

    try {
      String endpoint = 'admin/users/$userId';

      final response = await HttpClient.get(context, endpoint, body: {});

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        _userDetail = UserDetail.fromJson(jsonBody['data']);
        _errorMessage = ''; // Pastikan error message kosong saat success
      } else {
        _errorMessage = 'Gagal mengambil data. Status: ${response.statusCode}';
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

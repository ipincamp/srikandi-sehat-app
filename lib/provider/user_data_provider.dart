import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:srikandi_sehat_app/core/network/http_client.dart';
import 'package:srikandi_sehat_app/models/user_model.dart';

class UserDataProvider with ChangeNotifier {
  List<UserModel> _allUsers = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalUsers = 0;
  int _urbanCount = 0;
  int _ruralCount = 0;

  List<UserModel> get allUsers => _allUsers;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get totalUsers => _totalUsers;
  int get urbanCount => _urbanCount;
  int get ruralCount => _ruralCount;

  Future<void> fetchUsers(BuildContext context,
      {int page = 1, int? scope}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Build URL with pagination and scope filter
      String endpoint = 'users?page=$page&per_page=10';
      if (scope != null) {
        endpoint += '&scope=$scope';
      }

      // Gunakan HttpClient yang sudah terintegrasi auth guard
      final response = await HttpClient.get(context, endpoint, body: {});

      final jsonData = jsonDecode(response.body);
      final List<dynamic> userList = jsonData['data'];

      _allUsers = userList.map((json) => UserModel.fromJson(json)).toList();
      _currentPage = jsonData['meta']['current_page'];
      _lastPage = jsonData['meta']['last_page'];

      _totalUsers = jsonData['meta']['stats']['all_user'] ?? 0;
      _urbanCount = jsonData['meta']['stats']['urban_users'] ?? 0;
      _ruralCount = jsonData['meta']['stats']['rural_users'] ?? 0;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();

      // Error sudah dihandle oleh HttpClient, kita hanya perlu clear data jika perlu
      if (e.toString().contains('Unauthorized')) {
        _allUsers = [];
        notifyListeners();
      }
      rethrow;
    }
  }

  Future<void> refreshData(BuildContext context) async {
    await fetchUsers(context, page: 1);
  }
}

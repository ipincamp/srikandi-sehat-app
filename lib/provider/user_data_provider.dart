import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:srikandi_sehat_app/core/network/http_client.dart';
import 'package:srikandi_sehat_app/models/user_model.dart';

class UserDataProvider with ChangeNotifier {
  List<UserModel> _allUsers = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;
  int? _selectedClassification; // 1 for urban, 2 for rural

  List<UserModel> get allUsers => _allUsers;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int? get selectedClassification => _selectedClassification;

  Future<void> fetchUsers(
    BuildContext context, {
    int page = 1,
    int? classification, // 1 for urban, 2 for rural
  }) async {
    _isLoading = true;
    _selectedClassification = classification;
    notifyListeners();

    try {
      // Build query parameters
      final queryParams = {
        'page': page.toString(),
        'limit': '10',
        if (classification != null)
          'classification': classification == 1 ? 'urban' : 'rural',
      };

      // Build URL with query parameters
      final queryString = Uri(queryParameters: queryParams).query;
      final endpoint = 'admin/users?$queryString';

      // Use HttpClient
      final response = await HttpClient.get(context, endpoint, body: {});

      final jsonData = jsonDecode(response.body);
      final List<dynamic> userList = jsonData['data']['data'];

      _allUsers = userList.map((json) => UserModel.fromJson(json)).toList();
      _currentPage = jsonData['data']['meta']['current_page'];
      _totalPages = jsonData['data']['meta']['total_pages'];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> refreshData(BuildContext context) async {
    await fetchUsers(context, page: 1, classification: _selectedClassification);
  }

  Future<void> setClassificationFilter(
    BuildContext context,
    int? classification,
  ) async {
    await fetchUsers(context, page: 1, classification: classification);
  }
}

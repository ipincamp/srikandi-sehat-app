import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:app/core/network/http_client.dart';
import 'package:app/models/user_model.dart';
import 'package:app/widgets/custom_alert.dart';
import 'package:app/utils/logger.dart';

class UserDataProvider with ChangeNotifier {
  List<UserModel> _allUsers = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalUser = 0;
  int? _selectedClassification = 3; // 1 for urban, 2 for rural

  List<UserModel> get allUsers => _allUsers;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalUser => _totalUser;
  int? get selectedClassification => _selectedClassification;

  Future<void> fetchUsers(
    BuildContext context, {
    int page = 1,
    int? classification, // 1 for urban, 2 for rural
  }) async {
    AppLogger.startSection('UserDataProvider - Fetch users', emoji: '👥');
    AppLogger.log('UserDataProvider', 'Page: $page', emoji: '📄');
    AppLogger.log(
      'UserDataProvider',
      'Classification: ${classification == null ? "All" : (classification == 1
                ? "Urban"
                : classification == 2
                ? "Rural"
                : "All")}',
      emoji: '🏙️',
    );

    _isLoading = true;
    _selectedClassification = classification;
    notifyListeners();

    try {
      // Build query parameters
      final queryParams = {
        'page': page.toString(),
        'limit': '10',
        if (classification != null && classification != 3)
          'classification': classification == 1 ? 'urban' : 'rural',
      };

      // Build URL with query parameters
      final queryString = Uri(queryParameters: queryParams).query;
      final endpoint = 'admin/users?$queryString';

      AppLogger.log('UserDataProvider', 'Endpoint: $endpoint', emoji: '🌐');
      AppLogger.log('UserDataProvider', 'Fetching users...', emoji: '📡');

      // Use HttpClient
      final response = await HttpClient.get(context, endpoint, body: {});

      AppLogger.apiResponse(
        statusCode: response.statusCode,
        endpoint: endpoint,
      );

      final jsonData = jsonDecode(response.body);

      // Handle case when data is null
      if (jsonData['data']['data'] == null) {
        _allUsers = []; // Set empty list instead of null
        _currentPage = 1;
        _totalPages = 1;

        AppLogger.warning('UserDataProvider', 'No user data available');
      } else {
        final List<dynamic> userList = jsonData['data']['data'];
        _allUsers = userList.map((json) => UserModel.fromJson(json)).toList();
        _currentPage = jsonData['data']['meta']['current_page'] ?? 1;
        _totalPages = jsonData['data']['meta']['total_pages'] ?? 1;

        AppLogger.success(
          'UserDataProvider',
          'Fetched ${_allUsers.length} users',
        );
        AppLogger.log(
          'UserDataProvider',
          'Current Page: $_currentPage',
          emoji: '📄',
        );
        AppLogger.log(
          'UserDataProvider',
          'Total Pages: $_totalPages',
          emoji: '📊',
        );
      }

      _isLoading = false;

      AppLogger.endSection(message: '✅ Fetch completed successfully');

      notifyListeners();
    } catch (e) {
      _isLoading = false;
      // Set empty data instead of showing error for null data
      _allUsers = [];
      _currentPage = 1;
      _totalPages = 1;

      AppLogger.exception(category: 'UserDataProvider', error: e);

      // Only show error for actual connection issues, not for empty data
      if (e.toString().contains('Connection') ||
          e.toString().contains('Socket')) {
        AppLogger.warning('UserDataProvider', 'Network error detected');

        CustomAlert.show(
          context,
          'Tidak ada Koneksi Internet\nTidak Bisa Mendapatkan Data User',
          type: AlertType.warning,
          duration: Duration(seconds: 2),
        );
      }

      AppLogger.endSection();

      notifyListeners();
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

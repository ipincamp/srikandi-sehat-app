import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app/core/network/http_client.dart';
import 'package:app/models/user_model.dart';
import 'package:app/widgets/custom_alert.dart';

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
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 👥 [UserDataProvider] Fetch users');
      debugPrint('│ 📄 Page: $page');
      debugPrint('│ 🏙️ Classification: ${classification == null ? "All" : (classification == 1 ? "Urban" : classification == 2 ? "Rural" : "All")}');
    }
    
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

      if (kDebugMode) {
        debugPrint('│ 🌐 Endpoint: $endpoint');
        debugPrint('│ 📡 Fetching users...');
      }

      // Use HttpClient
      final response = await HttpClient.get(context, endpoint, body: {});

      if (kDebugMode) {
        debugPrint('│ 📊 Response Status: ${response.statusCode}');
      }

      final jsonData = jsonDecode(response.body);
      
      // Handle case when data is null
      if (jsonData['data']['data'] == null) {
        _allUsers = []; // Set empty list instead of null
        _currentPage = 1;
        _totalPages = 1;
        
        if (kDebugMode) {
          debugPrint('│ 📭 No user data available');
        }
      } else {
        final List<dynamic> userList = jsonData['data']['data'];
        _allUsers = userList.map((json) => UserModel.fromJson(json)).toList();
        _currentPage = jsonData['data']['meta']['current_page'] ?? 1;
        _totalPages = jsonData['data']['meta']['total_pages'] ?? 1;
        
        if (kDebugMode) {
          debugPrint('│ ✅ Fetched ${_allUsers.length} users');
          debugPrint('│ 📄 Current Page: $_currentPage');
          debugPrint('│ 📊 Total Pages: $_totalPages');
        }
      }
      
      _isLoading = false;
      
      if (kDebugMode) {
        debugPrint('│ ✅ Fetch completed successfully');
        debugPrint('└─────────────────────────────────────────');
      }
      
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      // Set empty data instead of showing error for null data
      _allUsers = [];
      _currentPage = 1;
      _totalPages = 1;

      if (kDebugMode) {
        debugPrint('│ ❌ Exception caught');
        debugPrint('│ 🔥 Error type: ${e.runtimeType}');
        debugPrint('│ 💬 Error: ${e.toString()}');
      }

      // Only show error for actual connection issues, not for empty data
      if (e.toString().contains('Connection') ||
          e.toString().contains('Socket')) {
        
        if (kDebugMode) {
          debugPrint('│ 🌐 Network error detected');
        }
        
        CustomAlert.show(
          context,
          'Tidak ada Koneksi Internet\nTidak Bisa Mendapatkan Data User',
          type: AlertType.warning,
          duration: Duration(seconds: 2),
        );
      }

      if (kDebugMode) {
        debugPrint('└─────────────────────────────────────────');
      }

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

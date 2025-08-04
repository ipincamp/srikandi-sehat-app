import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

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

  Future<void> fetchUsers({int page = 1, int? scope}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final baseUrl = dotenv.env['API_URL'];

      // Build URL with pagination and scope filter if provided
      Uri url = Uri.parse('$baseUrl/users?page=$page&per_page=10');
      if (scope != null) {
        url = Uri.parse('$baseUrl/users?page=$page&per_page=10&scope=$scope');
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> userList = jsonData['data'];

        _allUsers = userList.map((json) => UserModel.fromJson(json)).toList();
        _currentPage = jsonData['meta']['current_page'];
        _lastPage = jsonData['meta']['last_page'];

        _totalUsers = jsonData['meta']['stats']['all_user'] ?? 0;
        _urbanCount = jsonData['meta']['stats']['urban_users'] ?? 0;
        _ruralCount = jsonData['meta']['stats']['rural_users'] ?? 0;

        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception('Failed to fetch users');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}

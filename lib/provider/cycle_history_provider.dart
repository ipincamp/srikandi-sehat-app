import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CycleHistoryProvider with ChangeNotifier {
  List<dynamic> _cycleHistory = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  List<dynamic> get cycleHistory => _cycleHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> fetchCycleHistory({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    if (!_hasMore && !refresh) return;

    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final apiUrl = dotenv.env['API_URL'];

    if (token == null || apiUrl == null) {
      _error = 'Authentication token or API URL not found';
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final url = Uri.parse(
        '$apiUrl/menstrual/cycles?page=$_currentPage&limit=100',
      );
      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newCycles = data['data']['data'] ?? [];
        final metadata = data['data']['metadata'] ?? {};

        if (refresh) {
          _cycleHistory = newCycles;
        } else {
          _cycleHistory = [..._cycleHistory, ...newCycles];
        }

        _currentPage++;
        _hasMore = _currentPage <= (metadata['total_pages'] ?? 1);
        _error = null;
      } else {
        _error = 'Failed to load cycle history: ${response.statusCode}';
        if (response.statusCode == 401) {
          // Handle unauthorized (token expired)
          // You might want to trigger logout or token refresh here
        }
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

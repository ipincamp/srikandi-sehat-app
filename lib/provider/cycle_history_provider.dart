import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CycleHistoryProvider with ChangeNotifier {
  List<dynamic> _cycleHistory = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get cycleHistory => _cycleHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCycleHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/cycles/history'),
        headers: {
          'Authorization': 'Bearer ${await _getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _cycleHistory = data['data'] ?? [];
        _error = null;
      } else {
        _error = 'Failed to load cycle history';
      }
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> recordNewCycle(DateTime startDate) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/cycles/start'),
        headers: {
          'Authorization': 'Bearer ${await _getToken()}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'start_date': startDate.toIso8601String().split('T').first,
        }),
      );

      if (response.statusCode == 200) {
        await fetchCycleHistory(); // Refresh data
        _error = null;
      } else {
        _error = 'Failed to record new cycle';
      }
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

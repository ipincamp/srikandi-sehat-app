import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikandi_sehat_app/core/auth/auth_guard.dart';
import 'package:srikandi_sehat_app/core/network/api_exceptions.dart';
import 'package:srikandi_sehat_app/core/network/http_client.dart';

class CycleHistoryProvider with ChangeNotifier {
  List<dynamic> _cycleHistory = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get cycleHistory => _cycleHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCycleHistory(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await HttpClient.get(
        context,
        'cycles/history',
        body: {},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _cycleHistory = data['data'] ?? [];
        _error = null;
      } else {
        _error = 'Failed to load cycle history: ${response.statusCode}';
      }
    } on ApiException catch (e) {
      _error = 'API Error: ${e.message}';
      if (e.statusCode == 401) {
        // AuthGuard will handle the redirect automatically
        return;
      }
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> recordNewCycle(BuildContext context, DateTime startDate) async {
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
        await fetchCycleHistory(context); // Refresh data
        _error = null;
      } else if (response.statusCode == 401) {
        AuthGuard.redirectToLogin(context);
        _error = 'Session expired. Please login again.';
      } else {
        _error = 'Failed to record new cycle: ${response.statusCode}';
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

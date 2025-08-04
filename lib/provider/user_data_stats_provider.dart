import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class UserDataStatsProvider with ChangeNotifier {
  int _totalUsers = 0;
  int _activeUsers = 0;
  int _urbanCount = 0;
  int _ruralCount = 0;

  int get totalUsers => _totalUsers;
  int get activeUsers => _activeUsers;
  int get urbanCount => _urbanCount;
  int get ruralCount => _ruralCount;

  Future<void> fetchUserStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final baseUrl = dotenv.env['API_URL'];

      final response = await http.get(
        Uri.parse('$baseUrl/users/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final stats = jsonData['data'];

        _totalUsers = stats['total_user'] ?? 0;
        _activeUsers = stats['active_user'] ?? 0;
        _urbanCount = stats['urban_user'] ?? 0;
        _ruralCount = stats['rural_user'] ?? 0;

        notifyListeners();
      } else {
        throw Exception('Failed to load stats');
      }
    } catch (e) {
      print('Error fetching stats: $e');
      // You might want to handle errors differently
    }
  }
}

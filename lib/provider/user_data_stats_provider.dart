import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:srikandi_sehat_app/core/network/http_client.dart';

class UserDataStatsProvider with ChangeNotifier {
  int _totalUsers = 0;
  int _activeUsers = 0;
  int _urbanCount = 0;
  int _ruralCount = 0;

  int get totalUsers => _totalUsers;
  int get activeUsers => _activeUsers;
  int get urbanCount => _urbanCount;
  int get ruralCount => _ruralCount;

  Future<void> fetchUserStats(BuildContext context) async {
    try {
      String endpoint = 'users/stats';
      final response = await HttpClient.get(
        context,
        endpoint,
        body: {},
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

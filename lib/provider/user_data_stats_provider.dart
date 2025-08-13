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
      String endpoint = 'admin/users/statistics';
      final response = await HttpClient.get(context, endpoint, body: {});

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final stats = jsonData['data'];

        _totalUsers = stats['total_users'] ?? 0;
        _activeUsers = stats['total_active_users'] ?? 0;
        _urbanCount = stats['total_urban_users'] ?? 0;
        _ruralCount = stats['total_rural_users'] ?? 0;

        notifyListeners();
      } else if (response.statusCode == 401) {
        // Don't redirect here - HttpClient already handles it
        print('Unauthorized access to stats');
      } else {
        print('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching stats: $e');
      // Show error to user without logging out
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load statistics: ${e.toString()}')),
      );
    }
  }
}

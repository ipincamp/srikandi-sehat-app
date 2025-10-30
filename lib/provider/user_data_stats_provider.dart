import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/widgets/custom_alert.dart';

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
    final baseUrl = dotenv.env['API_URL'];
    final url = '$baseUrl/admin/users/statistics';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      // String endpoint = 'admin/users/statistics';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

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
        if (kDebugMode) {
          debugPrint('Unauthorized access to stats');
        }
      } else {
        if (kDebugMode) {
          debugPrint('Failed to load stats: ${response.statusCode}');
        }
      }
    } catch (e) {
      CustomAlert.show(
        context,
        'Tidak ada Koneksi Internet\nTidak Bisa Mendapatkan Statistik',
        type: AlertType.warning,
        duration: Duration(seconds: 2),
      );
    }
  }
}

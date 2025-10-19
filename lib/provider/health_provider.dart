import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HealthProvider with ChangeNotifier {
  bool _isMaintenance = false;
  bool get isMaintenance => _isMaintenance;

  DateTime? _lastCheckedAt;
  DateTime? get lastCheckedAt => _lastCheckedAt;

  String? _error;
  String? get error => _error;

  Future<void> checkHealth() async {
    try {
      final baseUrl = dotenv.env['API_URL'];
      final url = '$baseUrl/health';
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': token != null ? 'Bearer $token' : '',
          'Accept': 'application/json',
        },
      );

      _lastCheckedAt = DateTime.now();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'MAINTENANCE') {
          _isMaintenance = true;
        } else {
          _isMaintenance = false;
        }
        _error = null;
      } else {
        _error = 'Gagal memeriksa status server (${response.statusCode})';
      }
    } catch (e) {
      _error = 'Koneksi gagal: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }
}

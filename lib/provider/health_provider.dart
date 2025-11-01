import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HealthProvider with ChangeNotifier {
  bool _isMaintenance = false;
  bool _isLoading = false;
  bool _hasError = false;

  bool get isMaintenance => _isMaintenance;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  DateTime? _lastCheckedAt;
  DateTime? get lastCheckedAt => _lastCheckedAt;

  String? _error;
  String? get error => _error;

  Future<void> checkHealth() async {
    if (_isLoading) {
      if (kDebugMode) {
        debugPrint('⚠️ [HealthProvider] Already checking health, skipping');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 🏥 [HealthProvider] Check health');
    }

    _isLoading = true;
    _hasError = false;
    _error = null;
    notifyListeners();

    try {
      final baseUrl = dotenv.env['API_URL'];
      
      if (kDebugMode) {
        debugPrint('│ 🌐 API URL: ${baseUrl ?? "✗ Missing"}');
      }
      
      if (baseUrl == null || baseUrl.isEmpty) {
        if (kDebugMode) {
          debugPrint('│ ❌ API_URL not configured');
          debugPrint('└─────────────────────────────────────────');
        }
        throw Exception('API_URL tidak dikonfigurasi');
      }

      final url = '$baseUrl/health';
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (kDebugMode) {
        debugPrint('│ 🔑 Token: ${token != null ? "✓ (${token.length} chars)" : "✗ Not logged in"}');
        debugPrint('│ 📡 Checking server health...');
      }

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              if (token != null) 'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      _lastCheckedAt = DateTime.now();

      if (kDebugMode) {
        debugPrint('│ 📊 Response Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status'] as String?;

        if (status == 'OK') {
          _isMaintenance = false;
          if (kDebugMode) {
            debugPrint('│ ✅ Server status: ONLINE');
          }
        } else {
          // Jika status bukan 'OK', anggap maintenance
          _isMaintenance = true;
          if (kDebugMode) {
            debugPrint('│ ⚠️ Server status: MAINTENANCE (Status: $status)');
          }
        }
        _error = null;
      } else if (response.statusCode == 503) {
        // Service Unavailable - maintenance mode
        final data = jsonDecode(response.body);
        final status = data['status'] as String?;

        _isMaintenance = true;
        if (kDebugMode) {
          debugPrint('│ ⚠️ Server status: MAINTENANCE (503 - $status)');
        }
        _error = null;
      } else {
        // Status code lainnya (404, 500, dll)
        _hasError = true;
        _error = 'Gagal memeriksa status server (${response.statusCode})';
        _isMaintenance =
            false; // Pada error, biarkan user tetap bisa menggunakan app
        if (kDebugMode) {
          debugPrint('│ ❌ Health check error: ${response.statusCode}');
        }
      }
      
      if (kDebugMode) {
        debugPrint('│ ✅ Health check completed');
        debugPrint('│ 🏥 Is Maintenance: $_isMaintenance');
        debugPrint('└─────────────────────────────────────────');
      }
    } catch (e) {
      _hasError = true;
      _error = 'Koneksi gagal: ${e.toString()}';
      // Pada error koneksi, jangan set maintenance=true
      // agar user tetap bisa menggunakan app offline
      _isMaintenance = false;
      
      if (kDebugMode) {
        debugPrint('│ ❌ Exception caught');
        debugPrint('│ 🔥 Error type: ${e.runtimeType}');
        debugPrint('│ 💬 Error: ${e.toString()}');
        debugPrint('│ ⚠️ Allowing offline usage');
        debugPrint('└─────────────────────────────────────────');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method untuk manual refresh
  Future<void> refreshHealthStatus() async {
    await checkHealth();
  }

  // Reset state
  void reset() {
    _isMaintenance = false;
    _isLoading = false;
    _hasError = false;
    _error = null;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CycleProvider with ChangeNotifier {
  bool _isMenstruating = false;
  bool get isMenstruating => _isMenstruating;

  Future<void> loadCycleStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isMenstruating = prefs.getBool('isMenstruating') ?? false;
      print('✅ Cycle status loaded: $_isMenstruating');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading cycle status: $e');
    }
  }

  Future<void> startCycle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final apiUrl = dotenv.env['API_URL'];

      // Debugging logs
      print('🔍 DEBUG INFO:');
      print(
          '   Token: ${token != null ? "✅ Tersedia (${token.length} karakter)" : "❌ NULL/Kosong"}');
      print('   API URL: ${apiUrl ?? "❌ NULL/Kosong"}');

      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan login ulang.');
      }

      if (apiUrl == null || apiUrl.isEmpty) {
        throw Exception('API URL tidak dikonfigurasi dalam .env file');
      }

      final url = '$apiUrl/cycles/start';
      print('   Full URL: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - tidak ada respons dari server');
        },
      );

      print('📡 HTTP Response:');
      print('   Status Code: ${response.statusCode}');
      print('   Headers: ${response.headers}');
      print('   Body: ${response.body}');

      if (response.statusCode == 201) {
        _isMenstruating = true;
        await prefs.setBool('isMenstruating', true);
        print('✅ Siklus berhasil dimulai');
        notifyListeners();
      } else if (response.statusCode == 401) {
        throw Exception(
            'Token tidak valid atau sudah expired. Silakan login ulang.');
      } else if (response.statusCode == 400) {
        // Parse error message from response
        try {
          final responseData = json.decode(response.body);
          final errorMessage = responseData['message'] ?? 'Bad request';
          throw Exception('Request tidak valid: $errorMessage');
        } catch (e) {
          throw Exception('Request tidak valid: ${response.body}');
        }
      } else if (response.statusCode >= 500) {
        throw Exception(
            'Server error (${response.statusCode}). Coba lagi nanti.');
      } else {
        throw Exception(
            'Gagal memulai siklus (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print('❌ Error in startCycle: $e');
      rethrow; // Re-throw untuk ditangani di UI
    }
  }

  Future<void> endCycle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final apiUrl = dotenv.env['API_URL'];

      // Debugging logs
      print('🔍 DEBUG INFO:');
      print(
          '   Token: ${token != null ? "✅ Tersedia (${token.length} karakter)" : "❌ NULL/Kosong"}');
      print('   API URL: ${apiUrl ?? "❌ NULL/Kosong"}');

      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan login ulang.');
      }

      if (apiUrl == null || apiUrl.isEmpty) {
        throw Exception('API URL tidak dikonfigurasi dalam .env file');
      }

      final url = '$apiUrl/cycles/finish';
      print('   Full URL: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - tidak ada respons dari server');
        },
      );

      print('📡 HTTP Response:');
      print('   Status Code: ${response.statusCode}');
      print('   Headers: ${response.headers}');
      print('   Body: ${response.body}');

      if (response.statusCode == 200) {
        _isMenstruating = false;
        await prefs.setBool('isMenstruating', false);
        print('✅ Siklus berhasil diakhiri');
        notifyListeners();
      } else if (response.statusCode == 401) {
        throw Exception(
            'Token tidak valid atau sudah expired. Silakan login ulang.');
      } else if (response.statusCode == 400) {
        // Parse error message from response
        try {
          final responseData = json.decode(response.body);
          final errorMessage = responseData['message'] ?? 'Bad request';
          throw Exception('Request tidak valid: $errorMessage');
        } catch (e) {
          throw Exception('Request tidak valid: ${response.body}');
        }
      } else if (response.statusCode >= 500) {
        throw Exception(
            'Server error (${response.statusCode}). Coba lagi nanti.');
      } else {
        throw Exception(
            'Gagal mengakhiri siklus (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      print('❌ Error in endCycle: $e');
      rethrow; // Re-throw untuk ditangani di UI
    }
  }

  // Method untuk debug - bisa dihapus setelah masalah teratasi
  Future<void> debugTokenAndUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final apiUrl = dotenv.env['API_URL'];

      print('🔍 DEBUGGING TOKEN & URL:');
      print('   Token exists: ${token != null}');
      print('   Token value: ${token ?? "NULL"}');
      print('   API URL: ${apiUrl ?? "NULL"}');

      // Cek semua keys yang tersimpan di SharedPreferences
      final keys = prefs.getKeys();
      print('   SharedPreferences keys: $keys');
    } catch (e) {
      print('❌ Error in debugging: $e');
    }
  }
}

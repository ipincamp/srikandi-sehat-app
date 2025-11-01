import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/models/symptom_detail_model.dart';

class SymptomDetailProvider with ChangeNotifier {
  SymptomDetail? _detail;
  bool _isLoading = false;
  String? _error;

  SymptomDetail? get detail => _detail;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDetail(int id) async {
    if (_isLoading) {
      if (kDebugMode) {
        debugPrint('⚠️ [SymptomDetailProvider] Already loading, skipping');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 📋 [SymptomDetailProvider] Fetch symptom detail');
      debugPrint('│ 🆔 Log ID: $id');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final baseUrl = dotenv.env['API_URL'] ?? '';
      final url = '$baseUrl/menstrual/symptoms/log/$id';

      if (kDebugMode) {
        debugPrint('│ 🔑 Token: ${token.isNotEmpty ? "✓ (${token.length} chars)" : "✗ Missing"}');
        debugPrint('│ 🌐 API URL: $url');
        debugPrint('│ 📡 Fetching detail...');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        debugPrint('│ 📊 Response Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        _detail = SymptomDetail.fromJson(jsonData['data']);
        
        if (kDebugMode) {
          debugPrint('│ ✅ Detail fetched successfully');
          debugPrint('│ 📅 Log Date: ${_detail?.logDate}');
          debugPrint('│ 🔢 Symptom Count: ${_detail?.details.length ?? 0}');
          debugPrint('│ ✅ Fetch completed');
          debugPrint('└─────────────────────────────────────────');
        }
      } else {
        _error = 'Failed to load data: ${response.statusCode}';
        
        if (kDebugMode) {
          debugPrint('│ ❌ Failed to fetch detail');
          debugPrint('│ 📊 Status: ${response.statusCode}');
          debugPrint('│ 💬 Error: $_error');
          debugPrint('└─────────────────────────────────────────');
        }
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      
      if (kDebugMode) {
        debugPrint('│ ❌ Exception caught');
        debugPrint('│ 🔥 Error type: ${e.runtimeType}');
        debugPrint('│ 💬 Error: $_error');
        debugPrint('└─────────────────────────────────────────');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 🧹 [SymptomDetailProvider] Clear state');
      debugPrint('│ 📊 Had detail: ${_detail != null}');
    }
    
    _detail = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('│ ✅ State cleared');
      debugPrint('└─────────────────────────────────────────');
    }
  }
}

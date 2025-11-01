import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/models/menstural_history_detail_model.dart';

class MenstrualHistoryDetailProvider with ChangeNotifier {
  MenstrualCycleDetail? _detail;
  bool _isLoading = false;
  String? _error;

  MenstrualCycleDetail? get detail => _detail;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCycleDetail(int cycleId) async {
    if (_isLoading) {
      if (kDebugMode) {
        debugPrint('⚠️ [MenstrualHistoryDetailProvider] Already loading, skipping');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 📋 [MenstrualHistoryDetailProvider] Fetch cycle detail');
      debugPrint('│ 🆔 Cycle ID: $cycleId');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final baseUrl = dotenv.env['API_URL'] ?? '';
      final url = '$baseUrl/menstrual/cycles/$cycleId';

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
        if (jsonData['data'] != null) {
          _detail = MenstrualCycleDetail.fromJson(jsonData['data']);
          
          if (kDebugMode) {
            debugPrint('│ ✅ Detail fetched successfully');
            debugPrint('│ 📅 Start Date: ${_detail?.startDate}');
            debugPrint('│ 📅 Finish Date: ${_detail?.finishDate ?? "Ongoing"}');
            debugPrint('│ ✅ Fetch completed');
            debugPrint('└─────────────────────────────────────────');
          }
        } else {
          _error = 'Data tidak tersedia';
          
          if (kDebugMode) {
            debugPrint('│ ❌ No data in response');
            debugPrint('│ 💬 Error: $_error');
            debugPrint('└─────────────────────────────────────────');
          }
        }
      } else {
        _error = 'Gagal memuat data: ${response.statusCode}';
        
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

  Future<void> deleteCycleDetail(int cycleId, String reason) async {
    if (_isLoading) {
      if (kDebugMode) {
        debugPrint('⚠️ [MenstrualHistoryDetailProvider] Already loading, skipping delete');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 🗑️ [MenstrualHistoryDetailProvider] Delete cycle');
      debugPrint('│ 🆔 Cycle ID: $cycleId');
      debugPrint('│ 📝 Reason: $reason');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final baseUrl = dotenv.env['API_URL'] ?? '';
      final url = '$baseUrl/menstrual/cycles/$cycleId';

      if (kDebugMode) {
        debugPrint('│ 🔑 Token: ${token.isNotEmpty ? "✓ (${token.length} chars)" : "✗ Missing"}');
        debugPrint('│ 🌐 API URL: $url');
        debugPrint('│ 📡 Sending delete request...');
      }

      final response = await http.delete(
        Uri.parse(url),
        body: jsonEncode({'reason': reason}),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        debugPrint('│ 📊 Response Status: ${response.statusCode}');
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        _detail = null;
        
        if (kDebugMode) {
          debugPrint('│ ✅ Cycle deleted successfully');
          debugPrint('│ 🗑️ Detail cleared from state');
          debugPrint('│ ✅ Delete completed');
          debugPrint('└─────────────────────────────────────────');
        }
        
        // message:
        'Siklus berhasil dihapus';
      } else {
        _error = 'Gagal Menghapus Siklus';
        
        if (kDebugMode) {
          debugPrint('│ ❌ Failed to delete cycle');
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
      debugPrint('│ 🧹 [MenstrualHistoryDetailProvider] Clear state');
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

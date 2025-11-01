import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/models/cycle_history_model.dart';

class CycleTrackingProvider with ChangeNotifier {
  List<CycleData> _cycleHistory = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  String? _emptyMessage;

  List<CycleData> get cycleHistory => _cycleHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  String? get emptyMessage => _emptyMessage;

  Future<void> fetchCycleHistory({
    bool refresh = false,
    required BuildContext context,
  }) async {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 🔄 [CycleTrackingProvider] Fetch cycle history');
      debugPrint('│ 🔄 Refresh: $refresh');
      debugPrint('│ 📄 Current Page: $_currentPage');
      debugPrint('│ 📊 Has More: $_hasMore');
    }
    
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _emptyMessage = null;
      
      if (kDebugMode) {
        debugPrint('│ ♻️ Reset pagination state');
      }
    }

    if (!_hasMore && !refresh) {
      if (kDebugMode) {
        debugPrint('│ ⚠️ No more data to fetch');
        debugPrint('└─────────────────────────────────────────');
      }
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (kDebugMode) {
        debugPrint('│ 🔑 Retrieving auth token...');
      }
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final apiUrl = dotenv.env['API_URL'];

      if (kDebugMode) {
        debugPrint('│ 🔑 Token: ${token != null ? "✓ (${token.length} chars)" : "✗ Missing"}');
        debugPrint('│ 🌐 API URL: ${apiUrl ?? "✗ Missing"}');
      }

      if (token == null || apiUrl == null) {
        _error = 'Token autentikasi atau URL API tidak ditemukan';
        _isLoading = false;
        notifyListeners();
        
        if (kDebugMode) {
          debugPrint('│ ❌ Missing token or API URL');
          debugPrint('└─────────────────────────────────────────');
        }
        return;
      }

      final url = '$apiUrl/menstrual/cycles?page=$_currentPage&limit=10';
      
      if (kDebugMode) {
        debugPrint('│ 🌐 Request URL: $url');
        debugPrint('│ 📡 Fetching data...');
      }

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        debugPrint('│ 📊 Response Status: ${response.statusCode}');
      }

      final responseData = json.decode(response.body) as Map<String, dynamic>;
      final cycleResponse = CycleHistoryResponse.fromJson(responseData);

      if (response.statusCode == 200) {
        if (kDebugMode) {
          debugPrint('│ ✅ Request successful');
          debugPrint('│ 📦 Received ${cycleResponse.data.length} cycles');
          debugPrint('│ 📊 Total Data: ${cycleResponse.metadata.totalData}');
        }
        
        if (cycleResponse.data.isEmpty && refresh) {
          _emptyMessage = 'Belum ada data siklus';
          
          if (kDebugMode) {
            debugPrint('│ 📭 No cycle data available');
          }
        }

        if (refresh) {
          _cycleHistory = cycleResponse.data;
          
          if (kDebugMode) {
            debugPrint('│ 🔄 Replaced cycle history (refresh)');
          }
        } else {
          _cycleHistory.addAll(cycleResponse.data);
          
          if (kDebugMode) {
            debugPrint('│ ➕ Appended to cycle history');
          }
        }

        _hasMore = _cycleHistory.length < cycleResponse.metadata.totalData;
        _currentPage++;
        
        if (kDebugMode) {
          debugPrint('│ 📊 Current Total: ${_cycleHistory.length}');
          debugPrint('│ 📄 Next Page: $_currentPage');
          debugPrint('│ 📊 Has More: $_hasMore');
          debugPrint('│ ✅ Fetch completed successfully');
          debugPrint('└─────────────────────────────────────────');
        }
      } else {
        _error = cycleResponse.message.isNotEmpty
            ? cycleResponse.message
            : 'Gagal memuat riwayat siklus: ${response.statusCode}';
        
        if (kDebugMode) {
          debugPrint('│ ❌ Request failed');
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

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void resetState() {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 🔄 [CycleTrackingProvider] Reset state');
      debugPrint('│ 📊 Previous cycle count: ${_cycleHistory.length}');
    }
    
    _cycleHistory.clear();
    _currentPage = 1;
    _hasMore = true;
    _isLoading = false;
    _error = null;
    _emptyMessage = null;
    
    if (kDebugMode) {
      debugPrint('│ ✅ State reset completed');
      debugPrint('└─────────────────────────────────────────');
    }
    notifyListeners();
  }
}

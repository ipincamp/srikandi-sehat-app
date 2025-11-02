import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/models/menstural_history_detail_model.dart';
import 'package:app/utils/logger.dart';

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
        AppLogger.warning('MenstrualHistoryDetail', 'Already loading, skipping');
      }
      return;
    }

    if (kDebugMode) {
      AppLogger.startSection('MenstrualHistoryDetail - Fetch', emoji: '📋');
      AppLogger.info('MenstrualHistoryDetail', 'Cycle ID: $cycleId');
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
        AppLogger.apiRequest(
          method: 'GET',
          endpoint: '/menstrual/cycles/$cycleId',
          token: token,
        );
        AppLogger.info('MenstrualHistoryDetail', 'Full URL: $url');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        AppLogger.apiResponse(
          statusCode: response.statusCode,
          endpoint: '/menstrual/cycles/$cycleId',
        );
      }

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['data'] != null) {
          _detail = MenstrualCycleDetail.fromJson(jsonData['data']);
          
          if (kDebugMode) {
            AppLogger.success('MenstrualHistoryDetail', 'Detail fetched successfully');
            AppLogger.info('MenstrualHistoryDetail', 'Start: ${_detail?.startDate}');
            AppLogger.info('MenstrualHistoryDetail', 'Finish: ${_detail?.finishDate ?? "Ongoing"}');
            AppLogger.endSection(message: '│ ✅ Fetch completed');
          }
        } else {
          _error = 'Data tidak tersedia';
          
          if (kDebugMode) {
            AppLogger.error('MenstrualHistoryDetail', 'No data in response');
            AppLogger.endSection();
          }
        }
      } else {
        _error = 'Gagal memuat data: ${response.statusCode}';
        
        if (kDebugMode) {
          AppLogger.error('MenstrualHistoryDetail', _error ?? 'Unknown error');
          AppLogger.endSection();
        }
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      
      if (kDebugMode) {
        AppLogger.exception(
          category: 'MenstrualHistoryDetail',
          error: e,
        );
        AppLogger.endSection();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCycleDetail(int cycleId, String reason) async {
    if (_isLoading) {
      if (kDebugMode) {
        AppLogger.warning('MenstrualHistoryDetail', 'Already loading, skipping delete');
      }
      return;
    }

    if (kDebugMode) {
      AppLogger.startSection('MenstrualHistoryDetail - Delete', emoji: '🗑️');
      AppLogger.info('MenstrualHistoryDetail', 'Cycle ID: $cycleId');
      AppLogger.info('MenstrualHistoryDetail', 'Reason: $reason');
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
        AppLogger.apiRequest(
          method: 'DELETE',
          endpoint: '/menstrual/cycles/$cycleId',
          token: token,
          body: {'reason': reason},
        );
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
        AppLogger.apiResponse(
          statusCode: response.statusCode,
          endpoint: '/menstrual/cycles/$cycleId',
        );
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        _detail = null;
        
        if (kDebugMode) {
          AppLogger.success('MenstrualHistoryDetail', 'Cycle deleted successfully');
          AppLogger.info('MenstrualHistoryDetail', 'Detail cleared from state');
          AppLogger.endSection(message: '│ ✅ Delete completed');
        }
        
        // message:
        'Siklus berhasil dihapus';
      } else {
        _error = 'Gagal Menghapus Siklus';
        
        if (kDebugMode) {
          AppLogger.error('MenstrualHistoryDetail', _error ?? 'Unknown error');
          AppLogger.endSection();
        }
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      
      if (kDebugMode) {
        AppLogger.exception(
          category: 'MenstrualHistoryDetail',
          error: e,
        );
        AppLogger.endSection();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    if (kDebugMode) {
      AppLogger.startSection('MenstrualHistoryDetail - Clear', emoji: '🧹');
      AppLogger.info('MenstrualHistoryDetail', 'Had detail: ${_detail != null}');
    }
    
    _detail = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
    
    if (kDebugMode) {
      AppLogger.success('MenstrualHistoryDetail', 'State cleared');
      AppLogger.endSection();
    }
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/models/symptom_detail_model.dart';
import 'package:app/utils/logger.dart';

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
        AppLogger.warning('SymptomDetail', 'Already loading, skipping');
      }
      return;
    }

    if (kDebugMode) {
      AppLogger.startSection('SymptomDetail - Fetch', emoji: '📋');
      AppLogger.info('SymptomDetail', 'Log ID: $id');
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
        AppLogger.apiRequest(
          method: 'GET',
          endpoint: '/menstrual/symptoms/log/$id',
          token: token,
        );
        AppLogger.info('SymptomDetail', 'Full URL: $url');
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
          endpoint: '/menstrual/symptoms/log/$id',
        );
      }

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        _detail = SymptomDetail.fromJson(jsonData['data']);
        
        if (kDebugMode) {
          AppLogger.success('SymptomDetail', 'Detail fetched successfully');
          AppLogger.info('SymptomDetail', 'Log Date: ${_detail?.logDate}');
          AppLogger.info('SymptomDetail', 'Symptom Count: ${_detail?.details.length ?? 0}');
          AppLogger.endSection(message: '│ ✅ Fetch completed');
        }
      } else {
        _error = 'Failed to load data: ${response.statusCode}';
        
        if (kDebugMode) {
          AppLogger.error('SymptomDetail', _error ?? 'Unknown error');
          AppLogger.endSection();
        }
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      
      if (kDebugMode) {
        AppLogger.exception(
          category: 'SymptomDetail',
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
      AppLogger.startSection('SymptomDetail - Clear', emoji: '🧹');
      AppLogger.info('SymptomDetail', 'Had detail: ${_detail != null}');
    }
    
    _detail = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
    
    if (kDebugMode) {
      AppLogger.success('SymptomDetail', 'State cleared');
      AppLogger.endSection();
    }
  }
}

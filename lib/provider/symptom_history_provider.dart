import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/models/symptom_history_model.dart';
import 'package:app/utils/logger.dart';

class SymptomHistoryProvider with ChangeNotifier {
  List<Symptom> _symptoms = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Symptom> get symptoms => _symptoms;

  Metadata _metadata = Metadata(
    limit: 10,
    totalData: 0,
    totalPages: 1,
    currentPage: 1,
  );
  Metadata get metadata => _metadata;
  String _errorMessage = '';

  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;
  String get errorMessage => _errorMessage;

  int _limit = 10;
  int get limit => _limit;
  final List<int> _availableLimits = [5, 10, 20, 50, 100];
  List<int> get availableLimits => _availableLimits;

  Future<void> fetchSymptomHistory({
    DateTime? date,
    int page = 1,
    int? limit,
    bool isRefresh = false,
  }) async {
    if (kDebugMode) {
      AppLogger.startSection('SymptomHistoryProvider - Fetch', emoji: '📊');
      AppLogger.info('SymptomHistory', 'Date: ${date != null ? DateFormat('yyyy-MM-dd').format(date) : "All dates"}');
      AppLogger.info('SymptomHistory', 'Page: $page, Limit: ${limit ?? _limit}');
      AppLogger.info('SymptomHistory', 'Refresh: $isRefresh');
    }
    
    if (!isRefresh) _isLoading = true;
    _selectedDate = date;
    if (limit != null) _limit = limit;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final baseUrl = dotenv.env['API_URL'];

      String url =
          '$baseUrl/menstrual/symptoms/history?page=$page&limit=$_limit';
      if (date != null) {
        final formattedDate = DateFormat('yyyy-MM-dd').format(date);
        url += '&date=$formattedDate';
      }

      if (kDebugMode) {
        AppLogger.apiRequest(
          method: 'GET',
          endpoint: '/menstrual/symptoms/history',
          token: token,
        );
        AppLogger.info('SymptomHistory', 'Full URL: $url');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        AppLogger.apiResponse(
          statusCode: response.statusCode,
          endpoint: '/menstrual/symptoms/history',
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = SymptomHistoryResponse.fromJson(jsonDecode(response.body));
        _symptoms = data.data.data;
        _metadata = data.data.metadata;
        _errorMessage = '';
        
        if (kDebugMode) {
          AppLogger.success('SymptomHistory', 'Fetched ${_symptoms.length} symptoms');
          AppLogger.info('SymptomHistory', 'Total: ${_metadata.totalData}, Pages: ${_metadata.totalPages}');
          AppLogger.endSection(message: '│ ✅ Fetch completed successfully');
        }
      } else if (response.statusCode == 401) {
        _errorMessage = 'Unauthorized access. Please log in again.';
        
        if (kDebugMode) {
          AppLogger.error('SymptomHistory', _errorMessage);
          AppLogger.endSection();
        }
        
        throw Exception(_errorMessage);
      } else if (response.statusCode == 404) {
        _errorMessage = 'No symptom history found for the selected date.';
        _symptoms = [];
        
        if (kDebugMode) {
          AppLogger.warning('SymptomHistory', _errorMessage);
          AppLogger.endSection();
        }
      } else {
        final errorMsg = 'Failed to load symptom history: ${response.statusCode}';
        
        if (kDebugMode) {
          AppLogger.error('SymptomHistory', errorMsg);
          AppLogger.endSection();
        }
        
        throw Exception(errorMsg);
      }
    } catch (e) {
      _errorMessage = 'Error fetching symptom history: $e';
      
      if (kDebugMode) {
        AppLogger.exception(
          category: 'SymptomHistory',
          error: e,
        );
        AppLogger.endSection();
      }
      
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setLimit(int newLimit) async {
    if (kDebugMode) {
      AppLogger.info('SymptomHistory', 'Setting limit to: $newLimit');
    }
    await fetchSymptomHistory(limit: newLimit, page: 1);
  }

  Future<void> goToPage(int page) async {
    if (kDebugMode) {
      AppLogger.info('SymptomHistory', 'Going to page: $page');
    }
    await fetchSymptomHistory(page: page);
  }

  Future<void> refreshData() async {
    if (kDebugMode) {
      AppLogger.info('SymptomHistory', 'Refreshing data');
    }
    await fetchSymptomHistory(isRefresh: true);
  }

  Future<void> clearDateFilter() async {
    if (kDebugMode) {
      AppLogger.info('SymptomHistory', 'Clearing date filter');
    }
    _selectedDate = null;
    await fetchSymptomHistory(page: 1);
  }
}

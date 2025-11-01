import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/models/menstural_history_model.dart';

class MenstrualHistoryProvider with ChangeNotifier {
  List<MenstrualCycle> _cycles = [];
  bool _isLoading = false;

  Metadata _metadata = Metadata(
    limit: 10,
    totalData: 0,
    totalPages: 1,
    currentPage: 1,
  );
  String _errorMessage = '';
  DateTime? _selectedDate;
  int _limit = 10;
  final List<int> _availableLimits = [5, 10, 20, 50, 100];

  List<MenstrualCycle> get cycles => _cycles;
  bool get isLoading => _isLoading;
  Metadata get metadata => _metadata;
  String get errorMessage => _errorMessage;
  DateTime? get selectedDate => _selectedDate;
  int get limit => _limit;

  List<int> get availableLimits => _availableLimits;
  int get totalData => _metadata.totalData;
  int get currentPage => _metadata.currentPage;
  int get totalPages => _metadata.totalPages;

  Future<void> fetchCycles({
    DateTime? date,
    int page = 1,
    int? limit,
    bool isRefresh = false,
  }) async {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 📅 [MenstrualHistoryProvider] Fetch cycles');
      debugPrint('│ 📅 Date: ${date != null ? DateFormat('yyyy-MM-dd').format(date) : "All dates"}');
      debugPrint('│ 📄 Page: $page');
      debugPrint('│ 📊 Limit: ${limit ?? _limit}');
      debugPrint('│ 🔄 Refresh: $isRefresh');
    }
    
    if (!isRefresh) _isLoading = true;
    _selectedDate = date;
    if (limit != null) _limit = limit;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final baseUrl = dotenv.env['API_URL'];

      if (kDebugMode) {
        debugPrint('│ 🔑 Token: ${token != null ? "✓ (${token.length} chars)" : "✗ Missing"}');
      }

      String url = '$baseUrl/menstrual/cycles?page=$page&limit=$_limit';
      if (date != null) {
        final formattedDate = DateFormat('yyyy-MM-dd').format(date);
        url += '&date=$formattedDate';
      }

      if (kDebugMode) {
        debugPrint('│ 🌐 API URL: $url');
        debugPrint('│ 📡 Fetching cycles...');
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
        debugPrint('│ 📊 Response Status: ${response.statusCode}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        if (data['status'] == true) {
          // Case 1: Data kosong (response berupa array kosong)
          if (data['data'] is List && data['data'].isEmpty) {
            _cycles = [];
            _metadata = Metadata(
              limit: _limit,
              totalData: 0,
              totalPages: 1,
              currentPage: 1,
            );
            _errorMessage = data['message'] ?? '';
            
            if (kDebugMode) {
              debugPrint('│ 📭 No cycles found');
              debugPrint('│ 💬 Message: $_errorMessage');
            }
          }
          // Case 2: Data ada (response berupa object dengan data dan metadata)
          else if (data['data'] is Map && data['data']['data'] is List) {
            final cycleResponse = MenstrualCycleResponse.fromJson(data['data']);
            _cycles = cycleResponse.cycles;
            _metadata = cycleResponse.metadata;
            _errorMessage = '';
            
            if (kDebugMode) {
              debugPrint('│ ✅ Fetched ${_cycles.length} cycles');
              debugPrint('│ 📊 Total Data: ${_metadata.totalData}');
              debugPrint('│ 📄 Current Page: ${_metadata.currentPage}/${_metadata.totalPages}');
            }
          }
          // Case 3: Format response tidak dikenali
          else {
            _errorMessage = 'Format response tidak valid';
            
            if (kDebugMode) {
              debugPrint('│ ❌ Invalid response format');
              debugPrint('│ 📄 Data type: ${data['data'].runtimeType}');
            }
          }
          
          if (kDebugMode) {
            debugPrint('│ ✅ Fetch completed successfully');
            debugPrint('└─────────────────────────────────────────');
          }
        } else {
          _errorMessage = data['message'] ?? 'Gagal mengambil data siklus';
          
          if (kDebugMode) {
            debugPrint('│ ❌ Status false in response');
            debugPrint('│ 💬 Error: $_errorMessage');
            debugPrint('└─────────────────────────────────────────');
          }
        }
      } else {
        _errorMessage = 'Gagal memuat data: ${response.statusCode}';
        
        if (kDebugMode) {
          debugPrint('│ ❌ Failed to fetch cycles');
          debugPrint('│ 📊 Status: ${response.statusCode}');
          debugPrint('│ 💬 Error: $_errorMessage');
          debugPrint('└─────────────────────────────────────────');
        }
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      
      if (kDebugMode) {
        debugPrint('│ ❌ Exception caught');
        debugPrint('│ 🔥 Error type: ${e.runtimeType}');
        debugPrint('│ 💬 Error: $_errorMessage');
        debugPrint('└─────────────────────────────────────────');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setLimit(int newLimit) async {
    await fetchCycles(limit: newLimit, page: 1);
  }

  Future<void> goToPage(int page) async {
    await fetchCycles(page: page);
  }

  Future<void> refreshData() async {
    await fetchCycles(isRefresh: true);
  }

  Future<void> clearDateFilter() async {
    _selectedDate = null;
    await fetchCycles(page: 1);
  }

  Future<void> loadNextPage() async {
    if (_metadata.currentPage < _metadata.totalPages && !_isLoading) {
      await fetchCycles(page: _metadata.currentPage + 1);
    }
  }
}

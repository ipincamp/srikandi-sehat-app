import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/models/cycle_history_model.dart';
import 'package:app/utils/logger.dart';

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
    AppLogger.startSection(
      'CycleTrackingProvider - Fetch cycle history',
      emoji: '🔄',
    );
    AppLogger.log('CycleTrackingProvider', 'Refresh: $refresh', emoji: '🔄');
    AppLogger.log(
      'CycleTrackingProvider',
      'Current Page: $_currentPage',
      emoji: '📄',
    );
    AppLogger.log('CycleTrackingProvider', 'Has More: $_hasMore', emoji: '📊');

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _emptyMessage = null;

      AppLogger.log(
        'CycleTrackingProvider',
        'Reset pagination state',
        emoji: '♻️',
      );
    }

    if (!_hasMore && !refresh) {
      AppLogger.warning('CycleTrackingProvider', 'No more data to fetch');
      AppLogger.endSection();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      AppLogger.log(
        'CycleTrackingProvider',
        'Retrieving auth token...',
        emoji: '🔑',
      );

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final apiUrl = dotenv.env['API_URL'];

      AppLogger.log(
        'CycleTrackingProvider',
        'Token: ${token != null ? "✓ (${token.length} chars)" : "✗ Missing"}',
        emoji: '🔑',
      );
      AppLogger.log(
        'CycleTrackingProvider',
        'API URL: ${apiUrl ?? "✗ Missing"}',
        emoji: '🌐',
      );

      if (token == null || apiUrl == null) {
        _error = 'Token autentikasi atau URL API tidak ditemukan';
        _isLoading = false;
        notifyListeners();

        AppLogger.error('CycleTrackingProvider', 'Missing token or API URL');
        AppLogger.endSection();
        return;
      }

      final url = '$apiUrl/menstrual/cycles?page=$_currentPage&limit=10';

      AppLogger.apiRequest(
        method: 'GET',
        endpoint: '/menstrual/cycles?page=$_currentPage&limit=10',
        token: token,
      );

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      final responseData = json.decode(response.body) as Map<String, dynamic>;
      final cycleResponse = CycleHistoryResponse.fromJson(responseData);

      if (response.statusCode == 200) {
        AppLogger.apiResponse(
          statusCode: response.statusCode,
          endpoint: '/menstrual/cycles',
          data: cycleResponse.data,
        );
        AppLogger.log(
          'CycleTrackingProvider',
          'Received ${cycleResponse.data.length} cycles',
          emoji: '📦',
        );
        AppLogger.log(
          'CycleTrackingProvider',
          'Total Data: ${cycleResponse.metadata.totalData}',
          emoji: '📊',
        );

        if (cycleResponse.data.isEmpty && refresh) {
          _emptyMessage = 'Belum ada data siklus';
          AppLogger.warning('CycleTrackingProvider', 'No cycle data available');
        }

        if (refresh) {
          _cycleHistory = cycleResponse.data;
          AppLogger.log(
            'CycleTrackingProvider',
            'Replaced cycle history (refresh)',
            emoji: '🔄',
          );
        } else {
          _cycleHistory.addAll(cycleResponse.data);
          AppLogger.log(
            'CycleTrackingProvider',
            'Appended to cycle history',
            emoji: '➕',
          );
        }

        _hasMore = _cycleHistory.length < cycleResponse.metadata.totalData;
        _currentPage++;

        AppLogger.log(
          'CycleTrackingProvider',
          'Current Total: ${_cycleHistory.length}',
          emoji: '📊',
        );
        AppLogger.log(
          'CycleTrackingProvider',
          'Next Page: $_currentPage',
          emoji: '📄',
        );
        AppLogger.log(
          'CycleTrackingProvider',
          'Has More: $_hasMore',
          emoji: '📊',
        );
        AppLogger.endSection(message: '✅ Fetch completed successfully');
      } else {
        _error = cycleResponse.message.isNotEmpty
            ? cycleResponse.message
            : 'Gagal memuat riwayat siklus: ${response.statusCode}';

        AppLogger.apiResponse(
          statusCode: response.statusCode,
          endpoint: '/menstrual/cycles',
          errorMessage: _error,
        );
        AppLogger.endSection();
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';

      AppLogger.exception(category: 'CycleTrackingProvider', error: e);
      AppLogger.endSection();
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
    AppLogger.startSection('CycleTrackingProvider - Reset state', emoji: '🔄');
    AppLogger.log(
      'CycleTrackingProvider',
      'Previous cycle count: ${_cycleHistory.length}',
      emoji: '📊',
    );

    _cycleHistory.clear();
    _currentPage = 1;
    _hasMore = true;
    _isLoading = false;
    _error = null;
    _emptyMessage = null;

    AppLogger.endSection(message: '✅ State reset completed');
    notifyListeners();
  }
}

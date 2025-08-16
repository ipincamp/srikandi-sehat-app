import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:srikandi_sehat_app/models/cycle_history_model.dart';

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
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _emptyMessage = null;
    }

    if (!_hasMore && !refresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final apiUrl = dotenv.env['API_URL'];

      if (token == null || apiUrl == null) {
        _error = 'Token autentikasi atau URL API tidak ditemukan';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http
          .get(
            Uri.parse('$apiUrl/menstrual/cycles?page=$_currentPage&limit=10'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      final responseData = json.decode(response.body) as Map<String, dynamic>;
      final cycleResponse = CycleHistoryResponse.fromJson(responseData);

      if (response.statusCode == 200) {
        if (cycleResponse.data.isEmpty && refresh) {
          _emptyMessage = 'Belum ada data siklus';
        }
        debugPrint('Cycle history fetched successfully: ${responseData} items');

        if (refresh) {
          _cycleHistory = cycleResponse.data;
        } else {
          _cycleHistory.addAll(cycleResponse.data);
        }

        _hasMore = _cycleHistory.length < cycleResponse.metadata.totalData;
        _currentPage++;
      } else {
        _error = cycleResponse.message.isNotEmpty
            ? cycleResponse.message
            : 'Gagal memuat riwayat siklus: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

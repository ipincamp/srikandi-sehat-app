import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikandi_sehat_app/models/menstural_cycle_model.dart';
import 'dart:convert';

class MenstrualCycleProvider with ChangeNotifier {
  List<MenstrualCycle> _cycles = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _totalPages = 1;
  String _errorMessage = '';
  int _totalData = 0;

  List<MenstrualCycle> get cycles => _cycles;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  String get errorMessage => _errorMessage;
  int get totalData => _totalData;

  Future<void> fetchCycles({int page = 1, int limit = 5}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final baseUrl = dotenv.env['API_URL'];
      final url = '$baseUrl/menstrual/cycles';

      final response = await http.get(
        Uri.parse('$url?page=$page&limit=$limit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          final cycleResponse = MenstrualCycleResponse.fromJson(data['data']);
          _cycles = cycleResponse.cycles;
          _currentPage = cycleResponse.metadata.currentPage;
          _totalPages = cycleResponse.metadata.totalPages;
          _totalData = cycleResponse.metadata.totalData;
          _errorMessage = '';
        } else {
          _errorMessage = data['message'] ?? 'Gagal mengambil data siklus';
        }
      } else {
        _errorMessage = 'Gagal memuat data: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNextPage() async {
    if (_currentPage < _totalPages && !_isLoading) {
      await fetchCycles(page: _currentPage + 1);
    }
  }

  Future<void> refreshData() async {
    await fetchCycles(page: 1);
  }
}

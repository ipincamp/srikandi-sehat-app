import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikandi_sehat_app/models/menstural_history_model.dart';
import 'dart:convert';

class MenstrualHistoryProvider with ChangeNotifier {
  List<MenstrualCycle> _cycles = [];
  bool _isLoading = false;
  MenstrualCycleMetadata _metadata = MenstrualCycleMetadata(
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
  MenstrualCycleMetadata get metadata => _metadata;
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
    if (!isRefresh) _isLoading = true;
    _selectedDate = date;
    if (limit != null) _limit = limit;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final baseUrl = dotenv.env['API_URL'];

      String url = '$baseUrl/menstrual/cycles?page=$page&limit=$_limit';
      if (date != null) {
        final formattedDate = DateFormat('yyyy-MM-dd').format(date);
        url += '&date=$formattedDate';
      }

      final response = await http.get(
        Uri.parse(url),
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
          _metadata = cycleResponse.metadata;
          _errorMessage = '';
        } else {
          _errorMessage = data['message'] ?? 'Gagal mengambil data siklus';
        }
      } else {
        _errorMessage = 'Gagal memuat data: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      debugPrint('Error fetching menstrual cycles: $e');
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

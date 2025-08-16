import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikandi_sehat_app/models/symptom_history_model.dart';

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

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = SymptomHistoryResponse.fromJson(jsonDecode(response.body));
        _symptoms = data.data.data;
        _metadata = data.data.metadata;
      } else {
        throw Exception(
          'Failed to load symptom history: ${response.statusCode}',
        );
      }
    } catch (e) {
      _errorMessage = 'Error fetching symptom history: $e';
      debugPrint('Error fetching symptom history: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setLimit(int newLimit) async {
    await fetchSymptomHistory(limit: newLimit, page: 1);
  }

  Future<void> goToPage(int page) async {
    await fetchSymptomHistory(page: page);
  }

  Future<void> refreshData() async {
    await fetchSymptomHistory(isRefresh: true);
  }

  Future<void> clearDateFilter() async {
    _selectedDate = null;
    await fetchSymptomHistory(page: 1);
  }
}

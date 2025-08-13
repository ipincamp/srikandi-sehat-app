import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikandi_sehat_app/models/menstural_history_detail_model.dart';

class MenstrualCycleDetailProvider with ChangeNotifier {
  MenstrualCycleDetail? _cycleDetail;
  bool _isLoading = false;
  String? _error;

  MenstrualCycleDetail? get cycleDetail => _cycleDetail;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCycleDetail(int cycleId) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final baseUrl = dotenv.env['API_URL'] ?? '';
      final url = '$baseUrl/menstrual/cycles/$cycleId';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['data'] != null) {
          _cycleDetail = MenstrualCycleDetail.fromJson(jsonData['data']);
        } else {
          _error = 'Data tidak tersedia';
        }
      } else {
        _error = 'Gagal memuat data: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _cycleDetail = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
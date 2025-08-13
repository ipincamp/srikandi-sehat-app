import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikandi_sehat_app/models/symptom_detail_model.dart';

class SymptomDetailProvider with ChangeNotifier {
  SymptomDetail? _detail;
  bool _isLoading = false;
  String? _error;

  SymptomDetail? get detail => _detail;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDetail(int id) async {
    print('ini adalah id detail symptom: $id');
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final baseUrl = dotenv.env['API_URL'] ?? '';
      final url = '$baseUrl/menstrual/symptoms/log/$id';
      print('Fetching symptom detail from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('Symptom detail fetched successfully: $jsonData');
        _detail = SymptomDetail.fromJson(jsonData['data']);
      } else {
        _error = 'Failed to load data: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _detail = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}

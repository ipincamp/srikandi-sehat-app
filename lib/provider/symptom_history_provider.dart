import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikandi_sehat_app/models/symptom_history_model.dart'; // pastikan path benar

class SymptomHistoryProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Symptom> _symptomHistory = [];
  List<Symptom> get symptomHistory => _symptomHistory;

  Future<bool> fetchSymptomHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final baseUrl = dotenv.env['API_URL'];
      final url = '$baseUrl/menstrual/symptoms/history';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      _isLoading = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _symptomHistory = List<Symptom>.from(
          data['data'].map((json) => Symptom.fromJson(json)),
        );
        // print('Symptom history fetched successfully: ${_symptomHistory} items');
        notifyListeners();
        return true;
      } else {
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error fetching symptom history: $e');
      return false;
    }
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SymptomLogProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> logSymptoms({
    required List<String> symptoms,
    int? moodScore,
    String? notes,
    required String logDate,
  }) async { 
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final baseUrl = dotenv.env['API_URL'];
      final url = '$baseUrl/cycles/symptoms';

      final body = {
        "symptoms": symptoms,
        if (moodScore != null) "mood_score": moodScore,
        if (notes != null) "notes": notes,
        "log_date": logDate,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      _isLoading = false;
      notifyListeners();

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error logging symptoms: $e');
      return false;
    }
  }
}

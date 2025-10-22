import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/models/symptom_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SymptomProvider with ChangeNotifier {
  List<Symptom> _symptoms = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _usingFallbackData = false;

  List<Symptom> get symptoms => _symptoms;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get usingFallbackData => _usingFallbackData;

  // Data statis fallback
  static List<Symptom> get fallbackSymptoms {
    return [
      Symptom(id: 1, name: "Dismenore", type: "BASIC"),
      Symptom(id: 2, name: "Kram Perut", type: "BASIC"),
      Symptom(id: 3, name: "5L", type: "BASIC"),
      Symptom(
        id: 4,
        name: "Mood Swing",
        type: "OPTIONS",
        options: [
          {"id": 1, "name": "Senang"},
          {"id": 2, "name": "Biasa"},
          {"id": 3, "name": "Galau"},
          {"id": 4, "name": "Sedih"},
          {"id": 5, "name": "Marah"},
        ],
      ),
    ];
  }

  Future<void> fetchSymptoms() async {
    _isLoading = true;
    _errorMessage = '';
    _usingFallbackData = false;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final baseUrl = dotenv.env['API_URL'];
      final url = '$baseUrl/menstrual/symptoms/master';

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'] ?? [];
        _symptoms = data.map((e) => Symptom.fromJson(e)).toList();
      } else {
        _errorMessage = 'Gagal mengambil data gejala (${response.statusCode}).';
        _useFallbackData();
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      _useFallbackData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _useFallbackData() {
    _symptoms = fallbackSymptoms;
    _usingFallbackData = true;
  }

  // Untuk testing: force menggunakan data fallback
  void useFallbackForTesting() {
    _useFallbackData();
    notifyListeners();
  }
}

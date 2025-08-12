import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikandi_sehat_app/models/symptom_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SymptomProvider with ChangeNotifier {
  List<Symptom> _symptoms = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Symptom> get symptoms => _symptoms;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchSymptoms() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('token') ?? '';
      final baseUrl = dotenv.env['API_URL'];
      final url = '$baseUrl/menstrual/symptoms/master';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        print(jsonBody);
        final List<dynamic> data = jsonBody['data'] ?? [];
        _symptoms = data.map((e) => Symptom.fromJson(e)).toList();
      } else {
        _errorMessage = 'Gagal mengambil data gejala.';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

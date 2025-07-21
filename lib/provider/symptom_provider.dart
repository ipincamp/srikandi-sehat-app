import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikandi_sehat_app/models/symptom_model.dart';

class SymptomProvider with ChangeNotifier {
  List<Symptom> _symptoms = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Symptom> get symptoms => _symptoms;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchSymptoms() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final baseUrl = dotenv.env['API_URL'];
      final url = '$baseUrl/cycles/symptoms';

      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });

      _isLoading = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        _symptoms = (data['data'] as List)
            .map((json) => Symptom.fromJson(json))
            .toList();

        print(data);
        notifyListeners();
      } else {
        _errorMessage = 'Gagal memuat data gejala';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

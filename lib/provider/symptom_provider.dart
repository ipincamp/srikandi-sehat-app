import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
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

    final baseUrl = dotenv.env['API_URL'];
    final url = '$baseUrl/cycles/symptoms';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'];
        _symptoms = data.map((json) => Symptom.fromJson(json)).toList();
        // ✅ Print setelah data dimuat
        for (var symptom in _symptoms) {
          print('Loaded Symptom: ${symptom.id} - ${symptom.name}');
        }
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

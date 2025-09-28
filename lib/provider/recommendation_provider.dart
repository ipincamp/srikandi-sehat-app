import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srikandi_sehat_app/models/recommendation_model.dart';

class RecommendationProvider with ChangeNotifier {
  List<Recommendation> _recommendations = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _hasFetched = false;

  List<Recommendation> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasRecommendations => _recommendations.isNotEmpty;
  bool get hasFetched => _hasFetched;

  Future<void> fetchRecommendations() async {
    if (_hasFetched) return; // Hindari fetch berulang

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final baseUrl = dotenv.env['API_URL'];
      final url = '$baseUrl/menstrual/recommendations';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'];
        _recommendations = data
            .map((json) => Recommendation.fromJson(json))
            .toList();
        _hasFetched = true;
      } else {
        _errorMessage = 'Gagal memuat data rekomendasi';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _hasFetched = false;
    _recommendations = [];
    _errorMessage = '';
    notifyListeners();
  }
}

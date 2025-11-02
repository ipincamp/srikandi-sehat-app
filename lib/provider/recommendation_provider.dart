import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/models/recommendation_model.dart';
import 'package:app/utils/logger.dart';

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
    if (_hasFetched) {
      AppLogger.warning('RecommendationProvider', 'Already fetched, skipping');
      return; // Hindari fetch berulang
    }

    AppLogger.startSection(
      'RecommendationProvider - Fetch recommendations',
      emoji: '💡',
    );

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final baseUrl = dotenv.env['API_URL'];
      final url = '$baseUrl/menstrual/recommendations';

      AppLogger.apiRequest(
        method: 'GET',
        endpoint: '/menstrual/recommendations',
        token: token,
      );

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

        AppLogger.apiResponse(
          statusCode: response.statusCode,
          endpoint: '/menstrual/recommendations',
          data: data,
        );
        AppLogger.success(
          'RecommendationProvider',
          'Fetched ${_recommendations.length} recommendations',
        );
        AppLogger.endSection(message: '✅ Fetch completed successfully');
      } else {
        _errorMessage = 'Gagal memuat data rekomendasi';

        AppLogger.apiResponse(
          statusCode: response.statusCode,
          endpoint: '/menstrual/recommendations',
          errorMessage: _errorMessage,
        );
        AppLogger.endSection();
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';

      AppLogger.exception(category: 'RecommendationProvider', error: e);
      AppLogger.endSection();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    AppLogger.startSection('RecommendationProvider - Reset', emoji: '🔄');
    AppLogger.log(
      'RecommendationProvider',
      'Previous count: ${_recommendations.length}',
      emoji: '📊',
    );

    _hasFetched = false;
    _recommendations = [];
    _errorMessage = '';
    notifyListeners();

    AppLogger.endSection(message: '✅ Reset completed');
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/models/recommendation_model.dart';

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
      if (kDebugMode) {
        debugPrint('⚠️ [RecommendationProvider] Already fetched, skipping');
      }
      return; // Hindari fetch berulang
    }

    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 💡 [RecommendationProvider] Fetch recommendations');
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final baseUrl = dotenv.env['API_URL'];
      final url = '$baseUrl/menstrual/recommendations';

      if (kDebugMode) {
        debugPrint('│ 🔑 Token: ${token != null ? "✓ (${token.length} chars)" : "✗ Missing"}');
        debugPrint('│ 🌐 API URL: $url');
        debugPrint('│ 📡 Fetching recommendations...');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        debugPrint('│ 📊 Response Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'];
        _recommendations = data
            .map((json) => Recommendation.fromJson(json))
            .toList();
        _hasFetched = true;
        
        if (kDebugMode) {
          debugPrint('│ ✅ Fetched ${_recommendations.length} recommendations');
          debugPrint('│ ✅ Fetch completed successfully');
          debugPrint('└─────────────────────────────────────────');
        }
      } else {
        _errorMessage = 'Gagal memuat data rekomendasi';
        
        if (kDebugMode) {
          debugPrint('│ ❌ Failed to fetch recommendations');
          debugPrint('│ 📊 Status: ${response.statusCode}');
          debugPrint('│ 💬 Error: $_errorMessage');
          debugPrint('└─────────────────────────────────────────');
        }
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      
      if (kDebugMode) {
        debugPrint('│ ❌ Exception caught');
        debugPrint('│ 🔥 Error type: ${e.runtimeType}');
        debugPrint('│ 💬 Error: $_errorMessage');
        debugPrint('└─────────────────────────────────────────');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 🔄 [RecommendationProvider] Reset');
      debugPrint('│ 📊 Previous count: ${_recommendations.length}');
    }
    
    _hasFetched = false;
    _recommendations = [];
    _errorMessage = '';
    notifyListeners();
    
    if (kDebugMode) {
      debugPrint('│ ✅ Reset completed');
      debugPrint('└─────────────────────────────────────────');
    }
  }
}

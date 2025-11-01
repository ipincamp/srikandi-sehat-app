import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/village_model.dart';

class VillageProvider with ChangeNotifier {
  List<Village> _villages = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Village> get villages => _villages;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchVillages(String districtCode) async {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 🏘️ [VillageProvider] Fetch villages');
      debugPrint('│ 📍 District Code: $districtCode');
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final baseUrl = dotenv.env['API_URL'];
    final url = '$baseUrl/regions/villages?district_code=$districtCode';

    if (kDebugMode) {
      debugPrint('│ 🌐 API: $url');
    }

    try {
      final response = await http.get(Uri.parse(url));

      if (kDebugMode) {
        debugPrint('│ 📊 Response Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'];
        _villages = data.map((json) => Village.fromJson(json)).toList();

        if (kDebugMode) {
          debugPrint('│ ✅ Villages loaded successfully');
          debugPrint('│ 📊 Total Villages: ${_villages.length}');
          if (_villages.isNotEmpty) {
            debugPrint('│ 🏘️ First Village: ${_villages.first.name}');
          }
          debugPrint('└─────────────────────────────────────────');
        }
      } else {
        _errorMessage = 'Gagal memuat data desa';

        if (kDebugMode) {
          debugPrint('│ ❌ Failed to load villages');
          debugPrint('│ 💬 Error: $_errorMessage');
          debugPrint('└─────────────────────────────────────────');
        }
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';

      if (kDebugMode) {
        debugPrint('│ ❌ Exception caught!');
        debugPrint('│ 🔴 Type: ${e.runtimeType}');
        debugPrint('│ 💬 Message: ${e.toString()}');
        debugPrint('└─────────────────────────────────────────');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

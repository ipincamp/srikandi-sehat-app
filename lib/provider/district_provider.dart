import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/district_model.dart';

class DistrictProvider with ChangeNotifier {
  List<District> _districts = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<District> get districts => _districts;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchDistricts({String regencyCode = '3302'}) async {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 📍 [DistrictProvider] Fetch districts');
      debugPrint('│ 🏛️ Regency Code: $regencyCode');
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final baseUrl = dotenv.env['API_URL'];
    final url = '$baseUrl/regions/districts?regency_code=$regencyCode';

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
        _districts = data.map((json) => District.fromJson(json)).toList();

        if (kDebugMode) {
          debugPrint('│ ✅ Districts loaded successfully');
          debugPrint('│ 📊 Total Districts: ${_districts.length}');
          if (_districts.isNotEmpty) {
            debugPrint('│ 📍 First District: ${_districts.first.name}');
          }
          debugPrint('└─────────────────────────────────────────');
        }
      } else {
        _errorMessage = 'Gagal memuat data distrik';

        if (kDebugMode) {
          debugPrint('│ ❌ Failed to load districts');
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

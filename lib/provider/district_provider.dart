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
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final baseUrl = dotenv.env['API_URL'];
    final url = '$baseUrl/regions/districts?regency_code=$regencyCode';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'];
        _districts = data.map((json) => District.fromJson(json)).toList();
      } else {
        _errorMessage = 'Gagal memuat data distrik';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

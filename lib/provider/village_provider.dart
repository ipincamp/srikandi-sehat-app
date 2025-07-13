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
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final baseUrl = dotenv.env['API_URL'];
    final url = '$baseUrl/locations/districts/$districtCode/villages';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List<dynamic> data = jsonBody['data'];
        _villages = data.map((json) => Village.fromJson(json)).toList();
      } else {
        _errorMessage = 'Gagal memuat data desa';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

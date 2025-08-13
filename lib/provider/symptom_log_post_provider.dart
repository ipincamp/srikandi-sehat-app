import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SymptomLogResponse {
  final bool success;
  final int? id;
  final String? message;
  final String? error;

  SymptomLogResponse({
    required this.success,
    this.id,
    this.message,
    this.error,
  });

  factory SymptomLogResponse.fromJson(Map<String, dynamic> json) {
    return SymptomLogResponse(
      success: json['status'] ?? false,
      id: json['data']?['id'],
      message: json['message'],
    );
  }

  factory SymptomLogResponse.error(String error) {
    return SymptomLogResponse(success: false, error: error);
  }
}

class SymptomLogProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  SymptomLogResponse? _lastResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SymptomLogResponse? get lastResponse => _lastResponse;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<SymptomLogResponse> logSymptoms({
    required String loggedAt,
    String? note,
    required List<Map<String, dynamic>> symptoms,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Validate symptoms
      if (symptoms.isEmpty) {
        throw ArgumentError('Minimal pilih satu gejala');
      }

      // Validate dismenorea has option_id 1-5
      for (final symptom in symptoms) {
        if (symptom['symptom_id'] == 4) {
          if (symptom['option_id'] == null) {
            throw ArgumentError('Dismenorea harus memilih tingkat keparahan');
          }
          if (symptom['option_id'] < 1 || symptom['option_id'] > 5) {
            throw ArgumentError('Tingkat dismenorea harus antara 1-5');
          }
        }
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print(token);

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final baseUrl = dotenv.env['API_URL'];
      if (baseUrl == null) {
        throw Exception('API URL tidak dikonfigurasi');
      }
      print('$baseUrl/menstrual/symptoms/log');
      print(
        jsonEncode({'logged_at': loggedAt, 'note': note, 'symptoms': symptoms}),
      );

      final response = await http
          .post(
            Uri.parse('$baseUrl/menstrual/symptoms/log'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'logged_at': loggedAt,
              'note': note,
              'symptoms': symptoms,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _lastResponse = SymptomLogResponse.fromJson(data);
        return _lastResponse!;
      } else {
        final error =
            jsonDecode(response.body)['message'] ?? 'Terjadi kesalahan';
        throw Exception(error);
      }
    } on ArgumentError catch (e) {
      _setError(e.message);
      return SymptomLogResponse.error(e.message);
    } on Exception catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return SymptomLogResponse.error(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}

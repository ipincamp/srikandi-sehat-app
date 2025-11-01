import 'dart:convert';
import 'package:flutter/foundation.dart';
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
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 📝 [SymptomLogProvider] Log symptoms');
      debugPrint('│ 📅 Logged At: $loggedAt');
      debugPrint('│ 📝 Note: ${note ?? "None"}');
      debugPrint('│ 🔢 Symptom Count: ${symptoms.length}');
    }
    
    _setLoading(true);
    _setError(null);

    try {
      // Validate symptoms
      if (symptoms.isEmpty) {
        if (kDebugMode) {
          debugPrint('│ ❌ Validation failed: No symptoms selected');
          debugPrint('└─────────────────────────────────────────');
        }
        throw ArgumentError('Minimal pilih satu gejala');
      }

      // Validate dismenorea has option_id 1-5
      for (final symptom in symptoms) {
        if (symptom['symptom_id'] == 4) {
          if (symptom['option_id'] == null) {
            if (kDebugMode) {
              debugPrint('│ ❌ Validation failed: Dismenorea missing severity');
              debugPrint('└─────────────────────────────────────────');
            }
            throw ArgumentError('Dismenorea harus memilih tingkat keparahan');
          }
          if (symptom['option_id'] < 1 || symptom['option_id'] > 5) {
            if (kDebugMode) {
              debugPrint('│ ❌ Validation failed: Dismenorea severity out of range');
              debugPrint('└─────────────────────────────────────────');
            }
            throw ArgumentError('Tingkat dismenorea harus antara 1-5');
          }
        }
      }

      if (kDebugMode) {
        debugPrint('│ ✅ Validation passed');
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (kDebugMode) {
        debugPrint('│ 🔑 Token: ${token != null ? "✓ (${token.length} chars)" : "✗ Missing"}');
      }

      if (token == null) {
        if (kDebugMode) {
          debugPrint('│ ❌ Token not found');
          debugPrint('└─────────────────────────────────────────');
        }
        throw Exception('Token tidak ditemukan');
      }

      final baseUrl = dotenv.env['API_URL'];
      if (baseUrl == null) {
        if (kDebugMode) {
          debugPrint('│ ❌ API URL not configured');
          debugPrint('└─────────────────────────────────────────');
        }
        throw Exception('API URL tidak dikonfigurasi');
      }

      final url = '$baseUrl/menstrual/symptoms/log';
      
      if (kDebugMode) {
        debugPrint('│ 🌐 API URL: $url');
        debugPrint('│ 📡 Sending symptom log...');
      }

      final response = await http
          .post(
            Uri.parse(url),
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

      if (kDebugMode) {
        debugPrint('│ 📊 Response Status: ${response.statusCode}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _lastResponse = SymptomLogResponse.fromJson(data);
        
        if (kDebugMode) {
          debugPrint('│ ✅ Symptom log successful');
          debugPrint('│ 🆔 Log ID: ${_lastResponse?.id}');
          debugPrint('│ 💬 Message: ${_lastResponse?.message}');
          debugPrint('│ ✅ Log process completed');
          debugPrint('└─────────────────────────────────────────');
        }
        
        return _lastResponse!;
      } else {
        final error =
            jsonDecode(response.body)['message'] ?? 'Terjadi kesalahan';
        
        if (kDebugMode) {
          debugPrint('│ ❌ Failed to log symptoms');
          debugPrint('│ 📊 Status: ${response.statusCode}');
          debugPrint('│ 💬 Error: $error');
          debugPrint('└─────────────────────────────────────────');
        }
        
        throw Exception(error);
      }
    } on ArgumentError catch (e) {
      _setError(e.message);
      
      if (kDebugMode) {
        debugPrint('│ ❌ Argument error');
        debugPrint('│ 💬 Error: ${e.message}');
        debugPrint('└─────────────────────────────────────────');
      }
      
      return SymptomLogResponse.error(e.message);
    } on Exception catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      
      if (kDebugMode) {
        debugPrint('│ ❌ Exception caught');
        debugPrint('│ 🔥 Error type: ${e.runtimeType}');
        debugPrint('│ 💬 Error: ${e.toString()}');
        debugPrint('└─────────────────────────────────────────');
      }
      
      return SymptomLogResponse.error(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}

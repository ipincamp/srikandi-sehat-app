import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Enhanced response model for better type safety
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
      success: json['status'] as bool? ?? false,
      id: json['data']?['id'] as int?,
      message: json['message'] as String?,
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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<SymptomLogResponse> logSymptoms({
    required List<String> symptoms,
    int? moodScore,
    String? note,
    required String loggedAt,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Input validation
      if (symptoms.isEmpty) {
        throw ArgumentError('Symptoms list cannot be empty');
      }

      if (symptoms.contains('Mood Swing') && moodScore == null) {
        throw ArgumentError(
          'Mood score is required when Mood Swing is selected',
        );
      }

      if (moodScore != null && (moodScore < 1 || moodScore > 5)) {
        throw ArgumentError('Mood score must be between 1 and 5');
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final baseUrl = dotenv.env['API_URL'];
      if (baseUrl == null || baseUrl.isEmpty) {
        throw Exception('API URL not configured');
      }

      final url = '$baseUrl/menstrual/symptoms/log';

      final body = <String, dynamic>{
        "symptoms": symptoms,
        "log_date": loggedAt,
      };

      // Only add optional fields if they have values
      if (moodScore != null) {
        body["mood_score"] = moodScore;
      }
      if (note != null && note.trim().isNotEmpty) {
        body["note"] = note.trim();
      }

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        _lastResponse = SymptomLogResponse.fromJson(data);
        // Add this debug log to verify the response
        // debugPrint('Response data: $data');
        // debugPrint('Extracted ID: ${_lastResponse?.id}');

        return _lastResponse!;
      } else {
        // Handle different error status codes
        String errorMessage;
        try {
          final errorData = json.decode(response.body) as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? 'Unknown server error';
        } catch (_) {
          errorMessage = 'Server error: ${response.statusCode}';
        }

        _setError(errorMessage);
        return SymptomLogResponse.error(errorMessage);
      }
    } on ArgumentError catch (e) {
      _setError(e.message);
      return SymptomLogResponse.error(e.message);
    } on Exception catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      _setError(errorMsg);
      return SymptomLogResponse.error(errorMsg);
    } catch (e) {
      const errorMsg = 'Unexpected error occurred';
      _setError(errorMsg);
      return SymptomLogResponse.error(errorMsg);
    } finally {
      _setLoading(false);
    }
  }

  // Method to retry the last failed request
  Future<SymptomLogResponse> retry() async {
    if (_lastResponse != null && !_lastResponse!.success) {
      // You would need to store the last request parameters to retry
      // This is a placeholder for the retry functionality
      throw UnimplementedError(
        'Retry functionality needs last request parameters',
      );
    }
    throw StateError('No failed request to retry');
  }
}

// providers/cycle_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:srikandi_sehat_app/models/cycle_status_model.dart';

class CycleProvider with ChangeNotifier {
  bool _isMenstruating = false;
  CycleStatus? _cycleStatus;

  bool get isMenstruating => _isMenstruating;
  CycleStatus? get cycleStatus => _cycleStatus;

  Future<void> loadCycleStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final apiUrl = dotenv.env['API_URL'];

      // First try to load from server
      if (token != null &&
          token.isNotEmpty &&
          apiUrl != null &&
          apiUrl.isNotEmpty) {
        final response = await http.get(
          Uri.parse('$apiUrl/cycles/status'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          _cycleStatus = CycleStatus.fromJson(data['data']);
          _isMenstruating = _cycleStatus?.isMenstruating ?? false;

          // Save to local storage
          await prefs.setBool('isMenstruating', _isMenstruating);
        }
      }

      // Fallback to local storage if server fails
      if (_cycleStatus == null) {
        _isMenstruating = prefs.getBool('isMenstruating') ?? false;
      }

      notifyListeners();
    } catch (e) {
      // Use local storage as fallback
      final prefs = await SharedPreferences.getInstance();
      _isMenstruating = prefs.getBool('isMenstruating') ?? false;
      notifyListeners();
    }
  }

  Future<void> startCycle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final apiUrl = dotenv.env['API_URL'];

      if (token == null || token.isEmpty || apiUrl == null || apiUrl.isEmpty) {
        throw Exception('Authentication or configuration error');
      }

      final response = await http.post(
        Uri.parse('$apiUrl/cycles/start'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 201) {
        _isMenstruating = true;
        await prefs.setBool('isMenstruating', true);
        await loadCycleStatus(); // Refresh the status
      } else {
        throw Exception('Failed to start cycle');
      }
    } catch (e) {
      print('Error starting cycle: $e');
      rethrow;
    }
  }

  Future<void> endCycle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final apiUrl = dotenv.env['API_URL'];

      if (token == null || token.isEmpty || apiUrl == null || apiUrl.isEmpty) {
        throw Exception('Authentication or configuration error');
      }

      final response = await http.post(
        Uri.parse('$apiUrl/cycles/finish'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _isMenstruating = false;
        await prefs.setBool('isMenstruating', false);
        await loadCycleStatus(); // Refresh the status
      } else {
        throw Exception('Failed to end cycle');
      }
    } catch (e) {
      print('Error ending cycle: $e');
      rethrow;
    }
  }
}

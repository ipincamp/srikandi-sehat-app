import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:srikandi_sehat_app/models/cycle_status_model.dart';

class CycleProvider with ChangeNotifier {
  bool _isMenstruating = false;
  CycleStatus? _cycleStatus;
  DateTime? _lastFetched;

  bool get isMenstruating => _isMenstruating;
  CycleStatus? get cycleStatus => _cycleStatus;

  static const Duration cacheDuration = Duration(minutes: 5);

  Future<void> loadCycleStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _isMenstruating = prefs.getBool('isMenstruating') ?? false;
      notifyListeners();

      await _fetchCycleStatusFromApi(prefs);
    } catch (e) {
      await _handleCycleStatusError();
    }
  }

  Future<void> _fetchCycleStatusFromApi(SharedPreferences prefs) async {
    final token = prefs.getString('token');
    final apiUrl = dotenv.env['API_URL'];

    if (token == null || token.isEmpty || apiUrl == null || apiUrl.isEmpty) {
      return;
    }

    final response = await http.get(
      Uri.parse('$apiUrl/cycles/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['data'] != null) {
        _cycleStatus = CycleStatus.fromJson(data['data']);
        _lastFetched = DateTime.now();

        _isMenstruating = _cycleStatus?.isMenstruating ?? _isMenstruating;

        await _saveCycleData(prefs);
        notifyListeners();
      }
    }

    notifyListeners();
  }

  Future<void> _saveCycleData(SharedPreferences prefs) async {
    await prefs.setBool('isMenstruating', _cycleStatus?.isMenstruating ?? false);
    await prefs.setInt('periodLengthDays', _cycleStatus?.periodLengthDays ?? 0);
    await prefs.setInt('cycleDurationDays', _cycleStatus?.cycleDurationDays ?? 0);
  }

  Future<void> _handleCycleStatusError() async {
    final prefs = await SharedPreferences.getInstance();
    _isMenstruating = prefs.getBool('isMenstruating') ?? false;

    _cycleStatus = CycleStatus(
      periodLengthDays: prefs.getInt('periodLengthDays') ?? 0,
      cycleDurationDays: prefs.getInt('cycleDurationDays') ?? 0,
      isMenstruating: _isMenstruating,
    );

    notifyListeners();
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
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 201) {
        _isMenstruating = true;
        notifyListeners();

        await _fetchCycleStatusFromApi(prefs);
      } else {
        final responseData = json.decode(response.body);
        final errorMessage = responseData['message']?.toString() ?? 'Gagal memulai siklus';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error starting cycle: $e');
      rethrow;
    }
  }

  Future<void> _handleSuccessfulCycleStart(SharedPreferences prefs) async {
    _isMenstruating = true;
    await prefs.setBool('isMenstruating', true);
    await loadCycleStatus();
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
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _isMenstruating = false;
        notifyListeners();

        await prefs.setInt('current_cycle_number', 0);
        await _fetchCycleStatusFromApi(prefs);
      } else {
        throw Exception('Failed to end cycle');
      }
    } catch (e) {
      print('Error ending cycle: $e');
      rethrow;
    }
  }

  Future<void> _handleSuccessfulCycleEnd(SharedPreferences prefs) async {
    _isMenstruating = false;
    await prefs.setBool('isMenstruating', false);
    await loadCycleStatus();
  }

  Future<void> clearCycleData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isMenstruating');
    await prefs.remove('periodLengthDays');
    await prefs.remove('cycleDurationDays');

    _cycleStatus = null;
    _isMenstruating = false;
    _lastFetched = null;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:srikandi_sehat_app/models/cycle_status_model.dart';

class CycleProvider with ChangeNotifier {
  bool _isMenstruating = false;
  CycleStatus? _cycleStatus;
  Map<String, dynamic> _notificationFlags = {};
  int? _activeCycleRunningDays;
  bool _isLoading = false;

  bool get isMenstruating => _isMenstruating;
  CycleStatus? get cycleStatus => _cycleStatus;
  Map<String, dynamic> get notificationFlags => _notificationFlags;
  int? get activeCycleRunningDays => _activeCycleRunningDays;
  bool get isLoading => _isLoading;

  Future<void> synchronizeState() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    try {
      final responses = await Future.wait([
        _fetchDataFromServer(prefs, 'status'),
        _fetchDataFromServer(prefs, 'summary'),
      ]);

      final statusResponseData = responses[0];
      final summaryResponseData = responses[1];

      if (summaryResponseData != null) {
        final runningDaysValue =
            summaryResponseData['active_cycle_running_days'];

        _isMenstruating = (runningDaysValue != null);

        _activeCycleRunningDays = (runningDaysValue is num)
            ? runningDaysValue.toInt()
            : null;
        _notificationFlags = summaryResponseData['notification_flags'] ?? {};
      } else {
        _isMenstruating = prefs.getBool('isMenstruating') ?? false;
      }

      if (statusResponseData != null) {
        statusResponseData['is_menstruating'] = _isMenstruating;
        _cycleStatus = CycleStatus.fromJson(statusResponseData);
      }

      await prefs.setBool('isMenstruating', _isMenstruating);
    } catch (e) {
      print('Gagal sinkronisasi data: $e');
      await _handleError(prefs);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> _fetchDataFromServer(
    SharedPreferences prefs,
    String endpoint,
  ) async {
    final token = prefs.getString('token');
    final apiUrl = dotenv.env['API_URL'];
    if (token == null || apiUrl == null) return null;

    try {
      final url = Uri.parse('$apiUrl/cycles/$endpoint');
      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['data'];
      }
    } catch (e) {
      print("Gagal fetch data dari endpoint '$endpoint': $e");
    }
    return null;
  }

  Future<String> startCycle(DateTime startDate) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final apiUrl = dotenv.env['API_URL'];
      if (token == null || token.isEmpty || apiUrl == null || apiUrl.isEmpty) {
        throw Exception('Authentication or configuration error');
      }

      final formattedDate =
          "${DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(startDate)}+07:00";
      debugPrint('Starting cycle with date: $formattedDate');
      final response = await http.post(
        Uri.parse('$apiUrl/menstrual/cycles'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({'start_date': formattedDate}),
      );

      if (response.statusCode == 201 || response.statusCode == 409) {
        await synchronizeState();
        return response.statusCode == 201
            ? 'Siklus berhasil dimulai!'
            : 'Melanjutkan siklus yang sudah aktif.';
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
          responseData['message']?.toString() ?? 'Gagal memulai siklus.',
        );
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error saat memulai siklus: $e');
      rethrow;
    }
  }

  Future<void> endCycle(DateTime finishDate) async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final apiUrl = dotenv.env['API_URL'];
      if (token == null || token.isEmpty || apiUrl == null || apiUrl.isEmpty) {
        throw Exception('Authentication or configuration error');
      }

      final formattedDate = finishDate.toIso8601String();
      final response = await http.post(
        Uri.parse('$apiUrl/menstrual/cycles'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({'finish_date': formattedDate}),
      );

      if (response.statusCode == 200) {
        await synchronizeState();
      } else {
        throw Exception('Gagal mengakhiri siklus');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error saat mengakhiri siklus: $e');
      rethrow;
    }
  }

  Future<void> _handleError(SharedPreferences prefs) async {
    _isMenstruating = prefs.getBool('isMenstruating') ?? false;
    _cycleStatus = CycleStatus(isMenstruating: _isMenstruating);
  }
}

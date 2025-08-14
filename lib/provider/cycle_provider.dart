import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:srikandi_sehat_app/models/cycle_status_model.dart';
import 'package:srikandi_sehat_app/utils/datetime_format.dart';

class CycleProvider with ChangeNotifier {
  bool _isMenstruating = false;
  bool _isOnCycle = false; // New field to track cycle status
  CycleStatus? _cycleStatus;
  Map<String, dynamic> _notificationFlags = {};
  int? _activeCycleRunningDays;
  bool _isLoading = false;

  bool get isMenstruating => _isMenstruating;
  bool get isOnCycle => _isOnCycle; // New getter
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

        _isOnCycle =
            summaryResponseData['is_on_cycle'] ??
            false; // Set is_on_cycle status
        _isMenstruating =
            (runningDaysValue != null) &&
            _isOnCycle; // Only menstruating if on cycle

        _activeCycleRunningDays = (runningDaysValue is num)
            ? runningDaysValue.toInt()
            : null;
        _notificationFlags = summaryResponseData['notification_flags'] ?? {};
      } else {
        _isMenstruating = prefs.getBool('isMenstruating') ?? false;
        _isOnCycle =
            prefs.getBool('isOnCycle') ?? false; // Fallback to local storage
      }

      if (statusResponseData != null) {
        statusResponseData['is_menstruating'] = _isMenstruating;
        statusResponseData['is_on_cycle'] = _isOnCycle; // Include in status
        _cycleStatus = CycleStatus.fromJson(statusResponseData);
      }

      await prefs.setBool('isMenstruating', _isMenstruating);
      await prefs.setBool('isOnCycle', _isOnCycle); // Save to local storage
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
      final url = Uri.parse('$apiUrl/menstrual/cycles/status');
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
    if (_isOnCycle) {
      return 'Anda sudah dalam siklus menstruasi. Tidak bisa memulai siklus baru.';
    }

    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final apiUrl = dotenv.env['API_URL'];
      if (token == null || token.isEmpty || apiUrl == null || apiUrl.isEmpty) {
        throw Exception('Authentication or configuration error');
      }

      final formattedDate = startDate.toLocalIso8601String();
      debugPrint('Starting cycle with date: $formattedDate');
      final response = await http.post(
        Uri.parse('$apiUrl/menstrual/cycles'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'start_date': formattedDate,
          'is_on_cycle': true, // Explicitly set cycle status
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print(response.statusCode);
        await synchronizeState();
        final responseData = json.decode(response.body);
        return responseData['message']?.toString() ?? 'Gagal memulai siklus.';
      } else if (response.statusCode == 409) {
        final responseData = json.decode(response.body);
        throw Exception(
          responseData['message']?.toString() ??
              'Akhiri dulu siklus yang sedang berjalan.',
        );
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

  Future<String> endCycle(DateTime finishDate) async {
    if (!_isOnCycle) {
      return 'Tidak ada siklus aktif yang bisa diakhiri.';
    }

    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final apiUrl = dotenv.env['API_URL'];
      if (token == null || token.isEmpty || apiUrl == null || apiUrl.isEmpty) {
        throw Exception('Authentication or configuration error');
      }

      final formattedDate = finishDate.toLocalIso8601String();
      print(json.encode({'finish_date': formattedDate}));
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
        return 'Siklus berhasil diakhiri.';
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
          responseData['message']?.toString() ?? 'Gagal mengakhiri siklus.',
        );
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
    _isOnCycle = prefs.getBool('isOnCycle') ?? false; // Handle error case
    _cycleStatus = CycleStatus(
      isMenstruating: _isMenstruating,
      isOnCycle: _isOnCycle,
    );
  }
}

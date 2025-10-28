import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:app/models/cycle_status_model.dart';
import 'package:app/utils/date_format.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class CycleProvider with ChangeNotifier {
  bool _isOnCycle = false;
  CycleStatus? _cycleStatus;
  Map<String, dynamic> _notificationFlags = {};
  int? _activeCycleRunningDays;
  bool _isLoading = false;
  bool _hasNetworkError = false;

  bool get isOnCycle => _isOnCycle;
  CycleStatus? get cycleStatus => _cycleStatus;
  Map<String, dynamic> get notificationFlags => _notificationFlags;
  int? get activeCycleRunningDays => _activeCycleRunningDays;
  bool get isLoading => _isLoading;
  bool get hasNetworkError => _hasNetworkError;

  Future<bool> _checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> _showNetworkErrorAlert(BuildContext context) async {
    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Tidak Ada Koneksi Internet'),
          content: const Text(
            'Silakan periksa koneksi internet Anda dan coba lagi.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _checkProfileCompletion(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final isProfileComplete = prefs.getBool('profile_complete') ?? false;

    if (!isProfileComplete && context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 8,
          title: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: Colors.orange.shade700,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Profil Belum Lengkap',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Untuk menggunakan fitur pelacakan siklus menstruasi, Anda perlu melengkapi Profile',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'NANTI',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/edit-profile');
              },
              child: const Text(
                'LENGKAPI SEKARANG',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        ),
      );
    }
  }

  Future<void> synchronizeState({BuildContext? context}) async {
    _isLoading = true;
    _hasNetworkError = false;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    try {
      final responses = await Future.wait([
        _fetchDataFromServer(prefs, 'status'),
      ]);

      // Check profile completion if context is provided
      if (context != null) {
        await _checkProfileCompletion(context);
      }

      final statusResponseData = responses[0];

      // Prioritize status response for isOnCycle
      if (statusResponseData != null) {
        _isOnCycle = statusResponseData['is_on_cycle'] ?? false;
        statusResponseData['is_on_cycle'] = _isOnCycle;
        _cycleStatus = CycleStatus.fromJson(statusResponseData);
      } else {
        // Fallback to local storage if no summary data
        _isOnCycle = prefs.getBool('isOnCycle') ?? _isOnCycle;
      }

      // Save the state to local storage
      await prefs.setBool('isOnCycle', _isOnCycle);
    } catch (e) {
      _hasNetworkError = true;
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
      final url = Uri.parse('$apiUrl/menstrual/cycles/$endpoint');
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
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String> startCycle(DateTime startDate, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final isProfileComplete = prefs.getBool('profile_complete') ?? false;

    if (!isProfileComplete) {
      await _checkProfileCompletion(context);
      return 'Silakan lengkapi profil terlebih dahulu';
    }

    if (_isOnCycle) {
      return 'Anda sudah dalam siklus menstruasi. Tidak bisa memulai siklus baru.';
    }

    if (kDebugMode) {
      print(_isOnCycle);
    }

    // Check internet connection - Hanya untuk operasi POST
    final hasConnection = await _checkInternetConnection();
    if (!hasConnection) {
      await _showNetworkErrorAlert(context);
      return 'Tidak ada koneksi internet';
    }

    _isLoading = true;
    notifyListeners();

    try {
      final token = prefs.getString('token');
      final apiUrl = dotenv.env['API_URL'];
      if (token == null || token.isEmpty || apiUrl == null || apiUrl.isEmpty) {
        throw Exception('Authentication or configuration error');
      }

      final formattedDate = startDate.toLocalIso8601String();
      final response = await http.post(
        Uri.parse('$apiUrl/menstrual/cycles'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({'start_date': formattedDate, 'is_on_cycle': true}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        await synchronizeState(context: context); // This will update isOnCycle
        final responseData = json.decode(response.body);
        return responseData['message']?.toString() ??
            'Siklus berhasil dimulai.';
      }
      if (response.statusCode == 409) {
        final responseData = json.decode(response.body);
        throw Exception(
          responseData['message']?.toString() ?? 'Siklus sudah dimulai.',
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
      rethrow;
    }
  }

  Future<String> endCycle(DateTime finishDate, BuildContext context) async {
    // Check internet connection - Hanya untuk operasi POST
    final hasConnection = await _checkInternetConnection();
    if (!hasConnection) {
      await _showNetworkErrorAlert(context);
      return 'Tidak ada koneksi internet';
    }

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
        await synchronizeState(context: context); // This will update isOnCycle
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
      rethrow;
    }
  }

  Future<void> _handleError(SharedPreferences prefs) async {
    _isOnCycle = prefs.getBool('isOnCycle') ?? false;
    _cycleStatus = CycleStatus(isOnCycle: _isOnCycle);
  }
}

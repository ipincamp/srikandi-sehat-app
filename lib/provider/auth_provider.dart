import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:app/provider/cycle_tracking_provider.dart';
import 'package:app/core/auth/notification_service.dart';
import 'package:app/widgets/custom_alert.dart';

class AuthProvider with ChangeNotifier {
  String? _authToken;
  String? _userId;
  String? _name;
  String? _email;
  String? _role;
  bool _profileComplete = false;
  String? _createdAt;

  String? get authToken => _authToken;
  String? get userId => _userId;
  String? get name => _name;
  String? get email => _email;
  String? get role => _role;
  bool get profileComplete => _profileComplete;
  String? get createdAt => _createdAt;

  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Check internet connection
  Future<bool> _checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Tampilkan dialog peringatan tidak ada internet
  Future<void> _showNoInternetAlert(BuildContext context) async {
    if (context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false, // User harus menekan tombol
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 8,
          title: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  color: Colors.red.shade700,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Tidak Ada Koneksi Internet',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Perangkat Anda tidak terhubung ke internet. Silakan:',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 12),
              _buildStep(
                '1. Periksa koneksi WiFi atau data seluler',
                Icons.network_check,
              ),
              _buildStep(
                '2. Hidupkan mode pesawat lalu matikan lagi',
                Icons.airplanemode_active,
              ),
              _buildStep('3. Coba muat ulang halaman', Icons.refresh),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
              child: const Text(
                'MENGERTI',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        ),
      );
    }
  }

  Widget _buildStep(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.red.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }

  // Tampilkan dialog error dengan styling yang lebih baik
  Future<void> _showErrorAlert(BuildContext context, String message) async {
    if (context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false, // User harus menekan tombol
        builder: (ctx) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header dengan icon error
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 32,
                    color: Colors.red.shade600,
                  ),
                ),

                const SizedBox(height: 16),

                // Judul
                Text(
                  'Terjadi Kesalahan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),

                const SizedBox(height: 12),

                // Pesan error
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 20),

                // Tombol aksi
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text(
                      'MENGERTI',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Future<bool> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    // Check internet connection
    final hasConnection = await _checkInternetConnection();
    if (!hasConnection) {
      _isLoading = false;
      _errorMessage = 'No internet connection';
      notifyListeners();
      await _showNoInternetAlert(context);
      return false;
    }

    final baseUrl = dotenv.env['API_URL'];
    final url = '$baseUrl/auth/login';

    print('--- LOGIN REQUEST ---');
    print('URL: $url');
    print('Headers: ${{'Content-Type': 'application/json; charset=UTF-8'}}');
    print(
      'Body: ${jsonEncode(<String, String>{'email': email, 'password': password})}',
    );

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(<String, String>{
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('--- LOGIN RESPONSE ---');
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body: ${response.body}');
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData == null || responseData['data'] == null) {
          _errorMessage = 'Invalid server response';
          notifyListeners();
          await _showErrorAlert(context, _errorMessage);
          return false;
        }

        final data = responseData['data'];
        if (data is! Map<String, dynamic>) {
          _errorMessage = 'Invalid user data format';
          notifyListeners();
          await _showErrorAlert(context, _errorMessage);
          return false;
        }

        _authToken = data['token']?.toString();
        _userId = data['id']?.toString();
        _name = data['name']?.toString();
        _email = data['email']?.toString();
        // Di method login(), setelah mendapatkan response
        _role = data['role']?.toString().toLowerCase(); // Convert ke lowercase

        // Validasi role yang diharapkan
        if (_role != 'user' && _role != 'admin') {
          _errorMessage = 'Role tidak valid: $_role';
          notifyListeners();
          return false;
        }
        _profileComplete = data['profile_complete'] ?? false;
        _createdAt = data['created_at']?.toString();

        if (_authToken == null || _userId == null) {
          _errorMessage = 'Missing required user data';
          notifyListeners();
          await _showErrorAlert(context, _errorMessage);
          return false;
        }

        // Save to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('token', _authToken!);
        await prefs.setString('userId', _userId!);
        await prefs.setString('name', _name ?? '');
        await prefs.setString('email', _email ?? '');
        await prefs.setString('role', _role ?? '');
        await prefs.setBool('profile_complete', _profileComplete);
        await prefs.setString('created_at', _createdAt ?? '');

        await updateFcmToken(); // Cek dan update token FCM

        notifyListeners();
        return true;
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        _errorMessage = "Email atau Kata sandi salah";
        notifyListeners();
        return false;
      } else {
        _errorMessage =
            responseData['message']?.toString() ??
            responseData['error']?.toString() ??
            'Login failed with status ${response.statusCode}';
        notifyListeners();
        await _showErrorAlert(context, _errorMessage);
        return false;
      }
    } catch (error) {
      _errorMessage = 'An error occurred: ${error.toString()}';
      if (error is http.ClientException ||
          error.toString().contains('SocketException')) {
        _errorMessage = 'Network error. Please check your internet connection.';
        // await _showNoInternetAlert(context);
      } else if (error is TimeoutException) {
        _errorMessage = 'Request timed out. Please try again.';
        await _showErrorAlert(context, _errorMessage);
      }
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(
    String name,
    String email,
    String password,
    String confirmPassword,
    String fcmToken,
    BuildContext context,
  ) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    // Check internet connection
    final hasConnection = await _checkInternetConnection();
    if (!hasConnection) {
      _isLoading = false;
      _errorMessage = 'No internet connection';
      notifyListeners();
      await _showNoInternetAlert(context);
      return false;
    }

    final baseUrl = dotenv.env['API_URL'];
    final url = '$baseUrl/auth/register';

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(<String, String>{
              'name': name,
              'email': email,
              'password': password,
              'password_confirmation': confirmPassword,
              'fcm_token': fcmToken,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 202) {
        // Simpan token FCM yang digunakan untuk registrasi
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_sent_fcm_token', fcmToken);
        print("FCM Token dari registrasi disimpan lokal."); // Debugging

        // Status 202 (Accepted) dianggap sukses
        _errorMessage =
            responseData['message'] ??
            'Pendaftaran sedang diproses. Anda akan menerima notifikasi.';
        notifyListeners();

        if (context.mounted) {
          CustomAlert.show(
            context,
            _errorMessage,
            type: AlertType.info,
            duration: const Duration(seconds: 4),
          );
          // Langsung navigasi setelah menampilkan alert
          Navigator.pushReplacementNamed(context, '/login');
        }
        return true;

        // if (context.mounted) {
        //   await showDialog(
        //     context: context,
        //     barrierDismissible: false, // User harus tekan tombol
        //     builder: (ctx) => AlertDialog(
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(12.0),
        //       ),
        //       title: const Text(
        //         'Pendaftaran Diproses',
        //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        //         textAlign: TextAlign.center,
        //       ),
        //       content: Text(
        //         _errorMessage,
        //         style: const TextStyle(fontSize: 14),
        //         textAlign: TextAlign.center,
        //       ),
        //       actionsAlignment: MainAxisAlignment.center,
        //       actions: [
        //         ElevatedButton(
        //           style: ElevatedButton.styleFrom(
        //             backgroundColor: Colors.blue,
        //             minimumSize: const Size(120, 40),
        //             shape: RoundedRectangleBorder(
        //               borderRadius: BorderRadius.circular(8),
        //             ),
        //           ),
        //           onPressed: () => Navigator.of(ctx).pop(),
        //           child: const Text(
        //             'Mengerti',
        //             style: TextStyle(
        //               color: Colors.white,
        //               fontWeight: FontWeight.w500,
        //             ),
        //           ),
        //         ),
        //       ],
        //       contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        //       actionsPadding: const EdgeInsets.only(bottom: 16),
        //     ),
        //   );
        // }
        // return true;
      }

      // Handle error cases
      if (responseData.containsKey('message')) {
        _errorMessage = responseData['message'];
      } else if (responseData.containsKey('errors')) {
        _errorMessage = (responseData['errors'] as Map<String, dynamic>).values
            .map((e) => e.join(', '))
            .join('\n');
      } else {
        _errorMessage = 'Pendaftaran gagal. Silakan coba lagi.';
      }

      notifyListeners();
      await _showErrorAlert(context, _errorMessage);
      return false;
    } catch (error) {
      _errorMessage = 'Terjadi kesalahan: $error';
      if (error is http.ClientException ||
          error.toString().contains('SocketException')) {
        _errorMessage = 'Kesalahan jaringan. Periksa koneksi internet Anda.';
        await _showNoInternetAlert(context);
      } else if (error is TimeoutException) {
        _errorMessage = 'Waktu permintaan habis. Silakan coba lagi.';
        await _showErrorAlert(context, _errorMessage);
      }
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> logout(BuildContext context) async {
    final cycleProvider = Provider.of<CycleTrackingProvider>(
      context,
      listen: false,
    );
    // Check internet connection
    final hasConnection = await _checkInternetConnection();
    if (!hasConnection) {
      _errorMessage = 'No internet connection';
      notifyListeners();
      await _showNoInternetAlert(context);
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final baseUrl = dotenv.env['API_URL'];
    final url = '$baseUrl/auth/logout';

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 30));

      // Clear provider state
      _authToken = null;
      _userId = null;
      _name = null;
      _email = null;
      _role = null;
      _profileComplete = false;
      _createdAt = null;

      // Clear shared preferences
      // await prefs.clear();
      await prefs.remove('isLoggedIn');
      await prefs.remove('token');
      await prefs.remove('userId');
      await prefs.remove('name');
      await prefs.remove('email');
      await prefs.remove('role');
      await prefs.remove('profile_complete');
      await prefs.remove('created_at');

      if (response.statusCode == 200) {
        notifyListeners();
        cycleProvider.resetState();
        return true;
      } else if (response.statusCode == 401) {
        notifyListeners();
        if (context.mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
        return false;
      } else {
        _errorMessage = 'Logout failed with status ${response.statusCode}';
        notifyListeners();
        await _showErrorAlert(context, _errorMessage);
        return false;
      }
    } catch (error) {
      _errorMessage = 'An error occurred: $error';
      if (error is http.ClientException ||
          error.toString().contains('SocketException')) {
        _errorMessage = 'Network error. Please check your internet connection.';
        await _showNoInternetAlert(context);
      } else if (error is TimeoutException) {
        _errorMessage = 'Request timed out. Please try again.';
        await _showErrorAlert(context, _errorMessage);
      }
      notifyListeners();
      return false;
    }
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('token');
    _userId = prefs.getString('userId');
    _name = prefs.getString('name');
    _email = prefs.getString('email');
    _role = prefs.getString('role');
    _profileComplete = prefs.getBool('profile_complete') ?? false;
    _createdAt = prefs.getString('created_at');
    notifyListeners();
  }

  Future<bool> isLoggedIn() async {
    await loadUserData();
    return _authToken != null;
  }

  Future<bool> refreshToken(BuildContext context) async {
    // Check internet connection
    final hasConnection = await _checkInternetConnection();
    if (!hasConnection) {
      _errorMessage = 'No internet connection';
      notifyListeners();
      await _showNoInternetAlert(context);
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null) return false;

      final response = await http
          .post(
            Uri.parse('${dotenv.env['API_URL']}/auth/refresh'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'refresh_token': refreshToken}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await prefs.setString('token', data['access_token']);
        await prefs.setString('refresh_token', data['refresh_token']);
        await prefs.setString('token_expiry', data['expires_at'] ?? '');
        return true;
      } else {
        _errorMessage = 'Failed to refresh token: ${response.statusCode}';
        notifyListeners();
        await _showErrorAlert(context, _errorMessage);
        return false;
      }
    } catch (error) {
      _errorMessage = 'Error refreshing token: $error';
      if (error is http.ClientException ||
          error.toString().contains('SocketException')) {
        _errorMessage = 'Network error. Please check your internet connection.';
        await _showNoInternetAlert(context);
      } else if (error is TimeoutException) {
        _errorMessage = 'Request timed out. Please try again.';
        await _showErrorAlert(context, _errorMessage);
      }
      notifyListeners();
      return false;
    }
  }

  // Fungsi untuk update FCM Token
  Future<void> updateFcmToken({String? newToken}) async {
    try {
      final notificationService = NotificationService();
      // Dapatkan token saat ini atau gunakan token baru dari onTokenRefresh
      final currentFcmToken =
          newToken ?? await notificationService.getFCMToken();

      if (currentFcmToken == null) {
        print("FCM token saat ini tidak tersedia, lewati pembaruan.");
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final lastSentToken = prefs.getString('last_sent_fcm_token');

      // Bandingkan token saat ini dengan token terakhir yang dikirim
      if (currentFcmToken != lastSentToken) {
        print(
          "Token FCM berubah atau belum pernah dikirim. Mengirim ke backend...",
        ); // Debugging

        final token = prefs.getString('token'); // Auth token
        if (token == null) {
          print("Auth token tidak ditemukan, tidak bisa update FCM token.");
          return; // Jangan lakukan update jika tidak ada auth token
        }

        final baseUrl = dotenv.env['API_URL'];
        if (baseUrl == null) {
          print("API URL tidak ditemukan.");
          return;
        }
        final url = '$baseUrl/me/fcm-token';

        final response = await http
            .patch(
              Uri.parse(url),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({'fcm_token': currentFcmToken}),
            )
            .timeout(const Duration(seconds: 15)); // Tambahkan timeout

        // Jika berhasil, simpan token yang baru dikirim
        if (response.statusCode == 200 || response.statusCode == 204) {
          await prefs.setString('last_sent_fcm_token', currentFcmToken);
          print(
            "FCM Token berhasil diupdate di backend dan disimpan lokal.",
          ); // Debugging
        } else {
          print(
            "Gagal update FCM token di backend: ${response.statusCode} - ${response.body}",
          ); // Debugging
          // Pertimbangkan: apakah perlu retry atau menampilkan error ke user?
        }
      } else {
        print(
          "Token FCM sama dengan yang terakhir dikirim, tidak perlu update.",
        ); // Debugging
      }
    } catch (e) {
      print("Gagal update FCM token: $e");
      // Pertimbangkan: apakah perlu retry atau menampilkan error ke user?
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}

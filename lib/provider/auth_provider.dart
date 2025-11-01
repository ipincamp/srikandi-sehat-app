import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _isEmailVerified = false;

  String? get authToken => _authToken;
  String? get userId => _userId;
  String? get name => _name;
  String? get email => _email;
  String? get role => _role;
  bool get profileComplete => _profileComplete;
  String? get createdAt => _createdAt;
  bool get isEmailVerified => _isEmailVerified;

  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  final _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleSignInInitialized = false;

  AuthProvider() {
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      // Sign out first to clear any cached credentials
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        // Ignore sign out errors during initialization
        if (kDebugMode) {
          debugPrint('Sign out during init (safe to ignore): $e');
        }
      }

      await _googleSignIn.initialize();
      _isGoogleSignInInitialized = true;

      if (kDebugMode) {
        debugPrint('Google Sign-In initialized successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to initialize Google Sign-In: $e');
      }
      _isGoogleSignInInitialized = false;
    }
  }

  // Check internet connection
  Future<bool> _checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
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

  Future<bool> handleGoogleSignIn(BuildContext context) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    // Ensure Google Sign-In is initialized
    if (!_isGoogleSignInInitialized) {
      await _initializeGoogleSignIn();

      if (!_isGoogleSignInInitialized) {
        _isLoading = false;
        _errorMessage =
            'Gagal menginisialisasi Google Sign-In. Silakan coba lagi.';
        notifyListeners();
        if (context.mounted) {
          await _showErrorAlert(context, _errorMessage);
        }
        return false;
      }
    }

    final hasConnection = await _checkInternetConnection();
    if (!hasConnection) {
      _isLoading = false;
      _errorMessage = 'No internet connection';
      notifyListeners();
      await _showNoInternetAlert(context);
      return false;
    }

    try {
      // authenticate() throws exceptions instead of returning null
      if (kDebugMode) {
        debugPrint('Starting Google Sign-In authentication...');
      }

      final GoogleSignInAccount account = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile', 'openid'],
      );

      if (kDebugMode) {
        debugPrint('Google Sign-In successful: ${account.email}');
        debugPrint('Display Name: ${account.displayName}');
        debugPrint('ID: ${account.id}');
      }

      // Get the authentication token
      final auth = account.authentication;
      if (kDebugMode) {
        debugPrint(
          'Got authentication, idToken is ${auth.idToken != null ? "present" : "null"}',
        );
      }

      if (auth.idToken == null) {
        throw Exception('Failed to get ID token from Google Sign-In');
      }

      return await loginWithGoogle(auth.idToken!, context);
    } on GoogleSignInException catch (e) {
      _isLoading = false;
      if (kDebugMode) {
        debugPrint('GoogleSignInException caught:');
        debugPrint('  Code: ${e.code.name}');
        debugPrint('  Description: ${e.description}');
        debugPrint('  Details: ${e.details}');
      }

      // Handle specific Google Sign-In errors
      if (e.code.name == 'canceled') {
        _errorMessage = 'Login Google dibatalkan';
        // Don't show error alert for user cancellation
      } else if (e.code.name == 'network_error') {
        _errorMessage =
            'Terjadi kesalahan jaringan. Periksa koneksi internet Anda.';
        if (context.mounted) {
          await _showErrorAlert(context, _errorMessage);
        }
      } else if (e.code.name == 'sign_in_failed') {
        _errorMessage =
            'Login Google gagal. Pastikan aplikasi Google Play Services terinstal dan diperbarui.';
        if (context.mounted) {
          await _showErrorAlert(context, _errorMessage);
        }
      } else {
        _errorMessage = 'Terjadi kesalahan: ${e.description ?? e.code.name}';
        if (context.mounted) {
          await _showErrorAlert(context, _errorMessage);
        }
      }

      notifyListeners();
      return false;
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          'Unexpected error during Google Sign-In: ${error.toString()}',
        );
        debugPrint('Error type: ${error.runtimeType}');
      }
      _isLoading = false;
      _errorMessage = 'Terjadi kesalahan tidak terduga: ${error.toString()}';
      notifyListeners();

      if (context.mounted) {
        await _showErrorAlert(context, _errorMessage);
      }

      return false;
    }
  }

  Future<bool> loginWithGoogle(String idToken, BuildContext context) async {
    // _isLoading sudah true dari handleGoogleSignIn
    final baseUrl = dotenv.env['API_URL'];
    final url = '$baseUrl/auth/google';

    if (kDebugMode) {
      debugPrint('--- GOOGLE LOGIN REQUEST ---');
      debugPrint('URL: $url');
      debugPrint(
        'Headers: ${{'Content-Type': 'application/json; charset=UTF-8'}}',
      );
      debugPrint('Body: ${jsonEncode(<String, String>{'id_token': idToken})}');
    }

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(<String, String>{'id_token': idToken}),
          )
          .timeout(const Duration(seconds: 10));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Logika sukses (sama seperti login biasa)
        final data = responseData['data'];
        _authToken = data['token']?.toString();
        _userId = data['id']?.toString();
        _name = data['name']?.toString();
        _email = data['email']?.toString();
        _role = data['role']?.toString().toLowerCase();
        _profileComplete = data['profile_complete'] ?? false;
        _createdAt = data['created_at']?.toString();
        _isEmailVerified = data['is_verified'] ?? false; // Dari Google = true

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('token', _authToken!);
        await prefs.setString('userId', _userId!);
        await prefs.setString('name', _name ?? '');
        await prefs.setString('email', _email ?? '');
        await prefs.setString('role', _role ?? '');
        await prefs.setBool('profile_complete', _profileComplete);
        await prefs.setString('created_at', _createdAt ?? '');
        await prefs.setBool('is_email_verified', _isEmailVerified);

        await updateFcmToken();
        notifyListeners();
        return true;
      } else {
        // Gagal dari backend
        _errorMessage =
            responseData['message']?.toString() ?? 'Login Google Gagal';
        await _showErrorAlert(context, _errorMessage);
        return false;
      }
    } catch (error) {
      _errorMessage = 'Terjadi kesalahan: ${error.toString()}';
      if (context.mounted) {
        await _showErrorAlert(context, _errorMessage);
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
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

    if (kDebugMode) {
      debugPrint('--- LOGIN REQUEST ---');
      debugPrint('URL: $url');
      debugPrint(
        'Headers: ${{'Content-Type': 'application/json; charset=UTF-8'}}',
      );
      debugPrint(
        'Body: ${jsonEncode(<String, String>{'email': email, 'password': password})}',
      );
    }

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

      if (kDebugMode) {
        debugPrint('--- LOGIN RESPONSE ---');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Headers: ${response.headers}');
        debugPrint('Body: ${response.body}');
      }
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
        _isEmailVerified = data['is_verified'] ?? false;

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
        await prefs.setBool('is_email_verified', _isEmailVerified);

        await updateFcmToken(); // Cek dan update token FCM

        notifyListeners();
        return true;
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        _errorMessage = "Email atau Kata sandi salah";
        notifyListeners();
        return false;
      } else {
        debugPrint('Login failed: ${response.body}');
        _errorMessage =
            responseData['message']?.toString() ??
            responseData['error']?.toString() ??
            'Login failed with status ${response.statusCode}';
        notifyListeners();
        await _showErrorAlert(context, _errorMessage);
        return false;
      }
    } catch (error) {
      _errorMessage = 'Terjadi kesalahan: ${error.toString()}';

      if (error is TimeoutException) {
        _errorMessage =
            'Waktu tunggu koneksi habis. Periksa internet Anda dan coba lagi.';
        if (context.mounted) {
          await _showErrorAlert(context, _errorMessage);
        }
      } else if (error is SocketException || error is http.ClientException) {
        debugPrint('Network Error Detected: ${error.toString()}');
        _errorMessage = 'Kesalahan jaringan. Tidak dapat terhubung ke server.';
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/maintenance',
            (route) => false,
          );
        }
      } else {
        if (context.mounted) {
          await _showErrorAlert(context, _errorMessage);
        }
      }

      if (context.mounted) {
        notifyListeners();
      }
      return false;
    } finally {
      _isLoading = false;
      if (context.mounted) {
        notifyListeners();
      }
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
              // 'fcm_token': fcmToken, // DEPRECATED
            }),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 202) {
        final data = responseData['data'];
        _authToken = data['token']?.toString();
        _userId = data['id']?.toString();
        _name = data['name']?.toString();
        _email = data['email']?.toString();
        _role = data['role']?.toString().toLowerCase();
        _profileComplete = data['profile_complete'] ?? false;
        _createdAt = data['created_at']?.toString();
        _isEmailVerified = data['is_verified'] ?? false;

        if (_authToken == null || _userId == null) {
          _errorMessage = 'Respons registrasi tidak valid';
          notifyListeners();
          await _showErrorAlert(context, _errorMessage);
          return false;
        }

        // Simpan data login ke shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('token', _authToken!);
        await prefs.setString('userId', _userId!);
        await prefs.setString('name', _name ?? '');
        await prefs.setString('email', _email ?? '');
        await prefs.setString('role', _role ?? '');
        await prefs.setBool('profile_complete', _profileComplete);
        await prefs.setString('created_at', _createdAt ?? '');
        await prefs.setBool('is_email_verified', _isEmailVerified);

        // Update FCM token
        await updateFcmToken(newToken: fcmToken);

        // Simpan pesan sukses untuk ditampilkan di UI
        _errorMessage =
            responseData['message'] ??
            'Registrasi berhasil. Silakan verifikasi email Anda.';
        notifyListeners();
        return true; // Kembalikan true (sukses)
      }

      // Handle error cases
      if (responseData.containsKey('message')) {
        _errorMessage = responseData['message'];
      } else if (responseData.containsKey('errors')) {
        _errorMessage = (responseData['errors'] as Map<String, dynamic>).values
            .map((e) => e[0]) // Ambil error pertama saja
            .join('\n');
      } else {
        _errorMessage = 'Pendaftaran gagal. Silakan coba lagi.';
      }

      notifyListeners();
      return false; // Kembalikan false (gagal)
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
      _isEmailVerified = false;

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
      await prefs.remove('is_email_verified');

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
    _isEmailVerified = prefs.getBool('is_email_verified') ?? false;
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
        if (kDebugMode) {
          debugPrint("FCM token saat ini tidak tersedia, lewati pembaruan.");
        }
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final lastSentToken = prefs.getString('last_sent_fcm_token');

      // Bandingkan token saat ini dengan token terakhir yang dikirim
      if (currentFcmToken != lastSentToken) {
        if (kDebugMode) {
          debugPrint(
            "Token FCM berubah atau belum pernah dikirim. Mengirim ke backend...",
          );
        }

        final token = prefs.getString('token'); // Auth token
        if (token == null) {
          if (kDebugMode) {
            debugPrint(
              "Auth token tidak ditemukan, tidak bisa update FCM token.",
            );
          }
          return; // Jangan lakukan update jika tidak ada auth token
        }

        final baseUrl = dotenv.env['API_URL'];
        if (baseUrl == null) {
          if (kDebugMode) {
            debugPrint("API URL tidak ditemukan.");
          }
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
          if (kDebugMode) {
            debugPrint(
              "FCM Token berhasil diupdate di backend dan disimpan lokal.",
            );
          }
        } else {
          if (kDebugMode) {
            debugPrint(
              "Gagal update FCM token di backend: ${response.statusCode} - ${response.body}",
            );
          }
        }
      } else {
        if (kDebugMode) {
          debugPrint(
            "Token FCM sama dengan yang terakhir dikirim, tidak perlu update.",
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Gagal update FCM token: $e");
      }
    }
  }

  Future<bool> resendVerificationEmail(
    BuildContext context, {
    bool showAlert = false,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final hasConnection = await _checkInternetConnection();
    if (!hasConnection) {
      _isLoading = false;
      _errorMessage = 'No internet connection';
      notifyListeners();
      await _showNoInternetAlert(context);
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final baseUrl = dotenv.env['API_URL'];
    final url = '$baseUrl/auth/resend-verification';

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 202) {
        if (showAlert && context.mounted) {
          CustomAlert.show(
            context,
            responseData['message'] ?? 'Email verifikasi telah dikirim.',
            type: AlertType.success,
            duration: const Duration(seconds: 3),
          );
        }
        return true;
      } else {
        _errorMessage =
            responseData['message'] ?? 'Gagal mengirim email verifikasi.';
        if (context.mounted) {
          await _showErrorAlert(context, _errorMessage);
        }
        return false;
      }
    } catch (error) {
      _errorMessage = 'Terjadi kesalahan: ${error.toString()}';
      if (context.mounted) {
        await _showErrorAlert(context, _errorMessage);
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitOtp(String otp, BuildContext context) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final hasConnection = await _checkInternetConnection();
    if (!hasConnection) {
      _isLoading = false;
      _errorMessage = 'No internet connection';
      notifyListeners();
      await _showNoInternetAlert(context);
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final baseUrl = dotenv.env['API_URL'];
    final url = '$baseUrl/auth/verify-otp';

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'otp': otp}),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Sukses! Update status verifikasi
        _isEmailVerified = true;
        await prefs.setBool('is_email_verified', true);

        if (context.mounted) {
          CustomAlert.show(
            context,
            responseData['message'] ?? 'Email berhasil diverifikasi!',
            type: AlertType.success,
            duration: const Duration(seconds: 2),
          );
        }
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            responseData['message'] ?? 'OTP salah atau tidak valid.';
        if (context.mounted) {
          CustomAlert.show(context, _errorMessage, type: AlertType.error);
        }
        return false;
      }
    } catch (error) {
      _errorMessage = 'Terjadi kesalahan: ${error.toString()}';
      if (context.mounted) {
        CustomAlert.show(context, _errorMessage, type: AlertType.error);
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}

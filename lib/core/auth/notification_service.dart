import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/provider/auth_provider.dart'; // Pastikan import AuthProvider ada

// Handler untuk background message harus tetap di luar kelas (top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Pastikan Firebase diinisialisasi di background handler
  await Firebase.initializeApp();
  if (kDebugMode) {
    debugPrint("Handling a background message: ${message.messageId}");
  }
  // Anda bisa menambahkan logika lain di sini jika diperlukan saat notifikasi diterima di background
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Fungsi untuk mendapatkan FCM Token
  Future<String?> getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (kDebugMode) {
        debugPrint("===================================");
        debugPrint("FCM Token: $token");
        debugPrint("===================================");
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Failed to get FCM token: $e");
      }
      return null;
    }
  }

  // Fungsi untuk meminta izin notifikasi (dipindahkan ke dalam kelas)
  Future<void> _requestNotificationPermission() async {
    try {
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          );

      if (kDebugMode) {
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          debugPrint('User granted notification permission');
        } else if (settings.authorizationStatus ==
            AuthorizationStatus.provisional) {
          debugPrint('User granted provisional notification permission');
        } else {
          debugPrint(
            'User declined or has not accepted notification permission',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error requesting notification permission: $e');
      }
    }
  }

  // Fungsi inisialisasi utama
  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    // 1. Minta izin notifikasi setelah Firebase siap
    await _requestNotificationPermission();

    // 2. Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Handler untuk notifikasi saat aplikasi di foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('Foreground message received!');
        debugPrint('Message data: ${message.data}');
        if (message.notification != null) {
          debugPrint(
            'Message also contained a notification: ${message.notification}',
          );
        }
      }

      // Logika untuk menampilkan notifikasi/alert saat di foreground (jika diperlukan)
      // Misalnya, menggunakan snackbar atau custom alert
      final context = navigatorKey.currentState?.context;
      if (context != null && message.notification != null) {
        // Anda bisa menampilkan snackbar sederhana di sini
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //      content: Text(message.notification!.body ?? 'Notifikasi baru diterima'),
        //      backgroundColor: Colors.blue, // Atau warna lain
        //    ),
        // );
        debugPrint(
          "FCM Foreground: ${message.notification!.title} - ${message.notification!.body}",
        );
      }
    });

    // 4. Handler saat notifikasi di-tap (dari background/terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('Message opened from background/terminated state!');
        debugPrint('Message data: ${message.data}');
      }
      // Logika navigasi berdasarkan data notifikasi
      if (message.data['status'] == 'success') {
        // Pastikan navigator siap sebelum navigasi
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/login', // Arahkan ke login jika status 'success'
            (route) => false,
          );
        });
      }
      // Tambahkan penanganan untuk 'screen' atau data lain jika ada
      // else if (message.data.containsKey('screen')) {
      //   final screen = message.data['screen'];
      //   WidgetsBinding.instance.addPostFrameCallback((_) {
      //      navigatorKey.currentState?.pushNamed(screen);
      //   });
      // }
    });

    // 5. Handler untuk refresh token
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      if (kDebugMode) {
        debugPrint(">>>>> FCM Token Refreshed by Firebase: $newToken <<<<<");
      }
      final context = navigatorKey.currentState?.context;
      if (context != null) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final prefs = await SharedPreferences.getInstance();
        if (prefs.getBool('isLoggedIn') == true) {
          if (kDebugMode) {
            debugPrint(
              "Mencoba update token FCM yang di-refresh ke backend...",
            );
          }
          // Kirim token baru ke backend
          await authProvider.updateFcmToken(newToken: newToken);
        } else {
          if (kDebugMode) {
            debugPrint("Pengguna tidak login, token refresh diabaikan.");
          }
        }
      } else {
        if (kDebugMode) {
          debugPrint("Konteks tidak tersedia untuk update token refresh.");
        }
      }
    });

    // Cek initial message (jika app dibuka dari notifikasi saat terminated)
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialMessage != null) {
      if (kDebugMode) {
        debugPrint('App opened from terminated state via notification!');
        debugPrint('Initial message data: ${initialMessage.data}');
      }
      // Logika navigasi berdasarkan initialMessage.data (mirip onMessageOpenedApp)
      if (initialMessage.data['status'] == 'success') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        });
      }
      // else if (initialMessage.data.containsKey('screen')) {
      //   final screen = initialMessage.data['screen'];
      //   WidgetsBinding.instance.addPostFrameCallback((_) {
      //      navigatorKey.currentState?.pushNamed(screen);
      //   });
      // }
    }
  }
}

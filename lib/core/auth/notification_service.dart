import 'package:app/provider/auth_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/custom_alert.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<String?> getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (kDebugMode) {
        print("===================================");
        print("FCM Token: $token");
        print("===================================");
      }
      return token;
    } catch (e) {
      if (kDebugMode) {
        print("Failed to get FCM token: $e");
      }
      return null;
    }
  }

  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    await FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handler for when a message is received while the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Foreground message received!');
        print('Data: ${message.data}');
      }

      final context = navigatorKey.currentState?.context;
      if (context != null && message.notification != null) {
        // Determine alert type from backend data payload
        AlertType alertType = message.data['status'] == 'success'
            ? AlertType.success
            : AlertType.error;

        // Show the custom alert
        CustomAlert.show(
          context,
          message.notification!.body ?? 'Notifikasi baru',
          // title: message.notification!.title,
          type: alertType,
          duration: const Duration(seconds: 4),
        );

        // --- NEW LOGIC: Navigate after showing the alert if successful ---
        if (message.data['status'] == 'success') {
          // Add a short delay to allow the user to see the alert
          Future.delayed(const Duration(seconds: 2), () {
            navigatorKey.currentState?.pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          });
        }
      }
    });

    // Handler for when a user taps on a notification and the app opens
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Message opened from background/terminated state!');
        print('Data: ${message.data}');
      }
      // If the app was opened from a success notification, go to login
      if (message.data['status'] == 'success') {
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      if (kDebugMode) {
        print(
          ">>>>> FCM Token Refreshed by Firebase: $newToken <<<<<",
        );
      }
      // Pastikan ada konteks yang valid untuk mengakses AuthProvider
      // Menggunakan navigatorKey adalah cara yang umum
      final context = navigatorKey.currentState?.context;
      if (context != null) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        // Hanya update jika pengguna sedang login
        final prefs = await SharedPreferences.getInstance();
        if (prefs.getBool('isLoggedIn') == true) {
          if (kDebugMode) {
            print(
              "Mencoba update token FCM yang di-refresh ke backend...",
            );
          }
          await authProvider.updateFcmToken(
            newToken: newToken,
          ); // Kirim token baru
        } else {
          if (kDebugMode) {
            print(
              "Pengguna tidak login, token refresh diabaikan.",
            );
          }
        }
      } else {
        if (kDebugMode) {
          print(
            "Konteks tidak tersedia untuk update token refresh.",
          );
        }
      }
    });
  }
}

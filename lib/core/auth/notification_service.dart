import 'package:app/provider/auth_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
        // Tampilkan notifikasi sederhana atau log saja,
        // karena alert bisa menyebabkan masalah context setelah navigasi.
        // Alert utama dan navigasi sudah ditangani oleh register_screen.

        /*
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
        */
        // --- END HAPUS ATAU KOMENTARI ---

        // Juga hapus navigasi redundan dari foreground message handler
        /*
        if (message.data['status'] == 'success') {
          Future.delayed(const Duration(seconds: 2), () {
            // Periksa lagi jika context masih valid sebelum navigasi,
            // meskipun sebaiknya navigasi ini dihapus.
            if (navigatorKey.currentState?.context != null) {
               navigatorKey.currentState?.pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            }
          });
        }
        */

        // Anda bisa menambahkan log atau menampilkan snackbar sederhana jika perlu
        if (message.notification!.body != null) {
          if (kDebugMode) {
            print(
              "FCM Foreground: ${message.notification!.title} - ${message.notification!.body}",
            );
          }
          // Opsional: Tampilkan Snackbar sederhana
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text(message.notification!.body!)),
          // );
        }
      }
    });

    // Handler for when a user taps on a notification and the app opens
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Message opened from background/terminated state!');
        print('Data: ${message.data}');
      }
      // Logika navigasi saat notifikasi DITAP
      if (message.data['status'] == 'success') {
        // Pastikan navigator siap sebelum navigasi
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        });
      }
      // Tambahkan penanganan untuk status lain
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      if (kDebugMode) {
        print(">>>>> FCM Token Refreshed by Firebase: $newToken <<<<<");
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
            print("Mencoba update token FCM yang di-refresh ke backend...");
          }
          await authProvider.updateFcmToken(
            newToken: newToken,
          ); // Kirim token baru
        } else {
          if (kDebugMode) {
            print("Pengguna tidak login, token refresh diabaikan.");
          }
        }
      } else {
        if (kDebugMode) {
          print("Konteks tidak tersedia untuk update token refresh.");
        }
      }
    });
  }
}

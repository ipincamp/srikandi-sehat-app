import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/provider/auth_provider.dart'; // Pastikan import AuthProvider ada

// Initialize flutter local notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Handler untuk background message harus tetap di luar kelas (top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Pastikan Firebase diinisialisasi di background handler
  await Firebase.initializeApp();
  if (kDebugMode) {
    debugPrint("Handling a background message: ${message.messageId}");
  }

  // DO NOT show notification here!
  // When app is in background/terminated, Firebase Messaging automatically
  // displays the notification if the message contains a 'notification' payload.
  // Only handle data-only messages or custom logic here.
}

// Helper function to show notification (can be called from background)
Future<void> _showNotification(RemoteMessage message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'srikandi_sehat_channel', // channel id
        'Srikandi Sehat Notifications', // channel name
        channelDescription: 'Notifikasi dari Srikandi Sehat',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    message.hashCode, // notification id
    message.notification?.title ?? 'Srikandi Sehat',
    message.notification?.body ?? 'Anda memiliki notifikasi baru',
    platformChannelSpecifics,
    payload: message.data.toString(),
  );
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Initialize local notifications
  Future<void> _initializeLocalNotifications(
    GlobalKey<NavigatorState> navigatorKey,
  ) async {
    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (kDebugMode) {
          debugPrint('Notification tapped with payload: ${response.payload}');
        }
        // Handle notification tap - navigate to appropriate screen
        // You can parse the payload and navigate accordingly
        final context = navigatorKey.currentState?.context;
        if (context != null) {
          // Example: navigate to notification history
          navigatorKey.currentState?.pushNamed('/notification-history');
        }
      },
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'srikandi_sehat_channel', // id
      'Srikandi Sehat Notifications', // name
      description: 'Notifikasi dari Srikandi Sehat',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

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
    // 0. Initialize local notifications first
    await _initializeLocalNotifications(navigatorKey);

    // 1. Minta izin notifikasi setelah Firebase siap
    await _requestNotificationPermission();

    // 2. Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Handler untuk notifikasi saat aplikasi di foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (kDebugMode) {
        debugPrint('Foreground message received!');
        debugPrint('Message data: ${message.data}');
        if (message.notification != null) {
          debugPrint(
            'Message also contained a notification: ${message.notification}',
          );
        }
      }

      // Show popup notification when app is in foreground
      await _showNotification(message);

      // Optional: Show snackbar or custom alert
      final context = navigatorKey.currentState?.context;
      if (context != null && message.notification != null) {
        if (kDebugMode) {
          debugPrint(
            "FCM Foreground: ${message.notification!.title} - ${message.notification!.body}",
          );
        }
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

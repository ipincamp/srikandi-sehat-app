import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/notification_provider.dart';
import 'package:app/utils/logger.dart';

// Initialize flutter local notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Handler untuk background message harus tetap di luar kelas (top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Pastikan Firebase diinisialisasi di background handler
  await Firebase.initializeApp();
  AppLogger.log(
    'NotificationService',
    'Handling a background message: ${message.messageId}',
    emoji: '🔔',
  );

  // DO NOT show notification here!
  // When app is in background/terminated, Firebase Messaging automatically
  // displays the notification if the message contains a 'notification' payload.
  // Only handle data-only messages or custom logic here.
}

// Helper function to show notification (can be called from background)
Future<void> _showNotification(RemoteMessage message) async {
  if (kIsWeb) {
    // For web, use browser's notification API or just log
    // flutter_local_notifications doesn't work on web
    AppLogger.startSection('WEB NOTIFICATION RECEIVED', emoji: '🌐');
    AppLogger.log(
      'Notification',
      'Title: ${message.notification?.title ?? 'No title'}',
    );
    AppLogger.log(
      'Notification',
      'Body: ${message.notification?.body ?? 'No body'}',
    );
    AppLogger.log('Notification', 'Data: ${message.data}');
    AppLogger.endSection();
    // Web notifications are handled by the service worker
    // Or you can show a custom in-app notification UI
    return;
  }

  // Android/iOS notification using flutter_local_notifications
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
    // Skip local notifications on web - they're handled by service worker
    if (kIsWeb) {
      AppLogger.log(
        'NotificationService',
        'Web platform detected - using service worker for notifications',
        emoji: '🌐',
      );
      return;
    }

    // Android/iOS initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        AppLogger.log(
          'NotificationService',
          'Notification tapped with payload: ${response.payload}',
          emoji: '👆',
        );
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
      // For web, need to pass VAPID key
      String? token;
      if (kIsWeb) {
        // Get the VAPID key from Firebase Console > Project Settings > Cloud Messaging > Web Push certificates
        // For now, try to get token without VAPID (might work in some cases)
        token = await _firebaseMessaging.getToken();

        AppLogger.startSection('FCM Token (Web)', emoji: '🔑');
        AppLogger.log('FCM', 'Token: $token');
        if (token == null) {
          AppLogger.warning(
            'FCM',
            'Web FCM might need VAPID key configuration',
          );
          AppLogger.log(
            'FCM',
            'Go to Firebase Console > Project Settings > Cloud Messaging',
          );
          AppLogger.log(
            'FCM',
            'Generate Web Push certificates if not done yet',
          );
        }
        AppLogger.endSection();
      } else {
        token = await _firebaseMessaging.getToken();
        AppLogger.startSection('FCM Token (Mobile)', emoji: '🔑');
        AppLogger.log('FCM', 'Token: $token');
        AppLogger.endSection();
      }
      return token;
    } catch (e) {
      AppLogger.error('NotificationService', 'Failed to get FCM token: $e');
      if (kIsWeb) {
        AppLogger.warning(
          'NotificationService',
          'Web platform detected - check service worker registration',
        );
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

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        AppLogger.success(
          'NotificationService',
          'User granted notification permission',
        );
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        AppLogger.warning(
          'NotificationService',
          'User granted provisional notification permission',
        );
      } else {
        AppLogger.warning(
          'NotificationService',
          'User declined or has not accepted notification permission',
        );
      }
    } catch (e) {
      AppLogger.error(
        'NotificationService',
        'Error requesting notification permission: $e',
      );
    }
  }

  // Fungsi inisialisasi utama
  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    AppLogger.startSection('Initializing Notification Service', emoji: '🔔');
    AppLogger.log(
      'NotificationService',
      'Platform: ${kIsWeb ? 'Web' : 'Mobile'}',
      emoji: '📱',
    );

    // 0. Initialize local notifications first (skipped on web)
    await _initializeLocalNotifications(navigatorKey);

    // 1. Minta izin notifikasi setelah Firebase siap
    await _requestNotificationPermission();

    // 2. Set background message handler (only for mobile)
    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
    }

    // 3. Handler untuk notifikasi saat aplikasi di foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      AppLogger.startSection('FOREGROUND MESSAGE RECEIVED', emoji: '📨');
      AppLogger.log(
        'NotificationService',
        'Platform: ${kIsWeb ? 'Web' : 'Mobile'}',
        emoji: '📱',
      );
      AppLogger.log(
        'NotificationService',
        'Message ID: ${message.messageId}',
        emoji: '🆔',
      );
      AppLogger.log(
        'NotificationService',
        'Message data: ${message.data}',
        emoji: '📦',
      );
      if (message.notification != null) {
        AppLogger.log(
          'NotificationService',
          'Notification Title: ${message.notification!.title}',
          emoji: '📰',
        );
        AppLogger.log(
          'NotificationService',
          'Notification Body: ${message.notification!.body}',
          emoji: '📝',
        );
      }
      AppLogger.endSection();

      // Show notification (web will just log, mobile will show popup)
      await _showNotification(message);

      // Refresh notification list in all screens
      final context = navigatorKey.currentState?.context;
      if (context != null) {
        try {
          final notificationProvider = Provider.of<NotificationProvider>(
            context,
            listen: false,
          );
          await notificationProvider.refreshNotifications();
        } catch (e) {
          AppLogger.error(
            'NotificationService',
            'Failed to refresh notifications: $e',
          );
        }

        if (message.notification != null) {
          AppLogger.log(
            'NotificationService',
            'FCM Foreground: ${message.notification!.title} - ${message.notification!.body}',
            emoji: '🔔',
          );

          // For web, show an in-app notification using SnackBar
          if (kIsWeb) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.notification!.title ?? 'Notification',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (message.notification!.body != null)
                      Text(message.notification!.body!),
                  ],
                ),
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'View',
                  onPressed: () {
                    navigatorKey.currentState?.pushNamed(
                      '/notification-history',
                    );
                  },
                ),
              ),
            );
          }
        }
      }
    });

    // 4. Handler saat notifikasi di-tap (dari background/terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.startSection('MESSAGE OPENED FROM BACKGROUND', emoji: '📲');
      AppLogger.log(
        'NotificationService',
        'Message ID: ${message.messageId}',
        emoji: '🆔',
      );
      AppLogger.log(
        'NotificationService',
        'Message data: ${message.data}',
        emoji: '📦',
      );
      AppLogger.endSection();

      // Refresh notification list when opening from background
      final context = navigatorKey.currentState?.context;
      if (context != null) {
        try {
          final notificationProvider = Provider.of<NotificationProvider>(
            context,
            listen: false,
          );
          notificationProvider.refreshNotifications();
        } catch (e) {
          AppLogger.error(
            'NotificationService',
            'Failed to refresh notifications: $e',
          );
        }
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
      AppLogger.log(
        'NotificationService',
        'FCM Token Refreshed by Firebase: $newToken',
        emoji: '🔄',
      );
      final context = navigatorKey.currentState?.context;
      if (context != null) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final prefs = await SharedPreferences.getInstance();
        if (prefs.getBool('isLoggedIn') == true) {
          AppLogger.log(
            'NotificationService',
            'Updating refreshed FCM token to backend...',
            emoji: '📡',
          );
          // Kirim token baru ke backend
          await authProvider.updateFcmToken(newToken: newToken);
        } else {
          AppLogger.warning(
            'NotificationService',
            'User not logged in, token refresh ignored',
          );
        }
      } else {
        AppLogger.warning(
          'NotificationService',
          'Context not available for token refresh update',
        );
      }
    });

    // Cek initial message (jika app dibuka dari notifikasi saat terminated)
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialMessage != null) {
      AppLogger.log(
        'NotificationService',
        'App opened from terminated state via notification!',
        emoji: '🚀',
      );
      AppLogger.log(
        'NotificationService',
        'Initial message data: ${initialMessage.data}',
        emoji: '📦',
      );
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

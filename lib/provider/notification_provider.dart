import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;
  bool _hasLoadedOnce = false; // Track if notifications have been loaded

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;
  bool get hasLoadedOnce => _hasLoadedOnce;

  // Method to refresh notifications when FCM message received
  Future<void> refreshNotifications() async {
    if (kDebugMode) {
      debugPrint('🔄 Refreshing notifications after FCM message...');
    }
    await fetchNotifications();
  }

  // Method for initial load only (call once when app starts)
  Future<void> loadInitialNotifications() async {
    if (_hasLoadedOnce) {
      if (kDebugMode) {
        debugPrint('⏭️ Notifications already loaded, skipping fetch');
      }
      return;
    }
    if (kDebugMode) {
      debugPrint('📥 Loading initial notifications...');
    }
    await fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 📡 [NotificationProvider] Fetching notifications...');
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final baseUrl = dotenv.env['API_URL'];
      final url = '$baseUrl/notifications';

      if (kDebugMode) {
        debugPrint('│ 🌐 API URL: $url');
        debugPrint('│ 🔑 Token: ${token != null ? "Present (${token.length} chars)" : "Missing"}');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        debugPrint('│ 📊 Response Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        _notifications = data
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        // Count unread notifications
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        _hasLoadedOnce = true;

        if (kDebugMode) {
          debugPrint('│ ✅ Success: Fetched ${_notifications.length} notifications');
          debugPrint('│ 📬 Unread: $_unreadCount');
          debugPrint('│ 📭 Read: ${_notifications.length - _unreadCount}');
          debugPrint('└─────────────────────────────────────────');
        }
      } else {
        _error = 'Gagal memuat notifikasi';
        if (kDebugMode) {
          debugPrint('│ ❌ Error: HTTP ${response.statusCode}');
          debugPrint('│ 📄 Response: ${response.body}');
          debugPrint('└─────────────────────────────────────────');
        }
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: ${e.toString()}';
      if (kDebugMode) {
        debugPrint('│ ❌ Exception: $e');
        debugPrint('└─────────────────────────────────────────');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int notificationId) async {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 📖 [NotificationProvider] Marking notification as read');
      debugPrint('│ 🆔 Notification ID: $notificationId');
    }
    
    // Cari notifikasi di list lokal
    final int index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1 || _notifications[index].isRead) {
      if (kDebugMode) {
        if (index == -1) {
          debugPrint('│ ⚠️ Notification not found in local list');
        } else {
          debugPrint('│ ⏭️ Notification already marked as read');
        }
        debugPrint('└─────────────────────────────────────────');
      }
      return;
    }

    // Update state di UI secara optimis agar responsif
    _notifications[index].isRead = true;
    _unreadCount = _notifications.where((n) => !n.isRead).length;
    
    if (kDebugMode) {
      debugPrint('│ ✅ Optimistically updated UI');
      debugPrint('│ 📬 Unread count: $_unreadCount');
    }
    
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final baseUrl = dotenv.env['API_URL'];
      final url = '$baseUrl/notifications/$notificationId/read';

      if (kDebugMode) {
        debugPrint('│ 🌐 API URL: $url');
      }

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        debugPrint('│ 📊 Response Status: ${response.statusCode}');
      }

      if (response.statusCode != 200) {
        // Jika gagal, kembalikan state ke semula (belum dibaca)
        _notifications[index].isRead = false;
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
        
        if (kDebugMode) {
          debugPrint('│ ❌ Failed to mark as read - reverting state');
          debugPrint('│ 📄 Response: ${response.body}');
          debugPrint('└─────────────────────────────────────────');
        }
      } else {
        if (kDebugMode) {
          debugPrint('│ ✅ Successfully marked as read on server');
          debugPrint('└─────────────────────────────────────────');
        }
      }
    } catch (e) {
      // Jika terjadi error, kembalikan juga state-nya
      _notifications[index].isRead = false;
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
      
      if (kDebugMode) {
        debugPrint('│ ❌ Exception: $e');
        debugPrint('│ 🔄 Reverted to unread state');
        debugPrint('└─────────────────────────────────────────');
      }
    }
  }
}

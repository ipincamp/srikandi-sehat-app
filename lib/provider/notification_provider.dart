import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/models/notification_model.dart';
import 'package:app/utils/logger.dart';

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
      AppLogger.info('Notification', 'Refreshing after FCM message');
    }
    await fetchNotifications();
  }

  // Method for initial load only (call once when app starts)
  Future<void> loadInitialNotifications() async {
    if (_hasLoadedOnce) {
      if (kDebugMode) {
        AppLogger.info('Notification', 'Already loaded, skipping');
      }
      return;
    }
    if (kDebugMode) {
      AppLogger.info('Notification', 'Loading initial notifications');
    }
    await fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    if (kDebugMode) {
      AppLogger.startSection('Notification - Fetch', emoji: '📡');
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
        AppLogger.apiRequest(
          method: 'GET',
          endpoint: '/notifications',
          token: token,
        );
        AppLogger.info('Notification', 'Full URL: $url');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        AppLogger.apiResponse(
          statusCode: response.statusCode,
          endpoint: '/notifications',
        );
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
          AppLogger.success('Notification', 'Fetched ${_notifications.length} notifications');
          AppLogger.info('Notification', 'Unread: $_unreadCount, Read: ${_notifications.length - _unreadCount}');
          AppLogger.endSection();
        }
      } else {
        _error = 'Gagal memuat notifikasi';
        if (kDebugMode) {
          AppLogger.error('Notification', 'HTTP ${response.statusCode}');
          AppLogger.endSection();
        }
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: ${e.toString()}';
      if (kDebugMode) {
        AppLogger.exception(
          category: 'Notification',
          error: e,
        );
        AppLogger.endSection();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int notificationId) async {
    if (kDebugMode) {
      AppLogger.startSection('Notification - Mark Read', emoji: '📖');
      AppLogger.info('Notification', 'ID: $notificationId');
    }
    
    // Cari notifikasi di list lokal
    final int index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1 || _notifications[index].isRead) {
      if (kDebugMode) {
        if (index == -1) {
          AppLogger.warning('Notification', 'Not found in local list');
        } else {
          AppLogger.info('Notification', 'Already marked as read');
        }
        AppLogger.endSection();
      }
      return;
    }

    // Update state di UI secara optimis agar responsif
    _notifications[index].isRead = true;
    _unreadCount = _notifications.where((n) => !n.isRead).length;
    
    if (kDebugMode) {
      AppLogger.success('Notification', 'Optimistically updated UI');
      AppLogger.info('Notification', 'Unread count: $_unreadCount');
    }
    
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final baseUrl = dotenv.env['API_URL'];
      final url = '$baseUrl/notifications/$notificationId/read';

      if (kDebugMode) {
        AppLogger.apiRequest(
          method: 'PATCH',
          endpoint: '/notifications/$notificationId/read',
          token: token,
        );
      }

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        AppLogger.apiResponse(
          statusCode: response.statusCode,
          endpoint: '/notifications/$notificationId/read',
        );
      }

      if (response.statusCode != 200) {
        // Jika gagal, kembalikan state ke semula (belum dibaca)
        _notifications[index].isRead = false;
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
        
        if (kDebugMode) {
          AppLogger.warning('Notification', 'Failed - reverting state');
          AppLogger.endSection();
        }
      } else {
        if (kDebugMode) {
          AppLogger.success('Notification', 'Marked as read on server');
          AppLogger.endSection();
        }
      }
    } catch (e) {
      // Jika terjadi error, kembalikan juga state-nya
      _notifications[index].isRead = false;
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
      
      if (kDebugMode) {
        AppLogger.exception(
          category: 'Notification',
          error: e,
        );
        AppLogger.info('Notification', 'Reverted to unread state');
        AppLogger.endSection();
      }
    }
  }
}

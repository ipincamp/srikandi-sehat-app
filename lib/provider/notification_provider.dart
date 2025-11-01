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

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  // Method to refresh notifications when FCM message received
  Future<void> refreshNotifications() async {
    if (kDebugMode) {
      debugPrint('🔄 Refreshing notifications after FCM message...');
    }
    await fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final baseUrl = dotenv.env['API_URL'];
      final url = '$baseUrl/notifications'; // Asumsi endpoint-nya ini

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        _notifications = data
            .map((json) => NotificationModel.fromJson(json))
            .toList();

        // Count unread notifications
        _unreadCount = _notifications.where((n) => !n.isRead).length;

        if (kDebugMode) {
          debugPrint(
            'Fetched ${_notifications.length} notifications, $_unreadCount unread',
          );
        }
      } else {
        _error = 'Gagal memuat notifikasi';
      }
    } catch (e) {
      _error = 'Terjadi kesalahan: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int notificationId) async {
    // Cari notifikasi di list lokal
    final int index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1 || _notifications[index].isRead) {
      // Jika tidak ditemukan atau sudah dibaca, tidak perlu lakukan apa-apa
      return;
    }

    // Update state di UI secara optimis agar responsif
    _notifications[index].isRead = true;
    _unreadCount = _notifications.where((n) => !n.isRead).length;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final baseUrl = dotenv.env['API_URL'];
      final url = '$baseUrl/notifications/$notificationId/read';

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        // Jika gagal, kembalikan state ke semula (belum dibaca)
        _notifications[index].isRead = false;
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
        // Anda bisa menambahkan notifikasi error di sini jika perlu
      }
    } catch (e) {
      // Jika terjadi error, kembalikan juga state-nya
      _notifications[index].isRead = false;
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
      if (kDebugMode) {
        debugPrint('Failed to mark notification as read: $e');
      }
    }
  }
}

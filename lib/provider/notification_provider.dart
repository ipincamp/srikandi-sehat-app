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

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
        notifyListeners();
        // Anda bisa menambahkan notifikasi error di sini jika perlu
      }
    } catch (e) {
      // Jika terjadi error, kembalikan juga state-nya
      _notifications[index].isRead = false;
      notifyListeners();
      if (kDebugMode) {
        debugPrint('Failed to mark notification as read: $e');
      }
    }
  }
}

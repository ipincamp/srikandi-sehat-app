import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CsvDownloadProvider with ChangeNotifier {
  bool _isDownloading = false;
  String _downloadStatus = '';
  String _errorMessage = '';

  bool get isDownloading => _isDownloading;
  String get downloadStatus => _downloadStatus;
  String get errorMessage => _errorMessage;

  Future<void> downloadUserCsv() async {
    _isDownloading = true;
    _downloadStatus = 'Mempersiapkan unduhan...';
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final baseUrl = dotenv.env['API_URL'] ?? '';
      final url = '$baseUrl/users/export/csv';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _downloadStatus = 'Mengunduh file...';
        notifyListeners();

        // Get directory untuk menyimpan file
        final directory = await getDownloadsDirectory();
        if (directory == null) {
          throw Exception('Tidak dapat mengakses folder download');
        }

        // Buat nama file dengan timestamp
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'semua_pengguna_$timestamp.csv';
        final file = File('${directory.path}/$fileName');

        // Tulis data CSV ke file
        await file.writeAsBytes(response.bodyBytes);

        _downloadStatus = 'File berhasil diunduh!';
        notifyListeners();

        // Buka file setelah diunduh
        await OpenFile.open(file.path);
      } else {
        _errorMessage =
            'Gagal mengunduh CSV. Status code: ${response.statusCode}';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error saat mengunduh CSV: $e';
      notifyListeners();
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  void resetStatus() {
    _downloadStatus = '';
    _errorMessage = '';
    notifyListeners();
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:srikandi_sehat_app/core/network/http_client.dart';

class CsvDownloadProvider with ChangeNotifier {
  bool _isDownloading = false;
  String _downloadStatus = '';
  String _errorMessage = '';
  double _downloadProgress = 0;

  bool get isDownloading => _isDownloading;
  String get downloadStatus => _downloadStatus;
  String get errorMessage => _errorMessage;
  double get downloadProgress => _downloadProgress;

  Future<void> downloadUserCsv(BuildContext context) async {
    _isDownloading = true;
    _downloadProgress = 0;
    _downloadStatus = 'Mempersiapkan unduhan...';
    _errorMessage = '';
    notifyListeners();

    try {
      String endpoint = 'admin/reports/csv';
      final response = await HttpClient.get(context, endpoint, body: {});

      if (response.statusCode == 200) {
        // Verify content type
        final contentType = response.headers['content-type'];
        if (contentType == null || !contentType.contains('csv')) {
          throw Exception('Respons bukan file CSV yang valid');
        }

        _downloadStatus = 'Menyimpan file...';
        notifyListeners();

        // Get directory
        final directory = await getDownloadsDirectory();
        if (directory == null) {
          throw Exception('Tidak dapat mengakses folder download');
        }

        // Create filename with timestamp
        final timestamp = DateTime.now().toIso8601String().replaceAll(
          RegExp(r'[^0-9]'),
          '',
        );
        final fileName = 'laporan_pengguna_$timestamp.csv';
        final filePath = path.join(directory.path, fileName);

        // Save file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Verify file was saved
        if (!await file.exists()) {
          throw Exception('Gagal menyimpan file');
        }

        _downloadStatus = 'File berhasil diunduh!';
        _downloadProgress = 1.0;
        notifyListeners();

        // Open file
        final openResult = await OpenFile.open(filePath);
        if (openResult.type != ResultType.done) {
          _downloadStatus = 'File tidak dapat dibuka';
          notifyListeners();
        }
      } else {
        throw Exception('Gagal mengunduh. Status: ${response.statusCode}');
      }
    } on SocketException {
      _errorMessage = 'Tidak ada koneksi internet';
    } on HttpException {
      _errorMessage = 'Gagal mengunduh dari server';
    } on Exception catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  void resetStatus() {
    _downloadStatus = '';
    _errorMessage = '';
    _downloadProgress = 0;
    notifyListeners();
  }
}

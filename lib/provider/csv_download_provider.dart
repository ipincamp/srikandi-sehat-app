import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:srikandi_sehat_app/core/network/http_client.dart';
import 'package:srikandi_sehat_app/widgets/custom_alert.dart';

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

    CustomAlert.show(
      context,
      '📦 Mempersiapkan unduhan...',
      duration: Duration(seconds: 2),
    );

    try {
      // 🔒 Minta izin penyimpanan
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          throw Exception('Izin penyimpanan tidak diberikan');
        }
      }

      const endpoint = 'admin/reports/csv';
      final response = await Future.any([
        HttpClient.get(context, endpoint, body: {}),
        Future.delayed(const Duration(seconds: 15), () {
          throw TimeoutException('Waktu koneksi habis. Coba lagi nanti.');
        }),
      ]);

      if (response.statusCode == 200) {
        print('✅ CSV downloaded successfully.');
        final contentType = response.headers['content-type'] ?? '';
        if (!contentType.contains('csv')) {
          throw Exception('Respons bukan file CSV yang valid');
        }

        _downloadStatus = 'Menyimpan file...';
        notifyListeners();

        CustomAlert.show(
          context,
          '💾 Menyimpan file ke folder Download...',
          duration: Duration(seconds: 2),
        );

        // 📁 Tentukan lokasi penyimpanan
        Directory? directory;
        if (Platform.isAndroid) {
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            directory = await getExternalStorageDirectory();
          }
        } else {
          directory = await getDownloadsDirectory();
        }

        if (directory == null) {
          throw Exception('Tidak dapat mengakses folder unduhan');
        }

        // 🕓 Buat nama file unik
        final timestamp = DateTime.now().toIso8601String().replaceAll(
          RegExp(r'[^0-9]'),
          '',
        );
        final fileName = 'laporan_pengguna_$timestamp.csv';
        final filePath = path.join(directory.path, fileName);

        // 💾 Simpan file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        if (!await file.exists()) {
          throw Exception('Gagal menyimpan file');
        }

        _downloadStatus = 'File berhasil diunduh!';
        _downloadProgress = 1.0;
        notifyListeners();

        CustomAlert.show(
          context,
          '✅ File berhasil diunduh ke $filePath',
          type: AlertType.success,
          duration: const Duration(seconds: 3),
        );

        // 📂 Buka file otomatis
        final openResult = await OpenFile.open(filePath);
        if (openResult.type != ResultType.done) {
          CustomAlert.show(
            context,
            'File diunduh, tetapi gagal membuka file secara otomatis.',
            type: AlertType.info,
            duration: const Duration(seconds: 3),
          );
        }
      } else {
        throw Exception('Gagal mengunduh. Status: ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      _errorMessage = e.message ?? 'Koneksi terlalu lama, silakan coba lagi.';
      CustomAlert.show(
        context,
        _errorMessage,
        type: AlertType.error,
        duration: const Duration(seconds: 3),
      );
    } on SocketException {
      _errorMessage = 'Tidak ada koneksi internet.';
      CustomAlert.show(
        context,
        _errorMessage,
        type: AlertType.error,
        duration: const Duration(seconds: 3),
      );
    } on HttpException {
      _errorMessage = 'Gagal mengunduh dari server.';
      CustomAlert.show(
        context,
        _errorMessage,
        type: AlertType.error,
        duration: const Duration(seconds: 3),
      );
    } on Exception catch (e) {
      _errorMessage = e.toString();
      CustomAlert.show(
        context,
        _errorMessage,
        type: AlertType.error,
        duration: const Duration(seconds: 3),
      );
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

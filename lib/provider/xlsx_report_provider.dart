import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app/core/network/http_client.dart';
import 'package:app/models/xlsx_report_model.dart';
import 'package:app/widgets/custom_alert.dart';
import 'package:open_file/open_file.dart';

class XlsxReportProvider with ChangeNotifier {
  bool _isDownloading = false;
  String _downloadStatus = '';
  String _errorMessage = '';
  String? _password;
  String? _encryptedToken;
  DateTime? _expiresAt;

  bool get isDownloading => _isDownloading;
  String get downloadStatus => _downloadStatus;
  String get errorMessage => _errorMessage;
  String? get password => _password;
  String? get encryptedToken => _encryptedToken;
  DateTime? get expiresAt => _expiresAt;

  Future<void> generateReport(BuildContext context) async {
    if (kDebugMode) {
      debugPrint('┌─────────────────────────────────────────');
      debugPrint('│ 📥 [XlsxReportProvider] Generate XLSX Report');
    }

    _isDownloading = true;
    _downloadStatus = 'Generating report...';
    _errorMessage = '';
    notifyListeners();

    try {
      const endpoint = 'admin/reports/generate';
      final response = await HttpClient.post(context, endpoint);

      if (response.statusCode == 200) {
        final XlsxReportResponse reportResponse = XlsxReportResponse.fromJson(
          jsonDecode(response.body),
        );

        if (reportResponse.status && reportResponse.data.downloadUrl.isNotEmpty) {
          // Extract data from response
          _password = reportResponse.message.split('Password: ').last;
          _encryptedToken = reportResponse.data.encryptedToken;
          _expiresAt = reportResponse.data.expiresAt;

          _downloadStatus = 'Report generated successfully';
          _errorMessage = '';

          if (kDebugMode) {
            debugPrint('│ ✅ Report generation successful');
            debugPrint('│ 🔐 Password generated');
            debugPrint('│ 🎫 Token received');
            debugPrint('│ ⏰ Expires at: ${_expiresAt?.toLocal()}');
          }
        } else {
          throw Exception(reportResponse.message);
        }
      } else if (response.statusCode == 401) {
        _errorMessage = 'Session expired, please login again.';
        if (kDebugMode) {
          debugPrint('│ ❌ Unauthorized (401)');
          debugPrint('│ 💬 HttpClient should handle redirect');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to generate report');
      }
    } on TimeoutException catch (e) {
      _errorMessage = e.message ?? 'Connection timeout. Please try again.';
      if (kDebugMode) {
        debugPrint('│ ❌ Timeout exception');
        debugPrint('│ ⏱️ Error: $_errorMessage');
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        debugPrint('│ ❌ Error during report generation');
        debugPrint('│ 💬 Error: $_errorMessage');
      }
    } finally {
      _isDownloading = false;
      notifyListeners();
      if (kDebugMode) {
        debugPrint('└─────────────────────────────────────────');
      }
    }
  }

  Future<void> downloadReport(BuildContext context) async {
    if (_password == null || _encryptedToken == null) {
      _errorMessage = 'Please generate a report first';
      notifyListeners();
      return;
    }

    _isDownloading = true;
    _downloadStatus = 'Downloading report...';
    _errorMessage = '';
    notifyListeners();

    try {
      const endpoint = 'reports/download';
      final request = XlsxDownloadRequest(
        password: _password!,
        token: _encryptedToken!,
      );

      final response = await HttpClient.post(
        context,
        endpoint,
        body: request.toJson(),
      );

      if (response.statusCode == 200) {
        try {
          // Request appropriate permissions based on Android version
          bool permissionGranted = false;
          if (Platform.isAndroid) {
            if (await Permission.storage.request().isGranted) {
              permissionGranted = true;
            } else {
              // For Android 13 and above, request the new permissions
              final androidInfo = await DeviceInfoPlugin().androidInfo;
              if (androidInfo.version.sdkInt >= 33) {
                // Request media permissions for Android 13+
                await Permission.photos.request();
                await Permission.videos.request();
                await Permission.audio.request();
                permissionGranted = await Permission.photos.isGranted;
              } else {
                // For older Android versions
                permissionGranted = await Permission.storage.request().isGranted;
              }
            }
          } else {
            // For iOS or other platforms, we'll use the documents directory
            permissionGranted = true;
          }

          if (!permissionGranted) {
            throw Exception('Storage permission is required to save the file');
          }

          // Create custom directory in Downloads folder
          final baseDir = Directory('/storage/emulated/0/Download/SrikandiSehat');
          if (!await baseDir.exists()) {
            await baseDir.create(recursive: true);
          }
          
          final fileName = 'report_${DateTime.now().millisecondsSinceEpoch}.xlsx';
          final filePath = '${baseDir.path}/$fileName';
          final file = File(filePath);

          // Save response bytes directly to file
          await file.writeAsBytes(response.bodyBytes);
          _downloadStatus = 'File saved successfully';

          // Open the file
          final result = await OpenFile.open(filePath);
          if (result.type == ResultType.done) {
            _downloadStatus = 'File opened successfully';
            if (kDebugMode) {
              debugPrint('│ ✅ File opened successfully');
            }
          } else {
            CustomAlert.show(
              context,
              'File saved to: $filePath',
              type: AlertType.success,
              duration: const Duration(seconds: 5),
            );
          }

          if (kDebugMode) {
            debugPrint('│ ✅ File saved successfully');
            debugPrint('│ 📂 Path: $filePath');
          }
        } catch (e) {
          throw Exception('Failed to save file: $e');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to download report');
      }
    } on TimeoutException catch (e) {
      _errorMessage = e.message ?? 'Connection timeout. Please try again.';
      if (kDebugMode) {
        debugPrint('│ ❌ Timeout exception');
        debugPrint('│ ⏱️ Error: $_errorMessage');
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        debugPrint('│ ❌ Error during download');
        debugPrint('│ 💬 Error: $_errorMessage');
      }
    } finally {
      _isDownloading = false;
      notifyListeners();
      if (kDebugMode) {
        debugPrint('└─────────────────────────────────────────');
      }
    }
  }

  void reset() {
    _isDownloading = false;
    _downloadStatus = '';
    _errorMessage = '';
    _password = null;
    _encryptedToken = null;
    _expiresAt = null;
    notifyListeners();
  }
}
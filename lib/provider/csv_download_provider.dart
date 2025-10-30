import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app/core/network/http_client.dart';
import 'package:app/widgets/custom_alert.dart';
import 'package:url_launcher/url_launcher.dart';

class CsvDownloadProvider with ChangeNotifier {
  bool _isDownloading = false;
  String _downloadStatus = '';
  String _errorMessage = '';

  bool get isDownloading => _isDownloading;
  String get downloadStatus => _downloadStatus;
  String get errorMessage => _errorMessage;

  Future<void> downloadUserCsv(BuildContext context) async {
    _isDownloading = true;
    _downloadStatus = 'Meminta link unduhan...';
    _errorMessage = '';
    notifyListeners();

    if (kDebugMode) {
      debugPrint('🚀 [CSV Download] Requesting download link via POST...');
    }

    CustomAlert.show(
      context,
      '📦 Meminta link unduhan...',
      duration: const Duration(seconds: 2),
    );

    try {
      const endpoint = 'admin/reports/generate-csv-link';

      final response = await Future.any([
        HttpClient.post(context, endpoint), // Making the POST request
        Future.delayed(const Duration(seconds: 20), () {
          throw TimeoutException('Waktu tunggu habis saat meminta link unduhan.');
        }),
      ]);

      if (kDebugMode) {
        debugPrint('✅ [CSV Download] Response Status Code: ${response.statusCode}');
        debugPrint('✅ [CSV Download] Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Check the 'status' field first
        if (responseData['status'] == true &&
            responseData['data'] is Map && // Ensure 'data' is a map
            responseData['data']['download_url'] != null && // Check for the URL
            responseData['data']['download_url'] is String) { // Ensure URL is a string

          final downloadUrl = responseData['data']['download_url'] as String;
          // final expiresAt = responseData['data']['expires_at'] as String?; // Optional: get expiry time

          if (kDebugMode) {
            debugPrint('✅ [CSV Download] Download URL received: $downloadUrl');
            // if (expiresAt != null) debugPrint('✅ [CSV Download] Link expires at: $expiresAt');
          }

          _downloadStatus = 'Membuka link unduhan...';
          notifyListeners();

          CustomAlert.show(
            context,
            '🔗 Membuka link unduhan di browser...',
            duration: const Duration(seconds: 2),
          );

          final Uri url = Uri.parse(downloadUrl);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
            _downloadStatus = 'Link unduhan telah dibuka di browser.';
            if (kDebugMode) {
              debugPrint('✅ [CSV Download] Link opened successfully.');
            }
          } else {
            if (kDebugMode) {
               debugPrint('❌ [CSV Download] Could not launch URL: $downloadUrl');
            }
            throw Exception('Tidak dapat membuka URL: $downloadUrl');
          }

        } else {
          // Handle cases where 'status' is false or data structure is incorrect
          final message = responseData['message'] as String? ?? 'Format respons tidak valid atau URL tidak ditemukan.';
           if (kDebugMode) {
             debugPrint('❌ [CSV Download] Invalid response structure or missing URL. Message: $message');
           }
          throw Exception(message);
        }

      } else if (response.statusCode == 401) {
           _errorMessage = 'Sesi habis, silakan login kembali.';
           if (kDebugMode) {
            debugPrint('❌ [CSV Download] Unauthorized (401). HttpClient should handle redirect.');
          }
      }
      else {
        // Handle other error status codes
        String errorMsg = 'Gagal mendapatkan link unduhan.';
        try {
            final errorData = jsonDecode(response.body);
            errorMsg = errorData['message'] ?? '$errorMsg Status: ${response.statusCode}';
        } catch(_) {
            errorMsg = '$errorMsg Status: ${response.statusCode}';
        }
         if (kDebugMode) {
          debugPrint('❌ [CSV Download] Failed with status ${response.statusCode}: ${response.body}');
        }
        throw Exception(errorMsg);
      }
    } on TimeoutException catch (e) {
      _errorMessage = e.message ?? 'Koneksi terlalu lama, silakan coba lagi.';
      if (kDebugMode) {
        debugPrint('❌ [CSV Download] Timeout: $_errorMessage');
      }
      CustomAlert.show(
        context,
        _errorMessage,
        type: AlertType.error,
        duration: const Duration(seconds: 3),
      );
    } on SocketException {
      _errorMessage = 'Tidak ada koneksi internet.';
       if (kDebugMode) {
        debugPrint('❌ [CSV Download] SocketException: $_errorMessage');
      }
      CustomAlert.show(
        context,
        _errorMessage,
        type: AlertType.error,
        duration: const Duration(seconds: 3),
      );
    } on HttpException {
      _errorMessage = 'Gagal terhubung ke server.';
       if (kDebugMode) {
        debugPrint('❌ [CSV Download] HttpException: $_errorMessage');
      }
      CustomAlert.show(
        context,
        _errorMessage,
        type: AlertType.error,
        duration: const Duration(seconds: 3),
      );
    } on Exception catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
       if (kDebugMode) {
        debugPrint('❌ [CSV Download] Generic Exception: $_errorMessage');
      }
      if (!_errorMessage.contains('Sesi habis')) {
            CustomAlert.show(
            context,
            _errorMessage,
            type: AlertType.error,
            duration: const Duration(seconds: 3),
            );
       }
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

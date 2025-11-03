import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/xlsx_report_model.dart';

void main() {
  group('XlsxReportResponse', () {
    test('fromJson - with valid data', () {
      final json = {
        'status': true,
        'message': 'Report generated successfully. Use the encrypted token and password to download. Password: uNpdzoyWx\$yu',
        'data': {
          'download_url': 'https://srikandisehat.ntl.my.id/api/reports/download',
          'encrypted_token': 'V54KLqzOnUE2BmobcS_fkbPAcXv2OWL81sJQik4MZkuP5hfRL9IyoiertVVoerBonIa77uAUMbhLYwMm1jdiZw==',
          'expires_at': '2025-11-04T06:37:44.426355703+07:00',
        },
      };

      final response = XlsxReportResponse.fromJson(json);

      expect(response.status, true);
      expect(response.message, contains('Password: uNpdzoyWx\$yu'));
      expect(response.data.downloadUrl, 'https://srikandisehat.ntl.my.id/api/reports/download');
      expect(response.data.encryptedToken, 'V54KLqzOnUE2BmobcS_fkbPAcXv2OWL81sJQik4MZkuP5hfRL9IyoiertVVoerBonIa77uAUMbhLYwMm1jdiZw==');
      expect(response.data.expiresAt.toIso8601String(), '2025-11-04T06:37:44.426355703+07:00');
    });

    test('fromJson - with empty/invalid data', () {
      final json = {'status': false};
      final response = XlsxReportResponse.fromJson(json);

      expect(response.status, false);
      expect(response.message, '');
      expect(response.data.downloadUrl, '');
      expect(response.data.encryptedToken, '');
      expect(response.data.expiresAt.year, DateTime.now().year);
    });
  });

  group('XlsxDownloadRequest', () {
    test('toJson', () {
      final request = XlsxDownloadRequest(
        password: 'uNpdzoyWx\$yu',
        token: 'V54KLqzOnUE2BmobcS_fkbPAcXv2OWL81sJQik4MZkuP5hfRL9IyoiertVVoerBonIa77uAUMbhLYwMm1jdiZw==',
      );

      final json = request.toJson();

      expect(json['password'], 'uNpdzoyWx\$yu');
      expect(json['token'], 'V54KLqzOnUE2BmobcS_fkbPAcXv2OWL81sJQik4MZkuP5hfRL9IyoiertVVoerBonIa77uAUMbhLYwMm1jdiZw==');
    });
  });
}
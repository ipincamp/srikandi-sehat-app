import 'package:flutter_test/flutter_test.dart';
import 'package:app/provider/xlsx_report_provider.dart';

void main() {
  group('XlsxReportProvider', () {
    late XlsxReportProvider provider;

    setUp(() {
      provider = XlsxReportProvider();
    });

    test('initial state', () {
      expect(provider.isDownloading, false);
      expect(provider.downloadStatus, '');
      expect(provider.errorMessage, '');
      expect(provider.password, null);
      expect(provider.encryptedToken, null);
      expect(provider.expiresAt, null);
    });

    test('reset state', () {
      provider.reset();

      expect(provider.isDownloading, false);
      expect(provider.downloadStatus, '');
      expect(provider.errorMessage, '');
      expect(provider.password, null);
      expect(provider.encryptedToken, null);
      expect(provider.expiresAt, null);
    });
  });
}
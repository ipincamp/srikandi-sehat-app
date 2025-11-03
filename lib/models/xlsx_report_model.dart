class XlsxReportResponse {
  final bool status;
  final String message;
  final XlsxReportData data;

  XlsxReportResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory XlsxReportResponse.fromJson(Map<String, dynamic> json) {
    return XlsxReportResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: XlsxReportData.fromJson(json['data'] ?? {}),
    );
  }
}

class XlsxReportData {
  final String downloadUrl;
  final String encryptedToken;
  final DateTime expiresAt;

  XlsxReportData({
    required this.downloadUrl,
    required this.encryptedToken,
    required this.expiresAt,
  });

  factory XlsxReportData.fromJson(Map<String, dynamic> json) {
    return XlsxReportData(
      downloadUrl: json['download_url'] ?? '',
      encryptedToken: json['encrypted_token'] ?? '',
      expiresAt: DateTime.parse(json['expires_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class XlsxDownloadRequest {
  final String password;
  final String token;

  XlsxDownloadRequest({
    required this.password,
    required this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'password': password,
      'token': token,
    };
  }
}
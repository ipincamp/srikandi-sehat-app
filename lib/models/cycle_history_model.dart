class CycleHistoryResponse {
  final bool status;
  final String message;
  final List<CycleData> data;
  final CycleMetadata metadata;

  CycleHistoryResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.metadata,
  });

  factory CycleHistoryResponse.fromJson(Map<String, dynamic> json) {
    return CycleHistoryResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data']['data'] != null
          ? List<CycleData>.from(
              json['data']['data'].map((x) => CycleData.fromJson(x)),
            )
          : [],
      metadata: CycleMetadata.fromJson(json['data']['metadata'] ?? {}),
    );
  }
}

class CycleMetadata {
  final int limit;
  final int totalData;
  final int totalPages;
  final int currentPage;

  CycleMetadata({
    required this.limit,
    required this.totalData,
    required this.totalPages,
    required this.currentPage,
  });

  factory CycleMetadata.fromJson(Map<String, dynamic> json) {
    return CycleMetadata(
      limit: json['limit'] ?? 0,
      totalData: json['total_data'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
      currentPage: json['current_page'] ?? 0,
    );
  }
}

class CycleData {
  final String id;
  final DateTime startDate;
  final DateTime finishDate;
  final int periodLength;
  final int? cycleLength;

  CycleData({
    required this.id,
    required this.startDate,
    required this.finishDate,
    required this.periodLength,
    this.cycleLength,
  });

  factory CycleData.fromJson(Map<String, dynamic> json) {
    return CycleData(
      id: json['id'].toString(),
      startDate: DateTime.parse(json['start_date']).toLocal(),
      finishDate: DateTime.parse(json['finish_date']).toLocal(),
      periodLength: json['period_length'] as int,
      cycleLength: json['cycle_length'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_date': startDate.toIso8601String(),
      'finish_date': finishDate.toIso8601String(),
      'period_length': periodLength,
      'cycle_length': cycleLength,
    };
  }

  // Method untuk mengecek apakah siklus masih berlangsung
  bool isActive() {
    return finishDate.isAfter(DateTime.now());
  }

  // Method untuk mendapatkan durasi haid sampai hari ini jika masih berlangsung
  int getCurrentPeriodLength() {
    if (isActive()) {
      return DateTime.now().difference(startDate).inDays + 1;
    }
    return periodLength;
  }
}

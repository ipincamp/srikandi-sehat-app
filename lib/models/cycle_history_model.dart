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
    // The API may return two shapes:
    // 1) { status, message, data: { data: [...], metadata: {...} } }
    // 2) { status, message, data: [...] }
    final status = json['status'] ?? false;
    final message = json['message'] ?? '';

    List<CycleData> cycles = [];
    Map<String, dynamic> metadataJson = {};

    final dataField = json['data'];
    if (dataField is List) {
      // Shape 2: data is directly a list of cycles
      cycles = List<CycleData>.from(
        dataField.map((x) => CycleData.fromJson(x)),
      );
    } else if (dataField is Map) {
      // Shape 1: data contains { data: [...], metadata: {...} }
      final inner = dataField['data'];
      if (inner is List) {
        cycles = List<CycleData>.from(inner.map((x) => CycleData.fromJson(x)));
      }
      final meta = dataField['metadata'];
      if (meta is Map<String, dynamic>) metadataJson = meta;
    }

    return CycleHistoryResponse(
      status: status,
      message: message,
      data: cycles,
      metadata: CycleMetadata.fromJson(metadataJson),
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
    // Safe parsing with fallbacks for nullable/missing fields
    final rawId = json['id'];
    final id = rawId != null ? rawId.toString() : '';

    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      try {
        return DateTime.parse(value.toString()).toLocal();
      } catch (_) {
        return DateTime.now();
      }
    }

    final startDate = parseDate(json['start_date']);
    final finishDate = parseDate(json['finish_date']);

    int parseInt(dynamic value, {int fallback = 0}) {
      if (value == null) return fallback;
      if (value is int) return value;
      try {
        return int.parse(value.toString());
      } catch (_) {
        return fallback;
      }
    }

    final periodLength = parseInt(json['period_length'], fallback: 0);

    int? cycleLength;
    if (json.containsKey('cycle_length') && json['cycle_length'] != null) {
      cycleLength = parseInt(json['cycle_length'], fallback: 0);
    } else {
      cycleLength = null;
    }

    return CycleData(
      id: id,
      startDate: startDate,
      finishDate: finishDate,
      periodLength: periodLength,
      cycleLength: cycleLength,
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

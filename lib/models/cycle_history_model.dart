// cycle_history_model.dart
class CycleHistoryResponse {
  final bool status;
  final String message;
  final List<CycleData> data;

  CycleHistoryResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CycleHistoryResponse.fromJson(Map<String, dynamic> json) {
    return CycleHistoryResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<CycleData>.from(json['data'].map((x) => CycleData.fromJson(x)))
          : [],
    );
  }
}

class CycleData {
  final String id;
  final DateTime startDate;
  final DateTime finishDate;
  final int periodLength;
  final int cycleLength;

  CycleData({
    required this.id,
    required this.startDate,
    required this.finishDate,
    required this.periodLength,
    required this.cycleLength,
  });

  factory CycleData.fromJson(Map<String, dynamic> json) {
    return CycleData(
      id: json['id'] ?? '',
      startDate: DateTime.parse(json['start_date']),
      finishDate: DateTime.parse(json['finish_date']),
      periodLength: json['period_length'] ?? 0,
      cycleLength: json['cycle_length'] ?? 0,
    );
  }
}

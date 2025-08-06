// models/cycle_status_model.dart
class CycleStatus {
  final String? cycleId;
  final String? cycleStatus;
  final int cycleDurationDays;
  final String? periodStatus;
  final int periodLengthDays;
  final bool isMenstruating;

  CycleStatus({
    this.cycleId,
    this.cycleStatus,
    this.cycleDurationDays = 0,
    this.periodStatus,
    this.periodLengthDays = 0,
    this.isMenstruating = false,
  });

  factory CycleStatus.fromJson(Map<String, dynamic> json) {
    return CycleStatus(
      cycleId: json['cycle_id']?.toString(),
      cycleStatus: json['cycle_status']?.toString(),
      periodStatus: json['period_status']?.toString(),
      cycleDurationDays: (json['cycle_duration_days'] as num?)?.toInt() ?? 0,
      periodLengthDays: (json['period_length_days'] as num?)?.toInt() ?? 0,
      isMenstruating: json['is_menstruating'] ?? false,
    );
  }
}

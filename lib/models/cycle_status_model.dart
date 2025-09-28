class CycleStatus {
  final bool isOnCycle;
  final int? currentPeriodDay;
  final bool? isPeriodNormal;
  final bool? isCycleNormal;
  final int? lastPeriodLength;
  final int? lastCycleLength;
  final int? daysUntilNextPeriod;
  final String? predictedPeriodDate;
  final String? message;
  final bool isMenstruating;

  CycleStatus({
    required this.isOnCycle,
    this.currentPeriodDay,
    this.isPeriodNormal,
    this.isCycleNormal,
    this.lastPeriodLength,
    this.lastCycleLength,
    this.daysUntilNextPeriod,
    this.predictedPeriodDate,
    this.message,
    this.isMenstruating = false,
  });

  factory CycleStatus.fromJson(Map<String, dynamic> json) {
    return CycleStatus(
      isOnCycle: json['is_on_cycle'] ?? false,
      currentPeriodDay: json['current_period_day'] as int?,
      isPeriodNormal: json['is_period_normal'] as bool?,
      isCycleNormal: json['is_cycle_normal'] as bool?,
      lastPeriodLength: json['last_period_length'] as int?,
      lastCycleLength: json['last_cycle_length'] as int?,
      daysUntilNextPeriod: json['days_until_next_period'] as int?,
      predictedPeriodDate: json['predicted_period_date'] as String?,
      message: json['message'] as String?,
      isMenstruating:
          (json['is_on_cycle'] ?? false) &&
          (json['current_period_day'] != null),
    );
  }
}

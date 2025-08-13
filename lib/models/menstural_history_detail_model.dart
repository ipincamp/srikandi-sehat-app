class MenstrualCycleDetail {
  final int id;
  final DateTime startDate;
  final DateTime finishDate;
  final int periodLength;
  final int cycleLength;
  final bool isPeriodNormal;
  final bool isCycleNormal;
  final List<CycleSymptom> symptoms;

  MenstrualCycleDetail({
    required this.id,
    required this.startDate,
    required this.finishDate,
    required this.periodLength,
    required this.cycleLength,
    required this.isPeriodNormal,
    required this.isCycleNormal,
    required this.symptoms,
  });

  factory MenstrualCycleDetail.fromJson(Map<String, dynamic> json) {
    return MenstrualCycleDetail(
      id: json['id'] as int? ?? 0,
      startDate: DateTime.parse(json['start_date'] as String? ?? ''),
      finishDate: DateTime.parse(json['finish_date'] as String? ?? ''),
      periodLength: json['period_length'] as int? ?? 0,
      cycleLength: json['cycle_length'] as int? ?? 0,
      isPeriodNormal: json['is_period_normal'] as bool? ?? false,
      isCycleNormal: json['is_cycle_normal'] as bool? ?? false,
      symptoms:
          (json['symptoms'] as List<dynamic>?)
              ?.map((e) => CycleSymptom.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CycleSymptom {
  final int id;
  final DateTime loggedAt;
  final String? note;
  final List<SymptomDetail> details;

  CycleSymptom({
    required this.id,
    required this.loggedAt,
    this.note,
    required this.details,
  });

  factory CycleSymptom.fromJson(Map<String, dynamic> json) {
    return CycleSymptom(
      id: json['id'] as int? ?? 0,
      loggedAt: DateTime.parse(json['logged_at'] as String? ?? ''),
      note: json['note'] as String?,
      details:
          (json['details'] as List<dynamic>?)
              ?.map((e) => SymptomDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class SymptomDetail {
  final String symptomName;
  final String symptomCategory;
  final String? selectedOption;

  SymptomDetail({
    required this.symptomName,
    required this.symptomCategory,
    this.selectedOption,
  });

  factory SymptomDetail.fromJson(Map<String, dynamic> json) {
    return SymptomDetail(
      symptomName: json['symptom_name'] as String? ?? '',
      symptomCategory: json['symptom_category'] as String? ?? '',
      selectedOption: json['selected_option'] as String?,
    );
  }
}

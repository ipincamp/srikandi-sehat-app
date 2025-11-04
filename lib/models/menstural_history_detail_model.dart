class MenstrualCycleDetail {
  final int id;
  final DateTime startDate;
  final DateTime finishDate;
  final int periodLength;
  final int? cycleLength;
  final bool isPeriodNormal;
  final bool? isCycleNormal;
  final List<CycleSymptom> symptoms;

  MenstrualCycleDetail({
    required this.id,
    required this.startDate,
    required this.finishDate,
    required this.periodLength,
    this.cycleLength,
    required this.isPeriodNormal,
    this.isCycleNormal,
    required this.symptoms,
  });

  factory MenstrualCycleDetail.fromJson(Map<String, dynamic> json) {
    DateTime safeParseDate(dynamic dateString) {
      if (dateString == null) {
        // Jika tanggal null (misal siklus aktif),
        // gunakan tanggal hari ini sebagai fallback
        return DateTime.now();
      }
      try {
        // Konversi ke string dulu untuk keamanan ekstra
        return DateTime.parse(dateString.toString());
      } catch (e) {
        // Fallback jika format tanggal tidak valid
        return DateTime.now();
      }
    }

    return MenstrualCycleDetail(
      id: json['id'] as int? ?? 0,
      startDate: safeParseDate(json['start_date']),
      finishDate: safeParseDate(json['finish_date']),
      periodLength: json['period_length'] as int? ?? 0,
      cycleLength: json['cycle_length'] as int?,
      isPeriodNormal: json['is_period_normal'] as bool? ?? false,
      isCycleNormal: json['is_cycle_normal'] as bool?,
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
    DateTime safeParseDate(dynamic dateString) {
      if (dateString == null) {
        return DateTime.now();
      }
      try {
        return DateTime.parse(dateString.toString());
      } catch (e) {
        return DateTime.now();
      }
    }

    return CycleSymptom(
      id: json['id'] as int? ?? 0,
      loggedAt: safeParseDate(json['logged_at']),
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

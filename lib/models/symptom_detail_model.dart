class SymptomDetail {
  final int id;
  final String logDate;
  final String? note;
  final List<SymptomItem> details;
  final List<Recommendation> recommendations;

  SymptomDetail({
    required this.id,
    required this.logDate,
    this.note,
    required this.details,
    required this.recommendations,
  });

  factory SymptomDetail.fromJson(Map<String, dynamic> json) {
    return SymptomDetail(
      id: json['id'] as int? ?? 0, // Handle null dengan default value 0
      logDate: json['logged_at'] as String? ?? '',
      note: json['note'] as String?,
      details:
          (json['details'] as List<dynamic>?)
              ?.map((e) => SymptomItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recommendations:
          (json['recommendations'] as List<dynamic>?)
              ?.map((e) => Recommendation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class SymptomItem {
  final int symptomId;
  final String symptomName;
  final String symptomCategory;
  final String? selectedOption;

  SymptomItem({
    required this.symptomId,
    required this.symptomName,
    required this.symptomCategory,
    this.selectedOption,
  });

  factory SymptomItem.fromJson(Map<String, dynamic> json) {
    return SymptomItem(
      symptomId: json['symptom_id'] as int? ?? 0,
      symptomName: json['symptom_name'] as String? ?? '',
      symptomCategory: json['symptom_category'] as String? ?? '',
      selectedOption: json['selected_option'] as String?,
    );
  }
}

class Recommendation {
  final String forSymptom;
  final String title;
  final String description;
  final String? videoUrl;

  Recommendation({
    required this.forSymptom,
    required this.title,
    required this.description,
    this.videoUrl,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      forSymptom: json['for_symptom'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      videoUrl: json['source'] as String?,
    );
  }
}

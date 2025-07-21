class SymptomDetail {
  final int id;
  final String logDate;
  final String? notes;
  final List<String> loggedSymptoms;
  final List<Recommendation> recommendations;

  SymptomDetail({
    required this.id,
    required this.logDate,
    this.notes,
    required this.loggedSymptoms,
    required this.recommendations,
  });

  factory SymptomDetail.fromJson(Map<String, dynamic> json) {
    return SymptomDetail(
      id: json['id'],
      logDate: json['log_date'],
      notes: json['notes'],
      loggedSymptoms: List<String>.from(json['logged_symptoms'] ?? []),
      recommendations: (json['recommendations'] as List)
          .map((e) => Recommendation.fromJson(e))
          .toList(),
    );
  }
}

class Recommendation {
  final String symptomName;
  final String recommendationText;

  Recommendation({
    required this.symptomName,
    required this.recommendationText,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      symptomName: json['symptom_name'],
      recommendationText: json['recommendation_text'],
    );
  }
}

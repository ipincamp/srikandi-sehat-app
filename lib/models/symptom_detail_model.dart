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
  final List<RecommendationUrl> recommendationUrls;

  Recommendation({
    required this.symptomName,
    required this.recommendationText,
    required this.recommendationUrls,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      symptomName: json['symptom_name'],
      recommendationText: json['recommendation_txt'],
      recommendationUrls: (json['recommendation_url'] as List?)
              ?.map((e) => RecommendationUrl.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class RecommendationUrl {
  final int id;
  final String action;
  final String videoUrl;

  RecommendationUrl({
    required this.id,
    required this.action,
    required this.videoUrl,
  });

  factory RecommendationUrl.fromJson(Map<String, dynamic> json) {
    return RecommendationUrl(
      id: json['id'],
      action: json['action'],
      videoUrl: json['video_url'],
    );
  }
}

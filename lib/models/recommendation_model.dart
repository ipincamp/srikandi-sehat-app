
// Model untuk rekomendasi menstruasi
class Recommendation {
  final String forSymptom;
  final String title;
  final String description;
  final String? source;

  Recommendation({
    required this.forSymptom,
    required this.title,
    required this.description,
    this.source,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      forSymptom: json['for_symptom'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      source: json['source'],
    );
  }
}

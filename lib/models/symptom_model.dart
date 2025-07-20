class Symptom {
  final String id;
  final String name;
  final String category;
  final String recomendation;

  Symptom(
      {required this.id,
      required this.name,
      required this.category,
      required this.recomendation});

  factory Symptom.fromJson(Map<String, dynamic> json) {
    return Symptom(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      recomendation: json['recomendation'],
    );
  }
}

class Symptom {
  final int id;
  final String name;
  final String category;
  final String recommendation;

  Symptom({
    required this.id,
    required this.name,
    required this.category,
    required this.recommendation,
  });

  factory Symptom.fromJson(Map<String, dynamic> json) {
    return Symptom(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      recommendation: json['recommendation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'recommendation': recommendation,
    };
  }
}

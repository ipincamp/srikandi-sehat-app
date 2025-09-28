class Symptom {
  final int id;
  final String name;
  final String type;
  final List? options;

  Symptom({
    required this.id,
    required this.name,
    required this.type,
    this.options,
  });

  factory Symptom.fromJson(Map<String, dynamic> json) {
    return Symptom(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      options: json['options'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'type': type, 'options': options};
  }
}

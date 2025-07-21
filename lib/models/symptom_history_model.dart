class Symptom {
  final String id;
  final String logDate;

  Symptom({
    required this.id,
    required this.logDate,
  });

  factory Symptom.fromJson(Map<String, dynamic> json) {
    return Symptom(
      id: json['id']?.toString() ?? '',
      logDate: json['log_date'] ?? '-',
    );
  }
}

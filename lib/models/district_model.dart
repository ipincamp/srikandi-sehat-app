class District {
  final String name;
  final String code;

  District({required this.name, required this.code});

  factory District.fromJson(Map<String, dynamic> json) {
    // Add validation
    if (json['name'] == null || json['code'] == null) {
      throw Exception('Invalid district data: $json');
    }

    return District(name: json['name'] as String, code: json['code'] as String);
  }

  @override
  String toString() => 'District(name: $name, code: $code)';
}

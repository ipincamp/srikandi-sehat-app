class District {
  final String name;
  final String code;

  District({required this.name, required this.code});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      name: json['name'],
      code: json['code'],
    );
  }
}

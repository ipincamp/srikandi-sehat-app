class Village {
  final String code;
  final String name;
  final String classification;

  Village(
      {required this.code, required this.name, required this.classification});

  factory Village.fromJson(Map<String, dynamic> json) {
    return Village(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      classification: json['classification'] ?? '',
    );
  }
}

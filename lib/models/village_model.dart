class Village {
  final String code;
  final String name;
  final String type;

  Village({required this.code, required this.name, required this.type});

  factory Village.fromJson(Map<String, dynamic> json) {
    return Village(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
    );
  }
}

class UserModel {
  final String id;
  final String name;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  get scope => null;
}

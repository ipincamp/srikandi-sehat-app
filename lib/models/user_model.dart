class UserModel {
  final String id;
  final String name;
  final DateTime createdAt;
  final String? classification; // 'urban' or 'rural'
  final int? totalUser; // New field for total users

  UserModel({
    required this.id,
    required this.name,
    required this.createdAt,
    this.classification,
    this.totalUser,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
      classification:
          json['classification'], // This may be null in API response
      totalUser: json['meta.total_data'], // This may be null in API response
    );
  }
}

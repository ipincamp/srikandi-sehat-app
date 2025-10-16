class NotificationModel {
  final int id;
  final String title;
  final String body;
  final DateTime createdAt;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'] ?? 'Tidak ada judul',
      body: json['body'] ?? 'Tidak ada konten',
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      isRead: json['is_read'] ?? false,
    );
  }
}
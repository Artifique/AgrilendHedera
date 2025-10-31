class AppNotification {
  final int? id;
  final int userId;
  final String type;
  final String title;
  final String message;
  final bool? isRead;

  AppNotification({
    this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.isRead,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] is int
            ? json['id']
            : (json['id'] != null ? int.parse('${json['id']}') : null),
        userId: json['user_id'] ?? json['userId'],
        type: json['type'] ?? 'SYSTEM_ANNOUNCEMENT',
        title: json['title'] ?? '',
        message: json['message'] ?? '',
        isRead: json['is_read'] ?? json['isRead'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'type': type,
        'title': title,
        'message': message,
        'is_read': isRead,
      };
}

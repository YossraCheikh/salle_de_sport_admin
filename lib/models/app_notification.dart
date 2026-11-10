enum NotificationTarget { all, members, coaches }
enum NotificationStatus { sent, planned }

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationTarget target;
  final DateTime scheduledAt;
  final NotificationStatus status;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.target,
    required this.scheduledAt,
    this.status = NotificationStatus.sent,
  });

  String get targetLabel {
    switch (target) {
      case NotificationTarget.members:
        return 'Adhérents';
      case NotificationTarget.coaches:
        return 'Coachs';
      case NotificationTarget.all:
      default:
        return 'Tous les membres';
    }
  }

  factory AppNotification.fromMap(Map<String, dynamic> map, String docId) {
    return AppNotification(
      id: docId,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      target: map['target'] == 'coaches'
          ? NotificationTarget.coaches
          : map['target'] == 'members'
              ? NotificationTarget.members
              : NotificationTarget.all,
      scheduledAt: map['scheduledAt'] != null
          ? DateTime.parse(map['scheduledAt'])
          : DateTime.now(),
      status: map['status'] == 'planned'
          ? NotificationStatus.planned
          : NotificationStatus.sent,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'target': target.name,
      'scheduledAt': scheduledAt.toIso8601String(),
      'status': status.name,
    };
  }
}

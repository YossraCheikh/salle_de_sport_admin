import 'package:cloud_firestore/cloud_firestore.dart';

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
      scheduledAt: _parseDateTime(map['scheduledAt']),
      status: map['status'] == 'planned'
          ? NotificationStatus.planned
          : NotificationStatus.sent,
    );
  }

  static DateTime _parseDateTime(dynamic val) {
    if (val == null) return DateTime.now();
    if (val is Timestamp) return val.toDate();
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    return DateTime.now();
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

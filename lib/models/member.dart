import 'package:cloud_firestore/cloud_firestore.dart';

enum MemberStatus { active, expiring, toVerify, inactive }

class Member {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final MemberStatus status;
  final String subscriptionName;
  final DateTime createdAt;
  final bool isSubscriptionApproved;

  Member({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    required this.status,
    required this.subscriptionName,
    required this.createdAt,
    this.isSubscriptionApproved = true,
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return 'M';
  }

  factory Member.fromMap(Map<String, dynamic> map, String docId) {
    return Member(
      id: docId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      photoUrl: map['photoUrl'],
      status: _parseStatus(map['status']),
      subscriptionName: map['subscriptionName'] ?? 'Sans abonnement',
      createdAt: _parseDateTime(map['createdAt']),
      isSubscriptionApproved: map['isSubscriptionApproved'] ?? (map['status'] != 'toVerify'),
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
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'status': status.name,
      'subscriptionName': subscriptionName,
      'createdAt': createdAt.toIso8601String(),
      'isSubscriptionApproved': isSubscriptionApproved,
    };
  }

  Member copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    MemberStatus? status,
    String? subscriptionName,
    DateTime? createdAt,
    bool? isSubscriptionApproved,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      subscriptionName: subscriptionName ?? this.subscriptionName,
      createdAt: createdAt ?? this.createdAt,
      isSubscriptionApproved: isSubscriptionApproved ?? this.isSubscriptionApproved,
    );
  }

  static MemberStatus _parseStatus(String? statusStr) {
    switch (statusStr) {
      case 'active':
        return MemberStatus.active;
      case 'expiring':
        return MemberStatus.expiring;
      case 'toVerify':
        return MemberStatus.toVerify;
      case 'inactive':
      default:
        return MemberStatus.inactive;
    }
  }
}

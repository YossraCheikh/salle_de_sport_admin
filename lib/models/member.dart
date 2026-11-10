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

  Member({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    required this.status,
    required this.subscriptionName,
    required this.createdAt,
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
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
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

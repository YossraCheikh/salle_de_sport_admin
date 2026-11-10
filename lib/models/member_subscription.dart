enum SubscriptionStatus { active, expiring, expired, none }

class MemberSubscription {
  final String id;
  final String memberId;
  final String planId;
  final String planName;
  final DateTime startDate;
  final DateTime endDate;
  final SubscriptionStatus status;

  MemberSubscription({
    required this.id,
    required this.memberId,
    required this.planId,
    required this.planName,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory MemberSubscription.fromMap(Map<String, dynamic> map, String docId) {
    return MemberSubscription(
      id: docId,
      memberId: map['memberId'] ?? '',
      planId: map['planId'] ?? '',
      planName: map['planName'] ?? 'Sans abonnement',
      startDate: map['startDate'] != null
          ? DateTime.parse(map['startDate'])
          : DateTime.now(),
      endDate: map['endDate'] != null
          ? DateTime.parse(map['endDate'])
          : DateTime.now().add(const Duration(days: 30)),
      status: _parseStatus(map['status']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'planId': planId,
      'planName': planName,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.name,
    };
  }

  static SubscriptionStatus _parseStatus(String? statusStr) {
    switch (statusStr) {
      case 'active':
        return SubscriptionStatus.active;
      case 'expiring':
        return SubscriptionStatus.expiring;
      case 'expired':
        return SubscriptionStatus.expired;
      default:
        return SubscriptionStatus.none;
    }
  }
}

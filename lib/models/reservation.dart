import 'package:cloud_firestore/cloud_firestore.dart';

enum ReservationStatus { confirmed, cancelled }

class Reservation {
  final String id;
  final String sessionId;
  final String sessionTitle;
  final String sessionTime;
  final String memberId;
  final String memberName;
  final String memberEmail;
  final DateTime bookingTime;
  final ReservationStatus status;
  final String paymentType; // 'subscription' | 'singleSeance'
  final double? pricePaidTnd;
  final bool isPrivateCoaching;
  final double? coachingFeeTnd;

  Reservation({
    required this.id,
    required this.sessionId,
    required this.sessionTitle,
    required this.sessionTime,
    required this.memberId,
    required this.memberName,
    required this.memberEmail,
    required this.bookingTime,
    this.status = ReservationStatus.confirmed,
    this.paymentType = 'subscription',
    this.pricePaidTnd,
    this.isPrivateCoaching = false,
    this.coachingFeeTnd,
  });

  factory Reservation.fromMap(Map<String, dynamic> map, String docId) {
    return Reservation(
      id: docId,
      sessionId: map['sessionId'] ?? '',
      sessionTitle: map['sessionTitle'] ?? '',
      sessionTime: map['sessionTime'] ?? '',
      memberId: map['memberId'] ?? '',
      memberName: map['memberName'] ?? '',
      memberEmail: map['memberEmail'] ?? '',
      bookingTime: _parseDateTime(map['bookingTime']),
      status: map['status'] == 'cancelled'
          ? ReservationStatus.cancelled
          : ReservationStatus.confirmed,
      paymentType: map['paymentType'] ?? 'subscription',
      pricePaidTnd: map['pricePaidTnd'] != null
          ? (map['pricePaidTnd'] as num).toDouble()
          : null,
      isPrivateCoaching: map['isPrivateCoaching'] ?? false,
      coachingFeeTnd: map['coachingFeeTnd'] != null
          ? (map['coachingFeeTnd'] as num).toDouble()
          : null,
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
      'sessionId': sessionId,
      'sessionTitle': sessionTitle,
      'sessionTime': sessionTime,
      'memberId': memberId,
      'memberName': memberName,
      'memberEmail': memberEmail,
      'bookingTime': bookingTime.toIso8601String(),
      'status': status.name,
      'paymentType': paymentType,
      'pricePaidTnd': pricePaidTnd,
      'isPrivateCoaching': isPrivateCoaching,
      'coachingFeeTnd': coachingFeeTnd,
    };
  }
}

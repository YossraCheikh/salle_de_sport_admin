import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class GymSession {
  final String id;
  final String title;
  final String type; // Musculation, Cardio, Pilates, Yoga, CrossFit, Spinning, Zumba, Boxe
  final String coachId;
  final String coachName;
  final DateTime startAt;
  final int durationMin;
  final int maxParticipants;
  final int enrolledCount;
  final double? singleSeancePriceTnd;
  final bool isPrivateCoaching;
  final double? coachingFeeTnd;
  final bool isApproved; // Validé par l'admin (true) ou en attente (false)
  final String status; // 'approved', 'pendingApproval', 'rejected'

  GymSession({
    required this.id,
    required this.title,
    required this.type,
    required this.coachId,
    required this.coachName,
    required this.startAt,
    required this.durationMin,
    required this.maxParticipants,
    required this.enrolledCount,
    this.singleSeancePriceTnd,
    this.isPrivateCoaching = false,
    this.coachingFeeTnd,
    this.isApproved = true,
    this.status = 'approved',
  });

  String get formattedTime => DateFormat('HH:mm').format(startAt);

  double get occupancyRate =>
      maxParticipants > 0 ? (enrolledCount / maxParticipants) : 0.0;

  int get occupancyPercentage => (occupancyRate * 100).round();

  double get totalPriceTnd =>
      (singleSeancePriceTnd ?? 0.0) + (isPrivateCoaching ? (coachingFeeTnd ?? 0.0) : 0.0);

  factory GymSession.fromMap(Map<String, dynamic> map, String docId) {
    return GymSession(
      id: docId,
      title: map['title'] ?? '',
      type: map['type'] ?? 'Musculation',
      coachId: map['coachId'] ?? '',
      coachName: map['coachName'] ?? 'Coach non assigné',
      startAt: _parseDateTime(map['startAt']),
      durationMin: map['durationMin'] ?? 45,
      maxParticipants: map['maxParticipants'] ?? 15,
      enrolledCount: map['enrolledCount'] ?? 0,
      singleSeancePriceTnd: map['singleSeancePriceTnd'] != null
          ? (map['singleSeancePriceTnd'] as num).toDouble()
          : null,
      isPrivateCoaching: map['isPrivateCoaching'] ?? false,
      coachingFeeTnd: map['coachingFeeTnd'] != null
          ? (map['coachingFeeTnd'] as num).toDouble()
          : null,
      isApproved: map['isApproved'] ?? true,
      status: map['status'] ?? 'approved',
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
      'type': type,
      'coachId': coachId,
      'coachName': coachName,
      'startAt': startAt.toIso8601String(),
      'durationMin': durationMin,
      'maxParticipants': maxParticipants,
      'enrolledCount': enrolledCount,
      'singleSeancePriceTnd': singleSeancePriceTnd,
      'isPrivateCoaching': isPrivateCoaching,
      'coachingFeeTnd': coachingFeeTnd,
      'isApproved': isApproved,
      'status': status,
    };
  }

  GymSession copyWith({
    String? id,
    String? title,
    String? type,
    String? coachId,
    String? coachName,
    DateTime? startAt,
    int? durationMin,
    int? maxParticipants,
    int? enrolledCount,
    double? singleSeancePriceTnd,
    bool? isPrivateCoaching,
    double? coachingFeeTnd,
    bool? isApproved,
    String? status,
  }) {
    return GymSession(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      coachId: coachId ?? this.coachId,
      coachName: coachName ?? this.coachName,
      startAt: startAt ?? this.startAt,
      durationMin: durationMin ?? this.durationMin,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      enrolledCount: enrolledCount ?? this.enrolledCount,
      singleSeancePriceTnd: singleSeancePriceTnd ?? this.singleSeancePriceTnd,
      isPrivateCoaching: isPrivateCoaching ?? this.isPrivateCoaching,
      coachingFeeTnd: coachingFeeTnd ?? this.coachingFeeTnd,
      isApproved: isApproved ?? this.isApproved,
      status: status ?? this.status,
    );
  }
}

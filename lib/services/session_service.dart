import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/gym_session.dart';
import '../models/reservation.dart';
import 'local_storage_service.dart';
import 'reservation_service.dart';

class SessionService {
  static const String _storageKey = 'pulse_admin_sessions';
  static List<GymSession>? _cachedSessions;

  FirebaseFirestore? get _db =>
      Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null;

  final List<GymSession> _defaultSessions = [
    GymSession(
      id: 's1',
      title: 'CrossFit Power 1-on-1',
      type: 'CrossFit',
      coachId: 'c3',
      coachName: 'Karem Louati',
      startAt: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 9, 0),
      durationMin: 60,
      maxParticipants: 15,
      enrolledCount: 3,
      singleSeancePriceTnd: 20,
      isPrivateCoaching: true,
      coachingFeeTnd: 20,
    ),
    GymSession(
      id: 's2',
      title: 'Spinning Express',
      type: 'Spinning',
      coachId: 'c4',
      coachName: 'Sarra Gharbi',
      startAt: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 11, 0),
      durationMin: 45,
      maxParticipants: 20,
      enrolledCount: 2,
      singleSeancePriceTnd: 15,
    ),
    GymSession(
      id: 's3',
      title: 'Pilates Reformer',
      type: 'Pilates',
      coachId: 'c2',
      coachName: 'Yasmine Trabelsi',
      startAt: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 14, 30),
      durationMin: 60,
      maxParticipants: 12,
      enrolledCount: 2,
      singleSeancePriceTnd: 18,
    ),
    GymSession(
      id: 's4',
      title: 'Musculation Hypertrophie',
      type: 'Musculation',
      coachId: 'c1',
      coachName: 'Sami Ben Ali',
      startAt: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 17, 0),
      durationMin: 75,
      maxParticipants: 10,
      enrolledCount: 1,
      singleSeancePriceTnd: 15,
    ),
  ];

  List<GymSession> get defaultSessions {
    final now = DateTime.now();
    return _defaultSessions.map((s) {
      return s.copyWith(
        startAt: DateTime(now.year, now.month, now.day, s.startAt.hour, s.startAt.minute),
      );
    }).toList();
  }

  static void resetCache() {
    _cachedSessions = null;
  }

  GymSession? checkScheduleConflict({
    required List<GymSession> sessions,
    required DateTime startAt,
    required int durationMin,
    String? excludeSessionId,
  }) {
    final endAt = startAt.add(Duration(minutes: durationMin));

    for (final s in sessions) {
      if (excludeSessionId != null && s.id == excludeSessionId) continue;

      final existingStart = s.startAt;
      final existingEnd = s.startAt.add(Duration(minutes: s.durationMin));

      final isSameDay = existingStart.year == startAt.year &&
          existingStart.month == startAt.month &&
          existingStart.day == startAt.day;

      if (isSameDay) {
        if (existingStart.isBefore(endAt) && existingEnd.isAfter(startAt)) {
          return s; // Chevauchement trouvé
        }
      }
    }
    return null;
  }

  Stream<List<GymSession>> getSessionsStream() {
    if (_db == null) {
      return Stream.fromFuture(fetchSessionsForDate(DateTime.now()));
    }

    return _db!.collection('sessions').snapshots().asyncMap((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        final sessions = snapshot.docs
            .map((doc) => GymSession.fromMap(doc.data(), doc.id))
            .toList();
        _cachedSessions = sessions;
        await _saveToDisk();
        return sessions;
      } else {
        final defaultWithToday = defaultSessions;
        for (final s in defaultWithToday) {
          try {
            await _db!.collection('sessions').doc(s.id).set(s.toMap());
          } catch (_) {}
        }
        _cachedSessions = defaultWithToday;
        await _saveToDisk();
        return defaultWithToday;
      }
    });
  }

  Stream<List<Map<String, dynamic>>> getEnrolledMembersStream(String sessionId) {
    if (_db == null) {
      return Stream.fromFuture(fetchEnrolledMembers(sessionId));
    }

    return _db!
        .collection('reservations')
        .where('sessionId', isEqualTo: sessionId)
        .where('status', isEqualTo: 'confirmed')
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      } else {
        return await fetchEnrolledMembers(sessionId);
      }
    });
  }

  Future<List<GymSession>> fetchSessionsForDate(DateTime date) async {
    if (_cachedSessions == null || _cachedSessions!.isEmpty) {
      await _loadAllSessions();
    }

    return _cachedSessions!.where((s) {
      return s.startAt.year == date.year &&
          s.startAt.month == date.month &&
          s.startAt.day == date.day;
    }).toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));
  }

  Future<void> _loadAllSessions() async {
    try {
      if (_db != null) {
        final snapshot = await _db!.collection('sessions').get();
        if (snapshot.docs.isNotEmpty) {
          _cachedSessions = snapshot.docs
              .map((doc) => GymSession.fromMap(doc.data(), doc.id))
              .toList();
          await _saveToDisk();
          return;
        }
      }
    } catch (e) {
      if (kDebugMode) print('SessionService Firestore fallback: $e');
    }

    final diskList = await LocalStorageService.loadJsonList(_storageKey);
    if (diskList != null && diskList.isNotEmpty) {
      _cachedSessions = diskList.map((map) => GymSession.fromMap(map, map['id'] ?? '')).toList();
    } else {
      _cachedSessions = defaultSessions;
      await _saveToDisk();
    }
  }

  Future<void> _saveToDisk() async {
    if (_cachedSessions != null) {
      final jsonList = _cachedSessions!.map((s) {
        final map = s.toMap();
        map['id'] = s.id;
        return map;
      }).toList();
      await LocalStorageService.saveJsonList(_storageKey, jsonList);
    }
  }

  Future<List<Map<String, dynamic>>> fetchEnrolledMembers(String sessionId) async {
    try {
      if (_db != null) {
        final snapshot = await _db!
            .collection('reservations')
            .where('sessionId', isEqualTo: sessionId)
            .where('status', isEqualTo: 'confirmed')
            .get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        }
      }
    } catch (e) {
      if (kDebugMode) print('SessionService fetchEnrolledMembers error: $e');
    }

    final resList = await ReservationService().fetchReservations();
    final matching = resList
        .where((r) => r.sessionId == sessionId && r.status == ReservationStatus.confirmed)
        .toList();
    if (matching.isNotEmpty) {
      return matching.map((r) => r.toMap()).toList();
    }

    return [
      {
        'memberName': 'Mohamed Amine Ayari',
        'memberEmail': 'amine.ayari@gmail.com',
        'paymentType': 'singleSeance',
        'pricePaidTnd': 20.0,
        'bookingTime': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
      },
      {
        'memberName': 'Sarra Mansouri',
        'memberEmail': 'sarra.m@gmail.com',
        'paymentType': 'subscription',
        'pricePaidTnd': 80.0,
        'bookingTime': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'memberName': 'Nadia Bouaziz',
        'memberEmail': 'nadia.b@gmail.com',
        'paymentType': 'subscription',
        'pricePaidTnd': 90.0,
        'bookingTime': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      },
    ];
  }

  Future<GymSession> addSession({
    required String title,
    required String type,
    required String coachId,
    required String coachName,
    required DateTime startAt,
    required int durationMin,
    required int maxParticipants,
    double? singleSeancePriceTnd,
    bool isPrivateCoaching = false,
    double? coachingFeeTnd,
  }) async {
    final newSession = GymSession(
      id: 's_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      type: type,
      coachId: coachId,
      coachName: coachName,
      startAt: startAt,
      durationMin: durationMin,
      maxParticipants: maxParticipants,
      enrolledCount: 0,
      singleSeancePriceTnd: singleSeancePriceTnd,
      isPrivateCoaching: isPrivateCoaching,
      coachingFeeTnd: coachingFeeTnd,
    );

    try {
      if (_db != null) {
        await _db!.collection('sessions').doc(newSession.id).set(newSession.toMap());
      }
    } catch (_) {}

    if (_cachedSessions == null) {
      await _loadAllSessions();
    }
    _cachedSessions!.add(newSession);
    await _saveToDisk();

    return newSession;
  }

  Future<void> updateSession(GymSession updated) async {
    try {
      if (_db != null) {
        await _db!.collection('sessions').doc(updated.id).update(updated.toMap());
      }
    } catch (_) {}

    if (_cachedSessions == null) {
      await _loadAllSessions();
    }
    final index = _cachedSessions!.indexWhere((s) => s.id == updated.id);
    if (index != -1) {
      _cachedSessions![index] = updated;
      await _saveToDisk();
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      if (_db != null) {
        await _db!.collection('sessions').doc(sessionId).delete();
      }
    } catch (_) {}

    if (_cachedSessions == null) {
      await _loadAllSessions();
    }
    _cachedSessions!.removeWhere((s) => s.id == sessionId);
    await _saveToDisk();
  }
}

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
          return s;
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
      final sessions = snapshot.docs
          .map((doc) => GymSession.fromMap(doc.data(), doc.id))
          .toList();
      _cachedSessions = sessions;
      await _saveToDisk();
      return sessions;
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
      _cachedSessions = [];
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

    return [];
  }

  Future<void> approveSession(String sessionId) async {
    try {
      if (_db != null) {
        await _db!.collection('sessions').doc(sessionId).set({
          'isApproved': true,
          'status': 'approved',
        }, SetOptions(merge: true));
      }
    } catch (_) {}

    if (_cachedSessions == null) {
      await _loadAllSessions();
    }
    final index = _cachedSessions!.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      _cachedSessions![index] = _cachedSessions![index].copyWith(
        isApproved: true,
        status: 'approved',
      );
      await _saveToDisk();
    }
  }

  Future<void> rejectSession(String sessionId) async {
    try {
      if (_db != null) {
        await _db!.collection('sessions').doc(sessionId).set({
          'isApproved': false,
          'status': 'rejected',
        }, SetOptions(merge: true));
      }
    } catch (_) {}

    if (_cachedSessions == null) {
      await _loadAllSessions();
    }
    final index = _cachedSessions!.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      _cachedSessions![index] = _cachedSessions![index].copyWith(
        isApproved: false,
        status: 'rejected',
      );
      await _saveToDisk();
    }
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

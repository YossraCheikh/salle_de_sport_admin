import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/coach.dart';
import 'local_storage_service.dart';

class CoachService {
  static const String _storageKey = 'pulse_admin_coaches';
  static List<Coach>? _cachedCoaches;

  FirebaseFirestore? get _db =>
      Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null;

  static void resetCache() {
    _cachedCoaches = null;
  }

  Stream<List<Coach>> getCoachesStream() {
    if (_db == null) {
      return Stream.fromFuture(fetchCoaches());
    }

    return _db!.collection('users').snapshots().asyncMap((snapshot) async {
      final list = snapshot.docs
          .where((doc) => (doc.data()['role'] ?? '').toString().toLowerCase() == 'coach')
          .map((doc) => Coach.fromMap(doc.data(), doc.id))
          .toList();

      _cachedCoaches = list;
      await _saveToDisk();
      return list;
    });
  }

  Future<List<Coach>> fetchCoaches() async {
    if (_cachedCoaches != null && _cachedCoaches!.isNotEmpty) {
      return List.from(_cachedCoaches!);
    }

    try {
      if (_db != null) {
        final snapshot = await _db!.collection('users').get();
        final list = snapshot.docs
            .where((doc) => (doc.data()['role'] ?? '').toString().toLowerCase() == 'coach')
            .map((doc) => Coach.fromMap(doc.data(), doc.id))
            .toList();

        _cachedCoaches = list;
        await _saveToDisk();
        return list;
      }
    } catch (e) {
      if (kDebugMode) print('CoachService Firestore fallback: $e');
    }

    final diskList = await LocalStorageService.loadJsonList(_storageKey);
    if (diskList != null && diskList.isNotEmpty) {
      _cachedCoaches = diskList.map((map) => Coach.fromMap(map, map['id'] ?? '')).toList();
      return List.from(_cachedCoaches!);
    }

    return [];
  }

  Future<void> _saveToDisk() async {
    if (_cachedCoaches != null) {
      final jsonList = _cachedCoaches!.map((c) {
        final map = c.toMap();
        map['id'] = c.id;
        return map;
      }).toList();
      await LocalStorageService.saveJsonList(_storageKey, jsonList);
    }
  }

  Future<List<Map<String, dynamic>>> fetchCoachSessions(String coachId) async {
    try {
      if (_db != null) {
        final snapshot = await _db!
            .collection('sessions')
            .where('coachId', isEqualTo: coachId)
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
      if (kDebugMode) print('CoachService fetchCoachSessions error: $e');
    }
    return [];
  }

  Future<Coach> addCoach({
    required String name,
    required String email,
    required String phone,
    required String bio,
    required List<String> specialties,
    CoachType type = CoachType.gym,
  }) async {
    final newCoach = Coach(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      bio: bio,
      specialties: specialties,
      activeSessionsCount: 0,
      type: type,
    );

    try {
      if (_db != null) {
        final data = newCoach.toMap();
        data['role'] = 'coach';
        await _db!.collection('users').doc(newCoach.id).set(data);
      }
    } catch (_) {}

    if (_cachedCoaches == null) {
      await fetchCoaches();
    }
    _cachedCoaches!.insert(0, newCoach);
    await _saveToDisk();

    return newCoach;
  }

  Future<void> updateCoach(Coach updated) async {
    try {
      if (_db != null) {
        final data = updated.toMap();
        data['role'] = 'coach';
        await _db!.collection('users').doc(updated.id).set(data, SetOptions(merge: true));
      }
    } catch (_) {}

    if (_cachedCoaches == null) {
      await fetchCoaches();
    }
    final index = _cachedCoaches!.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      _cachedCoaches![index] = updated;
      await _saveToDisk();
    }
  }

  Future<void> deleteCoach(String coachId) async {
    try {
      if (_db != null) {
        await _db!.collection('users').doc(coachId).delete();
      }
    } catch (_) {}

    if (_cachedCoaches == null) {
      await fetchCoaches();
    }
    _cachedCoaches!.removeWhere((c) => c.id == coachId);
    await _saveToDisk();
  }
}

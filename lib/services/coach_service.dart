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

  final List<Coach> _defaultCoaches = [
    Coach(
      id: 'c1',
      name: 'Sami Ben Ali',
      email: 'sami.benali@gym.tn',
      phone: '+216 20 123 456',
      bio: 'Expert en Musculation et Bodybuilding avec 8 ans d\'expérience.',
      specialties: ['Musculation', 'Bodybuilding', 'Prise de masse'],
      activeSessionsCount: 12,
      type: CoachType.gym,
    ),
    Coach(
      id: 'c2',
      name: 'Yasmine Trabelsi',
      email: 'yasmine.trabelsi@gym.tn',
      phone: '+216 22 987 654',
      bio: 'Instructrice certifiée de Yoga et Pilates.',
      specialties: ['Yoga', 'Pilates', 'Souplesse'],
      activeSessionsCount: 8,
      type: CoachType.gym,
    ),
    Coach(
      id: 'c3',
      name: 'Karem Louati',
      email: 'karem.louati@gym.tn',
      phone: '+216 55 444 333',
      bio: 'Spécialiste CrossFit et préparation physique haute intensité.',
      specialties: ['CrossFit', 'HIIT', 'Cardio'],
      activeSessionsCount: 15,
      type: CoachType.private,
    ),
    Coach(
      id: 'c4',
      name: 'Sarra Gharbi',
      email: 'sarra.gharbi@gym.tn',
      phone: '+216 98 111 222',
      bio: 'Coach de Spinning et d\'Aérobic dynamique.',
      specialties: ['Spinning', 'Aérobic', 'Perte de poids'],
      activeSessionsCount: 10,
      type: CoachType.gym,
    ),
  ];

  List<Coach> get defaultCoaches => List.from(_defaultCoaches);

  static void resetCache() {
    _cachedCoaches = null;
  }

  Stream<List<Coach>> getCoachesStream() {
    if (_db == null) {
      return Stream.fromFuture(fetchCoaches());
    }

    return _db!.collection('coaches').snapshots().asyncMap((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        final list = snapshot.docs
            .map((doc) => Coach.fromMap(doc.data(), doc.id))
            .toList();
        _cachedCoaches = list;
        await _saveToDisk();
        return list;
      } else {
        for (final c in _defaultCoaches) {
          try {
            await _db!.collection('coaches').doc(c.id).set(c.toMap());
          } catch (_) {}
        }
        _cachedCoaches = List.from(_defaultCoaches);
        await _saveToDisk();
        return List.from(_defaultCoaches);
      }
    });
  }

  Future<List<Coach>> fetchCoaches() async {
    if (_cachedCoaches != null && _cachedCoaches!.isNotEmpty) {
      return List.from(_cachedCoaches!);
    }

    try {
      if (_db != null) {
        final snapshot = await _db!.collection('coaches').get();
        if (snapshot.docs.isNotEmpty) {
          _cachedCoaches = snapshot.docs
              .map((doc) => Coach.fromMap(doc.data(), doc.id))
              .toList();
          await _saveToDisk();
          return List.from(_cachedCoaches!);
        }
      }
    } catch (e) {
      if (kDebugMode) print('CoachService Firestore fallback: $e');
    }

    final diskList = await LocalStorageService.loadJsonList(_storageKey);
    if (diskList != null && diskList.isNotEmpty) {
      _cachedCoaches = diskList.map((map) => Coach.fromMap(map, map['id'] ?? '')).toList();
    } else {
      _cachedCoaches = List.from(_defaultCoaches);
      await _saveToDisk();
    }

    return List.from(_cachedCoaches!);
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
        await _db!.collection('coaches').doc(newCoach.id).set(newCoach.toMap());
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
        await _db!.collection('coaches').doc(updated.id).update(updated.toMap());
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
        await _db!.collection('coaches').doc(coachId).delete();
      }
    } catch (_) {}

    if (_cachedCoaches == null) {
      await fetchCoaches();
    }
    _cachedCoaches!.removeWhere((c) => c.id == coachId);
    await _saveToDisk();
  }
}

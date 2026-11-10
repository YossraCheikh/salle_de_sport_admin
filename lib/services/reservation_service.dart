import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/reservation.dart';
import 'local_storage_service.dart';

class ReservationService {
  static const String _storageKey = 'pulse_admin_reservations';
  static List<Reservation>? _cachedReservations;

  FirebaseFirestore? get _db =>
      Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null;

  final List<Reservation> _defaultReservations = [
    Reservation(
      id: 'res1',
      sessionId: 's1',
      sessionTitle: 'CrossFit Power 1-on-1',
      sessionTime: '09:00',
      memberId: 'm1',
      memberName: 'Mohamed Amine Ayari',
      memberEmail: 'amine.ayari@gmail.com',
      bookingTime: DateTime.now().subtract(const Duration(hours: 5)),
      status: ReservationStatus.confirmed,
      paymentType: 'singleSeance',
      pricePaidTnd: 20,
      isPrivateCoaching: true,
      coachingFeeTnd: 20,
    ),
    Reservation(
      id: 'res2',
      sessionId: 's2',
      sessionTitle: 'Spinning Express',
      sessionTime: '11:00',
      memberId: 'm2',
      memberName: 'Sarra Mansouri',
      memberEmail: 'sarra.m@gmail.com',
      bookingTime: DateTime.now().subtract(const Duration(hours: 3)),
      status: ReservationStatus.confirmed,
      paymentType: 'subscription',
    ),
    Reservation(
      id: 'res3',
      sessionId: 's3',
      sessionTitle: 'Pilates Reformer',
      sessionTime: '14:30',
      memberId: 'm6',
      memberName: 'Nadia Bouaziz',
      memberEmail: 'nadia.b@gmail.com',
      bookingTime: DateTime.now().subtract(const Duration(hours: 2)),
      status: ReservationStatus.confirmed,
      paymentType: 'subscription',
    ),
  ];

  List<Reservation> get defaultReservations => List.from(_defaultReservations);

  static void resetCache() {
    _cachedReservations = null;
  }

  Stream<List<Reservation>> getReservationsStream() {
    if (_db == null) {
      return Stream.fromFuture(fetchReservations());
    }

    return _db!.collection('reservations').snapshots().asyncMap((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        final list = snapshot.docs
            .map((doc) => Reservation.fromMap(doc.data(), doc.id))
            .toList();
        _cachedReservations = list;
        await _saveToDisk();
        return list;
      } else {
        for (final r in _defaultReservations) {
          try {
            await _db!.collection('reservations').doc(r.id).set(r.toMap());
          } catch (_) {}
        }
        _cachedReservations = List.from(_defaultReservations);
        await _saveToDisk();
        return List.from(_defaultReservations);
      }
    });
  }

  Future<List<Reservation>> fetchReservations() async {
    if (_cachedReservations != null && _cachedReservations!.isNotEmpty) {
      return List.from(_cachedReservations!);
    }

    try {
      if (_db != null) {
        final snapshot = await _db!.collection('reservations').get();
        if (snapshot.docs.isNotEmpty) {
          _cachedReservations = snapshot.docs
              .map((doc) => Reservation.fromMap(doc.data(), doc.id))
              .toList();
          await _saveToDisk();
          return List.from(_cachedReservations!);
        }
      }
    } catch (e) {
      if (kDebugMode) print('ReservationService Firestore fallback: $e');
    }

    final diskList = await LocalStorageService.loadJsonList(_storageKey);
    if (diskList != null && diskList.isNotEmpty) {
      _cachedReservations =
          diskList.map((map) => Reservation.fromMap(map, map['id'] ?? '')).toList();
    } else {
      _cachedReservations = List.from(_defaultReservations);
      await _saveToDisk();
    }

    return List.from(_cachedReservations!);
  }

  Future<void> _saveToDisk() async {
    if (_cachedReservations != null) {
      final jsonList = _cachedReservations!.map((r) {
        final map = r.toMap();
        map['id'] = r.id;
        return map;
      }).toList();
      await LocalStorageService.saveJsonList(_storageKey, jsonList);
    }
  }

  Future<Reservation> addReservation({
    required String sessionId,
    required String sessionTitle,
    required String sessionTime,
    required String memberId,
    required String memberName,
    required String memberEmail,
    String paymentType = 'subscription',
    double? pricePaidTnd,
    bool isPrivateCoaching = false,
    double? coachingFeeTnd,
  }) async {
    final newRes = Reservation(
      id: 'res_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: sessionId,
      sessionTitle: sessionTitle,
      sessionTime: sessionTime,
      memberId: memberId,
      memberName: memberName,
      memberEmail: memberEmail,
      bookingTime: DateTime.now(),
      status: ReservationStatus.confirmed,
      paymentType: paymentType,
      pricePaidTnd: pricePaidTnd,
      isPrivateCoaching: isPrivateCoaching,
      coachingFeeTnd: coachingFeeTnd,
    );

    try {
      if (_db != null) {
        await _db!.collection('reservations').doc(newRes.id).set(newRes.toMap());
      }
    } catch (e) {
      if (kDebugMode) print('ReservationService Firestore save fallback: $e');
    }

    if (_cachedReservations == null) {
      await fetchReservations();
    }
    _cachedReservations!.insert(0, newRes);
    await _saveToDisk();

    return newRes;
  }

  Future<void> cancelReservation(String id) async {
    try {
      if (_db != null) {
        await _db!
            .collection('reservations')
            .doc(id)
            .update({'status': 'cancelled'});
      }
    } catch (e) {
      if (kDebugMode) print('ReservationService Firestore cancel fallback: $e');
    }

    if (_cachedReservations == null) {
      await fetchReservations();
    }
    final index = _cachedReservations!.indexWhere((r) => r.id == id);
    if (index != -1) {
      final old = _cachedReservations![index];
      _cachedReservations![index] = Reservation(
        id: old.id,
        sessionId: old.sessionId,
        sessionTitle: old.sessionTitle,
        sessionTime: old.sessionTime,
        memberId: old.memberId,
        memberName: old.memberName,
        memberEmail: old.memberEmail,
        bookingTime: old.bookingTime,
        status: ReservationStatus.cancelled,
        paymentType: old.paymentType,
        pricePaidTnd: old.pricePaidTnd,
        isPrivateCoaching: old.isPrivateCoaching,
        coachingFeeTnd: old.coachingFeeTnd,
      );
      await _saveToDisk();
    }
  }
}

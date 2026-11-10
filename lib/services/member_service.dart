import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/member.dart';
import 'local_storage_service.dart';

class MemberService {
  static const String _storageKey = 'pulse_admin_members';
  static List<Member>? _cachedMembers;

  FirebaseFirestore? get _db =>
      Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null;

  final List<Member> _defaultMembers = [
    Member(
      id: 'm1',
      name: 'Mohamed Amine Ayari',
      email: 'amine.ayari@gmail.com',
      phone: '+216 21 001 002',
      status: MemberStatus.active,
      subscriptionName: 'Trimestriel',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    Member(
      id: 'm2',
      name: 'Sarra Mansouri',
      email: 'sarra.m@gmail.com',
      phone: '+216 52 334 455',
      status: MemberStatus.active,
      subscriptionName: 'Premium Annuel',
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
    Member(
      id: 'm3',
      name: 'Ahmed Jaziri',
      email: 'ahmed.j@yahoo.fr',
      phone: '+216 97 889 900',
      status: MemberStatus.expiring,
      subscriptionName: 'Mensuel',
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
    Member(
      id: 'm4',
      name: 'Ines Bouchoucha',
      email: 'ines.b@gmail.com',
      phone: '+216 26 112 233',
      status: MemberStatus.toVerify,
      subscriptionName: 'Mensuel - Pilates',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Member(
      id: 'm5',
      name: 'Billal Hammami',
      email: 'billal.h@outlook.com',
      phone: '+216 50 667 788',
      status: MemberStatus.inactive,
      subscriptionName: 'Sans abonnement',
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
    ),
    Member(
      id: 'm6',
      name: 'Nadia Bouaziz',
      email: 'nadia.b@gmail.com',
      phone: '+216 93 445 566',
      status: MemberStatus.active,
      subscriptionName: 'Mensuel',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
  ];

  List<Member> get defaultMembers => List.from(_defaultMembers);

  static void resetCache() {
    _cachedMembers = null;
  }

  Stream<List<Member>> getMembersStream() {
    if (_db == null) {
      return Stream.fromFuture(fetchMembers());
    }

    return _db!.collection('members').snapshots().asyncMap((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        final list = snapshot.docs
            .map((doc) => Member.fromMap(doc.data(), doc.id))
            .toList();
        _cachedMembers = list;
        await _saveToDisk();
        return list;
      } else {
        for (final m in _defaultMembers) {
          try {
            await _db!.collection('members').doc(m.id).set(m.toMap());
          } catch (_) {}
        }
        _cachedMembers = List.from(_defaultMembers);
        await _saveToDisk();
        return List.from(_defaultMembers);
      }
    });
  }

  Future<List<Member>> fetchMembers() async {
    if (_cachedMembers != null && _cachedMembers!.isNotEmpty) {
      return List.from(_cachedMembers!);
    }

    try {
      if (_db != null) {
        final snapshot = await _db!.collection('members').get();
        if (snapshot.docs.isNotEmpty) {
          _cachedMembers = snapshot.docs
              .map((doc) => Member.fromMap(doc.data(), doc.id))
              .toList();
          await _saveToDisk();
          return List.from(_cachedMembers!);
        }
      }
    } catch (e) {
      if (kDebugMode) print('MemberService Firestore fallback: $e');
    }

    final diskList = await LocalStorageService.loadJsonList(_storageKey);
    if (diskList != null && diskList.isNotEmpty) {
      _cachedMembers = diskList.map((map) => Member.fromMap(map, map['id'] ?? '')).toList();
    } else {
      _cachedMembers = List.from(_defaultMembers);
      await _saveToDisk();
    }

    return List.from(_cachedMembers!);
  }

  Future<void> _saveToDisk() async {
    if (_cachedMembers != null) {
      final jsonList = _cachedMembers!.map((m) {
        final map = m.toMap();
        map['id'] = m.id;
        return map;
      }).toList();
      await LocalStorageService.saveJsonList(_storageKey, jsonList);
    }
  }

  Future<List<Map<String, dynamic>>> fetchMemberActivityHistory(String memberId) async {
    try {
      if (_db != null) {
        final snapshot = await _db!
            .collection('reservations')
            .where('memberId', isEqualTo: memberId)
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
      if (kDebugMode) print('MemberService fetchMemberActivityHistory error: $e');
    }
    return [];
  }

  Future<Member> addMember({
    required String name,
    required String email,
    required String phone,
    required String subscriptionName,
    MemberStatus status = MemberStatus.active,
  }) async {
    final newMember = Member(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      status: status,
      subscriptionName: subscriptionName,
      createdAt: DateTime.now(),
    );

    try {
      if (_db != null) {
        await _db!.collection('members').doc(newMember.id).set(newMember.toMap());
      }
    } catch (e) {
      if (kDebugMode) print('MemberService Firestore save fallback: $e');
    }

    if (_cachedMembers == null) {
      await fetchMembers();
    }
    _cachedMembers!.insert(0, newMember);
    await _saveToDisk();

    return newMember;
  }

  Future<void> updateMember(Member updated) async {
    try {
      if (_db != null) {
        await _db!.collection('members').doc(updated.id).update(updated.toMap());
      }
    } catch (_) {}

    if (_cachedMembers == null) {
      await fetchMembers();
    }
    final index = _cachedMembers!.indexWhere((m) => m.id == updated.id);
    if (index != -1) {
      _cachedMembers![index] = updated;
      await _saveToDisk();
    }
  }

  Future<void> deleteMember(String memberId) async {
    try {
      if (_db != null) {
        await _db!.collection('members').doc(memberId).delete();
      }
    } catch (_) {}

    if (_cachedMembers == null) {
      await fetchMembers();
    }
    _cachedMembers!.removeWhere((m) => m.id == memberId);
    await _saveToDisk();
  }
}

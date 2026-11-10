import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/app_notification.dart';
import 'local_storage_service.dart';

class NotificationService {
  static const String _storageKey = 'pulse_admin_notifications';
  static List<AppNotification>? _cachedNotifications;

  FirebaseFirestore? get _db =>
      Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null;

  final List<AppNotification> _defaultNotifications = [
    AppNotification(
      id: 'n1',
      title: 'Nouveau planning disponible',
      body: 'Le planning des cours de Pilates, CrossFit et Musculation de la semaine est en ligne !',
      target: NotificationTarget.all,
      scheduledAt: DateTime.now().subtract(const Duration(days: 1)),
      status: NotificationStatus.sent,
    ),
    AppNotification(
      id: 'n2',
      title: 'Relance Automatique Expiration (≤ 5 jours)',
      body: 'Rappel automatique envoyé aux membres expirant sous 5 jours.',
      target: NotificationTarget.members,
      scheduledAt: DateTime.now(),
      status: NotificationStatus.sent,
    ),
  ];

  List<AppNotification> get defaultNotifications => List.from(_defaultNotifications);

  static void resetCache() {
    _cachedNotifications = null;
  }

  Stream<List<AppNotification>> getNotificationsStream() {
    if (_db == null) {
      return Stream.fromFuture(fetchNotifications());
    }

    return _db!
        .collection('notifications')
        .orderBy('scheduledAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        final list = snapshot.docs
            .map((doc) => AppNotification.fromMap(doc.data(), doc.id))
            .toList();
        _cachedNotifications = list;
        await _saveToDisk();
        return list;
      } else {
        for (final n in _defaultNotifications) {
          try {
            await _db!.collection('notifications').doc(n.id).set(n.toMap());
          } catch (_) {}
        }
        _cachedNotifications = List.from(_defaultNotifications);
        await _saveToDisk();
        return List.from(_defaultNotifications);
      }
    });
  }

  Future<List<AppNotification>> fetchNotifications() async {
    if (_cachedNotifications != null && _cachedNotifications!.isNotEmpty) {
      return List.from(_cachedNotifications!);
    }

    try {
      if (_db != null) {
        final snapshot = await _db!
            .collection('notifications')
            .orderBy('scheduledAt', descending: true)
            .get();

        if (snapshot.docs.isNotEmpty) {
          _cachedNotifications = snapshot.docs
              .map((doc) => AppNotification.fromMap(doc.data(), doc.id))
              .toList();
          await _saveToDisk();
          return List.from(_cachedNotifications!);
        }
      }
    } catch (e) {
      if (kDebugMode) print('NotificationService Firestore fallback: $e');
    }

    final diskList = await LocalStorageService.loadJsonList(_storageKey);
    if (diskList != null && diskList.isNotEmpty) {
      _cachedNotifications = diskList
          .map((map) => AppNotification.fromMap(map, map['id'] ?? ''))
          .toList();
    } else {
      _cachedNotifications = List.from(_defaultNotifications);
      await _saveToDisk();
    }

    return List.from(_cachedNotifications!);
  }

  Future<void> _saveToDisk() async {
    if (_cachedNotifications != null) {
      final jsonList = _cachedNotifications!.map((n) {
        final map = n.toMap();
        map['id'] = n.id;
        return map;
      }).toList();
      await LocalStorageService.saveJsonList(_storageKey, jsonList);
    }
  }

  Future<AppNotification> createNotification({
    required String title,
    required String body,
    required NotificationTarget target,
  }) async {
    final newNotification = AppNotification(
      id: 'n_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      target: target,
      scheduledAt: DateTime.now(),
      status: NotificationStatus.sent,
    );

    try {
      if (_db != null) {
        await _db!
            .collection('notifications')
            .doc(newNotification.id)
            .set(newNotification.toMap());
      }
    } catch (e) {
      if (kDebugMode) print('Sauvegarde Firestore notification local fallback: $e');
    }

    if (_cachedNotifications == null) {
      await fetchNotifications();
    }
    _cachedNotifications!.insert(0, newNotification);
    await _saveToDisk();

    return newNotification;
  }

  Future<void> sendExpiringSubscriptionsAlerts(int expiringCount) async {
    final alertNotif = AppNotification(
      id: 'n_exp_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Relance Abonnements Expirants (5-7 jours)',
      body: 'Rappel automatique Push envoyé aux $expiringCount membres dont l\'abonnement expire incessamment.',
      target: NotificationTarget.members,
      scheduledAt: DateTime.now(),
      status: NotificationStatus.sent,
    );

    try {
      if (_db != null) {
        await _db!
            .collection('notifications')
            .doc(alertNotif.id)
            .set(alertNotif.toMap());
      }
    } catch (_) {}

    if (_cachedNotifications == null) {
      await fetchNotifications();
    }
    _cachedNotifications!.insert(0, alertNotif);
    await _saveToDisk();
  }
}

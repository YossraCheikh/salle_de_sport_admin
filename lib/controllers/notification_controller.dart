import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/app_notification.dart';
import '../services/notification_service.dart';

class NotificationController extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  StreamSubscription<List<AppNotification>>? _notificationSubscription;

  List<AppNotification> _notifications = [];
  bool _isLoading = false;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;

  NotificationController() {
    _initStream();
  }

  void _initStream() {
    _isLoading = true;
    notifyListeners();

    _notificationSubscription?.cancel();
    _notificationSubscription =
        _notificationService.getNotificationsStream().listen(
      (list) async {
        _notifications = list.isNotEmpty ? list : await _notificationService.fetchNotifications();
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) async {
        if (kDebugMode) print('Erreur NotificationController stream: $e');
        _notifications = await _notificationService.fetchNotifications();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> createNotification({
    required String title,
    required String body,
    required NotificationTarget target,
  }) async {
    try {
      await _notificationService.createNotification(
        title: title,
        body: body,
        target: target,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> sendExpiringAlerts(int expiringCount) async {
    await _notificationService.sendExpiringSubscriptionsAlerts(expiringCount);
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }
}

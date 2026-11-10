import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/app_notification.dart';
import '../models/gym_session.dart';
import '../services/notification_service.dart';
import '../services/session_service.dart';

class SessionController extends ChangeNotifier {
  final SessionService _sessionService = SessionService();
  StreamSubscription<List<GymSession>>? _sessionsSubscription;

  DateTime _selectedDate = DateTime.now();
  List<GymSession> _sessions = [];
  bool _isLoading = false;
  String _selectedActivityFilter = 'Tous';

  DateTime get selectedDate => _selectedDate;
  List<GymSession> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String get selectedActivityFilter => _selectedActivityFilter;

  List<GymSession> get filteredSessions {
    if (_selectedActivityFilter == 'Tous') return _sessions;
    return _sessions
        .where((s) => s.type.toLowerCase() == _selectedActivityFilter.toLowerCase())
        .toList();
  }

  int get totalReserved => _sessions.fold(0, (sum, s) => sum + s.enrolledCount);
  int get totalCapacity => _sessions.fold(0, (sum, s) => sum + s.maxParticipants);

  int get fillRatePercentage {
    if (totalCapacity == 0) return 0;
    return ((totalReserved / totalCapacity) * 100).round();
  }

  SessionController() {
    _initStream();
  }

  void _initStream() {
    _isLoading = true;
    notifyListeners();

    _sessionsSubscription?.cancel();
    _sessionsSubscription = _sessionService.getSessionsStream().listen(
      (allSessions) async {
        final sessionsToUse = allSessions.isNotEmpty ? allSessions : await _sessionService.fetchSessionsForDate(_selectedDate);
        _updateSessionsForSelectedDate(sessionsToUse);
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) async {
        if (kDebugMode) print('SessionController stream error: $e');
        final fallback = await _sessionService.fetchSessionsForDate(_selectedDate);
        _sessions = fallback;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void _updateSessionsForSelectedDate(List<GymSession> allSessions) {
    _sessions = allSessions.where((s) {
      return s.startAt.year == _selectedDate.year &&
          s.startAt.month == _selectedDate.month &&
          s.startAt.day == _selectedDate.day;
    }).toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));
  }

  void setActivityFilter(String activity) {
    _selectedActivityFilter = activity;
    notifyListeners();
  }

  Future<void> setSelectedDate(DateTime date) async {
    _selectedDate = date;
    final allSessions = await _sessionService.fetchSessionsForDate(date);
    _sessions = allSessions;
    notifyListeners();
  }

  GymSession? checkScheduleConflict({
    required DateTime startAt,
    required int durationMin,
    String? excludeSessionId,
  }) {
    return _sessionService.checkScheduleConflict(
      sessions: _sessions,
      startAt: startAt,
      durationMin: durationMin,
      excludeSessionId: excludeSessionId,
    );
  }

  Future<List<Map<String, dynamic>>> fetchEnrolledMembers(String sessionId) {
    return _sessionService.fetchEnrolledMembers(sessionId);
  }

  Stream<List<Map<String, dynamic>>> getEnrolledMembersStream(String sessionId) {
    return _sessionService.getEnrolledMembersStream(sessionId);
  }

  Future<bool> addSession({
    required String title,
    required String type,
    required String coachName,
    required DateTime startAt,
    required int durationMin,
    required int maxParticipants,
    double? singleSeancePriceTnd,
    bool isPrivateCoaching = false,
    double? coachingFeeTnd,
  }) async {
    try {
      final newSession = await _sessionService.addSession(
        title: title,
        type: type,
        coachId: 'coach_default',
        coachName: coachName,
        startAt: startAt,
        durationMin: durationMin,
        maxParticipants: maxParticipants,
        singleSeancePriceTnd: singleSeancePriceTnd,
        isPrivateCoaching: isPrivateCoaching,
        coachingFeeTnd: coachingFeeTnd,
      );
      if (!_sessions.any((s) => s.id == newSession.id)) {
        _sessions.add(newSession);
        _sessions.sort((a, b) => a.startAt.compareTo(b.startAt));
        notifyListeners();
      }

      final timeStr = '${startAt.hour.toString().padLeft(2, '0')}:${startAt.minute.toString().padLeft(2, '0')}';
      await NotificationService().createNotification(
        title: '📅 Nouvelle séance au planning',
        body: 'Le cours "$title" ($type) a été planifié par Coach $coachName à $timeStr.',
        target: NotificationTarget.all,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateSession(GymSession updated) async {
    await _sessionService.updateSession(updated);
    final index = _sessions.indexWhere((s) => s.id == updated.id);
    if (index != -1) {
      _sessions[index] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteSession(String sessionId) async {
    await _sessionService.deleteSession(sessionId);
    _sessions.removeWhere((s) => s.id == sessionId);
    notifyListeners();
  }

  @override
  void dispose() {
    _sessionsSubscription?.cancel();
    super.dispose();
  }
}

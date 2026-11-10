import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/coach_service.dart';
import '../services/member_service.dart';
import '../services/reservation_service.dart';
import '../services/session_service.dart';
import '../services/stats_service.dart';

class DashboardController extends ChangeNotifier {
  final StatsService _statsService = StatsService();
  final MemberService _memberService = MemberService();
  final CoachService _coachService = CoachService();
  final SessionService _sessionService = SessionService();
  final ReservationService _reservationService = ReservationService();

  StreamSubscription? _membersSub;
  StreamSubscription? _coachesSub;
  StreamSubscription? _sessionsSub;
  StreamSubscription? _reservationsSub;

  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;

  DashboardController() {
    _initLiveStats();
  }

  void _initLiveStats() {
    loadStats();

    // Ecouter les modifications en direct dans la base de données
    _membersSub = _memberService.getMembersStream().listen((_) => loadStats());
    _coachesSub = _coachService.getCoachesStream().listen((_) => loadStats());
    _sessionsSub = _sessionService.getSessionsStream().listen((_) => loadStats());
    _reservationsSub = _reservationService.getReservationsStream().listen((_) => loadStats());
  }

  Future<void> loadStats() async {
    try {
      final newStats = await _statsService.fetchDashboardStats();
      _stats = newStats;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Erreur DashboardController: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _membersSub?.cancel();
    _coachesSub?.cancel();
    _sessionsSub?.cancel();
    _reservationsSub?.cancel();
    super.dispose();
  }
}

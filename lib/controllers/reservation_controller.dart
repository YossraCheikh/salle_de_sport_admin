import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/reservation.dart';
import '../services/reservation_service.dart';

class ReservationController extends ChangeNotifier {
  final ReservationService _reservationService = ReservationService();
  StreamSubscription<List<Reservation>>? _reservationSubscription;

  List<Reservation> _reservations = [];
  bool _isLoading = false;
  String _query = '';

  List<Reservation> get reservations => _reservations;
  bool get isLoading => _isLoading;

  List<Reservation> get filteredReservations {
    if (_query.isEmpty) return _reservations;
    return _reservations.where((r) {
      return r.memberName.toLowerCase().contains(_query.toLowerCase()) ||
          r.sessionTitle.toLowerCase().contains(_query.toLowerCase());
    }).toList();
  }

  ReservationController() {
    _initStream();
  }

  void _initStream() {
    _isLoading = true;
    notifyListeners();

    _reservationSubscription?.cancel();
    _reservationSubscription =
        _reservationService.getReservationsStream().listen(
      (list) async {
        _reservations = list.isNotEmpty ? list : await _reservationService.fetchReservations();
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) async {
        if (kDebugMode) print('Erreur ReservationController stream: $e');
        _reservations = await _reservationService.fetchReservations();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void setSearchQuery(String query) {
    _query = query;
    notifyListeners();
  }

  Future<void> cancelReservation(String id) async {
    await _reservationService.cancelReservation(id);
  }

  @override
  void dispose() {
    _reservationSubscription?.cancel();
    super.dispose();
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/coach.dart';
import '../models/subscription_plan.dart';
import '../services/coach_service.dart';
import '../services/subscription_plan_service.dart';

class ManagementController extends ChangeNotifier {
  final CoachService _coachService = CoachService();
  final SubscriptionPlanService _planService = SubscriptionPlanService();

  StreamSubscription<List<Coach>>? _coachesSubscription;
  StreamSubscription<List<SubscriptionPlan>>? _plansSubscription;

  List<Coach> _coaches = [];
  List<SubscriptionPlan> _plans = [];
  bool _isLoading = false;

  List<Coach> get coaches => _coaches;
  List<SubscriptionPlan> get plans => _plans;
  bool get isLoading => _isLoading;

  ManagementController() {
    _initStreams();
  }

  void _initStreams() {
    _isLoading = true;
    notifyListeners();

    _coachesSubscription?.cancel();
    _coachesSubscription = _coachService.getCoachesStream().listen(
      (list) async {
        _coaches = list.isNotEmpty ? list : await _coachService.fetchCoaches();
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) async {
        if (kDebugMode) print('Erreur ManagementController coaches stream: $e');
        _coaches = await _coachService.fetchCoaches();
        _isLoading = false;
        notifyListeners();
      },
    );

    _plansSubscription?.cancel();
    _plansSubscription = _planService.getPlansStream().listen(
      (list) async {
        _plans = list.isNotEmpty ? list : await _planService.fetchPlans();
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) async {
        if (kDebugMode) print('Erreur ManagementController plans stream: $e');
        _plans = await _planService.fetchPlans();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> addCoach({
    required String name,
    required String email,
    required String phone,
    required String bio,
    required List<String> specialties,
    CoachType type = CoachType.gym,
  }) async {
    try {
      final coach = await _coachService.addCoach(
        name: name,
        email: email,
        phone: phone,
        bio: bio,
        specialties: specialties,
        type: type,
      );
      if (!_coaches.any((c) => c.id == coach.id)) {
        _coaches.insert(0, coach);
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateCoach(Coach updated) async {
    await _coachService.updateCoach(updated);
    final index = _coaches.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      _coaches[index] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteCoach(String coachId) async {
    await _coachService.deleteCoach(coachId);
    _coaches.removeWhere((c) => c.id == coachId);
    notifyListeners();
  }

  Future<bool> addPlan({
    required String name,
    required double priceTnd,
    required int durationMonths,
    required List<String> benefits,
    PlanCategory category = PlanCategory.allInclusive,
    String? targetActivity,
    bool hasCoachOption = true,
    double? coachFeeTnd = 20.0,
  }) async {
    try {
      final plan = await _planService.addPlan(
        name: name,
        priceTnd: priceTnd,
        durationMonths: durationMonths,
        benefits: benefits,
        category: category,
        targetActivity: targetActivity,
        hasCoachOption: hasCoachOption,
        coachFeeTnd: coachFeeTnd,
      );
      if (!_plans.any((p) => p.id == plan.id)) {
        _plans.insert(0, plan);
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updatePlan(SubscriptionPlan updated) async {
    await _planService.updatePlan(updated);
    final index = _plans.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      _plans[index] = updated;
      notifyListeners();
    }
  }

  Future<void> deletePlan(String planId) async {
    await _planService.deletePlan(planId);
    _plans.removeWhere((p) => p.id == planId);
    notifyListeners();
  }

  @override
  void dispose() {
    _coachesSubscription?.cancel();
    _plansSubscription?.cancel();
    super.dispose();
  }
}

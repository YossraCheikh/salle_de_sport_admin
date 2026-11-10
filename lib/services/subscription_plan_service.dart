import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/subscription_plan.dart';
import 'local_storage_service.dart';

class SubscriptionPlanService {
  static const String _storageKey = 'pulse_admin_subscription_plans';
  static List<SubscriptionPlan>? _cachedPlans;

  FirebaseFirestore? get _db =>
      Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null;

  final List<SubscriptionPlan> _defaultPlans = [
    // Pass Global Tout Accès
    SubscriptionPlan(
      id: 'p1',
      name: 'Pass Tout Accès - Mensuel',
      priceTnd: 80,
      durationMonths: 1,
      benefits: ['Accès illimité à tous les cours collectifs', 'Accès plateau musculation & cardio', 'Option Coach de Salle (+20 TND/mois)'],
      category: PlanCategory.allInclusive,
      hasCoachOption: true,
      coachFeeTnd: 20,
    ),
    SubscriptionPlan(
      id: 'p2',
      name: 'Pass Tout Accès - Trimestriel',
      priceTnd: 220,
      durationMonths: 3,
      benefits: ['Économisez 20 TND sur 3 mois', 'Accès prioritaire aux réservations', '1 séance bilan coach offerte', 'Option Coach de Salle (+20 TND/mois)'],
      category: PlanCategory.allInclusive,
      hasCoachOption: true,
      coachFeeTnd: 20,
    ),
    SubscriptionPlan(
      id: 'p3',
      name: 'Pass Tout Accès - Premium Annuel',
      priceTnd: 750,
      durationMonths: 12,
      benefits: ['Meilleure offre (-210 TND)', 'Serviette & boissons incluses', 'Suivi Coach de Salle inclus', 'Invité gratuit 1x/mois'],
      category: PlanCategory.allInclusive,
      hasCoachOption: true,
      coachFeeTnd: 0,
    ),

    // Abonnements Mensuels Spécifiques par Sport (Toutes les activités)
    SubscriptionPlan(
      id: 'p_muscu_m',
      name: 'Abonnement Mensuel - Musculation & Force',
      priceTnd: 75,
      durationMonths: 1,
      benefits: ['Accès illimité plateau musculation & haltérophilie', 'Programme d\'entraînement personnalisé', 'Option Coach de Salle dédié (+20 TND/mois)'],
      category: PlanCategory.activitySpecific,
      targetActivity: 'Musculation',
      hasCoachOption: true,
      coachFeeTnd: 20,
    ),
    SubscriptionPlan(
      id: 'p_cardio_m',
      name: 'Abonnement Mensuel - Cardio Training',
      priceTnd: 70,
      durationMonths: 1,
      benefits: ['Accès illimité à l\'espace cardio & tapis de course', 'Analyse du rythme cardiaque', 'Option Coach de Salle (+15 TND/mois)'],
      category: PlanCategory.activitySpecific,
      targetActivity: 'Cardio',
      hasCoachOption: true,
      coachFeeTnd: 15,
    ),
    SubscriptionPlan(
      id: 'p_pilates_m',
      name: 'Abonnement Mensuel - Pilates Reformer',
      priceTnd: 90,
      durationMonths: 1,
      benefits: ['Accès illimité aux cours Pilates Reformer & Matwork', 'Tapis & serviette fournis', 'Option Coach de Salle dédié (+25 TND/mois)'],
      category: PlanCategory.activitySpecific,
      targetActivity: 'Pilates',
      hasCoachOption: true,
      coachFeeTnd: 25,
    ),
    SubscriptionPlan(
      id: 'p_yoga_m',
      name: 'Abonnement Mensuel - Yoga Vinyasa',
      priceTnd: 85,
      durationMonths: 1,
      benefits: ['Accès illimité aux séances de Yoga Vinyasa & Yin Yoga', 'Salles de méditation zen', 'Option Coach de Salle (+20 TND/mois)'],
      category: PlanCategory.activitySpecific,
      targetActivity: 'Yoga',
      hasCoachOption: true,
      coachFeeTnd: 20,
    ),
    SubscriptionPlan(
      id: 'p_crossfit_m',
      name: 'Abonnement Mensuel - CrossFit & WOD',
      priceTnd: 100,
      durationMonths: 1,
      benefits: ['Accès illimité Box CrossFit & WODs quotidiens', 'Suivi de performance athlétique', 'Option Master Coach (+30 TND/mois)'],
      category: PlanCategory.activitySpecific,
      targetActivity: 'CrossFit',
      hasCoachOption: true,
      coachFeeTnd: 30,
    ),
    SubscriptionPlan(
      id: 'p_spinning_m',
      name: 'Abonnement Mensuel - Spinning RPM',
      priceTnd: 80,
      durationMonths: 1,
      benefits: ['Accès illimité aux cours de Spinning haute intensité', 'Chaussures & vélos professionnels', 'Option Coach de Salle (+15 TND/mois)'],
      category: PlanCategory.activitySpecific,
      targetActivity: 'Spinning',
      hasCoachOption: true,
      coachFeeTnd: 15,
    ),
    SubscriptionPlan(
      id: 'p_zumba_m',
      name: 'Abonnement Mensuel - Zumba Fitness',
      priceTnd: 70,
      durationMonths: 1,
      benefits: ['Accès illimité aux cours de Zumba Dance', 'Ambiance festive et entraînante', 'Option Coach de Salle (+15 TND/mois)'],
      category: PlanCategory.activitySpecific,
      targetActivity: 'Zumba',
      hasCoachOption: true,
      coachFeeTnd: 15,
    ),
    SubscriptionPlan(
      id: 'p_boxe_m',
      name: 'Abonnement Mensuel - Boxe Anglaise',
      priceTnd: 95,
      durationMonths: 1,
      benefits: ['Accès illimité au Ring de Boxe & sac de frappe', 'Coaching technique de combat', 'Option Coach Privé (+25 TND/mois)'],
      category: PlanCategory.activitySpecific,
      targetActivity: 'Boxe',
      hasCoachOption: true,
      coachFeeTnd: 25,
    ),

    // Passes Séances Uniques par Sport (Toutes les activités)
    SubscriptionPlan(
      id: 'p_muscu_s',
      name: 'Pass Séance Unique - Musculation',
      priceTnd: 12,
      durationMonths: 1,
      benefits: ['Valable pour 1 séance sur plateau musculation', 'Option Coach de Salle (+10 TND/séance)'],
      category: PlanCategory.singleSeance,
      targetActivity: 'Musculation',
      hasCoachOption: true,
      coachFeeTnd: 10,
    ),
    SubscriptionPlan(
      id: 'p_cardio_s',
      name: 'Pass Séance Unique - Cardio Training',
      priceTnd: 10,
      durationMonths: 1,
      benefits: ['Valable pour 1 accès à l\'espace cardio', 'Option Coach (+5 TND/séance)'],
      category: PlanCategory.singleSeance,
      targetActivity: 'Cardio',
      hasCoachOption: true,
      coachFeeTnd: 5,
    ),
    SubscriptionPlan(
      id: 'p_pilates_s',
      name: 'Pass Séance Unique - Pilates Reformer',
      priceTnd: 18,
      durationMonths: 1,
      benefits: ['Valable pour 1 séance de Pilates Reformer', 'Option Coach de Salle (+10 TND/séance)'],
      category: PlanCategory.singleSeance,
      targetActivity: 'Pilates',
      hasCoachOption: true,
      coachFeeTnd: 10,
    ),
    SubscriptionPlan(
      id: 'p_yoga_s',
      name: 'Pass Séance Unique - Yoga',
      priceTnd: 15,
      durationMonths: 1,
      benefits: ['Valable pour 1 séance de Yoga Vinyasa', 'Option Coach (+10 TND/séance)'],
      category: PlanCategory.singleSeance,
      targetActivity: 'Yoga',
      hasCoachOption: true,
      coachFeeTnd: 10,
    ),
    SubscriptionPlan(
      id: 'p_crossfit_s',
      name: 'Pass Séance Unique - CrossFit WOD',
      priceTnd: 20,
      durationMonths: 1,
      benefits: ['Valable pour 1 WOD CrossFit guidé par un coach', 'Option Coach Privé (+15 TND/séance)'],
      category: PlanCategory.singleSeance,
      targetActivity: 'CrossFit',
      hasCoachOption: true,
      coachFeeTnd: 15,
    ),
    SubscriptionPlan(
      id: 'p_spinning_s',
      name: 'Pass Séance Unique - Spinning RPM',
      priceTnd: 15,
      durationMonths: 1,
      benefits: ['Valable pour 1 cours de Spinning RPM', 'Option Coach (+5 TND/séance)'],
      category: PlanCategory.singleSeance,
      targetActivity: 'Spinning',
      hasCoachOption: true,
      coachFeeTnd: 5,
    ),
    SubscriptionPlan(
      id: 'p_zumba_s',
      name: 'Pass Séance Unique - Zumba',
      priceTnd: 12,
      durationMonths: 1,
      benefits: ['Valable pour 1 cours de Zumba Fitness', 'Option Coach (+5 TND/séance)'],
      category: PlanCategory.singleSeance,
      targetActivity: 'Zumba',
      hasCoachOption: true,
      coachFeeTnd: 5,
    ),
    SubscriptionPlan(
      id: 'p_boxe_s',
      name: 'Pass Séance Unique - Boxe',
      priceTnd: 20,
      durationMonths: 1,
      benefits: ['Valable pour 1 entraînement de Boxe avec Ring', 'Option Coach Privé (+15 TND/séance)'],
      category: PlanCategory.singleSeance,
      targetActivity: 'Boxe',
      hasCoachOption: true,
      coachFeeTnd: 15,
    ),
  ];

  List<SubscriptionPlan> get defaultPlans => List.from(_defaultPlans);

  static void resetCache() {
    _cachedPlans = null;
  }

  Stream<List<SubscriptionPlan>> getPlansStream() {
    if (_db == null) {
      return Stream.fromFuture(fetchPlans());
    }

    return _db!.collection('subscription_plans').snapshots().asyncMap((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        final list = snapshot.docs
            .map((doc) => SubscriptionPlan.fromMap(doc.data(), doc.id))
            .toList();
        _cachedPlans = _ensureAllActivitiesIncluded(list);
        await _saveToDisk();
        return List.from(_cachedPlans!);
      } else {
        for (final p in _defaultPlans) {
          try {
            await _db!.collection('subscription_plans').doc(p.id).set(p.toMap());
          } catch (_) {}
        }
        _cachedPlans = List.from(_defaultPlans);
        await _saveToDisk();
        return List.from(_defaultPlans);
      }
    });
  }

  List<SubscriptionPlan> _ensureAllActivitiesIncluded(List<SubscriptionPlan> existingList) {
    final result = List<SubscriptionPlan>.from(existingList);
    for (final def in _defaultPlans) {
      if (!result.any((p) => p.id == def.id || p.name.toLowerCase() == def.name.toLowerCase())) {
        result.add(def);
      }
    }
    return result;
  }

  Future<List<SubscriptionPlan>> fetchPlans() async {
    if (_cachedPlans != null && _cachedPlans!.isNotEmpty) {
      return List.from(_cachedPlans!);
    }

    try {
      if (_db != null) {
        final snapshot = await _db!.collection('subscription_plans').get();
        if (snapshot.docs.isNotEmpty) {
          final list = snapshot.docs
              .map((doc) => SubscriptionPlan.fromMap(doc.data(), doc.id))
              .toList();
          _cachedPlans = _ensureAllActivitiesIncluded(list);
          await _saveToDisk();
          return List.from(_cachedPlans!);
        }
      }
    } catch (e) {
      if (kDebugMode) print('SubscriptionPlanService Firestore fallback: $e');
    }

    final diskList = await LocalStorageService.loadJsonList(_storageKey);
    if (diskList != null && diskList.isNotEmpty) {
      final loaded = diskList
          .map((map) => SubscriptionPlan.fromMap(map, map['id'] ?? ''))
          .toList();
      _cachedPlans = _ensureAllActivitiesIncluded(loaded);
    } else {
      _cachedPlans = List.from(_defaultPlans);
      await _saveToDisk();
    }

    return List.from(_cachedPlans!);
  }

  Future<void> _saveToDisk() async {
    if (_cachedPlans != null) {
      final jsonList = _cachedPlans!.map((p) {
        final map = p.toMap();
        map['id'] = p.id;
        return map;
      }).toList();
      await LocalStorageService.saveJsonList(_storageKey, jsonList);
    }
  }

  Future<SubscriptionPlan> addPlan({
    required String name,
    required double priceTnd,
    required int durationMonths,
    required List<String> benefits,
    PlanCategory category = PlanCategory.allInclusive,
    String? targetActivity,
    bool hasCoachOption = true,
    double? coachFeeTnd = 20.0,
  }) async {
    final plan = SubscriptionPlan(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      priceTnd: priceTnd,
      durationMonths: durationMonths,
      benefits: benefits,
      category: category,
      targetActivity: targetActivity,
      hasCoachOption: hasCoachOption,
      coachFeeTnd: coachFeeTnd,
    );

    try {
      if (_db != null) {
        await _db!
            .collection('subscription_plans')
            .doc(plan.id)
            .set(plan.toMap());
      }
    } catch (e) {
      if (kDebugMode) print('SubscriptionPlanService Firestore save fallback: $e');
    }

    if (_cachedPlans == null) {
      await fetchPlans();
    }
    _cachedPlans!.add(plan);
    await _saveToDisk();

    return plan;
  }

  Future<void> updatePlan(SubscriptionPlan updated) async {
    try {
      if (_db != null) {
        await _db!
            .collection('subscription_plans')
            .doc(updated.id)
            .update(updated.toMap());
      }
    } catch (_) {}

    if (_cachedPlans == null) {
      await fetchPlans();
    }
    final index = _cachedPlans!.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      _cachedPlans![index] = updated;
      await _saveToDisk();
    }
  }

  Future<void> deletePlan(String planId) async {
    try {
      if (_db != null) {
        await _db!.collection('subscription_plans').doc(planId).delete();
      }
    } catch (_) {}

    if (_cachedPlans == null) {
      await fetchPlans();
    }
    _cachedPlans!.removeWhere((p) => p.id == planId);
    await _saveToDisk();
  }
}

enum PlanCategory { allInclusive, activitySpecific, singleSeance }

class SubscriptionPlan {
  final String id;
  final String name;
  final double priceTnd;
  final int durationMonths;
  final List<String> benefits;
  final bool isActive;
  final PlanCategory category;
  final String? targetActivity; // e.g. "Musculation", "Pilates", "Cardio", etc.
  final bool hasCoachOption;
  final double? coachFeeTnd;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.priceTnd,
    required this.durationMonths,
    required this.benefits,
    this.isActive = true,
    this.category = PlanCategory.allInclusive,
    this.targetActivity,
    this.hasCoachOption = true,
    this.coachFeeTnd = 20.0,
  });

  String get formattedPrice => '${priceTnd.toStringAsFixed(0)} TND';

  double get totalPriceWithCoach => priceTnd + (hasCoachOption ? (coachFeeTnd ?? 20.0) : 0.0);

  String get categoryLabel {
    switch (category) {
      case PlanCategory.activitySpecific:
        return targetActivity != null && targetActivity!.isNotEmpty
            ? 'Mensuel ($targetActivity)'
            : 'Activité Spécifique';
      case PlanCategory.singleSeance:
        return 'Ticket Séance Unique';
      case PlanCategory.allInclusive:
      default:
        return 'Pass Tout Accès';
    }
  }

  factory SubscriptionPlan.fromMap(Map<String, dynamic> map, String docId) {
    return SubscriptionPlan(
      id: docId,
      name: map['name'] ?? '',
      priceTnd: (map['priceTnd'] ?? 0).toDouble(),
      durationMonths: map['durationMonths'] ?? 1,
      benefits: List<String>.from(map['benefits'] ?? []),
      isActive: map['isActive'] ?? true,
      category: _parseCategory(map['category']),
      targetActivity: map['targetActivity'],
      hasCoachOption: map['hasCoachOption'] ?? true,
      coachFeeTnd: map['coachFeeTnd'] != null
          ? (map['coachFeeTnd'] as num).toDouble()
          : 20.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'priceTnd': priceTnd,
      'durationMonths': durationMonths,
      'benefits': benefits,
      'isActive': isActive,
      'category': category.name,
      'targetActivity': targetActivity,
      'hasCoachOption': hasCoachOption,
      'coachFeeTnd': coachFeeTnd,
    };
  }

  static PlanCategory _parseCategory(String? catStr) {
    switch (catStr) {
      case 'activitySpecific':
        return PlanCategory.activitySpecific;
      case 'singleSeance':
        return PlanCategory.singleSeance;
      case 'allInclusive':
      default:
        return PlanCategory.allInclusive;
    }
  }
}

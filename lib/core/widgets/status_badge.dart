import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum BadgeStatus {
  active,
  expiring,
  inactive,
  toVerify,
  custom,
}

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeStatus status;
  final Color? customColor;

  const StatusBadge({
    super.key,
    required this.label,
    this.status = BadgeStatus.active,
    this.customColor,
  });

  factory StatusBadge.fromStatusString(String statusStr) {
    final lower = statusStr.toLowerCase();
    if (lower.contains('actif') || lower == 'active') {
      return const StatusBadge(label: 'Actif', status: BadgeStatus.active);
    } else if (lower.contains('expire') || lower == 'expiring') {
      return const StatusBadge(label: 'Expire bientôt', status: BadgeStatus.expiring);
    } else if (lower.contains('vérifier') || lower == 'toverify') {
      return const StatusBadge(label: 'À vérifier', status: BadgeStatus.toVerify);
    } else {
      return const StatusBadge(label: 'Inactif', status: BadgeStatus.inactive);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    switch (status) {
      case BadgeStatus.active:
        badgeColor = AppColors.lime;
        break;
      case BadgeStatus.expiring:
        badgeColor = AppColors.warning;
        break;
      case BadgeStatus.toVerify:
        badgeColor = AppColors.purple;
        break;
      case BadgeStatus.inactive:
        badgeColor = AppColors.textMuted;
        break;
      case BadgeStatus.custom:
        badgeColor = customColor ?? AppColors.lime;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: badgeColor.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}

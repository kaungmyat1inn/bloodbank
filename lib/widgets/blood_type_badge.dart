import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A small red pill showing a blood type, e.g. "O+".
class BloodTypeBadge extends StatelessWidget {
  const BloodTypeBadge({super.key, required this.bloodType, this.large = false});

  final String bloodType;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 10,
        vertical: large ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.primaryRed.withValues(alpha: 0.3)),
      ),
      child: Text(
        bloodType.isEmpty ? '?' : bloodType,
        style: TextStyle(
          color: AppTheme.primaryRed,
          fontWeight: FontWeight.bold,
          fontSize: large ? 20 : 13,
        ),
      ),
    );
  }
}

/// Shows whether a donor is currently eligible to donate again, or how many
/// days remain until they are.
class EligibilityBadge extends StatelessWidget {
  const EligibilityBadge({super.key, required this.eligible, required this.daysUntilEligible});

  final bool eligible;
  final int daysUntilEligible;

  @override
  Widget build(BuildContext context) {
    final color = eligible ? AppTheme.eligibleGreen : AppTheme.waitingOrange;
    final label = eligible
        ? 'သွေးလှူနိုင်ပါပြီ'
        : 'နောက် $daysUntilEligible ရက်စောင့်ပါ';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

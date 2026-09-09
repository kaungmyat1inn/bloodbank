import 'package:flutter/material.dart';

import '../models/donor.dart';
import 'blood_type_badge.dart';

/// One row representing a donor, used across the list / search / eligible
/// screens. Tapping it calls [onTap] (usually opens the donor's profile).
class DonorTile extends StatelessWidget {
  const DonorTile({super.key, required this.donor, this.onTap, this.trailing});

  final Donor donor;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: BloodTypeBadge(bloodType: donor.bloodType),
        title: Text(
          donor.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'အဖွဲ့ဝင်အမှတ် ${donor.memberId}  •  ${donor.phone}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right),
      ),
    );
  }
}

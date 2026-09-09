import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/donor.dart';
import '../services/donor_service.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final donorService = context.read<DonorService>();

    return StreamBuilder<List<Donor>>(
      stream: donorService.watchDonors(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('အမှားဖြစ်ပွားပါသည်: ${snapshot.error}'));
        }
        final donors = snapshot.data ?? [];
        final eligible = donors.where((d) => d.isEligible).length;
        final totalDonations =
            donors.fold<int>(0, (sum, d) => sum + d.donationHistory.length);

        final byType = <String, int>{};
        for (final type in kBloodTypes) {
          byType[type] = donors.where((d) => d.bloodType == type).length;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: MaxWidthBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _StatCard(
                      label: 'စုစုပေါင်း အလှူရှင်',
                      value: '${donors.length}',
                      icon: Icons.people_alt_outlined,
                      color: AppTheme.primaryRed,
                    ),
                    _StatCard(
                      label: 'ယခုသွေးလှူနိုင်သူ',
                      value: '$eligible',
                      icon: Icons.event_available_outlined,
                      color: AppTheme.eligibleGreen,
                    ),
                    _StatCard(
                      label: 'သွေးလှူမှတ်တမ်း (စုစုပေါင်း)',
                      value: '$totalDonations',
                      icon: Icons.history,
                      color: AppTheme.waitingOrange,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'သွေးအမျိုးအစားအလိုက် စာရင်း',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final type in kBloodTypes)
                          _BloodTypeCount(type: type, count: byType[type] ?? 0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      label,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BloodTypeCount extends StatelessWidget {
  const _BloodTypeCount({required this.type, required this.count});

  final String type;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            type,
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryRed),
          ),
          const SizedBox(height: 4),
          Text('$count ဦး', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
        ],
      ),
    );
  }
}

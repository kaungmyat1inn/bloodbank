import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/donor.dart';
import '../services/donor_service.dart';
import '../theme/app_theme.dart';
import '../utils/launch.dart';
import '../widgets/blood_type_badge.dart';
import '../widgets/responsive.dart';
import 'donor_edit_screen.dart';

class DonorProfileScreen extends StatelessWidget {
  const DonorProfileScreen({super.key, required this.donorId});

  final String donorId;

  Future<void> _confirmDeleteDonor(BuildContext context, Donor donor) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('အလှူရှင်ကို ဖျက်မည်'),
        content: Text(
          '${donor.name} (အဖွဲ့ဝင်အမှတ် ${donor.memberId}) နှင့် '
          'သွေးလှူမှတ်တမ်းအားလုံးကို အပြီးအပိုင် ဖျက်မှာ သေချာပါသလား။',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('မဖျက်တော့ပါ'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryRed),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('ဖျက်မည်'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await context.read<DonorService>().deleteDonor(donor.id);
      if (!context.mounted) return;
      Navigator.of(context).pop(); // leave the (now gone) profile
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${donor.name} ကို ဖျက်ပြီးပါပြီ')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ဖျက်၍မရပါ: $e')),
      );
    }
  }

  Future<void> _confirmDeleteDonation(
      BuildContext context, Donor donor, DateTime date) async {
    final dateFmt = DateFormat('dd-MM-yyyy');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('မှတ်တမ်းတစ်ခု ဖျက်မည်'),
        content: Text('${dateFmt.format(date)} ရက်စွဲ မှတ်တမ်းကို ဖျက်မှာ သေချာပါသလား။'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('မဖျက်တော့ပါ'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primaryRed),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('ဖျက်မည်'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await context.read<DonorService>().removeDonation(donor, date);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ဖျက်၍မရပါ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final donorService = context.read<DonorService>();
    final dateFmt = DateFormat('dd-MM-yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('သွေးလှူရှင် ပရိုဖိုင်')),
      body: StreamBuilder<Donor?>(
        stream: donorService.watchDonor(donorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final donor = snapshot.data;
          if (donor == null) {
            return const Center(child: Text('အလှူရှင် ရှာမတွေ့ပါ'));
          }

          final history = donor.donationHistory.reversed.toList(); // newest first

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: MaxWidthBox(
                maxWidth: 700,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                BloodTypeBadge(bloodType: donor.bloodType, large: true),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        donor.name,
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                      Text(
                                        'အဖွဲ့ဝင်အမှတ် ${donor.memberId}',
                                        style: TextStyle(color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                                EligibilityBadge(
                                  eligible: donor.isEligible,
                                  daysUntilEligible: donor.daysUntilEligible,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => DonorEditScreen(donor: donor),
                                    ),
                                  ),
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  label: const Text('ပြင်ဆင်ရန်'),
                                ),
                                const SizedBox(width: 4),
                                TextButton.icon(
                                  onPressed: () => _confirmDeleteDonor(context, donor),
                                  icon: const Icon(Icons.delete_outline, size: 18),
                                  label: const Text('ဖျက်ရန်'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppTheme.primaryRed,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            _InfoRow(icon: Icons.home_outlined, label: 'လိပ်စာ', value: donor.address),
                            _InfoRow(
                              icon: Icons.phone_outlined,
                              label: 'ဖုန်း',
                              value: donor.phone,
                              onTap: () => callPhone(context, donor.phone),
                            ),
                            if (donor.viber.trim().isNotEmpty)
                              _InfoRow(
                                icon: Icons.chat_bubble_outline,
                                label: 'Viber',
                                value: donor.viber,
                                onTap: () => openViber(context, donor.viber),
                              ),
                            _InfoRow(
                              icon: Icons.event_outlined,
                              label: 'နောက်ဆုံးသွေးလှူသည့်ရက်',
                              value: donor.lastDonationDate == null
                                  ? 'မရှိသေးပါ'
                                  : dateFmt.format(donor.lastDonationDate!),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('သွေးလှူမှတ်တမ်း (${history.length})',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    if (history.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('မှတ်တမ်း မရှိသေးပါ'),
                        ),
                      )
                    else
                      Card(
                        child: Column(
                          children: [
                            for (int i = 0; i < history.length; i++)
                              ListTile(
                                leading: const Icon(Icons.bloodtype, color: AppTheme.primaryRed),
                                title: Text(dateFmt.format(history[i])),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('#${history.length - i}',
                                        style: TextStyle(color: Colors.grey.shade600)),
                                    IconButton(
                                      tooltip: 'မှတ်တမ်း ဖျက်ရန်',
                                      icon: const Icon(Icons.close, size: 18),
                                      onPressed: () => _confirmDeleteDonation(
                                          context, donor, history[i]),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value, this.onTap});

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            SizedBox(
              width: 70,
              child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
            ),
            Expanded(
              child: Text(
                value.isEmpty ? '-' : value,
                style: TextStyle(
                  color: onTap != null ? AppTheme.primaryRed : null,
                  fontWeight: onTap != null ? FontWeight.w600 : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

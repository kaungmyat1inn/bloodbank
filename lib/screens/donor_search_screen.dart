import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/donor.dart';
import '../services/donor_service.dart';
import '../theme/app_theme.dart';
import '../utils/launch.dart';
import '../widgets/blood_type_badge.dart';
import '../widgets/responsive.dart';
import 'donor_profile_screen.dart';

/// အလှူရှင်ရှာရန် — pick a blood type; shows donors of that type who are
/// currently eligible (never donated, or 120+ days since last donation).
class DonorSearchScreen extends StatefulWidget {
  const DonorSearchScreen({super.key});

  @override
  State<DonorSearchScreen> createState() => _DonorSearchScreenState();
}

class _DonorSearchScreenState extends State<DonorSearchScreen> {
  String? _bloodType;

  @override
  Widget build(BuildContext context) {
    final donorService = context.read<DonorService>();
    final dateFmt = DateFormat('dd-MM-yyyy');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: MaxWidthBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('လိုအပ်သော သွေးအမျိုးအစား ရွေးပါ',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final type in kBloodTypes)
                      ChoiceChip(
                        label: Text(type),
                        selected: _bloodType == type,
                        selectedColor: AppTheme.primaryRed.withValues(alpha: 0.15),
                        onSelected: (selected) =>
                            setState(() => _bloodType = selected ? type : null),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _bloodType == null
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'သွေးအမျိုးအစားရွေးပြီး ယခုသွေးလှူနိုင်သော အလှူရှင်များကို ကြည့်ရှုပါ',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : StreamBuilder<List<Donor>>(
                  stream: donorService.watchDonors(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final results = (snapshot.data ?? [])
                        .where((d) => d.bloodType == _bloodType && d.isEligible)
                        .toList()
                      ..sort((a, b) {
                        final da = a.lastDonationDate;
                        final db = b.lastDonationDate;
                        if (da == null && db == null) return 0;
                        if (da == null) return -1;
                        if (db == null) return 1;
                        return da.compareTo(db);
                      });

                    if (results.isEmpty) {
                      return Center(
                        child: Text('$_bloodType အမျိုးအစား ယခုသွေးလှူနိုင်သူ မရှိသေးပါ'),
                      );
                    }

                    return Center(
                      child: MaxWidthBox(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: results.length,
                          itemBuilder: (context, i) {
                            final donor = results[i];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: ListTile(
                                leading: BloodTypeBadge(bloodType: donor.bloodType),
                                title: Text(donor.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text(
                                  'အဖွဲ့ဝင်အမှတ် ${donor.memberId} • ${donor.phone}\n'
                                  '${donor.lastDonationDate == null ? 'တစ်ကြိမ်မှ မလှူရသေး' : 'နောက်ဆုံးလှူ - ${dateFmt.format(donor.lastDonationDate!)}'}',
                                ),
                                isThreeLine: true,
                                trailing: IconButton(
                                  icon: const Icon(Icons.call, color: AppTheme.primaryRed),
                                  onPressed: () => callPhone(context, donor.phone),
                                ),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => DonorProfileScreen(donorId: donor.id),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

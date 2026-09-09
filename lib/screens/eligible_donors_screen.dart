import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/donor.dart';
import '../services/donor_service.dart';
import '../widgets/donor_tile.dart';
import '../widgets/responsive.dart';
import 'donor_profile_screen.dart';

/// သွေးလှူနိုင်သောစာရင်း — donors whose last donation was at least
/// [kDonationEligibilityDays] days ago, or who have never donated.
/// Sorted so the longest-waiting donors show first.
class EligibleDonorsScreen extends StatelessWidget {
  const EligibleDonorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final donorService = context.read<DonorService>();
    final dateFmt = DateFormat('dd-MM-yyyy');

    return StreamBuilder<List<Donor>>(
      stream: donorService.watchDonors(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('အမှားဖြစ်ပွားပါသည်: ${snapshot.error}'));
        }
        final eligible = (snapshot.data ?? []).where((d) => d.isEligible).toList()
          ..sort((a, b) {
            // Never-donated donors first (treated as "longest waiting"),
            // then by oldest last-donation date.
            final da = a.lastDonationDate;
            final db = b.lastDonationDate;
            if (da == null && db == null) return a.memberId.compareTo(b.memberId);
            if (da == null) return -1;
            if (db == null) return 1;
            return da.compareTo(db);
          });

        if (eligible.isEmpty) {
          return const Center(child: Text('ယခုသွေးလှူနိုင်သော အလှူရှင်မရှိသေးပါ'));
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: MaxWidthBox(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ယခုသွေးလှူနိုင်သူ ${eligible.length} ဦး (နောက်ဆုံးလှူချိန်မှ $kDonationEligibilityDays ရက်ကျော်သူများ)',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: MaxWidthBox(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16, top: 8),
                    itemCount: eligible.length,
                    itemBuilder: (context, i) {
                      final donor = eligible[i];
                      return DonorTile(
                        donor: donor,
                        trailing: Text(
                          donor.lastDonationDate == null
                              ? 'တစ်ကြိမ်မှ မလှူရသေး'
                              : dateFmt.format(donor.lastDonationDate!),
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DonorProfileScreen(donorId: donor.id),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

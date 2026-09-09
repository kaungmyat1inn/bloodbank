import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/donor.dart';
import '../services/donor_service.dart';
import '../widgets/blood_type_badge.dart';
import '../widgets/responsive.dart';
import 'add_donation_record_screen.dart';
import 'donor_profile_screen.dart';

class _Record {
  _Record(this.donor, this.date);
  final Donor donor;
  final DateTime date;
}

/// သွေးလှူမှတ်တမ်း — a feed of every donation ever recorded, newest first,
/// with a button to add a new record for an already-registered donor.
class DonationHistoryScreen extends StatelessWidget {
  const DonationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final donorService = context.read<DonorService>();
    final dateFmt = DateFormat('dd-MM-yyyy');

    return Scaffold(
      body: StreamBuilder<List<Donor>>(
        stream: donorService.watchDonors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('အမှားဖြစ်ပွားပါသည်: ${snapshot.error}'));
          }
          final donors = snapshot.data ?? [];
          final records = <_Record>[];
          for (final donor in donors) {
            for (final date in donor.donationHistory) {
              records.add(_Record(donor, date));
            }
          }
          records.sort((a, b) => b.date.compareTo(a.date)); // newest first

          if (records.isEmpty) {
            return const Center(child: Text('သွေးလှူမှတ်တမ်း မရှိသေးပါ'));
          }

          return Center(
            child: MaxWidthBox(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 90),
                itemCount: records.length,
                itemBuilder: (context, i) {
                  final r = records[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    child: ListTile(
                      leading: BloodTypeBadge(bloodType: r.donor.bloodType),
                      title: Text(r.donor.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('အဖွဲ့ဝင်အမှတ် ${r.donor.memberId}'),
                      trailing: Text(dateFmt.format(r.date)),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DonorProfileScreen(donorId: r.donor.id),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddDonationRecordScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('မှတ်တမ်းအသစ်ထည့်မည်'),
      ),
    );
  }
}

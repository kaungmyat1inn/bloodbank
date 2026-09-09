import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/donor.dart';
import '../services/donor_service.dart';
import '../widgets/blood_type_badge.dart';
import '../widgets/responsive.dart';

/// Search an already-registered donor by member ID or name, pick the donation
/// date (defaults to today), then confirm "သွေးလှူပြီးပါပြီ" to append it to
/// their donation history.
class AddDonationRecordScreen extends StatefulWidget {
  const AddDonationRecordScreen({super.key});

  @override
  State<AddDonationRecordScreen> createState() => _AddDonationRecordScreenState();
}

class _AddDonationRecordScreenState extends State<AddDonationRecordScreen> {
  final _queryCtrl = TextEditingController();
  String _query = '';
  Donor? _selected;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  void _select(Donor donor) {
    setState(() {
      _selected = donor;
      _date = DateTime.now();
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      helpText: 'သွေးလှူသည့်ရက် ရွေးပါ',
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _confirmDonation(Donor donor) async {
    setState(() => _saving = true);
    try {
      await context.read<DonorService>().recordDonation(donor, date: _date);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${donor.name} အတွက် မှတ်တမ်း ထည့်ပြီးပါပြီ')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('မအောင်မြင်ပါ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final donorService = context.read<DonorService>();
    final dateFmt = DateFormat('dd-MM-yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('မှတ်တမ်းအသစ်ထည့်မည်')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: MaxWidthBox(
              child: TextField(
                controller: _queryCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'အဖွဲ့ဝင်အမှတ် (သို့) အမည်ဖြင့်ရှာပါ',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => setState(() {
                  _query = v.trim().toLowerCase();
                  _selected = null;
                }),
              ),
            ),
          ),
          if (_selected != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MaxWidthBox(
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            BloodTypeBadge(bloodType: _selected!.bloodType, large: true),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_selected!.name,
                                      style: const TextStyle(
                                          fontSize: 17, fontWeight: FontWeight.bold)),
                                  Text('အဖွဲ့ဝင်အမှတ် ${_selected!.memberId}'),
                                  Text(
                                    _selected!.lastDonationDate == null
                                        ? 'တစ်ကြိမ်မှ မလှူရသေးပါ'
                                        : 'နောက်ဆုံးလှူသည့်ရက် - ${dateFmt.format(_selected!.lastDonationDate!)}',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => setState(() => _selected = null),
                              child: const Text('ပြောင်းရန်'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Icon(Icons.event_outlined,
                                    size: 20, color: Colors.grey.shade600),
                                const SizedBox(width: 12),
                                const Text('သွေးလှူသည့်ရက် - '),
                                Text(
                                  dateFmt.format(_date),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.edit_calendar_outlined, size: 16),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (!_selected!.isEligible)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              'သတိပြုရန် - ဤအလှူရှင်သည် $kDonationEligibilityDays ရက် မပြည့်သေးပါ (နောက် ${_selected!.daysUntilEligible} ရက်ခန့် ကျန်ပါသည်)',
                              style: const TextStyle(color: Colors.deepOrange, fontSize: 12.5),
                            ),
                          ),
                        ElevatedButton.icon(
                          onPressed: _saving ? null : () => _confirmDonation(_selected!),
                          icon: _saving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.check_circle_outline),
                          label: const Text('သွေးလှူပြီးပါပြီ'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: StreamBuilder<List<Donor>>(
                stream: donorService.watchDonors(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (_query.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'သွေးလှူသူကို အဖွဲ့ဝင်အမှတ် (သို့) အမည်ဖြင့် ရှာဖွေပါ',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  final donors = (snapshot.data ?? [])
                      .where((d) =>
                          d.name.toLowerCase().contains(_query) ||
                          d.memberId.toLowerCase().contains(_query))
                      .toList();
                  if (donors.isEmpty) {
                    return const Center(child: Text('ရှာမတွေ့ပါ'));
                  }
                  return Center(
                    child: MaxWidthBox(
                      child: ListView.builder(
                        itemCount: donors.length,
                        itemBuilder: (context, i) {
                          final donor = donors[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                              leading: BloodTypeBadge(bloodType: donor.bloodType),
                              title: Text(donor.name),
                              subtitle: Text('အဖွဲ့ဝင်အမှတ် ${donor.memberId}'),
                              onTap: () => _select(donor),
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
      ),
    );
  }
}

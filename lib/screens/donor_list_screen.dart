import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/donor.dart';
import '../services/donor_service.dart';
import '../widgets/donor_tile.dart';
import '../widgets/responsive.dart';
import 'donor_profile_screen.dart';

/// သွေးအလှူရှင်ပရိုဖိုင် — full donor list with a quick text search box
/// (matches member ID or name), tap through to see the full profile and
/// donation history.
class DonorListScreen extends StatefulWidget {
  const DonorListScreen({super.key});

  @override
  State<DonorListScreen> createState() => _DonorListScreenState();
}

class _DonorListScreenState extends State<DonorListScreen> {
  final _queryCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final donorService = context.read<DonorService>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: MaxWidthBox(
            child: TextField(
              controller: _queryCtrl,
              decoration: InputDecoration(
                hintText: 'အဖွဲ့ဝင်အမှတ် (သို့) အမည်ဖြင့်ရှာပါ',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _queryCtrl.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Donor>>(
            stream: donorService.watchDonors(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('အမှားဖြစ်ပွားပါသည်: ${snapshot.error}'));
              }
              var donors = snapshot.data ?? [];
              if (_query.isNotEmpty) {
                donors = donors
                    .where((d) =>
                        d.name.toLowerCase().contains(_query) ||
                        d.memberId.toLowerCase().contains(_query))
                    .toList();
              }
              if (donors.isEmpty) {
                return const Center(child: Text('အလှူရှင် စာရင်းမရှိသေးပါ'));
              }
              return Center(
                child: MaxWidthBox(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: donors.length,
                    itemBuilder: (context, i) {
                      final donor = donors[i];
                      return DonorTile(
                        donor: donor,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DonorProfileScreen(donorId: donor.id),
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

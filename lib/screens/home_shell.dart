import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../widgets/responsive.dart';
import 'dashboard_screen.dart';
import 'donor_register_screen.dart';
import 'donor_list_screen.dart';
import 'eligible_donors_screen.dart';
import 'donation_history_screen.dart';
import 'donor_search_screen.dart';
import 'apk_download_screen.dart';

class _NavItem {
  const _NavItem(this.label, this.icon, this.builder);
  final String label;
  final IconData icon;
  final WidgetBuilder builder;
}

/// The main authenticated app shell: a responsive navigation frame around
/// the six feature screens. Desktop/wide screens get a persistent sidebar
/// (NavigationRail); phones get a Drawer + bottom nav.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  List<_NavItem> get _items => [
        _NavItem('ပင်မစာမျက်နှာ', Icons.home_outlined, (_) => const DashboardScreen()),
        _NavItem('အသစ်စာရင်းသွင်းမည်', Icons.person_add_alt_1_outlined,
            (_) => const DonorRegisterScreen()),
        _NavItem('သွေးလှူရှင်ပရိုဖိုင်', Icons.people_outline, (_) => const DonorListScreen()),
        _NavItem('သွေးလှူနိုင်သောစာရင်း', Icons.event_available_outlined,
            (_) => const EligibleDonorsScreen()),
        _NavItem('သွေးလှူမှတ်တမ်း', Icons.history, (_) => const DonationHistoryScreen()),
        _NavItem('အလှူရှင်ရှာရန်', Icons.search, (_) => const DonorSearchScreen()),
      ];

  @override
  Widget build(BuildContext context) {
    final desktop = isDesktop(context);
    final items = _items;
    final bankName = context.watch<User?>()?.displayName?.trim();
    final title = (bankName == null || bankName.isEmpty)
        ? 'သွေးလှူဒါန်းရေးအသင်း'
        : bankName;
    final body = IndexedStack(
      index: _index,
      children: [for (final item in items) Builder(builder: item.builder)],
    );

    if (desktop) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    const Icon(Icons.bloodtype, color: Color(0xFFC62828), size: 32),
                    const SizedBox(height: 12),
                    IconButton(
                      tooltip: 'ထွက်ရန်',
                      icon: const Icon(Icons.logout),
                      onPressed: () => context.read<AuthService>().signOut(),
                    ),
                  ],
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: IconButton(
                      tooltip: 'Android App Download',
                      icon: const Icon(Icons.android),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ApkDownloadScreen()),
                      ),
                    ),
                  ),
                ),
              ),
              destinations: [
                for (final item in items)
                  NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.icon, color: const Color(0xFFC62828)),
                    label: Text(item.label, textAlign: TextAlign.center),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppBar(
                    title: Text(items[_index].label),
                    automaticallyImplyLeading: false,
                  ),
                  Expanded(child: body),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Mobile layout: AppBar + hamburger Drawer (6 sections is too many for a
    // cramped bottom nav bar) with the first 4 items also reachable from a
    // slim bottom nav for one-tap access to the most common actions.
    const quickAccessCount = 4;
    return Scaffold(
      appBar: AppBar(
        title: Text(items[_index].label),
        actions: [
          IconButton(
            tooltip: 'Android App Download',
            icon: const Icon(Icons.android),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ApkDownloadScreen()),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.bloodtype, color: Color(0xFFC62828), size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  children: [
                    for (int i = 0; i < items.length; i++)
                      ListTile(
                        leading: Icon(items[i].icon,
                            color: i == _index ? const Color(0xFFC62828) : null),
                        title: Text(items[i].label),
                        selected: i == _index,
                        onTap: () {
                          setState(() => _index = i);
                          Navigator.of(context).pop();
                        },
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('ထွက်ရန်'),
                onTap: () => context.read<AuthService>().signOut(),
              ),
            ],
          ),
        ),
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index < quickAccessCount ? _index : 0,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final item in items.take(quickAccessCount))
            NavigationDestination(icon: Icon(item.icon), label: item.label),
        ],
      ),
    );
  }
}

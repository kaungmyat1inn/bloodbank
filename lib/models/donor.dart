import 'package:cloud_firestore/cloud_firestore.dart';

/// A blood donation is eligible again after this many days.
const int kDonationEligibilityDays = 120;

/// The fixed set of blood types the app supports.
const List<String> kBloodTypes = [
  'A+',
  'A-',
  'B+',
  'B-',
  'AB+',
  'AB-',
  'O+',
  'O-',
];

class Donor {
  final String id; // Firestore document id
  final String memberId; // e.g. "001"
  final String name;
  final String bloodType;
  final String address;
  final String phone;
  final String viber;
  final List<DateTime> donationHistory; // sorted ascending
  final DateTime createdAt;

  Donor({
    required this.id,
    required this.memberId,
    required this.name,
    required this.bloodType,
    required this.address,
    required this.phone,
    required this.viber,
    required this.donationHistory,
    required this.createdAt,
  });

  /// The most recent donation date, or null if the donor has never donated.
  DateTime? get lastDonationDate =>
      donationHistory.isEmpty ? null : donationHistory.last;

  /// Days elapsed since the last donation. Null if never donated.
  int? get daysSinceLastDonation {
    final last = lastDonationDate;
    if (last == null) return null;
    return DateTime.now().difference(last).inDays;
  }

  /// True if the donor has never donated, or it has been at least
  /// [kDonationEligibilityDays] days since their last donation.
  bool get isEligible {
    final days = daysSinceLastDonation;
    return days == null || days >= kDonationEligibilityDays;
  }

  /// Days remaining until eligible again (0 if already eligible).
  int get daysUntilEligible {
    final days = daysSinceLastDonation;
    if (days == null) return 0;
    final remaining = kDonationEligibilityDays - days;
    return remaining > 0 ? remaining : 0;
  }

  factory Donor.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final historyRaw = (data['donationHistory'] as List<dynamic>?) ?? [];
    final history = historyRaw
        .map((e) => (e as Timestamp).toDate())
        .toList()
      ..sort();
    final createdAtTs = data['createdAt'];
    return Donor(
      id: doc.id,
      memberId: (data['memberId'] ?? '').toString(),
      name: (data['name'] ?? '').toString(),
      bloodType: (data['bloodType'] ?? '').toString(),
      address: (data['address'] ?? '').toString(),
      phone: (data['phone'] ?? '').toString(),
      viber: (data['viber'] ?? '').toString(),
      donationHistory: history,
      createdAt: createdAtTs is Timestamp ? createdAtTs.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'memberId': memberId,
      'name': name,
      'bloodType': bloodType,
      'address': address,
      'phone': phone,
      'viber': viber,
      'donationHistory':
          donationHistory.map((d) => Timestamp.fromDate(d)).toList(),
      'lastDonationDate': lastDonationDate == null
          ? null
          : Timestamp.fromDate(lastDonationDate!),
      'createdAt': Timestamp.fromDate(createdAt),
      // Kept for simple, index-free lookups & search.
      'nameLower': name.toLowerCase(),
    };
  }
}

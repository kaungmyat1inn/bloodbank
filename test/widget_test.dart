// Unit tests for the donor eligibility rules. These need no Firebase and run
// with `flutter test`.

import 'package:blood_bank_app/models/donor.dart';
import 'package:flutter_test/flutter_test.dart';

Donor donorWith(List<DateTime> history) => Donor(
      id: 'x',
      memberId: '001',
      name: 'Test',
      bloodType: 'O+',
      address: 'addr',
      phone: '0900000000',
      viber: '',
      donationHistory: history,
      createdAt: DateTime(2020),
    );

void main() {
  test('a donor who never donated is eligible', () {
    final d = donorWith([]);
    expect(d.isEligible, isTrue);
    expect(d.daysUntilEligible, 0);
    expect(d.lastDonationDate, isNull);
  });

  test('a donor who donated today is not eligible', () {
    final d = donorWith([DateTime.now()]);
    expect(d.isEligible, isFalse);
    expect(d.daysUntilEligible, greaterThan(0));
    expect(d.daysUntilEligible, lessThanOrEqualTo(kDonationEligibilityDays));
  });

  test('eligibility returns after kDonationEligibilityDays', () {
    final past = DateTime.now()
        .subtract(const Duration(days: kDonationEligibilityDays + 1));
    final d = donorWith([past]);
    expect(d.isEligible, isTrue);
    expect(d.daysUntilEligible, 0);
  });

  test('lastDonationDate is the tail of the (ascending) history', () {
    final d = donorWith([
      DateTime(2022, 3, 3),
      DateTime(2023, 1, 1),
      DateTime(2024, 6, 1),
    ]);
    expect(d.lastDonationDate, DateTime(2024, 6, 1));
  });
}

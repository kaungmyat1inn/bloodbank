import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/donor.dart';

/// Handles all Firestore reads/writes for donors and donation records.
///
/// Data model:
///   donors/{docId}            -> donor fields (see Donor.toFirestore)
///   meta/donorCounter         -> { lastMemberId: <int> }  (used to hand out
///                                 sequential member IDs starting at "001")
class DonorService {
  DonorService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _donors =>
      _db.collection('donors');

  DocumentReference<Map<String, dynamic>> get _counterDoc =>
      _db.collection('meta').doc('donorCounter');

  /// A single shared stream of every donor. The dashboard, list, eligible,
  /// history and search screens are all built at once (IndexedStack in
  /// HomeShell), so without this each would open its own full-collection
  /// Firestore listener. This keeps one listener open for the life of the
  /// service and multicasts it, replaying the latest snapshot to any screen
  /// that subscribes later.
  StreamController<List<Donor>>? _donorsController;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _donorsSub;
  List<Donor>? _lastDonors;

  /// Live stream of every donor, ordered by member ID.
  Stream<List<Donor>> watchDonors() {
    final controller = _donorsController ??= StreamController<List<Donor>>.broadcast(
      onCancel: () {
        // Keep the Firestore listener alive; screens come and go with hot
        // reload / navigation but the collection listener should persist.
      },
    );
    _donorsSub ??= _donors.orderBy('memberId').snapshots().listen(
      (snap) {
        _lastDonors = snap.docs.map(Donor.fromFirestore).toList();
        controller.add(_lastDonors!);
      },
      onError: controller.addError,
    );
    if (_lastDonors != null) {
      return Stream<List<Donor>>.multi((multi) {
        multi.add(_lastDonors!);
        multi.addStream(controller.stream);
      });
    }
    return controller.stream;
  }

  void dispose() {
    _donorsSub?.cancel();
    _donorsController?.close();
  }

  /// Live stream of a single donor by document id.
  Stream<Donor?> watchDonor(String donorId) {
    return _donors.doc(donorId).snapshots().map(
          (snap) => snap.exists ? Donor.fromFirestore(snap) : null,
        );
  }

  /// Atomically reserves and returns the next member ID ("001", "002", ...).
  Future<String> _nextMemberId() {
    return _db.runTransaction<String>((tx) async {
      final snap = await tx.get(_counterDoc);
      final current = (snap.data()?['lastMemberId'] as int?) ?? 0;
      final next = current + 1;
      tx.set(_counterDoc, {'lastMemberId': next}, SetOptions(merge: true));
      // Pad to at least 3 digits: 001, 002 ... 999, 1000, 1001 ...
      return next.toString().padLeft(3, '0');
    });
  }

  /// Registers a new donor and returns the assigned member ID.
  Future<String> registerDonor({
    required String name,
    required String bloodType,
    required String address,
    required String phone,
    required String viber,
  }) async {
    final memberId = await _nextMemberId();
    final donor = Donor(
      id: '',
      memberId: memberId,
      name: name.trim(),
      bloodType: bloodType,
      address: address.trim(),
      phone: phone.trim(),
      viber: viber.trim(),
      donationHistory: const [],
      createdAt: DateTime.now(),
    );
    await _donors.add(donor.toFirestore());
    return memberId;
  }

  /// Updates the editable profile fields of an existing donor. Leaves the
  /// donation history untouched (that is managed by [recordDonation]).
  Future<void> updateDonorInfo({
    required String donorId,
    required String name,
    required String bloodType,
    required String address,
    required String phone,
    required String viber,
  }) {
    return _donors.doc(donorId).update({
      'name': name.trim(),
      'nameLower': name.trim().toLowerCase(),
      'bloodType': bloodType,
      'address': address.trim(),
      'phone': phone.trim(),
      'viber': viber.trim(),
    });
  }

  Future<void> deleteDonor(String donorId) {
    return _donors.doc(donorId).delete();
  }

  /// Records a new donation for [donor] on [date] (defaults to now).
  ///
  /// `lastDonationDate` is only moved forward, never backward, so recording a
  /// backdated donation does not corrupt the "eligible again" calculation.
  Future<void> recordDonation(Donor donor, {DateTime? date}) {
    final donationDate = date ?? DateTime.now();
    final current = donor.lastDonationDate;
    final data = <String, dynamic>{
      'donationHistory': FieldValue.arrayUnion(
        [Timestamp.fromDate(donationDate)],
      ),
    };
    if (current == null || donationDate.isAfter(current)) {
      data['lastDonationDate'] = Timestamp.fromDate(donationDate);
    }
    return _donors.doc(donor.id).update(data);
  }

  /// Removes a single donation date from [donor]'s history and recomputes
  /// `lastDonationDate` from what remains.
  Future<void> removeDonation(Donor donor, DateTime date) {
    final remaining = donor.donationHistory
        .where((d) => !d.isAtSameMomentAs(date))
        .toList()
      ..sort();
    return _donors.doc(donor.id).update({
      'donationHistory':
          remaining.map((d) => Timestamp.fromDate(d)).toList(),
      'lastDonationDate':
          remaining.isEmpty ? null : Timestamp.fromDate(remaining.last),
    });
  }
}

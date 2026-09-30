// Emergency contacts and the employee's health insurance card — the two
// things someone else may need to find fast, in an emergency, on this
// phone. Nothing here needs a network connection to read.

import 'package:flutter/foundation.dart';

class EmergencyContact {
  final String id;
  final String name;
  final String relation;
  final String phone;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.relation,
    required this.phone,
  });
}

class HealthInsuranceCard {
  final String provider;
  final String policyNumber;
  final String memberId;
  final String planName;
  final double annualCoverage;
  final DateTime validUntil;
  final String claimsHotline;

  const HealthInsuranceCard({
    required this.provider,
    required this.policyNumber,
    required this.memberId,
    required this.planName,
    required this.annualCoverage,
    required this.validUntil,
    required this.claimsHotline,
  });
}

/// Nepal's public emergency numbers.
const nepalEmergencyNumbers = [
  ('Police', '100'),
  ('Fire Brigade', '101'),
  ('Ambulance', '102'),
];

class EmergencyInfoState extends ChangeNotifier {
  final List<EmergencyContact> _contacts = _seed();
  int _nextId = 100;

  // A growable list, NOT a `const [...]` literal: this list is added to
  // and cleared, and a const list throws "Cannot add to an unmodifiable
  // list" — which crashed "Add emergency contact" and logout alike.
  static List<EmergencyContact> _seed() => [
    const EmergencyContact(
      id: 'seed-1',
      name: 'Kamala Sigdel',
      relation: 'Mother',
      phone: '+977 9841000000',
    ),
  ];

  // Demo card. With a backend this comes from HR's insurance roster.
  final HealthInsuranceCard insurance = HealthInsuranceCard(
    provider: 'Himalayan Health Insurance (demo)',
    policyNumber: 'GRP-KHR-2083-0147',
    memberId: 'MB-24071-01',
    planName: 'Group Medical — Staff',
    annualCoverage: 500000,
    validUntil: DateTime(2027, 7, 16),
    claimsHotline: '+977 1 4000000',
  );

  List<EmergencyContact> get contacts => List.unmodifiable(_contacts);

  void add({
    required String name,
    required String relation,
    required String phone,
  }) {
    _contacts.add(
      EmergencyContact(
        id: 'c-${_nextId++}',
        name: name.trim(),
        relation: relation.trim(),
        phone: phone.trim(),
      ),
    );
    notifyListeners();
  }

  void remove(String id) {
    _contacts.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  void reset() {
    _contacts
      ..clear()
      ..addAll(_seed());
    _nextId = 100;
    notifyListeners();
  }
}

// The documents HR keeps on file for each employee (contract, citizenship,
// work permit...), with an optional expiry date so HR is warned before a
// contract or permit lapses. COMPANY data: logout does not reset it.

import 'package:flutter/foundation.dart';

enum DocType { contract, citizenship, pan, workPermit, certificate, other }

class EmployeeDocument {
  final String id;
  final String employeeId;
  final DocType type;
  final String title;

  /// A calendar day, or null for a document that never expires.
  final DateTime? expiresOn;

  const EmployeeDocument({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.title,
    this.expiresOn,
  });

  /// Whole days from [today] until it expires; negative once it has.
  /// Null when it has no expiry.
  int? daysLeft(DateTime today) {
    final e = expiresOn;
    if (e == null) return null;
    final from = DateTime.utc(today.year, today.month, today.day);
    final to = DateTime.utc(e.year, e.month, e.day);
    return to.difference(from).inDays;
  }
}

class EmployeeDocumentsState extends ChangeNotifier {
  /// How far ahead "expiring soon" looks.
  static const warningDays = 30;

  final List<EmployeeDocument> _docs = _seed();
  var _nextId = 100;

  static List<EmployeeDocument> _seed() {
    final t = DateTime.now();
    DateTime inDays(int d) => DateTime(t.year, t.month, t.day + d);
    return [
      const EmployeeDocument(
        id: 'd1',
        employeeId: 'MB-21003',
        type: DocType.contract,
        title: 'Employment contract',
      ),
      EmployeeDocument(
        id: 'd2',
        employeeId: 'MB-23044',
        type: DocType.workPermit,
        title: 'Work permit',
        expiresOn: inDays(20),
      ),
      EmployeeDocument(
        id: 'd3',
        employeeId: 'MB-22021',
        type: DocType.contract,
        title: 'Fixed-term contract',
        expiresOn: inDays(12),
      ),
      EmployeeDocument(
        id: 'd4',
        employeeId: 'MB-23088',
        type: DocType.workPermit,
        title: 'Work permit',
        expiresOn: inDays(-5),
      ),
      const EmployeeDocument(
        id: 'd5',
        employeeId: 'MB-24012',
        type: DocType.pan,
        title: 'PAN card',
      ),
      EmployeeDocument(
        id: 'd6',
        employeeId: 'MB-23102',
        type: DocType.certificate,
        title: 'CA certificate',
        expiresOn: inDays(200),
      ),
      const EmployeeDocument(
        id: 'd7',
        employeeId: 'MB-24071',
        type: DocType.citizenship,
        title: 'Citizenship certificate',
      ),
    ];
  }

  List<EmployeeDocument> get all => List.unmodifiable(_docs);

  List<EmployeeDocument> forEmployee(String employeeId) =>
      _docs.where((d) => d.employeeId == employeeId).toList();

  /// Documents that have expired or will within [warningDays], soonest
  /// first (the already expired come first).
  List<EmployeeDocument> expiringSoon({DateTime? now}) {
    final today = now ?? DateTime.now();
    return _docs.where((d) {
      final left = d.daysLeft(today);
      return left != null && left <= warningDays;
    }).toList()..sort((a, b) => a.expiresOn!.compareTo(b.expiresOn!));
  }

  /// Adds a document. A blank title is refused (returns false).
  bool add({
    required String employeeId,
    required DocType type,
    required String title,
    DateTime? expiresOn,
  }) {
    final name = title.trim();
    if (name.isEmpty) return false;
    _docs.add(
      EmployeeDocument(
        id: 'd${_nextId++}',
        employeeId: employeeId,
        type: type,
        title: name,
        expiresOn: expiresOn == null
            ? null
            : DateTime(expiresOn.year, expiresOn.month, expiresOn.day),
      ),
    );
    notifyListeners();
    return true;
  }

  void remove(String id) {
    final before = _docs.length;
    _docs.removeWhere((d) => d.id == id);
    if (_docs.length != before) notifyListeners();
  }
}

// Everything waiting for HR's decision, in one list: leave, expense,
// overtime and HR requests from the whole company. This is COMPANY data,
// so logout does not reset it.
//
// The employee app keeps each employee's own request lists; with a backend,
// both sides read the same table and a decision here shows up there.

import 'package:flutter/foundation.dart';

enum InboxKind { leave, expense, overtime, hrRequest }

enum InboxStatus { pending, approved, rejected }

class InboxItem {
  final String id;
  final InboxKind kind;
  final String employeeName;
  final String initials;

  /// What was asked for, e.g. "Sick Leave · 2 days".
  final String title;

  /// Dates, amount or reason, e.g. "Oct 7 – Oct 8 · Tihar break".
  final String detail;
  final DateTime submittedAt;
  final InboxStatus status;

  const InboxItem({
    required this.id,
    required this.kind,
    required this.employeeName,
    required this.initials,
    required this.title,
    required this.detail,
    required this.submittedAt,
    this.status = InboxStatus.pending,
  });

  bool get isPending => status == InboxStatus.pending;

  InboxItem withStatus(InboxStatus status) => InboxItem(
    id: id,
    kind: kind,
    employeeName: employeeName,
    initials: initials,
    title: title,
    detail: detail,
    submittedAt: submittedAt,
    status: status,
  );
}

class HrInboxState extends ChangeNotifier {
  final List<InboxItem> _items = _seed();

  // Dates are relative to today so the demo always looks current.
  static List<InboxItem> _seed() {
    final now = DateTime.now();
    DateTime ago(int days, [int hours = 0]) =>
        now.subtract(Duration(days: days, hours: hours));

    return [
      InboxItem(
        id: 'r1',
        kind: InboxKind.leave,
        employeeName: 'Sita Gurung',
        initials: 'SG',
        title: 'Home Leave · 3 days',
        detail: 'Tihar break with family',
        submittedAt: ago(0, 3),
      ),
      InboxItem(
        id: 'r2',
        kind: InboxKind.leave,
        employeeName: 'Prakash Adhikari',
        initials: 'PA',
        title: 'Sick Leave · 2 days',
        detail: 'Fever; medical certificate attached',
        submittedAt: ago(1),
      ),
      InboxItem(
        id: 'r3',
        kind: InboxKind.leave,
        employeeName: 'Manisha Rai',
        initials: 'MR',
        title: 'Home Leave · 1 day',
        detail: 'Family function',
        submittedAt: ago(2),
      ),
      InboxItem(
        id: 'r4',
        kind: InboxKind.expense,
        employeeName: 'Ramesh Thapa',
        initials: 'RT',
        title: 'Phone / Internet · Rs. 1,200',
        detail: 'Monthly data pack, paid by eSewa',
        submittedAt: ago(1, 5),
      ),
      InboxItem(
        id: 'r5',
        kind: InboxKind.expense,
        employeeName: 'Anita Shrestha',
        initials: 'AS',
        title: 'Client Meal · Rs. 3,400',
        detail: 'Lunch with the audit team; receipt attached',
        submittedAt: ago(3, 2),
      ),
      InboxItem(
        id: 'r6',
        kind: InboxKind.overtime,
        employeeName: 'Bikash Lama',
        initials: 'BL',
        title: 'Overtime · 3 hours',
        detail: 'Month-end closing',
        submittedAt: ago(0, 8),
      ),
      InboxItem(
        id: 'r7',
        kind: InboxKind.hrRequest,
        employeeName: 'Ramesh Thapa',
        initials: 'RT',
        title: 'ID Card Reissue',
        detail: 'Card lost on the way to work',
        submittedAt: ago(4),
      ),
      InboxItem(
        id: 'r8',
        kind: InboxKind.leave,
        employeeName: 'Anita Shrestha',
        initials: 'AS',
        title: 'Home Leave · 2 days',
        detail: 'Visit to Pokhara',
        submittedAt: ago(9),
        status: InboxStatus.approved,
      ),
      InboxItem(
        id: 'r9',
        kind: InboxKind.expense,
        employeeName: 'Prakash Adhikari',
        initials: 'PA',
        title: 'Travel & Lodging · Rs. 18,500',
        detail: 'No receipt attached',
        submittedAt: ago(11),
        status: InboxStatus.rejected,
      ),
    ];
  }

  List<InboxItem> get items => List.unmodifiable(_items);

  /// Pending first (oldest waiting longest), then decided (newest first).
  List<InboxItem> get pending =>
      _items.where((i) => i.isPending).toList()
        ..sort((a, b) => a.submittedAt.compareTo(b.submittedAt));

  List<InboxItem> get decided =>
      _items.where((i) => !i.isPending).toList()
        ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

  int get pendingCount => _items.where((i) => i.isPending).length;

  /// Approve or reject a pending request. A decision is final: asking again
  /// for one that is already decided does nothing.
  void decide(String id, InboxStatus status) {
    if (status == InboxStatus.pending) return;
    final i = _items.indexWhere((item) => item.id == id);
    if (i < 0 || !_items[i].isPending) return;
    _items[i] = _items[i].withStatus(status);
    notifyListeners();
  }
}

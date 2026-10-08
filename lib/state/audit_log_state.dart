// A record of what HR changed: who, what and when. COMPANY data, and it is
// never reset on logout: an audit log you can wipe is not an audit log.
//
// With a backend this becomes an append-only table that no screen can edit.

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../data/current_employee.dart';

enum AuditAction {
  employeeAdded,
  employeeUpdated,
  employeeDeactivated,
  employeeReactivated,
  requestApproved,
  requestRejected,
  payrollRun,
  payrollApproved,
  payrollPaid,
  noticePublished,
  noticeDeleted,
  holidayAdded,
  holidayRemoved,
  documentAdded,
  documentRemoved,
  reviewStarted,
  jobPosted,
  applicantHired,
  employeesImported,
  payViewed,
}

class AuditEntry {
  final AuditAction action;

  /// What it was done to: a name, a notice title, a month.
  final String detail;

  /// Who did it.
  final String actor;
  final DateTime when;

  const AuditEntry({
    required this.action,
    required this.detail,
    required this.actor,
    required this.when,
  });
}

class AuditLogState extends ChangeNotifier {
  /// Oldest are dropped past this, so the log can't grow without bound.
  static const maxEntries = 200;

  final List<AuditEntry> _entries = [];

  /// Newest first.
  List<AuditEntry> get entries => List.unmodifiable(_entries);

  /// The whole log as CSV, newest first: When, Actor, Action, Detail.
  String toCsv() {
    String cell(String v) =>
        v.contains(',') || v.contains('"') ? '"${v.replaceAll('"', '""')}"' : v;
    String two(int n) => n.toString().padLeft(2, '0');
    String when(DateTime d) =>
        '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';

    return [
      'When,Actor,Action,Detail',
      for (final e in _entries)
        [when(e.when), cell(e.actor), e.action.name, cell(e.detail)].join(','),
    ].join('\n');
  }

  void log(
    AuditAction action,
    String detail, {
    required String actor,
    DateTime? now,
  }) {
    _entries.insert(
      0,
      AuditEntry(
        action: action,
        detail: detail,
        actor: actor,
        when: now ?? DateTime.now(),
      ),
    );
    if (_entries.length > maxEntries) _entries.removeLast();
    notifyListeners();
  }
}

/// Records an HR action as the signed-in user. Call it after the change
/// itself has gone through.
void logAudit(BuildContext context, AuditAction action, String detail) {
  context.read<AuditLogState>().log(
    action,
    detail,
    actor: currentEmployee.name,
  );
}

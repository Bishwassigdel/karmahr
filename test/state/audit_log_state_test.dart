import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_flutter_app/state/audit_log_state.dart';
import 'package:my_first_flutter_app/state/employee_records_state.dart';
import 'package:my_first_flutter_app/state/payroll_state.dart';

void main() {
  group('AuditLogState', () {
    test('starts empty', () => expect(AuditLogState().entries, isEmpty));

    test('records who, what and when, newest first', () {
      final log = AuditLogState();
      log.log(
        AuditAction.employeeAdded,
        'Nima Sherpa',
        actor: 'Bishwas Sigdel',
        now: DateTime(2026, 10, 5, 9),
      );
      log.log(
        AuditAction.payrollApproved,
        'Ashwin 2083',
        actor: 'Bishwas Sigdel',
        now: DateTime(2026, 10, 5, 10),
      );

      expect(log.entries.length, 2);
      expect(log.entries.first.action, AuditAction.payrollApproved);
      expect(log.entries.last.detail, 'Nima Sherpa');
      expect(log.entries.last.actor, 'Bishwas Sigdel');
      expect(log.entries.last.when, DateTime(2026, 10, 5, 9));
    });

    test('notifies on every entry', () {
      final log = AuditLogState();
      var n = 0;
      log.addListener(() => n++);
      log.log(AuditAction.noticeDeleted, 'x', actor: 'a');
      log.log(AuditAction.noticeDeleted, 'y', actor: 'a');
      expect(n, 2);
    });

    test('keeps only the newest ${AuditLogState.maxEntries} entries', () {
      final log = AuditLogState();
      for (var i = 0; i < AuditLogState.maxEntries + 25; i++) {
        log.log(AuditAction.holidayAdded, 'h$i', actor: 'a');
      }
      expect(log.entries.length, AuditLogState.maxEntries);
      expect(log.entries.first.detail, 'h${AuditLogState.maxEntries + 24}');
      expect(log.entries.any((e) => e.detail == 'h0'), isFalse);
    });

    test('the entries list cannot be edited from outside', () {
      final log = AuditLogState()..log(AuditAction.payrollRun, 'x', actor: 'a');
      expect(() => log.entries.clear(), throwsUnsupportedError);
    });
  });

  group('exports and summaries', () {
    test('the employee CSV has a header and a row per record', () {
      final csv = EmployeeRecordsState().toCsv();
      final lines = csv.split('\n');
      expect(lines.first, startsWith('Staff ID,Name,Job title,Department'));
      expect(lines.length, 10); // header + 9 employees
      expect(csv, contains('MB-24071,Bishwas Sigdel'));
      expect(csv, contains('Inactive'));
    });

    test('a comma or quote in a field is escaped', () {
      final state = EmployeeRecordsState();
      final r = state.byId('MB-24071')!;
      state.update(r.copyWith(jobTitle: 'Head, "People" Team'));
      expect(state.toCsv(), contains('"Head, ""People"" Team"'));
    });

    test('latest payroll is the most recent month, not the last one run', () {
      final records = EmployeeRecordsState().records;
      final payroll = PayrollState();
      expect(payroll.latest, isNull);

      payroll.calculate(2083, 7, records);
      payroll.calculate(2083, 5, records); // an earlier month, run later
      payroll.calculate(2083, 6, records);

      expect(payroll.latest!.month, 7);
    });

    test('latest crosses the year end correctly', () {
      final records = EmployeeRecordsState().records;
      final payroll = PayrollState()
        ..calculate(2083, 12, records)
        ..calculate(2084, 1, records);
      expect(payroll.latest!.year, 2084);
    });
  });
}

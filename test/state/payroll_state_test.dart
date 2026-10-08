import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_utils/nepali_utils.dart';

import 'package:my_first_flutter_app/domain/nepal/bs_dates.dart';
import 'package:my_first_flutter_app/domain/nepal/payroll_calculator.dart';
import 'package:my_first_flutter_app/domain/nepal/tax_slabs.dart';
import 'package:my_first_flutter_app/state/employee_records_state.dart';
import 'package:my_first_flutter_app/state/payroll_state.dart';

// Ashwin 2083 (BS month 6).
const _year = 2083;
const _month = 6;

void main() {
  late List<EmployeeRecord> records;

  setUp(() => records = EmployeeRecordsState().records);

  group('calculate', () {
    test('pays every active employee who had joined, and no one else', () {
      final run = PayrollState().calculate(_year, _month, records);

      // 8 active; the inactive former employee is left out.
      expect(run.employeeCount, 8);
      expect(run.lines.any((l) => l.name == 'Dipesh Pandey'), isFalse);
      expect(run.status, PayrollStatus.draft);
    });

    test('someone who joins after the month is not paid for it', () {
      final future = records.first.copyWith(joiningDate: DateTime(2030, 1, 1));
      final run = PayrollState().calculate(_year, _month, [future]);
      expect(run.lines, isEmpty);
    });

    test('someone who joined during the month is paid for it', () {
      final end = bsMonthEndAd(_year, _month);
      final joiner = records.first.copyWith(joiningDate: end);
      final run = PayrollState().calculate(_year, _month, [joiner]);
      expect(run.employeeCount, 1);
    });

    test('each line matches the payroll calculator exactly', () {
      final r = records.firstWhere((r) => r.id == 'MB-24071');
      final run = PayrollState().calculate(_year, _month, [r]);

      final expected = computePayroll(
        PayrollInput(
          basicSalary: r.basicSalary,
          allowances: r.allowances,
          filingStatus: r.filingStatus,
          fiscalStartYear: 2083, // Ashwin is in fiscal year 2083/84
        ),
      );
      expect(run.lines.single.net, expected.netMonthly);
      expect(run.lines.single.tax, expected.monthlyTax);
      expect(run.lines.single.gross, r.grossMonthly);
    });

    test('Baisakh to Ashad use the previous fiscal year', () {
      // Baisakh 2084 belongs to fiscal year 2083/84, not 2084/85.
      final r = records.firstWhere((r) => r.id == 'MB-24071');
      final run = PayrollState().calculate(2084, 1, [r]);
      final expected = computePayroll(
        PayrollInput(
          basicSalary: r.basicSalary,
          allowances: r.allowances,
          filingStatus: r.filingStatus,
          fiscalStartYear: 2083,
        ),
      );
      expect(run.lines.single.net, expected.netMonthly);
    });

    test('totals add up: gross - deductions = net', () {
      final run = PayrollState().calculate(_year, _month, records);
      expect(run.totalGross - run.totalDeductions, closeTo(run.totalNet, 0.01));
      expect(run.totalGross, greaterThan(0));
    });

    test('lines are sorted by name', () {
      final names = PayrollState()
          .calculate(_year, _month, records)
          .lines
          .map((l) => l.name)
          .toList();
      expect(names, [...names]..sort());
    });

    test('married filers pay no more tax than single at the same pay', () {
      final r = records.first;
      final single = r.copyWith(filingStatus: FilingStatus.single);
      final married = r.copyWith(filingStatus: FilingStatus.married);
      final state = PayrollState();
      final s = state.calculate(_year, _month, [single]).lines.single.tax;
      final m = PayrollState()
          .calculate(_year, _month, [married])
          .lines
          .single
          .tax;
      expect(m, lessThanOrEqualTo(s));
    });
  });

  group('status', () {
    test('draft -> approved -> paid, in that order only', () {
      final state = PayrollState()..calculate(_year, _month, records);

      state.markPaid(_year, _month); // too early: ignored
      expect(state.runFor(_year, _month)!.status, PayrollStatus.draft);

      state.approve(_year, _month);
      expect(state.runFor(_year, _month)!.status, PayrollStatus.approved);

      state.approve(_year, _month); // already approved: ignored
      expect(state.runFor(_year, _month)!.status, PayrollStatus.approved);

      state.markPaid(_year, _month);
      expect(state.runFor(_year, _month)!.status, PayrollStatus.paid);
    });

    test(
      'an approved payroll is frozen: recalculating returns it unchanged',
      () {
        final state = PayrollState();
        final run = state.calculate(_year, _month, records);
        state.approve(_year, _month);
        final totalBefore = run.totalNet;

        // HR raises everyone's salary afterwards.
        final raised = [
          for (final r in records) r.copyWith(basicSalary: r.basicSalary * 2),
        ];
        final again = state.calculate(_year, _month, raised);

        expect(again.status, PayrollStatus.approved);
        expect(again.totalNet, totalBefore);
      },
    );

    test('a draft can be recalculated with new figures', () {
      final state = PayrollState();
      final before = state.calculate(_year, _month, records).totalNet;
      final raised = [
        for (final r in records) r.copyWith(basicSalary: r.basicSalary * 2),
      ];
      final after = state.calculate(_year, _month, raised).totalNet;
      expect(after, greaterThan(before));
    });

    test('months are independent', () {
      final state = PayrollState()..calculate(_year, _month, records);
      expect(state.runFor(_year, _month + 1), isNull);
    });

    test('notifies on calculate and on each status change only', () {
      final state = PayrollState();
      var n = 0;
      state.addListener(() => n++);
      state.calculate(_year, _month, records);
      state.approve(_year, _month);
      state.approve(_year, _month); // no-op
      state.markPaid(_year, _month);
      expect(n, 3);
    });
  });

  group('CSV', () {
    test('has a header and one row per employee', () {
      final run = PayrollState().calculate(_year, _month, records);
      final lines = run.toCsv().split('\n');
      expect(
        lines.first,
        'Staff ID,Name,Gross,SSF,CIT,Insurance,Tax (TDS),Net',
      );
      expect(lines.length, 1 + run.employeeCount);
    });

    test('a name with a comma is quoted, amounts have 2 decimals', () {
      final tricky = records.first.copyWith(name: 'Karki, Suresh');
      final csv = PayrollState().calculate(_year, _month, [tricky]).toCsv();
      expect(csv, contains('"Karki, Suresh"'));
      expect(csv.split('\n')[1], matches(RegExp(r'\d+\.\d{2},\d+\.\d{2}')));
    });
  });

  group('month helpers', () {
    test('fiscalMonthsUpTo lists Shrawan through the current month', () {
      final months = fiscalMonthsUpTo(NepaliDateTime(2083, 6, 10));
      expect(months.first, (year: 2083, month: 4));
      expect(months.last, (year: 2083, month: 6));
      expect(months.length, 3);
    });

    test('it rolls into the new year after Chaitra', () {
      final months = fiscalMonthsUpTo(NepaliDateTime(2084, 2, 5));
      expect(months.first, (year: 2083, month: 4));
      expect(months.last, (year: 2084, month: 2));
      expect(months.length, 11);
    });

    test('in Shrawan the list is just that month', () {
      final months = fiscalMonthsUpTo(NepaliDateTime(2083, 4, 1));
      expect(months, [(year: 2083, month: 4)]);
    });

    test('bsMonthEndAd is the day before the next month starts', () {
      final end = bsMonthEndAd(2083, 6);
      final nextStart = NepaliDateTime(2083, 7, 1).toDateTime();
      final gap = DateTime.utc(
        nextStart.year,
        nextStart.month,
        nextStart.day,
      ).difference(DateTime.utc(end.year, end.month, end.day)).inDays;
      expect(gap, 1);
    });
  });

  group('payroll files', () {
    PayrollRun run0() => PayrollState().calculate(_year, _month, records);

    test('the bank file has one row per paid person with an account', () {
      final run = run0();
      final lines = run.toBankCsv().split('\n');
      expect(lines.first, 'Bank,Account number,Name,Amount');
      expect(lines.length, 1 + run.employeeCount);
      expect(run.toBankCsv(), contains('0050500567890'));
    });

    test('someone with no account is left out and reported', () {
      final noAccount = records.first.copyWith(accountNumber: '');
      final run = PayrollState().calculate(_year, _month, [
        noAccount,
        ...records.skip(1),
      ]);

      expect(run.missingBankDetails.single.name, noAccount.name);
      expect(run.toBankCsv().contains(noAccount.name), isFalse);
      expect(
        run.toBankCsv().split('\n').length,
        run.employeeCount, // header + everyone but one
      );
    });

    test('the amount in the bank file is the net pay', () {
      final r = records.firstWhere((r) => r.id == 'MB-24071');
      final run = PayrollState().calculate(_year, _month, [r]);
      expect(
        run.toBankCsv().split('\n')[1],
        endsWith(run.lines.single.net.toStringAsFixed(2)),
      );
    });

    test('the TDS report carries gross, taxable income and tax', () {
      final run = run0();
      final first = run.toTdsCsv().split('\n')[1].split(',');
      expect(run.toTdsCsv().split('\n').first, contains('Taxable (annual)'));
      expect(double.parse(first[2]), greaterThan(0));
      expect(double.parse(first[4]), greaterThanOrEqualTo(0));
    });

    test('the SSF report shows the employee and employer shares', () {
      final r = records.firstWhere((r) => r.id == 'MB-24071');
      final run = PayrollState().calculate(_year, _month, [r]);
      final row = run.toSsfCsv().split('\n')[1].split(',');
      expect(
        double.parse(row[3]),
        closeTo(run.lines.single.result.socialSecurityFundDeduction, 0.01),
      );
      expect(
        double.parse(row[4]),
        closeTo(run.lines.single.gross * employerSsfRate, 0.01),
      );
    });

    test('a line keeps its salary parts and bank details', () {
      final r = records.firstWhere((r) => r.id == 'MB-24071');
      final line = PayrollState().calculate(_year, _month, [r]).lines.single;
      expect(line.basic, r.basicSalary);
      expect(line.dearness, r.dearnessAllowance);
      expect(line.transport, r.transportAllowance);
      expect(line.bankName, r.bankName);
      expect(line.accountNumber, r.accountNumber);
    });

    test('a frozen payroll keeps the bank details it had when approved', () {
      final state = PayrollState();
      state.calculate(_year, _month, records);
      state.approve(_year, _month);
      final moved = [for (final r in records) r.copyWith(accountNumber: '1')];
      final run = state.calculate(_year, _month, moved);
      expect(run.toBankCsv(), isNot(contains(',1,')));
    });
  });
}

// Monthly payroll runs. A run is calculated for every active employee with
// the Nepal rules in payroll_calculator.dart, then approved (which freezes
// the figures) and finally marked paid. COMPANY data: logout does not
// reset it.
//
// NOTE(finance-review): the tax slabs, SSF rate and deduction caps behind
// these numbers are placeholders. Have finance verify them before any real
// payroll is run from this.

import 'package:flutter/foundation.dart';

import '../domain/nepal/bs_dates.dart';
import '../domain/nepal/payroll_calculator.dart';
import 'employee_records_state.dart';

enum PayrollStatus { draft, approved, paid }

/// NOTE(finance-review): the employer's SSF share is a placeholder (20% of
/// gross). Confirm the rate and what it is charged on before filing.
const employerSsfRate = 0.20;

/// One employee's pay for the month. Stores the figures themselves, not a
/// link to the employee record, so a later edit to someone's salary can't
/// change a payroll that was already approved.
class PayrollLine {
  final String employeeId;
  final String name;
  final String initials;
  final PayrollResult result;

  /// The salary parts the gross was made of, as they were at calculation.
  final double basic;
  final double dearness;
  final double transport;

  /// Where the net pay goes, as it was at calculation.
  final String bankName;
  final String accountNumber;

  const PayrollLine({
    required this.employeeId,
    required this.name,
    required this.initials,
    required this.result,
    this.basic = 0,
    this.dearness = 0,
    this.transport = 0,
    this.bankName = '',
    this.accountNumber = '',
  });

  double get gross => result.grossMonthly;
  double get tax => result.monthlyTax;
  double get net => result.netMonthly;
}

class PayrollRun {
  final int year; // BS
  final int month; // BS, 1 = Baisakh
  final PayrollStatus status;
  final List<PayrollLine> lines;
  final DateTime createdAt;

  const PayrollRun({
    required this.year,
    required this.month,
    required this.status,
    required this.lines,
    required this.createdAt,
  });

  PayrollRun withStatus(PayrollStatus status) => PayrollRun(
    year: year,
    month: month,
    status: status,
    lines: lines,
    createdAt: createdAt,
  );

  int get employeeCount => lines.length;
  double get totalGross => lines.fold(0.0, (sum, l) => sum + l.gross);
  double get totalDeductions =>
      lines.fold(0.0, (sum, l) => sum + l.result.totalDeductions);
  double get totalNet => lines.fold(0.0, (sum, l) => sum + l.net);

  static String _cell(String v) =>
      v.contains(',') || v.contains('"') ? '"${v.replaceAll('"', '""')}"' : v;
  static String _money(double v) => v.toStringAsFixed(2);

  /// What the bank needs to pay everyone: account, name and net amount.
  /// Anyone with no account on file is left out; see [missingBankDetails].
  String toBankCsv() {
    return [
      'Bank,Account number,Name,Amount',
      for (final l in lines)
        if (l.accountNumber.isNotEmpty)
          [
            _cell(l.bankName),
            _cell(l.accountNumber),
            _cell(l.name),
            _money(l.net),
          ].join(','),
    ].join('\n');
  }

  /// Employees who would be missing from the bank file.
  List<PayrollLine> get missingBankDetails =>
      lines.where((l) => l.accountNumber.isEmpty).toList();

  /// Income tax withheld, for the tax return.
  String toTdsCsv() {
    return [
      'Staff ID,Name,Gross,Taxable (annual),Tax (TDS)',
      for (final l in lines)
        [
          _cell(l.employeeId),
          _cell(l.name),
          _money(l.gross),
          _money(l.result.taxableAnnualIncome),
          _money(l.tax),
        ].join(','),
    ].join('\n');
  }

  /// Social Security Fund contributions: the employee's share, and the
  /// employer's share at [employerSsfRate].
  String toSsfCsv() {
    return [
      'Staff ID,Name,Gross,Employee contribution,Employer contribution',
      for (final l in lines)
        [
          _cell(l.employeeId),
          _cell(l.name),
          _money(l.gross),
          _money(l.result.socialSecurityFundDeduction),
          _money(l.gross * employerSsfRate),
        ].join(','),
    ].join('\n');
  }

  /// A spreadsheet-ready table: one row per employee, amounts to 2 places.
  String toCsv() {
    String cell(String v) => _cell(v);
    String money(double v) => _money(v);

    final rows = <String>[
      'Staff ID,Name,Gross,SSF,CIT,Insurance,Tax (TDS),Net',
      for (final l in lines)
        [
          cell(l.employeeId),
          cell(l.name),
          money(l.gross),
          money(l.result.socialSecurityFundDeduction),
          money(l.result.citDeduction),
          money(l.result.insuranceDeduction),
          money(l.tax),
          money(l.net),
        ].join(','),
    ];
    return rows.join('\n');
  }
}

class PayrollState extends ChangeNotifier {
  final Map<String, PayrollRun> _runs = {};

  static String _key(int year, int month) => '$year-$month';

  PayrollRun? runFor(int year, int month) => _runs[_key(year, month)];

  /// The most recent month that has a run, or null if none has been run.
  PayrollRun? get latest {
    PayrollRun? best;
    for (final r in _runs.values) {
      if (best == null ||
          r.year * 100 + r.month > best.year * 100 + best.month) {
        best = r;
      }
    }
    return best;
  }

  /// Calculates (or recalculates) the run for a BS month from [records].
  ///
  /// Only active employees who had joined by the end of that month are paid.
  /// An approved or paid run is final: it is returned untouched.
  PayrollRun calculate(int year, int month, Iterable<EmployeeRecord> records) {
    final existing = runFor(year, month);
    if (existing != null && existing.status != PayrollStatus.draft) {
      return existing;
    }

    final monthEnd = bsMonthEndAd(year, month);
    // Which fiscal year's tax slabs apply: Shrawan to Chaitra belong to the
    // year they fall in, Baisakh to Ashad to the one before.
    final fiscalStartYear = month >= 4 ? year : year - 1;

    final lines = <PayrollLine>[
      for (final r in records)
        if (r.isActive && !r.joiningDate.isAfter(monthEnd))
          PayrollLine(
            employeeId: r.id,
            name: r.name,
            initials: r.initials,
            basic: r.basicSalary,
            dearness: r.dearnessAllowance,
            transport: r.transportAllowance,
            bankName: r.bankName,
            accountNumber: r.accountNumber,
            result: computePayroll(
              PayrollInput(
                basicSalary: r.basicSalary,
                allowances: r.allowances,
                filingStatus: r.filingStatus,
                fiscalStartYear: fiscalStartYear,
              ),
            ),
          ),
    ]..sort((a, b) => a.name.compareTo(b.name));

    final run = PayrollRun(
      year: year,
      month: month,
      status: PayrollStatus.draft,
      lines: lines,
      createdAt: DateTime.now(),
    );
    _runs[_key(year, month)] = run;
    notifyListeners();
    return run;
  }

  /// draft -> approved. Does nothing for any other state.
  void approve(int year, int month) =>
      _move(year, month, from: PayrollStatus.draft, to: PayrollStatus.approved);

  /// approved -> paid. Does nothing for any other state.
  void markPaid(int year, int month) =>
      _move(year, month, from: PayrollStatus.approved, to: PayrollStatus.paid);

  void _move(
    int year,
    int month, {
    required PayrollStatus from,
    required PayrollStatus to,
  }) {
    final run = runFor(year, month);
    if (run == null || run.status != from) return;
    _runs[_key(year, month)] = run.withStatus(to);
    notifyListeners();
  }
}

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_flutter_app/domain/nepal/payroll_calculator.dart';
import 'package:my_first_flutter_app/domain/nepal/tax_slabs.dart';
import 'package:my_first_flutter_app/domain/pdf_documents.dart';
import 'package:my_first_flutter_app/state/employee_records_state.dart';

void main() {
  final record = EmployeeRecordsState().byId('MB-24071')!;
  final result = computePayroll(
    PayrollInput(
      basicSalary: record.basicSalary,
      allowances: record.allowances,
      filingStatus: FilingStatus.single,
      fiscalStartYear: 2083,
    ),
  );

  PayslipPdfData data() => payslipDataFromPayroll(
    month: 'Ashwin 2083',
    payDate: 'End of Ashwin 2083',
    status: 'Approved',
    basic: record.basicSalary,
    dearness: record.dearnessAllowance,
    transport: record.transportAllowance,
    result: result,
  );

  test('the payslip says exactly what payroll calculated', () {
    final d = data();
    expect(d.gross, result.grossMonthly);
    expect(d.totalDeductions, closeTo(result.totalDeductions, 0.001));
    expect(d.net, closeTo(result.netMonthly, 0.001));
  });

  test('empty deduction lines are left off, tax and SSF stay', () {
    final labels = data().deductions.map((i) => i.label).toList();
    expect(labels, contains('Income Tax (TDS)'));
    expect(labels, contains('Social Security Fund'));
    expect(labels, isNot(contains('CIT Contribution')));
    expect(labels, isNot(contains('Provident Fund')));
  });

  test('a PDF is produced for an employee record', () async {
    final bytes = await buildPayslipPdf(
      data(),
      employee: record.toProfile(),
      compress: false,
    );
    // Text is written word by word, so look for each word on its own.
    final text = latin1.decode(bytes);
    expect(text, startsWith('%PDF'));
    expect(text, contains('[(Bishwas)]TJ'));
    expect(text, contains('[(Sigdel)]TJ'));
    expect(text, contains('[(MB-24071)]TJ'));
  });

  test('toProfile carries the record across unchanged', () {
    final p = record.toProfile();
    expect(p.employeeId, record.id);
    expect(p.grossMonthly, record.grossMonthly);
    expect(p.joiningDate, record.joiningDate);
  });
}

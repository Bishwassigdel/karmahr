import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_flutter_app/data/current_employee.dart';
import 'package:my_first_flutter_app/domain/nepal/payroll_calculator.dart';
import 'package:my_first_flutter_app/domain/nepal/tax_slabs.dart';
import 'package:my_first_flutter_app/domain/pdf_documents.dart';

// latin1, not utf8: PDF bytes aren't valid UTF-8, but every byte maps
// 1:1 to a latin1 char, so plain-text search over them is safe.
String _text(List<int> bytes) => latin1.decode(bytes);

// The pdf package lays text out word by word — "Rs. 48,000" is written
// as two separate runs, [(Rs.)]TJ and [(48,000)]TJ — so a multi-word
// phrase never appears contiguously in the bytes. Check every word of
// it is present as its own drawn run instead.
Matcher _printsWords(String phrase) => allOf([
  for (final word in phrase.split(' ')) contains('[($word)]TJ'),
]);

void main() {
  const sample = PayslipPdfData(
    month: 'September 2026',
    payDate: 'Oct 1, 2026',
    status: 'Paid',
    earnings: [PdfLineItem('Basic Salary', 45000), PdfLineItem('DA', 7500)],
    deductions: [PdfLineItem('Provident Fund (10%)', 4500)],
  );

  test('PayslipPdfData totals add up', () {
    expect(sample.gross, 52500);
    expect(sample.totalDeductions, 4500);
    expect(sample.net, 48000);
  });

  test('payslip PDF is a real PDF naming the employee and net pay', () async {
    final bytes = await buildPayslipPdf(sample, compress: false);
    final text = _text(bytes);

    expect(text.startsWith('%PDF-'), isTrue);
    expect(text, _printsWords(currentEmployee.name));
    expect(text, _printsWords('Rs. 48,000'));
  });

  test(
    "salary certificate states the same net salary the payslip engine "
    'computes (a certificate must never contradict the payslips)',
    () async {
      final expectedNet = computePayroll(
        PayrollInput(
          basicSalary: currentEmployee.basicSalary,
          allowances: currentEmployee.allowances,
          filingStatus: FilingStatus.single,
          fiscalStartYear: 2082,
          providentFundRate: 0.10,
          socialSecurityFundRate: 0,
        ),
      ).netMonthly;

      final bytes = await buildSalaryCertificatePdf(
        issuedOn: DateTime(2026, 9, 30),
        compress: false,
      );
      final text = _text(bytes);

      expect(text.startsWith('%PDF-'), isTrue);
      expect(text, _printsWords('SALARY CERTIFICATE'));
      expect(text, _printsWords(formatRupees(expectedNet)));
      expect(text, _printsWords('DRAFT - UNSIGNED'));
      expect(text, _printsWords('KHR/SC/MB-24071/20260930'));
    },
  );

  test('formatRupees groups thousands', () {
    expect(formatRupees(45000), 'Rs. 45,000');
    expect(formatRupees(1234567), 'Rs. 1,234,567');
    expect(formatRupees(999), 'Rs. 999');
  });
}

// Builds the two PDFs KarmaHR can export: a monthly payslip and a
// salary certificate (the document Nepali banks, embassies, and
// landlords ask for). Pure Dart — returns bytes, never touches the UI
// or a platform channel — so both are unit-testable, and sharing/
// printing lives separately in the screen layer.
//
// FONT NOTE: this uses the PDF standard fonts (Helvetica), which only
// cover Latin characters. Everything printed today is Latin-script, so
// that's fine. The moment Nepali (Devanagari) text is added — e.g. a
// BS date in नेपाली numerals, or the employee's name in Devanagari —
// bundle a Devanagari TTF (e.g. Noto Sans Devanagari) as an asset and
// pass it via pw.ThemeData.withFont, or those glyphs render as blanks.
// Likewise, keep text ASCII-safe (plain hyphens, not em dashes).

import 'dart:typed_data';

import 'package:nepali_utils/nepali_utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/current_employee.dart';
import 'nepal/payroll_calculator.dart';
import 'nepal/tax_slabs.dart';

const _brandRed = PdfColor.fromInt(0xFFC62828);
const _grey = PdfColor.fromInt(0xFF6B6B6B);
const _lightGrey = PdfColor.fromInt(0xFFF2F2F2);

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String _adDate(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';

String _bsDate(DateTime d) =>
    '${NepaliDateFormat('MMMM d, y', Language.english).format(d.toNepaliDateTime())} BS';

/// One row in an earnings/deductions table.
class PdfLineItem {
  final String label;
  final double amount;
  const PdfLineItem(this.label, this.amount);
}

/// Everything a payslip PDF needs — a plain public shape so the screen's
/// private payslip model can be mapped into it without exposing it.
class PayslipPdfData {
  final String month;
  final String payDate;
  final String status;
  final List<PdfLineItem> earnings;
  final List<PdfLineItem> deductions;

  const PayslipPdfData({
    required this.month,
    required this.payDate,
    required this.status,
    required this.earnings,
    required this.deductions,
  });

  double get gross => earnings.fold(0, (sum, i) => sum + i.amount);
  double get totalDeductions => deductions.fold(0, (sum, i) => sum + i.amount);
  double get net => gross - totalDeductions;
}

// ============================================================
// PAYSLIP
// ============================================================
// [compress] exists for tests: an uncompressed PDF keeps its text
// readable in the raw bytes, so a test can check what was printed.
Future<Uint8List> buildPayslipPdf(
  PayslipPdfData data, {
  EmployeeProfile? employee,
  bool compress = true,
}) async {
  final e = employee ?? currentEmployee;
  final doc = pw.Document(
    title: 'Payslip - ${data.month}',
    author: 'KarmaHR',
    compress: compress,
  );

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _letterhead(),
          pw.SizedBox(height: 24),
          pw.Text(
            'PAYSLIP - ${data.month.toUpperCase()}',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 14),
          _keyValueGrid([
            ('Employee Name', e.name),
            ('Employee ID', e.employeeId),
            ('Designation', e.jobTitle),
            ('Department', e.department),
            ('Pay Date', data.payDate),
            ('Status', data.status),
          ]),
          pw.SizedBox(height: 20),
          _amountTable('EARNINGS', data.earnings, 'Gross Pay', data.gross),
          pw.SizedBox(height: 14),
          _amountTable(
            'DEDUCTIONS',
            data.deductions,
            'Total Deductions',
            data.totalDeductions,
          ),
          pw.SizedBox(height: 18),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(14),
            decoration: const pw.BoxDecoration(color: _brandRed),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'NET PAY',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  formatRupees(data.net),
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          pw.Spacer(),
          pw.Text(
            'This is a system-generated payslip from the KarmaHR app and '
            'does not require a signature. Tax figures use placeholder IRD '
            'slabs pending finance review.',
            style: const pw.TextStyle(fontSize: 8, color: _grey),
          ),
        ],
      ),
    ),
  );

  return doc.save();
}

// ============================================================
// SALARY CERTIFICATE
// ============================================================
Future<Uint8List> buildSalaryCertificatePdf({
  EmployeeProfile? employee,
  DateTime? issuedOn,
  bool compress = true,
}) async {
  final e = employee ?? currentEmployee;
  final today = issuedOn ?? DateTime.now();

  // Same engine and same inputs as the payslip screen — the certificate
  // can't state a different net salary than the payslips it backs up.
  final payroll = computePayroll(
    PayrollInput(
      basicSalary: e.basicSalary,
      allowances: e.allowances,
      filingStatus: FilingStatus.single,
      fiscalStartYear: 2082,
      providentFundRate: 0.10,
      socialSecurityFundRate: 0,
    ),
  );

  final reference =
      'KHR/SC/${e.employeeId}/'
      '${today.year}${today.month.toString().padLeft(2, '0')}'
      '${today.day.toString().padLeft(2, '0')}';

  final doc = pw.Document(
    title: 'Salary Certificate - ${e.name}',
    author: 'KarmaHR',
    compress: compress,
  );

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(48),
      build: (context) => pw.Stack(
        children: [
          // Frontend-only honesty: nothing here is signed or sealed by a
          // real HR person, so the document says so across its face
          // instead of passing as a finished certificate.
          pw.Positioned.fill(
            child: pw.Center(
              child: pw.Transform.rotate(
                angle: 0.6,
                child: pw.Text(
                  'DRAFT - UNSIGNED',
                  style: pw.TextStyle(
                    fontSize: 58,
                    fontWeight: pw.FontWeight.bold,
                    color: const PdfColor(0.78, 0.16, 0.16, 0.08),
                  ),
                ),
              ),
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _letterhead(),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Ref: $reference',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Date: ${_adDate(today)}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        _bsDate(today),
                        style: const pw.TextStyle(fontSize: 9, color: _grey),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 28),
              pw.Center(
                child: pw.Text(
                  'SALARY CERTIFICATE',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
              pw.SizedBox(height: 22),
              pw.Text(
                'TO WHOM IT MAY CONCERN',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                'This is to certify that ${e.name} (Employee ID: '
                '${e.employeeId}) has been employed with KarmaHR Pvt. Ltd. '
                'as ${e.jobTitle} in the ${e.department} department since '
                '${_adDate(e.joiningDate)}, on a '
                '${e.employmentType.toLowerCase()} basis, and is currently '
                'working at our ${e.workLocation}.',
                style: const pw.TextStyle(fontSize: 11, lineSpacing: 4),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Their current monthly salary is as follows:',
                style: const pw.TextStyle(fontSize: 11),
              ),
              pw.SizedBox(height: 12),
              _amountTable(
                'MONTHLY SALARY',
                [
                  PdfLineItem('Basic Salary', e.basicSalary),
                  PdfLineItem('Dearness Allowance', e.dearnessAllowance),
                  PdfLineItem('Transport Allowance', e.transportAllowance),
                ],
                'Gross Monthly Salary',
                payroll.grossMonthly,
              ),
              pw.SizedBox(height: 10),
              _amountTable(
                'STATUTORY DEDUCTIONS',
                [
                  PdfLineItem(
                    'Provident Fund (10%)',
                    payroll.providentFundDeduction,
                  ),
                  PdfLineItem('Income Tax (TDS)', payroll.monthlyTax),
                ],
                'Net Monthly Salary',
                payroll.netMonthly,
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'This certificate is issued at the request of the employee '
                'for official purposes, without any liability on the part of '
                'the company.',
                style: const pw.TextStyle(fontSize: 11, lineSpacing: 4),
              ),
              pw.Spacer(),
              pw.Container(width: 160, height: 0.8, color: PdfColors.black),
              pw.SizedBox(height: 4),
              pw.Text(
                'Authorized Signatory',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'Human Resources, KarmaHR Pvt. Ltd.',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 18),
              pw.Text(
                'Generated from the KarmaHR app. Not valid without an '
                'authorized HR signature and company seal. Verify with '
                'hr@karmahr.com quoting the reference above.',
                style: const pw.TextStyle(fontSize: 8, color: _grey),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  return doc.save();
}

// ============================================================
// SHARED PIECES
// ============================================================
pw.Widget _letterhead() {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'KarmaHR Pvt. Ltd.',
        style: pw.TextStyle(
          fontSize: 20,
          fontWeight: pw.FontWeight.bold,
          color: _brandRed,
        ),
      ),
      pw.SizedBox(height: 2),
      pw.Text(
        'Kathmandu Head Office, Kathmandu, Nepal  |  hr@karmahr.com',
        style: const pw.TextStyle(fontSize: 9, color: _grey),
      ),
      pw.SizedBox(height: 8),
      pw.Container(height: 2, color: _brandRed),
    ],
  );
}

pw.Widget _keyValueGrid(List<(String, String)> rows) {
  return pw.Table(
    columnWidths: const {0: pw.FlexColumnWidth(1), 1: pw.FlexColumnWidth(2)},
    children: [
      for (final (label, value) in rows)
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 3),
              child: pw.Text(
                label,
                style: const pw.TextStyle(fontSize: 10, color: _grey),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 3),
              child: pw.Text(
                value,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
    ],
  );
}

pw.Widget _amountTable(
  String header,
  List<PdfLineItem> items,
  String totalLabel,
  double total,
) {
  pw.Widget cell(String text, {bool bold = false, bool right = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: pw.Text(
        text,
        textAlign: right ? pw.TextAlign.right : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  return pw.Table(
    border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
    columnWidths: const {0: pw.FlexColumnWidth(3), 1: pw.FlexColumnWidth(2)},
    children: [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: _lightGrey),
        children: [
          cell(header, bold: true),
          cell('AMOUNT', bold: true, right: true),
        ],
      ),
      for (final item in items)
        pw.TableRow(
          children: [
            cell(item.label),
            cell(formatRupees(item.amount), right: true),
          ],
        ),
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: _lightGrey),
        children: [
          cell(totalLabel, bold: true),
          cell(formatRupees(total), bold: true, right: true),
        ],
      ),
    ],
  );
}

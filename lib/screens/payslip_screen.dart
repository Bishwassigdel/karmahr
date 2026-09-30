// 1. IMPORT FLUTTER CUPERTINO
import 'package:flutter/cupertino.dart';

import '../data/current_employee.dart';
import '../domain/nepal/payroll_calculator.dart';
import '../domain/pdf_documents.dart';
import '../domain/nepal/tax_slabs.dart';
import 'apps/widgets/pdf_actions.dart';
import 'apps/widgets/refreshable_list_view.dart';
import 'apps/widgets/staggered_entrance.dart';

// 2. PAYSLIP LINE ITEM
//
// One row in the Earnings or Deductions breakdown.
class _LineItem {
  final String label;
  final double amount;

  const _LineItem(this.label, this.amount);
}

// 3. PAYSLIP MODEL
class _Payslip {
  final String month;
  final String payDate;
  final String status; // 'Paid' or 'Processing'
  final List<_LineItem> earnings;
  final List<_LineItem> deductions;

  const _Payslip({
    required this.month,
    required this.payDate,
    required this.status,
    required this.earnings,
    required this.deductions,
  });

  double get grossPay => earnings.fold(0, (sum, item) => sum + item.amount);

  double get totalDeductions =>
      deductions.fold(0, (sum, item) => sum + item.amount);

  double get netPay => grossPay - totalDeductions;
}

// 4. DEMO DATA — now computed from computePayroll() instead of hardcoded
// deduction numbers. Swap for a real backend feed later; only THIS
// function needs to change then, same pattern as calendar_data.dart.
//
// This employee's salary structure is assumed fixed below (no Profile/
// HR state holds a real one yet). festivalBonus is added to gross pay
// for display, but — NOTE(finance-review) — a one-time bonus is NOT
// re-annualized through computePayroll here, so the tax shown for a
// bonus month understates what would actually be withheld on it. Fine
// for a frontend demo, not for a real payslip.
List<_Payslip> _buildPayslips() {
  // From the shared profile, so the salary certificate PDF (which reads
  // the same object) can never state different figures than this.
  final basicSalary = currentEmployee.basicSalary;
  final dearnessAllowance = currentEmployee.dearnessAllowance;
  final transportAllowance = currentEmployee.transportAllowance;

  final payroll = computePayroll(
    PayrollInput(
      basicSalary: basicSalary,
      allowances: dearnessAllowance + transportAllowance,
      filingStatus: FilingStatus.single,
      fiscalStartYear: 2082,
      // This demo employee is on Provident Fund, not Social Security
      // Fund — a company is on one scheme or the other, never both, so
      // socialSecurityFundRate must be zeroed out here. Leaving it at
      // its 0.11 default would double-deduct both PF AND SSF on the
      // same salary. Flip these two lines instead if you want to demo
      // an SSF-scheme employee.
      providentFundRate: 0.10,
      socialSecurityFundRate: 0,
    ),
  );

  _Payslip payslipFor({
    required String month,
    required String payDate,
    required String status,
    double festivalBonus = 0,
  }) {
    return _Payslip(
      month: month,
      payDate: payDate,
      status: status,
      earnings: [
        _LineItem('Basic Salary', basicSalary),
        _LineItem('Dearness Allowance', dearnessAllowance),
        _LineItem('Transport Allowance', transportAllowance),
        if (festivalBonus > 0) _LineItem('Festival Bonus', festivalBonus),
      ],
      deductions: [
        _LineItem('Provident Fund (10%)', payroll.providentFundDeduction),
        _LineItem('Income Tax (TDS)', payroll.monthlyTax),
        if (payroll.socialSecurityFundDeduction > 0)
          _LineItem(
            'Social Security Fund',
            payroll.socialSecurityFundDeduction,
          ),
      ],
    );
  }

  return [
    payslipFor(
      month: 'September 2026',
      payDate: 'Oct 1, 2026',
      status: 'Processing',
    ),
    payslipFor(month: 'August 2026', payDate: 'Sep 1, 2026', status: 'Paid'),
    payslipFor(
      month: 'July 2026',
      payDate: 'Aug 1, 2026',
      status: 'Paid',
      festivalBonus: 15000,
    ),
    payslipFor(month: 'June 2026', payDate: 'Jul 1, 2026', status: 'Paid'),
  ];
}

final List<_Payslip> _payslips = _buildPayslips();

// 5. CURRENCY FORMAT
//
// Moved to data/current_employee.dart as formatRupees(), so the PDFs
// format money exactly the way this screen does.

// 6. PAYSLIP LIST SCREEN
class PayslipScreen extends StatelessWidget {
  const PayslipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // CupertinoDynamicColor values must be resolved against the current
    // context before use in a plain Container — otherwise they silently
    // always render their light-mode value, even in Dark Mode.
    final cardBackground = CupertinoColors.systemGrey6.resolveFrom(context);
    final subtleTextColor = CupertinoColors.systemGrey.resolveFrom(context);
    final paidColor = CupertinoColors.systemGreen.resolveFrom(context);
    final processingColor = CupertinoColors.systemOrange.resolveFrom(context);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Payslips')),
      child: SafeArea(
        child: RefreshableListView.builder(
          onRefresh: simulatedRefresh,
          padding: const EdgeInsets.all(16),
          itemCount: _payslips.length,
          itemBuilder: (context, index) {
            final payslip = _payslips[index];
            final statusColor = payslip.status == 'Paid'
                ? paidColor
                : processingColor;

            return StaggeredEntrance(
              index: index,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) =>
                          _PayslipDetailScreen(payslip: payslip),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBackground,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              payslip.month,
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatRupees(payslip.netPay),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                payslip.status,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        CupertinoIcons.chevron_right,
                        size: 18,
                        color: subtleTextColor,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// 7. PAYSLIP DETAIL SCREEN
class _PayslipDetailScreen extends StatelessWidget {
  final _Payslip payslip;

  const _PayslipDetailScreen({required this.payslip});

  @override
  Widget build(BuildContext context) {
    final subtleTextColor = CupertinoColors.systemGrey.resolveFrom(context);
    final karmaRed = CupertinoColors.systemRed.resolveFrom(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(payslip.month),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: () => showPdfActions(
            context,
            title: 'Payslip - ${payslip.month}',
            filename:
                'payslip-${payslip.month.toLowerCase().replaceAll(' ', '-')}.pdf',
            build: () => buildPayslipPdf(
              PayslipPdfData(
                month: payslip.month,
                payDate: payslip.payDate,
                status: payslip.status,
                earnings: [
                  for (final i in payslip.earnings)
                    PdfLineItem(i.label, i.amount),
                ],
                deductions: [
                  for (final i in payslip.deductions)
                    PdfLineItem(i.label, i.amount),
                ],
              ),
            ),
          ),
          child: const Icon(CupertinoIcons.share),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // NET PAY SUMMARY
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: karmaRed,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Net Pay',
                      style: TextStyle(
                        fontSize: 13,
                        color: CupertinoColors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatRupees(payslip.netPay),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pay date: ${payslip.payDate} · ${payslip.status}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // EARNINGS
            CupertinoListSection.insetGrouped(
              header: const Text('EARNINGS'),
              footer: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Gross Pay: ${formatRupees(payslip.grossPay)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: subtleTextColor,
                  ),
                ),
              ),
              children: payslip.earnings.map((item) {
                return CupertinoListTile(
                  title: Text(item.label),
                  trailing: Text(formatRupees(item.amount)),
                );
              }).toList(),
            ),

            // DEDUCTIONS
            CupertinoListSection.insetGrouped(
              header: const Text('DEDUCTIONS'),
              footer: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Total Deductions: ${formatRupees(payslip.totalDeductions)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: subtleTextColor,
                  ),
                ),
              ),
              children: payslip.deductions.map((item) {
                return CupertinoListTile(
                  title: Text(item.label),
                  trailing: Text(formatRupees(item.amount)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

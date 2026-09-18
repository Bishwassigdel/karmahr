// 1. IMPORT FLUTTER CUPERTINO
import 'package:flutter/cupertino.dart';

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

// 4. DEMO DATA
//
// Local/dummy data for now — swap for a real backend feed later.
const List<_Payslip> _payslips = [
  _Payslip(
    month: 'September 2026',
    payDate: 'Oct 1, 2026',
    status: 'Processing',
    earnings: [
      _LineItem('Basic Salary', 45000),
      _LineItem('Dearness Allowance', 4500),
      _LineItem('Transport Allowance', 3000),
    ],
    deductions: [
      _LineItem('Provident Fund (10%)', 4500),
      _LineItem('Income Tax (TDS)', 3200),
      _LineItem('Social Security Fund', 550),
    ],
  ),
  _Payslip(
    month: 'August 2026',
    payDate: 'Sep 1, 2026',
    status: 'Paid',
    earnings: [
      _LineItem('Basic Salary', 45000),
      _LineItem('Dearness Allowance', 4500),
      _LineItem('Transport Allowance', 3000),
    ],
    deductions: [
      _LineItem('Provident Fund (10%)', 4500),
      _LineItem('Income Tax (TDS)', 3200),
      _LineItem('Social Security Fund', 550),
    ],
  ),
  _Payslip(
    month: 'July 2026',
    payDate: 'Aug 1, 2026',
    status: 'Paid',
    earnings: [
      _LineItem('Basic Salary', 45000),
      _LineItem('Dearness Allowance', 4500),
      _LineItem('Transport Allowance', 3000),
      _LineItem('Festival Bonus', 15000),
    ],
    deductions: [
      _LineItem('Provident Fund (10%)', 4500),
      _LineItem('Income Tax (TDS)', 5100),
      _LineItem('Social Security Fund', 550),
    ],
  ),
  _Payslip(
    month: 'June 2026',
    payDate: 'Jul 1, 2026',
    status: 'Paid',
    earnings: [
      _LineItem('Basic Salary', 45000),
      _LineItem('Dearness Allowance', 4500),
      _LineItem('Transport Allowance', 3000),
    ],
    deductions: [
      _LineItem('Provident Fund (10%)', 4500),
      _LineItem('Income Tax (TDS)', 3200),
      _LineItem('Social Security Fund', 550),
    ],
  ),
];

// 5. CURRENCY FORMAT
//
// Simple thousand-separated "Rs. 45,000" formatting — no intl package
// needed for this.
String _formatCurrency(double amount) {
  final wholeNumber = amount.round().toString();
  final buffer = StringBuffer();

  for (var i = 0; i < wholeNumber.length; i++) {
    final positionFromEnd = wholeNumber.length - i;
    if (i != 0 && positionFromEnd % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(wholeNumber[i]);
  }

  return 'Rs. $buffer';
}

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
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _payslips.length,
          itemBuilder: (context, index) {
            final payslip = _payslips[index];
            final statusColor = payslip.status == 'Paid'
                ? paidColor
                : processingColor;

            return GestureDetector(
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
                            _formatCurrency(payslip.netPay),
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
      navigationBar: CupertinoNavigationBar(middle: Text(payslip.month)),
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
                      _formatCurrency(payslip.netPay),
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
                  'Gross Pay: ${_formatCurrency(payslip.grossPay)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: subtleTextColor,
                  ),
                ),
              ),
              children: payslip.earnings.map((item) {
                return CupertinoListTile(
                  title: Text(item.label),
                  trailing: Text(_formatCurrency(item.amount)),
                );
              }).toList(),
            ),

            // DEDUCTIONS
            CupertinoListSection.insetGrouped(
              header: const Text('DEDUCTIONS'),
              footer: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Total Deductions: ${_formatCurrency(payslip.totalDeductions)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: subtleTextColor,
                  ),
                ),
              ),
              children: payslip.deductions.map((item) {
                return CupertinoListTile(
                  title: Text(item.label),
                  trailing: Text(_formatCurrency(item.amount)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

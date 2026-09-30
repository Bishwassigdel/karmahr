// Tax Planner: "if I put Rs X a month into CIT / life insurance, how much
// tax do I save, and what's my take-home?" — live, as the sliders move.
//
// Uses the same computePayroll() engine as the payslip, so the planner's
// "today" number is exactly the payslip's number. Deduction caps are
// applied, and the screen says so when a slider passes one — otherwise it
// would promise savings that stop at the cap.

import 'package:flutter/cupertino.dart';

import '../data/current_employee.dart';
import '../domain/nepal/payroll_calculator.dart';
import '../domain/nepal/tax_slabs.dart';
import '../theme/app_colors.dart';
import 'apps/widgets/ui_kit.dart';

class TaxPlannerScreen extends StatefulWidget {
  const TaxPlannerScreen({super.key});

  @override
  State<TaxPlannerScreen> createState() => _TaxPlannerScreenState();
}

class _TaxPlannerScreenState extends State<TaxPlannerScreen> {
  static const _citMax = 30000.0;
  static const _insuranceMax = 6000.0;

  double _cit = 0;
  double _insurance = 0;
  FilingStatus _status = FilingStatus.single;

  PayrollResult _compute({required double cit, required double insurance}) {
    return computePayroll(
      PayrollInput(
        basicSalary: currentEmployee.basicSalary,
        allowances: currentEmployee.allowances,
        filingStatus: _status,
        fiscalStartYear: 2082,
        providentFundRate: 0.10,
        socialSecurityFundRate: 0,
        citContribution: cit,
        insurancePremium: insurance,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = _compute(cit: 0, insurance: 0);
    final planned = _compute(cit: _cit, insurance: _insurance);
    final monthlySaving = today.monthlyTax - planned.monthlyTax;
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);
    final green = CupertinoColors.systemGreen.resolveFrom(context);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Tax Planner')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // RESULT
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.karmaRed,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tax saved',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatRupees(monthlySaving)} / month',
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${formatRupees(monthlySaving * 12)} over the year',
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: 'Monthly TDS',
                    value: formatRupees(planned.monthlyTax),
                    was: formatRupees(today.monthlyTax),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniStat(
                    label: 'Take-home',
                    value: formatRupees(planned.netMonthly),
                    was: formatRupees(today.netMonthly),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // FILING STATUS
            SizedBox(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<FilingStatus>(
                groupValue: _status,
                children: const {
                  FilingStatus.single: Text('Single'),
                  FilingStatus.married: Text('Married (couple)'),
                },
                onValueChanged: (v) => setState(() => _status = v ?? _status),
              ),
            ),
            const SizedBox(height: 16),

            // SLIDERS
            SectionCard(
              title: 'CIT contribution',
              subtitle:
                  'Citizen Investment Trust — your own retirement '
                  'savings, deducted before tax.',
              child: _SliderRow(
                value: _cit,
                max: _citMax,
                divisions: 60,
                onChanged: (v) => setState(() => _cit = v),
                capNote: planned.retirementCapReached
                    ? 'Past the retirement deduction limit — anything above '
                          'this still goes to CIT but saves no more tax.'
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              title: 'Life insurance premium',
              subtitle: 'Monthly premium on a life policy in your name.',
              child: _SliderRow(
                value: _insurance,
                max: _insuranceMax,
                divisions: 24,
                onChanged: (v) => setState(() => _insurance = v),
                capNote: planned.insuranceCapReached
                    ? 'Past the insurance deduction limit — premium above '
                          'this saves no more tax.'
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'CIT isn\'t spent money: it\'s savings you get back later, '
              'moved out of your taxable income today.',
              style: TextStyle(fontSize: 12.5, color: green),
            ),
            const SizedBox(height: 12),
            const NoteBanner(
              icon: CupertinoIcons.info_circle,
              text:
                  'Estimates use placeholder tax slabs and deduction limits '
                  'pending finance review. Confirm with HR/finance before '
                  'changing your contributions.',
            ),
            const SizedBox(height: 8),
            Text(
              'Salary used: ${formatRupees(currentEmployee.grossMonthly)} gross '
              '/ month, PF 10% of basic.',
              style: TextStyle(fontSize: 11.5, color: subtle),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final String was;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.was,
  });

  @override
  Widget build(BuildContext context) {
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);
    return SectionCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: subtle)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
          Text('was $was', style: TextStyle(fontSize: 11, color: subtle)),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final double value;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final String? capNote;

  const _SliderRow({
    required this.value,
    required this.max,
    required this.divisions,
    required this.onChanged,
    this.capNote,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${formatRupees(value)} / month',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          width: double.infinity,
          child: CupertinoSlider(
            value: value,
            max: max,
            divisions: divisions,
            activeColor: AppColors.karmaRed,
            onChanged: onChanged,
          ),
        ),
        if (capNote != null)
          NoteBanner(
            icon: CupertinoIcons.exclamationmark_circle,
            text: capNote!,
          ),
      ],
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../data/company_demo.dart';
import '../../domain/owner_insights.dart';
import '../../l10n/l10n.dart';
import '../apps/widgets/ui_kit.dart';
import 'owner_widgets.dart';

/// Executive > Money: what payroll costs, how it has moved, and where it goes.
class OwnerMoneyScreen extends StatelessWidget {
  const OwnerMoneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.read<CompanyDemo>();
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);

    String money(double v) =>
        compactRupees(v, lakh: l10n.ownerLakh, crore: l10n.ownerCrore);

    final now = c.payrollAt(0);
    final change = percentChange(now, c.payrollAt(1));
    final people = c.headcountAt(0);
    final perHead = people == 0 ? 0.0 : now / people;

    // Where this month's payroll goes, biggest first.
    List<({String name, double amount})> split(
      Iterable<({String name, String id})> groups,
      double Function(String id) amountOf,
    ) =>
        [for (final g in groups) (name: g.name, amount: amountOf(g.id))]
          ..sort((a, b) => b.amount.compareTo(a.amount));

    final byDept = split([
      for (final d in c.depts) (name: d.name, id: d.id),
    ], (id) => c.payrollAt(0, deptId: id));
    final byBranch = split([
      for (final b in c.branches) (name: b.name, id: b.id),
    ], (id) => c.payrollAt(0, branchId: id));

    Widget bars(List<({String name, double amount})> rows) {
      final top = rows.isEmpty ? 1.0 : rows.first.amount;
      return Column(
        children: [
          for (final r in rows)
            PercentBar(
              label: r.name,
              value: top == 0 ? 0 : (r.amount * 100 / top).round(),
              valueText: money(r.amount),
            ),
        ],
      );
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.ownerKpiPayroll,
                    style: TextStyle(fontSize: 12.5, color: subtle),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      money(now),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (change != null)
                    Text(
                      l10n.ownerVsLastMonth('${change > 0 ? '+' : ''}$change%'),
                      style: TextStyle(fontSize: 12.5, color: subtle),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.ownerPerEmployee}: ${money(perHead)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SectionCard(
              title: l10n.ownerPayrollTrend,
              child: TrendChart(
                values: c.payrollSeries(),
                labels: [for (var m = 11; m >= 0; m--) c.monthLabel(m)],
                // Axis in crore, to two places: short enough to fit.
                format: (v) => (v / 10000000).toStringAsFixed(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: Text(
                l10n.ownerCrore,
                style: TextStyle(fontSize: 11.5, color: subtle),
              ),
            ),
            const SizedBox(height: 14),
            SectionCard(title: l10n.ownerByDepartment, child: bars(byDept)),
            const SizedBox(height: 14),
            SectionCard(title: l10n.ownerByBranch, child: bars(byBranch)),
            const SizedBox(height: 16),
            NoteBanner(
              icon: CupertinoIcons.info,
              text: l10n.ownerDemoBanner(c.people.length),
              color: CupertinoColors.systemGrey,
            ),
          ],
        ),
      ),
    );
  }
}

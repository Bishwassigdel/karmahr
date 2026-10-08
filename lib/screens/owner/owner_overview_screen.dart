import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../data/company_demo.dart';
import '../../domain/nepal/bs_dates.dart';
import '../../domain/owner_insights.dart';
import '../../l10n/l10n.dart';
import '../../state/employee_documents_state.dart';
import '../../state/hr_inbox_state.dart';
import '../../state/payroll_state.dart';
import '../../theme/app_colors.dart';
import '../apps/widgets/ui_kit.dart';
import 'owner_department_screen.dart';
import 'owner_nav_scope.dart';
import 'owner_people_screen.dart';
import 'owner_section.dart';
import 'owner_widgets.dart';

/// Executive > Overview: the headline numbers, then what needs attention, then
/// how each department is doing, worst first.
class OwnerOverviewScreen extends StatelessWidget {
  const OwnerOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.read<CompanyDemo>();
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);

    final all = c.progress();
    final payroll = c.payrollAt(0);
    final lastPayroll = c.payrollAt(1);
    final change = percentChange(payroll, lastPayroll);
    String money(double v) =>
        compactRupees(v, lakh: l10n.ownerLakh, crore: l10n.ownerCrore);

    // Departments, worst first. Small ones are left out of the ranking.
    final ranked =
        [for (final d in c.depts) (dept: d, p: c.progress(deptId: d.id))]
            .where((e) => largeEnoughToShow(e.p.headcount))
            .toList()
          ..sort((a, b) => a.p.score.compareTo(b.p.score));

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Kpi(
                    label: l10n.ownerKpiHeadcount,
                    value: '${all.headcount}',
                    note: l10n.ownerPlan(all.plan),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Kpi(
                    label: l10n.ownerKpiProgress,
                    value: '${all.score}',
                    valueColor: progressColor(all.status),
                    badge: ProgressBadge(all.status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Kpi(
                    label: l10n.ownerKpiAttendance,
                    value: '${all.attendance}%',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Kpi(
                    label: l10n.ownerKpiPayroll,
                    value: money(payroll),
                    note: change == null
                        ? null
                        : l10n.ownerVsLastMonth(
                            '${change > 0 ? '+' : ''}$change%',
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _Kpi(
              label: l10n.ownerKpiAttrition,
              value: '${c.attritionPercent().round()}%',
              note: l10n.ownerJoinedLeft(c.joinedLast(30), c.leftLast(30)),
            ),
            const SizedBox(height: 18),
            _Attention(company: c),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.ownerDeptProgress,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  onPressed: () => OwnerNavScope.openSection(
                    context,
                    OwnerSection.departments,
                  ),
                  child: Text(
                    l10n.ownerSeeAll,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            Text(
              l10n.ownerLowestFirst,
              style: TextStyle(fontSize: 12.5, color: subtle),
            ),
            const SizedBox(height: 6),
            SectionCard(
              child: Column(
                children: [
                  for (final e in ranked)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) =>
                              OwnerDepartmentScreen(deptId: e.dept.id),
                        ),
                      ),
                      child: PercentBar(
                        label: e.dept.name,
                        value: e.p.score,
                        valueText: '${e.p.score}',
                        color: progressColor(e.p.status),
                      ),
                    ),
                ],
              ),
            ),
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

class _Kpi extends StatelessWidget {
  final String label;
  final String value;
  final String? note;
  final Color? valueColor;
  final Widget? badge;

  const _Kpi({
    required this.label,
    required this.value,
    this.note,
    this.valueColor,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary.resolveFrom(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.5, color: subtle),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ),
          if (badge != null) ...[const SizedBox(height: 4), badge!],
          if (note != null) ...[
            const SizedBox(height: 4),
            Text(note!, style: TextStyle(fontSize: 12, color: subtle)),
          ],
        ],
      ),
    );
  }
}

/// What needs the executive's attention: the company's own signals first, then
/// the HR portal's live items (requests left waiting, documents, payroll).
class _Attention extends StatelessWidget {
  final CompanyDemo company;

  const _Attention({required this.company});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final nepali = Localizations.localeOf(context).languageCode == 'ne';

    final rows = <({IconData icon, String text, VoidCallback onTap})>[];

    for (final a in companyAttention(company)) {
      final text = switch (a.kind) {
        AttentionKind.deptBehind => l10n.ownerAttBehind(a.name, a.value),
        AttentionKind.deptAttrition => l10n.ownerAttAttrition(a.name, a.value),
        AttentionKind.deptShort => l10n.ownerAttShort(a.name, a.value),
        AttentionKind.branchAttendance => l10n.ownerAttAttendance(
          a.name,
          a.value,
        ),
      };
      rows.add((
        icon: a.kind == AttentionKind.branchAttendance
            ? CupertinoIcons.location_solid
            : CupertinoIcons.exclamationmark_triangle_fill,
        text: text,
        onTap: () => Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => a.kind == AttentionKind.branchAttendance
                ? OwnerPeoplePage(initialBranchId: a.id)
                : OwnerDepartmentScreen(deptId: a.id),
          ),
        ),
      ));
    }

    // The HR portal's live items.
    final pending = context.watch<HrInboxState>().pending;
    final now = DateTime.now(); // after the data, so ages never run early
    final waiting = pending
        .where((i) => now.difference(i.submittedAt).inDays >= 3)
        .length;
    if (waiting > 0) {
      rows.add((
        icon: CupertinoIcons.tray_full_fill,
        text: l10n.ownerAttRequests(waiting),
        onTap: () => OwnerNavScope.openSection(context, OwnerSection.activity),
      ));
    }
    final expiring = context
        .watch<EmployeeDocumentsState>()
        .expiringSoon()
        .length;
    if (expiring > 0) {
      rows.add((
        icon: CupertinoIcons.doc_text_fill,
        text: l10n.hrActionDocs(expiring),
        onTap: () => OwnerNavScope.openSection(context, OwnerSection.activity),
      ));
    }
    final today = bsToday();
    final payroll = context.watch<PayrollState>().runFor(
      today.year,
      today.month,
    );
    if (payroll == null || payroll.status == PayrollStatus.draft) {
      rows.add((
        icon: CupertinoIcons.money_dollar_circle_fill,
        text: l10n.hrActionPayroll(
          bsMonthLabel(today.year, today.month, nepali: nepali),
        ),
        onTap: () => OwnerNavScope.openSection(context, OwnerSection.money),
      ));
    }

    return SectionCard(
      title: l10n.ownerNeedsAttention,
      child: rows.isEmpty
          ? Row(
              children: [
                const Icon(
                  CupertinoIcons.check_mark_circled_solid,
                  color: CupertinoColors.activeGreen,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(l10n.ownerAllGood)),
              ],
            )
          : Column(
              children: [
                for (final r in rows)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: r.onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        children: [
                          Icon(r.icon, color: AppColors.karmaRed, size: 19),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              r.text,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const CupertinoListTileChevron(),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

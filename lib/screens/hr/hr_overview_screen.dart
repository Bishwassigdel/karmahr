import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../data/team_data.dart';
import '../../l10n/l10n.dart';
import '../../state/employee_records_state.dart';
import '../../theme/app_colors.dart';
import '../../domain/nepal/bs_dates.dart';
import '../../state/employee_documents_state.dart';
import '../../state/hr_inbox_state.dart';
import '../../state/payroll_state.dart';
import '../apps/widgets/ui_kit.dart';
import 'hr_bar_row.dart';
import 'hr_nav_scope.dart';
import 'hr_section.dart';

/// The HR portal's landing page: headcount at a glance.
///
/// Reads the demo employee directory and demo team leave. When the backend
/// exists these two reads become API calls; the layout doesn't change.
class HrOverviewScreen extends StatelessWidget {
  const HrOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final today = DateTime.now();
    final employees = context.watch<EmployeeRecordsState>().active;

    final outToday = demoTeamLeave().where((l) => l.coversDay(today)).toList();

    // department name -> number of employees
    final byDepartment = <String, int>{};
    for (final e in employees) {
      byDepartment[e.department] = (byDepartment[e.department] ?? 0) + 1;
    }
    final largest = byDepartment.values.fold<int>(1, (a, b) => a > b ? a : b);

    return Align(
      alignment: Alignment.topCenter,
      // Cap the width so the page stays readable on a wide monitor.
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const _NeedsActionCard(),
            const SizedBox(height: 16),
            _StatRow(
              stats: [
                _Stat(
                  icon: CupertinoIcons.person_2_fill,
                  value: '${employees.length}',
                  label: l10n.hrStatEmployees,
                ),
                _Stat(
                  icon: CupertinoIcons.building_2_fill,
                  value: '${byDepartment.length}',
                  label: l10n.hrStatDepartments,
                ),
                _Stat(
                  icon: CupertinoIcons.airplane,
                  value: '${outToday.length}',
                  label: l10n.hrStatOutToday,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: l10n.hrByDepartment,
              child: Column(
                children: [
                  for (final entry in byDepartment.entries)
                    HrBarRow(
                      name: entry.key,
                      count: entry.value,
                      fraction: entry.value / largest,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _PeopleEventsCard(today: today),
            const SizedBox(height: 16),
            _NewJoinersCard(today: today, employees: employees),
            const SizedBox(height: 16),
            SectionCard(
              title: l10n.hrStatOutToday,
              child: outToday.isEmpty
                  ? Text(
                      l10n.hrNobodyOut,
                      style: TextStyle(
                        fontSize: 13,
                        color: CupertinoColors.systemGrey.resolveFrom(context),
                      ),
                    )
                  : Column(
                      children: [
                        for (final leave in outToday)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                InitialsAvatar(
                                  initials: leave.initials,
                                  size: 34,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    leave.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    leave.leaveType,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: CupertinoColors.systemGrey
                                          .resolveFrom(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            NoteBanner(
              icon: CupertinoIcons.info,
              text: l10n.hrDemoDataNote,
              color: CupertinoColors.systemGrey,
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat {
  final IconData icon;
  final String value;
  final String label;

  const _Stat({required this.icon, required this.value, required this.label});
}

/// Stat cards side by side: three across when there's room, otherwise they
/// wrap onto a second row.
class _StatRow extends StatelessWidget {
  final List<_Stat> stats;

  const _StatRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final columns = constraints.maxWidth >= 560 ? stats.length : 2;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final stat in stats)
              SizedBox(width: width, child: _StatCard(stat)),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final _Stat stat;

  const _StatCard(this.stat);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary.resolveFrom(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(stat.icon, size: 22, color: AppColors.karmaRed),
          const SizedBox(height: 10),
          Text(
            stat.value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            stat.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: CupertinoColors.systemGrey.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// Birthdays and work anniversaries in the next 30 days.
class _PeopleEventsCard extends StatelessWidget {
  final DateTime today;

  const _PeopleEventsCard({required this.today});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(const Duration(days: 30));

    final events =
        demoCelebrations()
            .where((c) => !c.date.isBefore(start) && !c.date.isAfter(end))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    return SectionCard(
      title: l10n.hrPeopleEvents,
      child: events.isEmpty
          ? Text(
              l10n.hrNoPeopleEvents,
              style: TextStyle(fontSize: 13, color: subtle),
            )
          : Column(
              children: [
                for (final event in events)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        InitialsAvatar(initials: event.initials, size: 34),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                event.kind == CelebrationKind.birthday
                                    ? l10n.hrBirthday
                                    : l10n.hrAnniversary(event.years ?? 0),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12, color: subtle),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          shortDate(event.date),
                          style: TextStyle(fontSize: 12, color: subtle),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

/// People who joined in the last 30 days, newest first.
class _NewJoinersCard extends StatelessWidget {
  final DateTime today;
  final List<EmployeeRecord> employees;

  const _NewJoinersCard({required this.today, required this.employees});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);
    final todayOnly = DateTime(today.year, today.month, today.day);
    final since = todayOnly.subtract(const Duration(days: 30));

    final joiners =
        employees
            .where(
              (e) =>
                  !e.joiningDate.isBefore(since) &&
                  !e.joiningDate.isAfter(todayOnly),
            )
            .toList()
          ..sort((a, b) => b.joiningDate.compareTo(a.joiningDate));

    return SectionCard(
      title: l10n.hrNewJoiners,
      child: joiners.isEmpty
          ? Text(
              l10n.hrNoNewJoiners,
              style: TextStyle(fontSize: 13, color: subtle),
            )
          : Column(
              children: [
                for (final e in joiners)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        InitialsAvatar(initials: e.initials, size: 34),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${e.jobTitle} · ${e.department}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12, color: subtle),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          shortDate(e.joiningDate),
                          style: TextStyle(fontSize: 12, color: subtle),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

/// What needs HR's attention today; each row opens the place to do it.
class _NeedsActionCard extends StatelessWidget {
  const _NeedsActionCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final nepali = Localizations.localeOf(context).languageCode == 'ne';
    final pending = context.watch<HrInboxState>().pendingCount;

    // This BS month's payroll: nothing to do once it is approved or paid.
    final today = bsToday();
    final payroll = context.watch<PayrollState>().runFor(
      today.year,
      today.month,
    );
    final payrollOpen =
        payroll == null || payroll.status == PayrollStatus.draft;

    final expiring = context
        .watch<EmployeeDocumentsState>()
        .expiringSoon()
        .length;

    final rows = <_ActionRow>[
      if (pending > 0)
        _ActionRow(
          icon: CupertinoIcons.tray_full_fill,
          text: l10n.hrActionApprovals(pending),
          section: HrSection.leave,
        ),
      if (expiring > 0)
        _ActionRow(
          icon: CupertinoIcons.doc_text_fill,
          text: l10n.hrActionDocs(expiring),
          section: HrSection.employees,
        ),
      if (payrollOpen)
        _ActionRow(
          icon: CupertinoIcons.money_dollar_circle_fill,
          text: l10n.hrActionPayroll(
            bsMonthLabel(today.year, today.month, nepali: nepali),
          ),
          section: HrSection.payroll,
        ),
    ];

    return SectionCard(
      title: l10n.hrNeedsAction,
      child: rows.isEmpty
          ? Row(
              children: [
                const Icon(
                  CupertinoIcons.check_mark_circled_solid,
                  color: CupertinoColors.activeGreen,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(l10n.hrAllClear)),
              ],
            )
          : Column(
              children: [
                for (final row in rows)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => HrNavScope.openSection(context, row.section),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(row.icon, color: AppColors.karmaRed, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              row.text,
                              style: const TextStyle(
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

class _ActionRow {
  final IconData icon;
  final String text;
  final HrSection section;

  const _ActionRow({
    required this.icon,
    required this.text,
    required this.section,
  });
}

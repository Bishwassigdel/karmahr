import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../data/company_demo.dart';
import '../../domain/owner_insights.dart';
import '../../l10n/l10n.dart';
import '../../theme/app_colors.dart';
import '../apps/widgets/ui_kit.dart';
import 'owner_department_screen.dart';
import 'owner_widgets.dart';

/// CEO > Departments: every department's progress, worst first, filterable
/// by branch.
class OwnerDepartmentsScreen extends StatefulWidget {
  const OwnerDepartmentsScreen({super.key});

  @override
  State<OwnerDepartmentsScreen> createState() => _OwnerDepartmentsScreenState();
}

class _OwnerDepartmentsScreenState extends State<OwnerDepartmentsScreen> {
  /// null = every branch.
  String? _branchId;

  void _explain() {
    final l10n = context.l10n;
    showMessage(
      context,
      title: l10n.ownerHowCalculated,
      message: l10n.ownerFormulaBody(
        (Progress.goalsWeight * 100).round(),
        (Progress.reviewsWeight * 100).round(),
        (Progress.trainingWeight * 100).round(),
        (Progress.attendanceWeight * 100).round(),
        minGroupForStats,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.read<CompanyDemo>();
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);

    final rows = [
      for (final d in c.depts)
        (dept: d, p: c.progress(deptId: d.id, branchId: _branchId)),
    ];
    // Worst first; slices too small to show go to the end.
    rows.sort((a, b) {
      final aShown = largeEnoughToShow(a.p.headcount);
      final bShown = largeEnoughToShow(b.p.headcount);
      if (aShown != bShown) return aShown ? -1 : 1;
      return a.p.score.compareTo(b.p.score);
    });

    Widget chip(String label, String? id) {
      final selected = _branchId == id;
      return GestureDetector(
        onTap: () => setState(() => _branchId = id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.karmaRed
                : CupertinoColors.systemGrey5.resolveFrom(context),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected
                  ? CupertinoColors.white
                  : AppColors.textPrimary.resolveFrom(context),
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                chip(l10n.filterAll, null),
                for (final b in c.branches) chip(b.name, b.id),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.ownerLowestFirst,
              style: TextStyle(fontSize: 12.5, color: subtle),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 4),
                minimumSize: Size.zero,
                onPressed: _explain,
                child: Text(
                  l10n.ownerHowCalculated,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 4),
            for (final e in rows)
              _DepartmentCard(
                name: e.dept.name,
                progress: e.p,
                onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => OwnerDepartmentScreen(
                      deptId: e.dept.id,
                      branchId: _branchId,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DepartmentCard extends StatelessWidget {
  final String name;
  final Progress progress;
  final VoidCallback onTap;

  const _DepartmentCard({
    required this.name,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);
    final shown = largeEnoughToShow(progress.headcount);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary.resolveFrom(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (shown) ProgressBadge(progress.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              shown
                  ? l10n.ownerHeadcountOfPlan(progress.headcount, progress.plan)
                  : l10n.ownerFewPeople(minGroupForStats),
              style: TextStyle(fontSize: 12.5, color: subtle),
            ),
            if (shown)
              PercentBar(
                label: l10n.ownerKpiProgress,
                value: progress.score,
                valueText: '${progress.score}',
                color: progressColor(progress.status),
              ),
          ],
        ),
      ),
    );
  }
}

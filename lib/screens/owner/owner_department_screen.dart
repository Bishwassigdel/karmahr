import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../data/company_demo.dart';
import '../../domain/owner_insights.dart';
import '../../l10n/l10n.dart';
import '../../theme/app_colors.dart';
import '../apps/widgets/ui_kit.dart';
import 'owner_people_screen.dart';
import 'owner_widgets.dart';

/// One department (optionally within one branch): its score, the four
/// things the score is made of, how headcount has moved, and the branch
/// split. Groups too small to show give no figures.
class OwnerDepartmentScreen extends StatelessWidget {
  final String deptId;

  /// When set, every number is for that branch's part of the department.
  final String? branchId;

  const OwnerDepartmentScreen({super.key, required this.deptId, this.branchId});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.read<CompanyDemo>();
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);
    final dept = c.deptById(deptId);
    final branch = branchId == null ? null : c.branchById(branchId!);
    final p = c.progress(deptId: deptId, branchId: branchId);
    final shown = largeEnoughToShow(p.headcount);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          branch == null ? dept.name : '${dept.name} · ${branch.name}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (!shown)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.ownerFewPeople(minGroupForStats),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: subtle),
                    ),
                  )
                else ...[
                  SectionCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.ownerKpiProgress,
                                style: TextStyle(fontSize: 12.5, color: subtle),
                              ),
                              Text(
                                '${p.score}',
                                style: TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                  color: progressColor(p.status),
                                ),
                              ),
                              Text(
                                l10n.ownerHeadcountOfPlan(p.headcount, p.plan),
                                style: TextStyle(fontSize: 12.5, color: subtle),
                              ),
                            ],
                          ),
                        ),
                        ProgressBadge(p.status),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SectionCard(
                    child: Column(
                      children: [
                        PercentBar(
                          label: l10n.ownerMetricGoals,
                          value: p.goals,
                        ),
                        PercentBar(
                          label: l10n.ownerMetricReviews,
                          value: p.reviews,
                        ),
                        PercentBar(
                          label: l10n.ownerMetricTraining,
                          value: p.training,
                        ),
                        PercentBar(
                          label: l10n.ownerKpiAttendance,
                          value: p.attendance,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SectionCard(
                    title: l10n.ownerTrend12,
                    child: TrendChart(
                      values: [
                        for (final v in c.headcountSeries(
                          deptId: deptId,
                          branchId: branchId,
                        ))
                          v.toDouble(),
                      ],
                      labels: [for (var m = 11; m >= 0; m--) c.monthLabel(m)],
                      format: (v) => v.round().toString(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.ownerKpiAttrition}: '
                          '${l10n.ownerAttritionValue(c.attritionPercent(deptId: deptId, branchId: branchId).round())}',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.ownerJoinedLast90(
                            c.joinedLast(
                              90,
                              deptId: deptId,
                              branchId: branchId,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (branchId == null) ...[
                    const SizedBox(height: 14),
                    SectionCard(
                      title: l10n.ownerByBranch,
                      child: Column(
                        children: [
                          for (final b in c.branches)
                            _BranchRow(
                              name: b.name,
                              progress: c.progress(
                                deptId: deptId,
                                branchId: b.id,
                              ),
                              onTap: () => Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) => OwnerDepartmentScreen(
                                    deptId: deptId,
                                    branchId: b.id,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  CupertinoButton.filled(
                    onPressed: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => OwnerPeoplePage(
                          initialDeptId: deptId,
                          initialBranchId: branchId,
                        ),
                      ),
                    ),
                    child: Text(l10n.ownerViewPeople),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BranchRow extends StatelessWidget {
  final String name;
  final Progress progress;
  final VoidCallback onTap;

  const _BranchRow({
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
      onTap: shown ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    shown
                        ? l10n.ownerHeadcountOfPlan(
                            progress.headcount,
                            progress.plan,
                          )
                        : l10n.ownerFewPeople(minGroupForStats),
                    style: TextStyle(fontSize: 12.5, color: subtle),
                  ),
                ],
              ),
            ),
            if (shown) ...[
              Text(
                '${progress.score}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: progressColor(progress.status),
                ),
              ),
              const SizedBox(width: 6),
              const CupertinoListTileChevron(),
            ] else
              Icon(CupertinoIcons.lock, size: 16, color: AppColors.karmaRed),
          ],
        ),
      ),
    );
  }
}

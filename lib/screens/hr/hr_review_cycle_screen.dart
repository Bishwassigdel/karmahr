import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../state/employee_records_state.dart';
import '../../state/reviews_state.dart';
import '../../theme/app_colors.dart';
import '../apps/widgets/status_badge.dart';
import '../apps/widgets/ui_kit.dart';

String reviewStageLabel(AppLocalizations l10n, ReviewStage s) => switch (s) {
  ReviewStage.notStarted => l10n.hrStageNotStarted,
  ReviewStage.selfDone => l10n.hrStageSelf,
  ReviewStage.managerDone => l10n.hrStageManager,
  ReviewStage.completed => l10n.hrStageCompleted,
};

Color reviewStageColor(ReviewStage s) => switch (s) {
  ReviewStage.notStarted => CupertinoColors.systemGrey,
  ReviewStage.selfDone => CupertinoColors.systemOrange,
  ReviewStage.managerDone => CupertinoColors.systemBlue,
  ReviewStage.completed => CupertinoColors.activeGreen,
};

/// One review cycle: every person and the step they are at.
class HrReviewCycleScreen extends StatelessWidget {
  final String cycleId;

  const HrReviewCycleScreen({super.key, required this.cycleId});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);
    final cycle = context.watch<ReviewsState>().byId(cycleId);
    final records = context.watch<EmployeeRecordsState>();

    if (cycle == null) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(),
        child: Center(child: Text(l10n.hrReviewNoCycles)),
      );
    }

    // Furthest behind first: the people HR may need to chase.
    final people = cycle.stages.entries.toList()
      ..sort((a, b) {
        final byStage = a.value.index - b.value.index;
        if (byStage != 0) return byStage;
        final an = records.byId(a.key)?.name ?? a.key;
        final bn = records.byId(b.key)?.name ?? b.key;
        return an.compareTo(bn);
      });

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(cycle.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    l10n.hrReviewProgress(cycle.completed, cycle.total),
                    style: TextStyle(fontSize: 13, color: subtle),
                  ),
                ),
                CupertinoListSection.insetGrouped(
                  children: [
                    for (final entry in people)
                      Builder(
                        builder: (context) {
                          final r = records.byId(entry.key);
                          final stage = entry.value;
                          return CupertinoListTile(
                            leading: InitialsAvatar(
                              initials: r?.initials ?? '?',
                              size: 34,
                            ),
                            leadingSize: 34,
                            title: Text(
                              r?.name ?? entry.key,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: StatusBadge(
                                    label: reviewStageLabel(l10n, stage),
                                    color: reviewStageColor(stage),
                                  ),
                                ),
                              ),
                            ),
                            trailing: stage == ReviewStage.completed
                                ? null
                                : CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    onPressed: () => context
                                        .read<ReviewsState>()
                                        .advance(cycle.id, entry.key),
                                    child: Text(
                                      l10n.hrReviewAdvance,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        color: AppColors.karmaRed,
                                      ),
                                    ),
                                  ),
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

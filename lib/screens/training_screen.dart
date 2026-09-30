// Training & certifications: assigned courses with due dates, overdue
// flags, start/complete actions, and a shelf of earned badges.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../state/notification_state.dart';
import '../state/training_state.dart';
import '../theme/app_colors.dart';
import 'apps/widgets/ui_kit.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TrainingState>();
    final now = DateTime.now();
    final active =
        state.courses
            .where((c) => c.status != TrainingStatus.completed)
            .toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final done = state.completed;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Training')),
      child: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: SectionCard(
                title: 'Badges earned',
                child: done.isEmpty
                    ? const Text('Complete a course to earn your first badge.')
                    : Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          for (final c in done)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  c.badge,
                                  style: const TextStyle(fontSize: 30),
                                ),
                                SizedBox(
                                  width: 72,
                                  child: Text(
                                    c.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 10.5),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
              ),
            ),
            CupertinoListSection.insetGrouped(
              header: const Text('ASSIGNED TO YOU'),
              children: active.isEmpty
                  ? const [
                      CupertinoListTile(
                        title: Text("You're all caught up. 🎓"),
                      ),
                    ]
                  : [for (final c in active) _CourseTile(course: c, now: now)],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _CourseTile extends StatelessWidget {
  final TrainingCourse course;
  final DateTime now;

  const _CourseTile({required this.course, required this.now});

  @override
  Widget build(BuildContext context) {
    final overdue = course.isOverdue(now);
    final red = CupertinoColors.systemRed.resolveFrom(context);
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);

    return CupertinoListTile(
      leading: Text(course.badge, style: const TextStyle(fontSize: 24)),
      title: Text(course.title),
      subtitle: Text(
        '${course.mandatory ? 'Mandatory · ' : ''}${course.durationMinutes} min · '
        '${trainingStatusLabel(course.status)}',
      ),
      additionalInfo: TileInfo(
        overdue ? 'Overdue' : 'Due ${shortDate(course.dueDate)}',
        style: TextStyle(
          color: overdue ? red : subtle,
          fontWeight: overdue ? FontWeight.w600 : null,
        ),
      ),
      onTap: () => _open(context),
    );
  }

  void _open(BuildContext context) {
    final state = context.read<TrainingState>();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: Text(course.title),
        message: Text(
          '${course.provider} · ${course.durationMinutes} minutes\n'
          'Due ${dayDate(course.dueDate)}'
          '${course.mandatory ? ' · Mandatory' : ''}',
        ),
        actions: [
          if (course.status == TrainingStatus.notStarted)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(sheetContext);
                state.start(course);
              },
              child: const Text('Start Course'),
            ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(sheetContext);
              state.complete(course);
              notifyUser(
                context,
                kind: AppNotificationKind.system,
                title: 'Badge earned ${course.badge}',
                body: 'You completed "${course.title}".',
              );
            },
            child: const Text(
              'Mark as Completed',
              style: TextStyle(color: AppColors.karmaRed),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(sheetContext),
          child: const Text('Close'),
        ),
      ),
    );
  }
}

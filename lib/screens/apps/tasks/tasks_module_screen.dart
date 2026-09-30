import 'package:flutter/cupertino.dart';

import '../../../theme/app_colors.dart';
import '../widgets/async_state_view.dart';
import '../widgets/refreshable_list_view.dart';
import '../widgets/skeleton.dart';
import '../widgets/progress_bar.dart';
import '../widgets/stat_tile.dart';
import '../widgets/status_badge.dart';
import 'task_models.dart';

class TasksModuleScreen extends StatefulWidget {
  const TasksModuleScreen({super.key});

  @override
  State<TasksModuleScreen> createState() => _TasksModuleScreenState();
}

class _TasksModuleScreenState extends State<TasksModuleScreen> {
  LoadState _loadState = LoadState.loading;
  List<TaskItem> _tasks = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  // showSkeleton: false on pull-to-refresh — the pull spinner already
  // says "loading", so the existing list stays on screen until the new
  // data lands instead of flashing back to skeleton cards.
  Future<void> _load({bool showSkeleton = true}) async {
    if (showSkeleton) setState(() => _loadState = LoadState.loading);

    try {
      final tasks = await fetchMyTasks();
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
        _loadState = tasks.isEmpty ? LoadState.empty : LoadState.ready;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadState = LoadState.error);
    }
  }

  String _formatDueDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  void _showTaskDetails(TaskItem task) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: Text(
            task.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          message: Text(
            '${task.description}\n\n'
            'Status: ${taskStatusLabel(task.status)}\n'
            'Priority: ${taskPriorityLabel(task.priority)}\n'
            'Due: ${_formatDueDate(task.dueDate)}\n'
            'Progress: ${(task.progress * 100).round()}%',
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surface.resolveFrom(context);
    final surfaceSecondary = AppColors.surfaceSecondary.resolveFrom(context);
    final border = AppColors.border.resolveFrom(context);
    final subtleTextColor = CupertinoColors.systemGrey.resolveFrom(context);
    final redColor = CupertinoColors.systemRed.resolveFrom(context);

    // CupertinoDynamicColor values must be resolved against the
    // current context before use in a plain Container/Text.
    final pendingColor = taskStatusColor(TaskStatus.pending)
        .resolveFrom(context);
    final inProgressColor = taskStatusColor(TaskStatus.inProgress)
        .resolveFrom(context);
    final completedColor = taskStatusColor(TaskStatus.completed)
        .resolveFrom(context);

    final pendingCount = _tasks
        .where((t) => t.status == TaskStatus.pending)
        .length;
    final inProgressCount = _tasks
        .where((t) => t.status == TaskStatus.inProgress)
        .length;
    final completedCount = _tasks
        .where((t) => t.status == TaskStatus.completed)
        .length;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Tasks')),
      child: SafeArea(
        child: RefreshableListView(
          onRefresh: () => _load(showSkeleton: false),
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'My Tasks',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'Pending',
                    count: pendingCount,
                    color: pendingColor,
                    background: surfaceSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatTile(
                    label: 'In Progress',
                    count: inProgressCount,
                    color: inProgressColor,
                    background: surfaceSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatTile(
                    label: 'Completed',
                    count: completedCount,
                    color: completedColor,
                    background: surfaceSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Task List',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            AsyncStateView(
              state: _loadState,
              emptyMessage: 'No tasks assigned to you right now.',
              errorMessage: "Couldn't load your tasks.",
              onRetry: _load,
              loadingPlaceholder: const SkeletonList(itemHeight: 92),
              child: Column(
                children: _tasks.map((task) {
                  final isOverdue =
                      task.status != TaskStatus.completed &&
                      task.dueDate.isBefore(DateTime.now());
                  final statusColor = taskStatusColor(task.status)
                      .resolveFrom(context);
                  final priorityColor = taskPriorityColor(task.priority)
                      .resolveFrom(context);

                  return GestureDetector(
                    onTap: () => _showTaskDetails(task),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              // Badges wrap to a second line, and the due
                              // date truncates, instead of the row running
                              // off the card at large text sizes.
                              Expanded(
                                child: Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    StatusBadge(
                                      label: taskStatusLabel(task.status),
                                      color: statusColor,
                                    ),
                                    StatusBadge(
                                      label: taskPriorityLabel(task.priority),
                                      color: priorityColor,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                  isOverdue
                                      ? 'Overdue · ${_formatDueDate(task.dueDate)}'
                                      : 'Due ${_formatDueDate(task.dueDate)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isOverdue
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: isOverdue
                                        ? redColor
                                        : subtleTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ProgressBar(
                            progress: task.progress,
                            color: statusColor,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(task.progress * 100).round()}% complete',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: subtleTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

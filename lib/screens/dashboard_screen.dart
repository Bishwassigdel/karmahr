import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'profile_screen.dart';
import 'leave_screen.dart';
import 'apps/attendance/attendance_module_screen.dart';
import 'apps/tasks/task_models.dart';
import 'apps/tasks/tasks_module_screen.dart';
import 'apps/widgets/progress_bar.dart';
import 'apps/widgets/status_badge.dart';
import 'notices_screen.dart';
import 'settings_screen.dart';
import 'welcome_screen.dart';
import '../state/attendance_state.dart';
import '../theme/app_colors.dart';

// Back to StatelessWidget — this screen no longer holds its own
// check-in state. That now lives in AttendanceState (shared via
// Provider), so both Dashboard and the Attendance tab always agree.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // ============================================================
  // MENU (replaces Material's Drawer — Cupertino has no drawer widget)
  // ============================================================
  void _showMenu(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Bishwas Sigdel'),
        message: const Text('Staff ID: MB-24071'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: const Text('Profile'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            child: const Text('Settings'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context); // close the action sheet first
              _confirmLogout(context);
            },
            child: const Text('Logout'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  // ============================================================
  // LOGOUT CONFIRMATION
  // ============================================================
  //
  // A second confirmation before actually logging out — CupertinoAlertDialog
  // is the standard iOS pattern for "are you sure?" moments, distinct from
  // the CupertinoActionSheet used for the menu itself.
  void _confirmLogout(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              // rootNavigator: true reaches past this tab's own Navigator
              // (from CupertinoTabView) to the app's top-level Navigator —
              // otherwise this would only pop within the Home tab's stack,
              // not actually leave the tabbed section at all.
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                CupertinoPageRoute(builder: (context) => const WelcomeScreen()),
                (route) => false, // clears the entire navigation history
              );
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MAIN BUILD METHOD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    const karmaRed = AppColors.karmaRed;

    // CupertinoDynamicColor must be resolved against the current context
    // before use in plain widgets (Container, BoxDecoration) — otherwise
    // it silently always renders its light-mode value, even in Dark Mode.
    final surface = AppColors.surface.resolveFrom(context);
    final surfaceSecondary = AppColors.surfaceSecondary.resolveFrom(context);
    final border = AppColors.border.resolveFrom(context);

    // context.watch<AttendanceState>() = "give me the shared object, and
    // rebuild this widget automatically whenever it calls notifyListeners()."
    final attendance = context.watch<AttendanceState>();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('KarmaHR'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: () => _showMenu(context),
          child: const Icon(CupertinoIcons.line_horizontal_3),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(builder: (context) => const NoticesScreen()),
            );
          },
          child: const Icon(CupertinoIcons.bell),
        ),
      ),

      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================
              // GREETING
              // ============================================
              const Text(
                'Good Morning, Bishwas 👋',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Monday, September 9',
                style: TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 20),

              // ============================================
              // ATTENDANCE CARD — now reads from AttendanceState
              // ============================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Attendance',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          attendance.isCheckedIn
                              ? attendance.checkInTime!
                              : '--:-- --',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              attendance.isCheckedIn
                                  ? 'Checked In'
                                  : 'Not Checked In',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color.fromARGB(255, 142, 142, 231),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              attendance.isCheckedIn
                                  ? CupertinoIcons.check_mark_circled_solid
                                  : CupertinoIcons.circle,
                              color: attendance.isCheckedIn
                                  ? CupertinoColors.systemGreen
                                  : CupertinoColors.systemGrey,
                              size: 18,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Button now mirrors the same one-way-per-day logic as
                    // the Attendance screen: Check In once, then Check Out
                    // once, then disabled — matching, not just the data.
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: attendance.isCheckedOut
                            ? CupertinoColors.systemGrey
                            : karmaRed,
                        borderRadius: BorderRadius.circular(10),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        onPressed: attendance.isCheckedOut
                            ? null
                            : () {
                                // context.read (not watch) inside a callback —
                                // we're calling a method, not rebuilding here.
                                if (attendance.isCheckedIn) {
                                  context.read<AttendanceState>().checkOut();
                                } else {
                                  context.read<AttendanceState>().checkIn();
                                }
                              },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              attendance.isCheckedIn
                                  ? CupertinoIcons.arrow_left_circle
                                  : CupertinoIcons.arrow_right_circle,
                              size: 16,
                              color: CupertinoColors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              attendance.isCheckedOut
                                  ? 'Checked Out'
                                  : attendance.isCheckedIn
                                  ? 'Check Out'
                                  : 'Check In',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ============================================
              // LEAVE / WORK HOURS
              // ============================================
              Row(
                children: [
                  Expanded(
                    child: _statCard('Leave', '12 Days', surfaceSecondary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard('Work Hours', '7h 32m', surfaceSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ============================================
              // QUICK ACTIONS
              // ============================================
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _actionTile(
                      icon: CupertinoIcons.doc_text,
                      label: 'Apply Leave',
                      karmaRed: karmaRed,
                      surface: surface,
                      border: border,
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const LeaveScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _actionTile(
                      icon: CupertinoIcons.time,
                      label: 'Attendance',
                      karmaRed: karmaRed,
                      surface: surface,
                      border: border,
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const AttendanceModuleScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ============================================
              // IMPORTANT TASKS — high-priority or overdue tasks,
              // pulled from the exact same dummy data source the Tasks
              // module uses (fetchMyTasks), so the two screens can
              // never show conflicting info.
              // ============================================
              FutureBuilder<List<TaskItem>>(
                future: fetchMyTasks(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final importantTasks =
                      snapshot.data!
                          .where(
                            (task) =>
                                task.status != TaskStatus.completed &&
                                (task.priority == TaskPriority.high ||
                                    task.dueDate.isBefore(DateTime.now())),
                          )
                          .toList()
                        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

                  // Nothing urgent — don't clutter the dashboard with an
                  // empty section.
                  if (importantTasks.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final topTasks = importantTasks.take(2).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Important Tasks',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) =>
                                      const TasksModuleScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'View All',
                              style: TextStyle(fontSize: 13, color: karmaRed),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...topTasks.map(
                        (task) =>
                            _importantTaskCard(context, task, surface, border),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),

              // ============================================
              // TODAY'S EVENTS
              // ============================================
              const Text(
                "Today's Events",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(height: 1, color: border),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Team Meeting', style: TextStyle(fontSize: 14)),
                  Text(
                    '10:00 AM',
                    style: TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, Color surfaceSecondary) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceSecondary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String label,
    required Color karmaRed,
    required Color surface,
    required Color border,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            Icon(icon, color: karmaRed, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Compact preview card for one important task — tapping any of these
  // goes straight to the full Tasks module rather than duplicating the
  // detail sheet here.
  Widget _importantTaskCard(
    BuildContext context,
    TaskItem task,
    Color surface,
    Color border,
  ) {
    final isOverdue = task.dueDate.isBefore(DateTime.now());
    final statusColor = taskStatusColor(task.status).resolveFrom(context);
    final priorityColor = taskPriorityColor(task.priority).resolveFrom(context);
    final subtleTextColor = CupertinoColors.systemGrey.resolveFrom(context);
    final redColor = CupertinoColors.systemRed.resolveFrom(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => const TasksModuleScreen()),
        );
      },
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
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                StatusBadge(
                  label: taskPriorityLabel(task.priority),
                  color: priorityColor,
                ),
                const Spacer(),
                Text(
                  isOverdue
                      ? 'Overdue · ${_formatDueDate(task.dueDate)}'
                      : 'Due ${_formatDueDate(task.dueDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isOverdue ? redColor : subtleTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ProgressBar(progress: task.progress, color: statusColor),
          ],
        ),
      ),
    );
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
}

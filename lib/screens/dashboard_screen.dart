// The employee's home screen. Ordered by urgency, top to bottom:
//   1. Safety alert (only during an alert — it must never be scrolled past)
//   2. Greeting + today (AD and BS dates)
//   3. Attendance — the one thing everyone does every day
//   4. Leave left + hours today, and quick actions
//   5. Who's out today
//   6. Weekly pulse (until answered)
//   7. "Needs your attention" — overdue training, pending requests...
//   8. Dashain countdown + estimated festival bonus (in season)
//   9. Important tasks, and what's happening today
// Every section that can be empty hides itself instead of showing a
// blank box, so the dashboard stays short on a quiet day.

import 'package:flutter/cupertino.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import 'logout.dart';
import 'apps/attendance/attendance_module_screen.dart';
import 'apps/tasks/task_models.dart';
import 'apps/tasks/tasks_module_screen.dart';
import 'apps/widgets/progress_bar.dart';
import 'apps/widgets/status_badge.dart';
import 'apps/widgets/ui_kit.dart';
import 'expense_claims_screen.dart';
import 'leave_balances_screen.dart';
import 'leave_planner_screen.dart';
import 'leave_screen.dart';
import 'my_requests_screen.dart';
import 'notifications_screen.dart';
import 'onboarding_screen.dart';
import 'payslip_screen.dart';
import 'profile_screen.dart';
import 'pulse_survey_screen.dart';
import 'safety_checkin_screen.dart';
import 'settings_screen.dart';
import 'team_availability_screen.dart';
import 'training_screen.dart';
import '../data/calendar_data.dart';
import '../data/current_employee.dart';
import '../data/team_data.dart';
import '../domain/nepal/festival_bonus.dart';
import '../state/attendance_actions.dart';
import '../state/attendance_state.dart';
import '../state/expense_state.dart';
import '../state/leave_balance_state.dart';
import '../state/leave_state.dart';
import '../state/onboarding_state.dart';
import '../state/safety_state.dart';
import '../state/survey_state.dart';
import '../state/training_state.dart';
import '../theme/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Fetched ONCE for this screen's lifetime. It used to be
  // `FutureBuilder(future: fetchMyTasks())` inside build(), which started
  // a fresh 600ms fetch on EVERY rebuild — each check-in tap, each
  // Provider change — making Important Tasks vanish and reappear.
  late final Future<List<TaskItem>> _tasks = fetchMyTasks();

  // ============================================================
  // MENU (Cupertino has no drawer widget)
  // ============================================================
  void _showMenu(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: Text(currentEmployee.name),
        message: Text('Staff ID: ${currentEmployee.employeeId}'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(sheetContext);
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: const Text('Profile'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(sheetContext);
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            child: Text(context.l10n.settingsTitle),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(sheetContext);
              confirmLogout(context);
            },
            child: Text(context.l10n.logOut),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(sheetContext),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _open(Widget screen) {
    Navigator.push(context, CupertinoPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final safetyActive = context.watch<SafetyState>().isActive;
    final pulseDone = context.watch<SurveyState>().hasCheckedInThisWeek;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('KarmaHR'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: () => _showMenu(context),
          child: const Icon(CupertinoIcons.line_horizontal_3),
        ),
        trailing: const NotificationBell(),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (safetyActive) ...[
              const SafetyAlertBanner(),
              const SizedBox(height: 18),
            ],
            const _Greeting(),
            const SizedBox(height: 18),
            const _AttendanceCard(),
            const SizedBox(height: 12),
            _StatsRow(onOpenLeave: () => _open(const LeaveBalancesScreen())),
            const SizedBox(height: 22),
            const _SectionTitle('Quick Actions'),
            const SizedBox(height: 10),
            Row(
              children: [
                _QuickAction(
                  icon: CupertinoIcons.doc_text,
                  label: 'Apply Leave',
                  onTap: () => _open(const LeaveScreen()),
                ),
                _QuickAction(
                  icon: CupertinoIcons.airplane,
                  label: 'Plan Leave',
                  onTap: () => _open(const LeavePlannerScreen()),
                ),
                _QuickAction(
                  icon: CupertinoIcons.doc_on_clipboard,
                  label: 'New Claim',
                  onTap: () => _open(const NewExpenseClaimScreen()),
                ),
                _QuickAction(
                  icon: CupertinoIcons.money_dollar,
                  label: 'Payslips',
                  onTap: () => _open(const PayslipScreen()),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const WhosOutStrip(),
            if (!pulseDone) ...[
              const SizedBox(height: 12),
              const PulseCheckInCard(),
            ],
            _AttentionCard(open: _open),
            const _DashainCard(),
            _ImportantTasks(tasks: _tasks),
            const _TodayCard(),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SMALL PIECES
// ============================================================
class _SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;

  const _SectionTitle(this.text, {this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  static String _greeting(DateTime now) {
    if (now.hour < 12) return 'Good Morning';
    if (now.hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstName = currentEmployee.name.split(' ').first;
    final bs = NepaliDateFormat(
      'MMMM d, y',
      Language.english,
    ).format(NepaliDateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_greeting(now)}, $firstName 👋',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '${dayDate(now)} · $bs',
          style: TextStyle(
            fontSize: 13,
            color: CupertinoColors.systemGrey.resolveFrom(context),
          ),
        ),
      ],
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard();

  @override
  Widget build(BuildContext context) {
    final a = context.watch<AttendanceState>();
    final surface = AppColors.surface.resolveFrom(context);
    final border = AppColors.border.resolveFrom(context);
    final green = CupertinoColors.systemGreen.resolveFrom(context);
    final blue = CupertinoColors.systemBlue.resolveFrom(context);
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);

    // Adaptive system colors instead of the old hardcoded light purple,
    // which was hard to read and ignored Dark Mode.
    final (statusText, statusColor) = a.isCheckedOut
        ? ('Checked Out', blue)
        : a.isCheckedIn
        ? ('Checked In', green)
        : ('Not Checked In', subtle);

    return Container(
      padding: const EdgeInsets.all(18),
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
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Attendance',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              Icon(
                a.isCheckedIn || a.isCheckedOut
                    ? CupertinoIcons.check_mark_circled_solid
                    : CupertinoIcons.circle,
                color: statusColor,
                size: 18,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  statusText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _timeBlock('In', a.checkInTime)),
              const SizedBox(width: 12),
              Expanded(child: _timeBlock('Out', a.checkOutTime)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              color: a.isCheckedOut
                  ? CupertinoColors.systemGrey
                  : AppColors.karmaRed,
              borderRadius: BorderRadius.circular(10),
              padding: const EdgeInsets.symmetric(vertical: 12),
              // Shared with the Attendance module — see attendance_actions.dart.
              onPressed: a.isCheckedOut
                  ? null
                  : () => toggleAttendance(context),
              child: Text(
                a.isCheckedOut
                    ? 'Done for today'
                    : a.isCheckedIn
                    ? 'Check Out'
                    : 'Check In',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeBlock(String label, String? time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: CupertinoColors.systemGrey,
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            time ?? '--:--',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final VoidCallback onOpenLeave;

  const _StatsRow({required this.onOpenLeave});

  @override
  Widget build(BuildContext context) {
    final requests = context.watch<LeaveState>().requests;
    final homeLeave = context.read<LeaveBalanceState>().balanceFor(
      'Home Leave',
      requests,
    );
    final a = context.watch<AttendanceState>();

    final left = homeLeave?.remaining;
    final leaveText = left == null
        ? '—'
        : '${left == left.roundToDouble() ? left.toStringAsFixed(0) : left.toStringAsFixed(1)} days';

    final worked = a.workedToday;
    final hoursText = worked != null
        ? '${worked.inHours}h ${worked.inMinutes.remainder(60)}m'
        : a.isCheckedIn
        ? 'Since ${a.checkInTime}'
        : '—';

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onOpenLeave,
            child: _stat(context, 'Home Leave left', leaveText),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: _stat(context, 'Hours today', hoursText)),
      ],
    );
  }

  Widget _stat(BuildContext context, String label, String value) {
    return SectionCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              color: CupertinoColors.systemGrey.resolveFrom(context),
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            color: AppColors.surface.resolveFrom(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border.resolveFrom(context)),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.karmaRed, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// NEEDS YOUR ATTENTION — only rows that actually apply
// ============================================================
class _AttentionCard extends StatelessWidget {
  final void Function(Widget) open;

  const _AttentionCard({required this.open});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final overdue = context.watch<TrainingState>().overdue(now);
    final onboarding = context.watch<OnboardingState>();
    final expenses = context.watch<ExpenseState>();
    final pendingLeave = context
        .watch<LeaveState>()
        .requests
        .where((r) => r.status == LeaveRequestStatus.pending)
        .length;

    final rows = <(IconData, CupertinoDynamicColor, String, Widget)>[
      if (overdue.isNotEmpty)
        (
          CupertinoIcons.exclamationmark_circle_fill,
          CupertinoColors.systemRed,
          overdue.length == 1
              ? 'Overdue training: ${overdue.first.title}'
              : '${overdue.length} overdue trainings',
          const TrainingScreen(),
        ),
      if (!onboarding.isComplete)
        (
          CupertinoIcons.list_bullet,
          CupertinoColors.systemTeal,
          'Onboarding: ${onboarding.doneCount} of ${onboarding.tasks.length} steps done',
          const OnboardingScreen(),
        ),
      if (pendingLeave > 0)
        (
          CupertinoIcons.airplane,
          CupertinoColors.systemOrange,
          pendingLeave == 1
              ? '1 leave request awaiting approval'
              : '$pendingLeave leave requests awaiting approval',
          const MyRequestsScreen(),
        ),
      if (expenses.pendingCount > 0)
        (
          CupertinoIcons.doc_on_clipboard,
          CupertinoColors.systemPurple,
          '${expenses.pendingCount} expense claim${expenses.pendingCount == 1 ? '' : 's'} '
              'pending · ${formatRupees(expenses.pendingTotal)}',
          const ExpenseClaimsScreen(),
        ),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Needs Your Attention'),
          const SizedBox(height: 10),
          SectionCard(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Column(
              children: [
                for (final (icon, color, text, screen) in rows)
                  CupertinoListTile(
                    leading: Icon(icon, color: color.resolveFrom(context)),
                    title: Text(
                      text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => open(screen),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DASHAIN — countdown + estimated festival bonus, in season only
// ============================================================
class _DashainCard extends StatelessWidget {
  const _DashainCard();

  @override
  Widget build(BuildContext context) {
    final dashain = nextDashainDate();
    if (dashain == null) return const SizedBox.shrink();
    final today = dateOnly(DateTime.now());
    final days = dateOnly(dashain).difference(today).inDays;
    if (days < 0 || days > 60) return const SizedBox.shrink();

    final bonus = estimateDashainBonus(
      basicSalary: currentEmployee.basicSalary,
      joiningDate: currentEmployee.joiningDate,
      festivalDate: dashain,
    );
    const white = CupertinoColors.white;

    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFFE65100), Color(0xFFC62828)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              days == 0
                  ? '🪔 Happy Dashain!'
                  : '🪔 Dashain in $days day${days == 1 ? '' : 's'}',
              style: const TextStyle(
                color: white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Estimated festival bonus',
              style: TextStyle(color: white, fontSize: 12.5),
            ),
            Text(
              formatRupees(bonus.amount),
              style: const TextStyle(
                color: white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              bonus.prorated
                  ? 'Pro-rated for ${bonus.monthsOfService} months of service. '
                        'Estimate only — confirm with HR.'
                  : "One month's basic salary. Estimate only — confirm with HR.",
              style: const TextStyle(color: Color(0xDDFFFFFF), fontSize: 11.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// IMPORTANT TASKS — high priority or overdue, from the Tasks data
// ============================================================
class _ImportantTasks extends StatelessWidget {
  final Future<List<TaskItem>> tasks;

  const _ImportantTasks({required this.tasks});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TaskItem>>(
      future: tasks,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final now = DateTime.now();
        final important =
            snapshot.data!
                .where(
                  (t) =>
                      t.status != TaskStatus.completed &&
                      (t.priority == TaskPriority.high ||
                          t.dueDate.isBefore(now)),
                )
                .toList()
              ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
        if (important.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(
                'Important Tasks',
                trailing: CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  onPressed: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => const TasksModuleScreen(),
                    ),
                  ),
                  child: const Text('View All', style: TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(height: 10),
              for (final t in important.take(2)) _TaskCard(task: t),
            ],
          ),
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskItem task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final overdue = task.dueDate.isBefore(DateTime.now());
    final red = CupertinoColors.systemRed.resolveFrom(context);
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        CupertinoPageRoute(builder: (_) => const TasksModuleScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface.resolveFrom(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border.resolveFrom(context)),
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
                Flexible(
                  child: StatusBadge(
                    label: taskPriorityLabel(task.priority),
                    color: taskPriorityColor(task.priority)
                        .resolveFrom(context),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    overdue
                        ? 'Overdue · ${shortDate(task.dueDate)}'
                        : 'Due ${shortDate(task.dueDate)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: overdue ? red : subtle,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ProgressBar(
              progress: task.progress,
              color: taskStatusColor(task.status).resolveFrom(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TODAY — real holidays, company events, and celebrations
// (replaces a hardcoded "Team Meeting 10:00 AM" shown every day)
// ============================================================
class _TodayCard extends StatelessWidget {
  const _TodayCard();

  @override
  Widget build(BuildContext context) {
    final today = dateOnly(DateTime.now());
    final holiday = holidayNameOn(today);
    final events = demoCompanyEvents();
    final todaysEvents = events
        .where((e) => dateOnly(e.startsAt) == today)
        .toList();
    final celebrations = demoCelebrations()
        .where((c) => c.date == today)
        .toList();
    final upcomingEvents =
        events.where((e) => dateOnly(e.startsAt).isAfter(today)).toList()
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    final next = upcomingEvents.isEmpty ? null : upcomingEvents.first;

    final rows = <(String, String)>[
      if (holiday != null) ('🎊 $holiday', 'Public holiday'),
      for (final e in todaysEvents) ('⭐ ${e.title}', clockTime(e.startsAt)),
      for (final c in celebrations)
        (
          c.kind == CelebrationKind.birthday
              ? "🎂 ${c.name}'s birthday"
              : '🎉 ${c.name} · ${c.years} years',
          'Say hi!',
        ),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Today'),
          const SizedBox(height: 10),
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (rows.isEmpty)
                  const Text(
                    'Nothing special today.',
                    style: TextStyle(fontSize: 14),
                  )
                else
                  for (final (title, detail) in rows)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Text(
                            detail,
                            style: TextStyle(
                              fontSize: 13,
                              color: CupertinoColors.systemGrey.resolveFrom(
                                context,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                if (next != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Next: ${next.title} · ${dayDate(next.startsAt)}',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: CupertinoColors.systemGrey.resolveFrom(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => const AttendanceModuleScreen(),
              ),
            ),
            child: const Text(
              'View attendance history →',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

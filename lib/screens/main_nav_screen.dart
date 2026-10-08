import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'apps/widgets/ui_kit.dart';
import '../l10n/l10n.dart';
import '../state/auth_state.dart';
import '../state/notification_state.dart';
import '../state/training_state.dart';

import 'dashboard_screen.dart';
import 'apps/attendance/attendance_module_screen.dart';
import 'manager/team_screen.dart';
import 'more_screen.dart';
import 'requests_screen.dart';
import 'time_off_screen.dart';
import '../theme/app_colors.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  @override
  void initState() {
    super.initState();
    // After the first frame, so the inbox badge animates in on a screen
    // the user can actually see.
    WidgetsBinding.instance.addPostFrameCallback((_) => _startupReminders());
  }

  // Things worth telling the user as soon as they're in the app. Runs
  // once per login: TrainingState only hands out overdue courses the
  // first time it's asked, and a logout resets that.
  void _startupReminders() {
    if (!mounted) return;
    final overdue = context.read<TrainingState>().takeOverdueToAnnounce(
      DateTime.now(),
    );
    for (final course in overdue) {
      notifyUser(
        context,
        kind: AppNotificationKind.reminder,
        title: 'Training overdue: ${course.title}',
        body:
            'It was due ${shortDate(course.dueDate)} and takes about '
            '${course.durationMinutes} minutes. Find it in More → Apps → Training.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const karmaRed = AppColors.karmaRed;
    final l10n = context.l10n;
    // The role can't change while this screen is up: switching role means
    // logging out, which replaces the whole navigator.
    final isManager = context.read<AuthState>().role == UserRole.manager;

    // Each screen next to its tab, so the two can never get out of order.
    final tabs = <(Widget, BottomNavigationBarItem)>[
      (
        const DashboardScreen(),
        BottomNavigationBarItem(
          icon: const Icon(CupertinoIcons.home),
          label: l10n.tabHome,
        ),
      ),
      if (isManager)
        (
          const TeamScreen(),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.person_3),
            label: l10n.tabTeam,
          ),
        ),
      (
        const TimeOffScreen(),
        BottomNavigationBarItem(
          icon: const Icon(CupertinoIcons.airplane),
          label: l10n.tabTimeOff,
        ),
      ),
      (
        const AttendanceModuleScreen(),
        BottomNavigationBarItem(
          icon: const Icon(CupertinoIcons.time),
          label: l10n.tabTime,
        ),
      ),
      (
        const RequestsScreen(),
        BottomNavigationBarItem(
          icon: const Icon(CupertinoIcons.tray_full),
          label: l10n.tabRequests,
        ),
      ),
      (
        const MoreScreen(),
        BottomNavigationBarItem(
          icon: const Icon(CupertinoIcons.ellipsis),
          label: l10n.tabMore,
        ),
      ),
    ];

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        activeColor: karmaRed,
        inactiveColor: CupertinoColors.systemGrey,
        items: [for (final tab in tabs) tab.$2],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(builder: (context) => tabs[index].$1);
      },
    );
  }
}

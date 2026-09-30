import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'apps/widgets/ui_kit.dart';
import '../state/notification_state.dart';
import '../state/training_state.dart';

import 'dashboard_screen.dart';
import 'leave_screen.dart';
import 'apps/attendance/attendance_module_screen.dart';
import 'events_screen.dart';
import 'apps_screen.dart';
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
            '${course.durationMinutes} minutes. Find it in Apps → Training.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const karmaRed = AppColors.karmaRed;

    // Order here must match the CupertinoTabBar items below —
    // index 0 goes with the first item, index 1 with the second, etc.
    final screens = const [
      DashboardScreen(),
      LeaveScreen(),
      AttendanceModuleScreen(), // tab label is "Time"
      EventsScreen(),
      AppsScreen(),
    ];

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        activeColor: karmaRed,
        inactiveColor: CupertinoColors.systemGrey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.calendar),
            label: 'Leave',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.time),
            label: 'Time',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.calendar_today),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.square_grid_2x2),
            label: 'Apps',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(builder: (context) => screens[index]);
      },
    );
  }
}

import 'package:flutter/cupertino.dart';

import 'dashboard_screen.dart';
import 'leave_screen.dart';
import 'apps/attendance/attendance_module_screen.dart';
import 'events_screen.dart';
import 'apps_screen.dart';
import '../theme/app_colors.dart';

class MainNavScreen extends StatelessWidget {
  const MainNavScreen({super.key});

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

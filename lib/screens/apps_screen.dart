import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';
import 'apps/attendance/attendance_module_screen.dart';
import 'apps/tasks/tasks_module_screen.dart';
import 'apps/widgets/app_module_card.dart';
import 'leave_balances_screen.dart';
import 'request_screen.dart';
import 'my_requests_screen.dart';
import 'kudos_screen.dart';
import 'employee_directory_screen.dart';
import 'payslip_screen.dart';
import 'anonymous_feedback_screen.dart';

class AppsScreen extends StatelessWidget {
  const AppsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Apps')),
      child: SafeArea(
        child: GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.95,
          children: [
            AppModuleCard(
              icon: CupertinoIcons.time,
              title: 'Attendance',
              subtitle: 'Check-in, history & status',
              iconColor: AppColors.karmaRed,
              onTap: () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const AttendanceModuleScreen(),
                ),
              ),
            ),
            AppModuleCard(
              icon: CupertinoIcons.heart_fill,
              title: 'Kudos Wall',
              subtitle: 'Give & see peer recognition',
              iconColor: CupertinoColors.systemPink,
              onTap: () => Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => const KudosScreen()),
              ),
            ),
            AppModuleCard(
              icon: CupertinoIcons.chat_bubble_text,
              title: 'Anonymous Feedback',
              subtitle: 'Share honest feedback, privately',
              iconColor: CupertinoColors.systemIndigo,
              onTap: () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const AnonymousFeedbackScreen(),
                ),
              ),
            ),
            AppModuleCard(
              icon: CupertinoIcons.tray_full,
              title: 'My Requests',
              subtitle: 'Leave & HR requests, all in one place',
              iconColor: CupertinoColors.systemPurple,
              onTap: () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const MyRequestsScreen(),
                ),
              ),
            ),
            AppModuleCard(
              icon: CupertinoIcons.checkmark_square,
              title: 'Tasks',
              subtitle: 'Assigned tasks & progress',
              iconColor: CupertinoColors.systemBlue,
              onTap: () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const TasksModuleScreen(),
                ),
              ),
            ),
            AppModuleCard(
              icon: CupertinoIcons.clock,
              title: 'HR Requests',
              subtitle: 'Time, salary, ID card & more',
              iconColor: CupertinoColors.systemOrange,
              onTap: () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const HrRequestScreen(),
                ),
              ),
            ),
            AppModuleCard(
              icon: CupertinoIcons.doc_text,
              title: 'Leave & Balances',
              subtitle: 'Apply leave & track balances',
              iconColor: CupertinoColors.systemGreen,
              onTap: () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const LeaveBalancesScreen(),
                ),
              ),
            ),

            AppModuleCard(
              icon: CupertinoIcons.money_dollar,
              title: 'Payslips',
              subtitle: 'View salary & deductions',
              iconColor: CupertinoColors.systemGreen,
              onTap: () => Navigator.push(
                context,
                CupertinoPageRoute(builder: (context) => const PayslipScreen()),
              ),
            ),
            AppModuleCard(
              icon: CupertinoIcons.person_2_fill,
              title: 'Directory',
              subtitle: 'Find & contact coworkers',
              iconColor: CupertinoColors.systemTeal,
              onTap: () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const EmployeeDirectoryScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

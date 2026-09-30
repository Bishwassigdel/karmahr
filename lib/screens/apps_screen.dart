import 'package:flutter/cupertino.dart';

import 'apps/attendance/attendance_module_screen.dart';
import 'apps/tasks/tasks_module_screen.dart';
import 'apps/widgets/app_module_card.dart';
import 'anonymous_feedback_screen.dart';
import 'document_wallet_screen.dart';
import 'emergency_info_screen.dart';
import 'employee_directory_screen.dart';
import 'expense_claims_screen.dart';
import 'global_search_screen.dart';
import 'goals_screen.dart';
import 'insights_screen.dart';
import 'kudos_screen.dart';
import 'leave_balances_screen.dart';
import 'leave_planner_screen.dart';
import 'my_requests_screen.dart';
import 'onboarding_screen.dart';
import 'payslip_screen.dart';
import 'pulse_survey_screen.dart';
import 'request_screen.dart';
import 'safety_checkin_screen.dart';
import 'shifts_overtime_screen.dart';
import 'tax_planner_screen.dart';
import 'team_availability_screen.dart';
import 'training_screen.dart';
import '../theme/app_colors.dart';

// One grid tile's worth of data. Keeping modules as data (not a long
// hand-written widget list) is what lets them be grouped into sections
// — and adding a module is one line in the right group.
class _Module {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final WidgetBuilder open;

  const _Module(this.icon, this.title, this.subtitle, this.color, this.open);
}

final _sections = <(String, List<_Module>)>[
  (
    'TIME & LEAVE',
    [
      _Module(
        CupertinoIcons.time,
        'Attendance',
        'Check-in, history & status',
        AppColors.karmaRed,
        (_) => const AttendanceModuleScreen(),
      ),
      _Module(
        CupertinoIcons.doc_text,
        'Leave & Balances',
        'Apply leave & track balances',
        CupertinoColors.systemGreen,
        (_) => const LeaveBalancesScreen(),
      ),
      _Module(
        CupertinoIcons.airplane,
        'Leave Planner',
        'Plan trips & find long breaks',
        CupertinoColors.systemTeal,
        (_) => const LeavePlannerScreen(),
      ),
      _Module(
        CupertinoIcons.clock_fill,
        'Shifts & Overtime',
        'Schedule & overtime requests',
        CupertinoColors.systemOrange,
        (_) => const ShiftsOvertimeScreen(),
      ),
      _Module(
        CupertinoIcons.person_2_square_stack,
        "Who's Out",
        'Coworkers on leave',
        CupertinoColors.systemBlue,
        (_) => const TeamAvailabilityScreen(),
      ),
    ],
  ),
  (
    'PAY & MONEY',
    [
      _Module(
        CupertinoIcons.money_dollar,
        'Payslips',
        'Salary, deductions & PDF',
        CupertinoColors.systemGreen,
        (_) => const PayslipScreen(),
      ),
      _Module(
        CupertinoIcons.slider_horizontal_3,
        'Tax Planner',
        'Save tax with CIT & insurance',
        CupertinoColors.systemIndigo,
        (_) => const TaxPlannerScreen(),
      ),
      _Module(
        CupertinoIcons.doc_on_clipboard,
        'Expense Claims',
        'Receipts & eSewa/Khalti payout',
        CupertinoColors.systemPurple,
        (_) => const ExpenseClaimsScreen(),
      ),
    ],
  ),
  (
    'REQUESTS',
    [
      _Module(
        CupertinoIcons.clock,
        'HR Requests',
        'Time, salary, ID card & more',
        CupertinoColors.systemOrange,
        (_) => const HrRequestScreen(),
      ),
      _Module(
        CupertinoIcons.tray_full,
        'My Requests',
        'Everything you submitted',
        CupertinoColors.systemPurple,
        (_) => const MyRequestsScreen(),
      ),
    ],
  ),
  (
    'GROWTH',
    [
      _Module(
        CupertinoIcons.flag_fill,
        'Goals',
        'Quarterly goals & progress',
        AppColors.karmaRed,
        (_) => const GoalsScreen(),
      ),
      _Module(
        CupertinoIcons.book_fill,
        'Training',
        'Courses & badges',
        CupertinoColors.systemBrown,
        (_) => const TrainingScreen(),
      ),
      _Module(
        CupertinoIcons.checkmark_square,
        'Tasks',
        'Assigned tasks & progress',
        CupertinoColors.systemBlue,
        (_) => const TasksModuleScreen(),
      ),
      _Module(
        CupertinoIcons.chart_bar_alt_fill,
        'Insights',
        'Leave, attendance & kudos',
        CupertinoColors.systemIndigo,
        (_) => const InsightsScreen(),
      ),
      _Module(
        CupertinoIcons.list_bullet,
        'Onboarding',
        'Your first-weeks checklist',
        CupertinoColors.systemTeal,
        (_) => const OnboardingScreen(),
      ),
    ],
  ),
  (
    'PEOPLE & CULTURE',
    [
      _Module(
        CupertinoIcons.heart_fill,
        'Kudos Wall',
        'Give & see recognition',
        CupertinoColors.systemPink,
        (_) => const KudosScreen(),
      ),
      _Module(
        CupertinoIcons.person_2_fill,
        'Directory',
        'Find & contact coworkers',
        CupertinoColors.systemTeal,
        (_) => const EmployeeDirectoryScreen(),
      ),
      _Module(
        CupertinoIcons.smiley,
        'Pulse & Polls',
        'Weekly mood & quick polls',
        CupertinoColors.systemYellow,
        (_) => const PulseSurveyScreen(),
      ),
      _Module(
        CupertinoIcons.chat_bubble_text,
        'Anonymous Feedback',
        'Share honest feedback',
        CupertinoColors.systemIndigo,
        (_) => const AnonymousFeedbackScreen(),
      ),
    ],
  ),
  (
    'SAFETY & DOCUMENTS',
    [
      _Module(
        CupertinoIcons.exclamationmark_shield_fill,
        'Safety Check-in',
        "Earthquake 'I'm safe' alerts",
        CupertinoColors.systemRed,
        (_) => const SafetyCheckInScreen(),
      ),
      _Module(
        CupertinoIcons.folder_fill,
        'Document Wallet',
        'PAN, citizenship & more',
        CupertinoColors.systemGrey,
        (_) => const DocumentWalletScreen(),
      ),
      _Module(
        CupertinoIcons.heart_circle_fill,
        'Emergency & Insurance',
        'Contacts & health card',
        CupertinoColors.systemRed,
        (_) => const EmergencyInfoScreen(),
      ),
    ],
  ),
];

class AppsScreen extends StatelessWidget {
  const AppsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Apps'),
        // Apps is the hub every module is reachable from, which makes
        // it the natural home for cross-module search too.
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const GlobalSearchScreen(),
            ),
          ),
          child: const Icon(CupertinoIcons.search),
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            for (final (title, modules) in _sections) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                      color: subtle,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.95,
                  children: [
                    for (final m in modules)
                      AppModuleCard(
                        icon: m.icon,
                        title: m.title,
                        subtitle: m.subtitle,
                        iconColor: m.color,
                        onTap: () => Navigator.push(
                          context,
                          CupertinoPageRoute(builder: m.open),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

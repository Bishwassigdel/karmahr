// QA smoke test: EVERY screen in the app, rendered with the app's real
// provider list, under three conditions:
//   - narrow phone (320pt wide — iPhone SE class), light mode
//   - narrow phone, DARK mode, with 130% text size (accessibility)
//   - wide phone (430pt — Pro Max class), light mode
//   - narrow phone in Nepali (Devanagari text runs longer)
// The viewport is made very tall so lists build ALL their rows, not just
// the ones that fit on screen — an overflow in row 9 counts too.
//
// This is the test that would have caught the Welcome-screen overflow
// before it reached a real device.

import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_first_flutter_app/data/notices_data.dart';
import 'package:my_first_flutter_app/l10n/app_localizations.dart';
import 'package:my_first_flutter_app/main.dart';
import 'package:my_first_flutter_app/screens/anonymous_feedback_screen.dart';
import 'package:my_first_flutter_app/screens/app_lock_screen.dart';
import 'package:my_first_flutter_app/screens/apps/attendance/attendance_module_screen.dart';
import 'package:my_first_flutter_app/screens/apps/tasks/tasks_module_screen.dart';
import 'package:my_first_flutter_app/screens/apps_screen.dart';
import 'package:my_first_flutter_app/screens/dashboard_screen.dart';
import 'package:my_first_flutter_app/screens/document_wallet_screen.dart';
import 'package:my_first_flutter_app/screens/emergency_info_screen.dart';
import 'package:my_first_flutter_app/screens/employee_directory_screen.dart';
import 'package:my_first_flutter_app/screens/events_screen.dart';
import 'package:my_first_flutter_app/screens/expense_claims_screen.dart';
import 'package:my_first_flutter_app/screens/give_kudos_screen.dart';
import 'package:my_first_flutter_app/screens/global_search_screen.dart';
import 'package:my_first_flutter_app/screens/goals_screen.dart';
import 'package:my_first_flutter_app/screens/holiday_calendar_screen.dart';
import 'package:my_first_flutter_app/screens/hr/hr_portal_screen.dart';
import 'package:my_first_flutter_app/screens/insights_screen.dart';
import 'package:my_first_flutter_app/screens/kudos_preview_screen.dart';
import 'package:my_first_flutter_app/screens/kudos_screen.dart';
import 'package:my_first_flutter_app/screens/leave_balances_screen.dart';
import 'package:my_first_flutter_app/screens/leave_planner_screen.dart';
import 'package:my_first_flutter_app/screens/leave_screen.dart';
import 'package:my_first_flutter_app/screens/login_screen.dart';
import 'package:my_first_flutter_app/screens/main_nav_screen.dart';
import 'package:my_first_flutter_app/screens/manager/team_screen.dart';
import 'package:my_first_flutter_app/screens/my_requests_screen.dart';
import 'package:my_first_flutter_app/screens/notices_screen.dart';
import 'package:my_first_flutter_app/screens/notifications_screen.dart';
import 'package:my_first_flutter_app/screens/onboarding_screen.dart';
import 'package:my_first_flutter_app/screens/payslip_screen.dart';
import 'package:my_first_flutter_app/screens/profile_screen.dart';
import 'package:my_first_flutter_app/screens/pulse_survey_screen.dart';
import 'package:my_first_flutter_app/screens/request_screen.dart';
import 'package:my_first_flutter_app/screens/safety_checkin_screen.dart';
import 'package:my_first_flutter_app/screens/settings_screen.dart';
import 'package:my_first_flutter_app/screens/shifts_overtime_screen.dart';
import 'package:my_first_flutter_app/screens/tax_planner_screen.dart';
import 'package:my_first_flutter_app/screens/team_availability_screen.dart';
import 'package:my_first_flutter_app/screens/training_screen.dart';
import 'package:my_first_flutter_app/screens/welcome_screen.dart';
import 'package:my_first_flutter_app/state/auth_state.dart';
import 'package:my_first_flutter_app/state/safety_state.dart';
import 'package:my_first_flutter_app/state/survey_state.dart';

final Map<String, Widget Function()> screens = {
  'Welcome': () => const WelcomeScreen(),
  'Login': () => const LoginScreen(),
  'MainNav (Dashboard tab)': () => const MainNavScreen(),
  'Dashboard': () => const DashboardScreen(),
  'Apps': () => const AppsScreen(),
  'Leave': () => const LeaveScreen(),
  'Leave (pre-filled)': () => LeaveScreen(
    initialStartDate: DateTime(2026, 10, 8),
    initialEndDate: DateTime(2026, 10, 9),
  ),
  'Leave & Balances': () => const LeaveBalancesScreen(),
  'Leave Planner': () => const LeavePlannerScreen(),
  'HR Requests': () => const HrRequestScreen(),
  'My Requests': () => const MyRequestsScreen(),
  'Kudos Wall': () => const KudosScreen(),
  'Give Kudos': () => const GiveKudosScreen(),
  'Kudos Preview': () => const KudosPreviewScreen(
    recipientName: 'Sita Gurung',
    category: 'Teamwork',
    message: 'Thanks for covering the payroll close at such short notice!',
    points: 20,
  ),
  'Anonymous Feedback': () => const AnonymousFeedbackScreen(),
  'Directory': () => const EmployeeDirectoryScreen(),
  'Payslips': () => const PayslipScreen(),
  'Notices': () => const NoticesScreen(),
  'Notice Detail': () => NoticeDetailScreen(notice: demoNotices.first),
  'HR Calendar': () => const HolidayCalendarScreen(),
  'Events': () => const EventsScreen(),
  'Profile': () => const ProfileScreen(),
  'Settings': () => const SettingsScreen(),
  'Attendance': () => const AttendanceModuleScreen(),
  'Tasks': () => const TasksModuleScreen(),
  'Insights': () => const InsightsScreen(),
  'Notifications': () => const NotificationsScreen(),
  'Global Search': () => const GlobalSearchScreen(),
  'App Lock': () => const AppLockScreen(),
  'Tax Planner': () => const TaxPlannerScreen(),
  'Expense Claims': () => const ExpenseClaimsScreen(),
  'New Expense Claim': () => const NewExpenseClaimScreen(),
  "Who's Out": () => const TeamAvailabilityScreen(),
  'Shifts & Overtime': () => const ShiftsOvertimeScreen(),
  'Request Overtime': () => const OvertimeRequestScreen(),
  'Document Wallet': () => const DocumentWalletScreen(),
  'Add Document': () => const AddDocumentScreen(),
  'Emergency & Insurance': () => const EmergencyInfoScreen(),
  'Onboarding': () => const OnboardingScreen(),
  'Training': () => const TrainingScreen(),
  'Goals': () => const GoalsScreen(),
  'Pulse & Polls': () => const PulseSurveyScreen(),
  'Safety Check-in': () => const SafetyCheckInScreen(),
  'Manager Team': () => const TeamScreen(),
  'HR Portal': () => const HrPortalScreen(),
};

class Condition {
  final String name;
  final double width;
  final Brightness brightness;
  final double textScale;
  final Locale locale;

  const Condition(
    this.name,
    this.width,
    this.brightness,
    this.textScale, [
    this.locale = const Locale('en'),
  ]);
}

const conditions = [
  Condition('narrow light', 320, Brightness.light, 1.0),
  Condition('narrow dark +130% text', 320, Brightness.dark, 1.3),
  Condition('wide light', 430, Brightness.light, 1.0),
  Condition('narrow Nepali', 320, Brightness.light, 1.0, Locale('ne')),
];

Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen,
  Condition c, {
  // Runs after the first frame, with a context under the providers —
  // changing state DURING a build would itself be an error.
  void Function(BuildContext context)? prime,
}) async {
  tester.view.physicalSize = Size(c.width, 3200);
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.textScaleFactorTestValue = c.textScale;
  tester.platformDispatcher.platformBrightnessTestValue = c.brightness;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);

  await tester.pumpWidget(
    MultiProvider(
      providers: appProviders(),
      child: CupertinoApp(
        theme: CupertinoThemeData(brightness: c.brightness),
        locale: c.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: screen,
      ),
    ),
  );

  if (prime != null) {
    prime(tester.element(find.byWidget(screen)));
  }

  // Fixed pumps, NOT pumpAndSettle: spinners and shimmer skeletons animate
  // forever by design. Two seconds covers every demo fetch (600ms), every
  // staggered entrance, and every route/Hero animation.
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 500));
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final c in conditions) {
    group(c.name, () {
      screens.forEach((name, build) {
        testWidgets(name, (tester) async {
          await pumpScreen(tester, build(), c);
          expect(tester.takeException(), isNull, reason: '$name / ${c.name}');
        });
      });

      // States that only appear after an action — the safety alert and a
      // completed pulse check-in change the Dashboard's layout.
      testWidgets('Dashboard during a safety drill, pulse answered', (tester) async {
        await pumpScreen(
          tester,
          const DashboardScreen(),
          c,
          prime: (context) {
            context.read<SafetyState>().startDrill();
            context.read<SurveyState>().checkIn(3);
          },
        );
        expect(tester.takeException(), isNull);
        expect(find.text('Earthquake Drill'), findsOneWidget);
      });

      testWidgets('MainNav as a manager (six tabs)', (tester) async {
        await pumpScreen(
          tester,
          // MainNavScreen reads the role once, so build a fresh one when
          // the role changes (in the app, a sign-in pushes a new one).
          Consumer<AuthState>(
            builder: (_, auth, _) => MainNavScreen(key: ValueKey(auth.role)),
          ),
          c,
          prime: (context) =>
              context.read<AuthState>().signIn(UserRole.manager),
        );
        expect(tester.takeException(), isNull);
        expect(find.byIcon(CupertinoIcons.person_3), findsOneWidget);
      });

      testWidgets('Safety Check-in during a drill', (tester) async {
        await pumpScreen(
          tester,
          const SafetyCheckInScreen(),
          c,
          prime: (context) => context.read<SafetyState>().startDrill(),
        );
        expect(tester.takeException(), isNull);
        expect(find.text("I'm Safe"), findsOneWidget);
      });
    });
  }
}

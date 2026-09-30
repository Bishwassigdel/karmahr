import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'screens/app_lock_gate.dart';
import 'screens/welcome_screen.dart';
import 'state/app_lock_state.dart';
import 'state/attendance_state.dart';
import 'state/leave_balance_state.dart';
import 'state/leave_state.dart';
import 'state/notification_state.dart';
import 'state/push_notification_state.dart';
import 'state/theme_state.dart';
import 'state/hr_request_state.dart';
import 'state/kudos_state.dart';
import 'state/feedback_state.dart';
import 'state/document_wallet_state.dart';
import 'state/emergency_info_state.dart';
import 'state/event_rsvp_state.dart';
import 'state/expense_state.dart';
import 'state/goals_state.dart';
import 'state/onboarding_state.dart';
import 'state/overtime_state.dart';
import 'state/safety_state.dart';
import 'state/survey_state.dart';
import 'state/training_state.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const MyApp());
}

/// Every app-wide shared state, in one list. A function rather than an
/// inline list so tests can build the exact same set — a screen test with
/// a hand-picked subset can pass while the real app crashes on a missing
/// provider, or the other way round.
List<SingleChildWidget> appProviders() => [
  ChangeNotifierProvider(create: (context) => AppLockState()),
  ChangeNotifierProvider(create: (context) => AttendanceState()),
  ChangeNotifierProvider(create: (context) => ThemeState()),
  ChangeNotifierProvider(create: (context) => LeaveState()),
  ChangeNotifierProvider(create: (context) => LeaveBalanceState()),
  ChangeNotifierProvider(create: (context) => HrRequestState()),
  ChangeNotifierProvider(create: (context) => KudosState()),
  ChangeNotifierProvider(create: (context) => FeedbackState()),
  ChangeNotifierProvider(create: (context) => NotificationState()),
  ChangeNotifierProvider(create: (context) => PushNotificationState()),
  ChangeNotifierProvider(create: (context) => ExpenseState()),
  ChangeNotifierProvider(create: (context) => OvertimeState()),
  ChangeNotifierProvider(create: (context) => DocumentWalletState()),
  ChangeNotifierProvider(create: (context) => EmergencyInfoState()),
  ChangeNotifierProvider(create: (context) => OnboardingState()),
  ChangeNotifierProvider(create: (context) => TrainingState()),
  ChangeNotifierProvider(create: (context) => GoalsState()),
  ChangeNotifierProvider(create: (context) => SurveyState()),
  ChangeNotifierProvider(create: (context) => SafetyState()),
  ChangeNotifierProvider(create: (context) => EventRsvpState()),
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider places both shared objects "on the shelf" above the
    // whole app, so every screen underneath (Welcome, Login, Dashboard,
    // Attendance, Settings, etc.) can reach the same instances.
    return MultiProvider(
      providers: appProviders(),
      // Consumer rebuilds just this part of the tree whenever the user
      // changes their theme choice in Settings.
      child: Consumer<ThemeState>(
        builder: (context, themeState, _) {
          // "System" means follow the phone's own Light/Dark setting —
          // otherwise, the user's manual pick always wins, no matter what
          // the phone is set to.
          final resolvedBrightness = switch (themeState.mode) {
            AppThemeMode.system => MediaQuery.platformBrightnessOf(context),
            AppThemeMode.light => Brightness.light,
            AppThemeMode.dark => Brightness.dark,
          };

          // IMPORTANT: we can't use AppColors.background.resolveFrom(context)
          // here — this context sits ABOVE CupertinoApp, so it has no
          // CupertinoTheme yet and .resolveFrom would fall back to the raw
          // platform brightness, ignoring a manual Light/Dark override.
          // Picking .color / .darkColor directly avoids that.
          final resolvedBackground = resolvedBrightness == Brightness.dark
              ? AppColors.background.darkColor
              : AppColors.background.color;

          return CupertinoApp(
            debugShowCheckedModeBanner: false,
            title: 'KarmaHR',

            theme: CupertinoThemeData(
              brightness: resolvedBrightness,
              primaryColor: AppColors.karmaRed,
              scaffoldBackgroundColor: resolvedBackground,
            ),

            home: const AppLockGate(child: WelcomeScreen()),
          );
        },
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'screens/welcome_screen.dart';
import 'state/attendance_state.dart';
import 'state/leave_state.dart';
import 'state/theme_state.dart';
import 'state/hr_request_state.dart';
import 'state/kudos_state.dart';
import 'state/feedback_state.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider places both shared objects "on the shelf" above the
    // whole app, so every screen underneath (Welcome, Login, Dashboard,
    // Attendance, Settings, etc.) can reach the same instances.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AttendanceState()),
        ChangeNotifierProvider(create: (context) => ThemeState()),
        ChangeNotifierProvider(create: (context) => LeaveState()),
        ChangeNotifierProvider(create: (context) => HrRequestState()),
        ChangeNotifierProvider(create: (context) => KudosState()),
        ChangeNotifierProvider(create: (context) => FeedbackState()),
      ],
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

            home: const WelcomeScreen(),
          );
        },
      ),
    );
  }
}

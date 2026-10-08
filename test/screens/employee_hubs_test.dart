// The BambooHR-style reorganisation of the employee portal: tabs, the
// Time Off and Requests hubs, My Info, and the Home feed.

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_first_flutter_app/data/current_employee.dart';
import 'package:my_first_flutter_app/main.dart';
import 'package:my_first_flutter_app/screens/dashboard_screen.dart';
import 'package:my_first_flutter_app/screens/leave_screen.dart';
import 'package:my_first_flutter_app/screens/main_nav_screen.dart';
import 'package:my_first_flutter_app/screens/profile_screen.dart';
import 'package:my_first_flutter_app/screens/requests_screen.dart';
import 'package:my_first_flutter_app/screens/time_off_screen.dart';

Future<void> pump(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(393, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MultiProvider(
      providers: appProviders(),
      child: CupertinoApp(home: screen),
    ),
  );
  await settle(tester);
}

// Bounded settling: Home has spinners that never stop.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

Finder tab(String label) => find.descendant(
  of: find.byType(CupertinoTabBar),
  matching: find.text(label),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('tabs are Home, Time Off, Time, Requests, More', (tester) async {
    await pump(tester, const MainNavScreen());

    for (final label in ['Home', 'Time Off', 'Time', 'Requests', 'More']) {
      expect(tab(label), findsOneWidget, reason: label);
    }
    expect(tab('Events'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home has the feed and no menu button', (tester) async {
    await pump(tester, const DashboardScreen());

    expect(find.text("What's happening"), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.line_horizontal_3), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Time Off: Request time off opens the leave form', (
    tester,
  ) async {
    await pump(tester, const TimeOffScreen());
    expect(find.text('Home Leave'), findsWidgets);

    await tester.tap(find.text('Request time off'));
    await settle(tester);
    expect(find.byType(LeaveScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Requests lists every kind, and Open hides closed ones', (
    tester,
  ) async {
    await pump(tester, const RequestsScreen());

    // From the demo data: an approved HR request and a pending one.
    expect(find.text('Time Correction'), findsOneWidget);
    expect(find.text('Salary Advance'), findsOneWidget);

    await tester.tap(find.text('Open'));
    await settle(tester);
    expect(find.text('Salary Advance'), findsOneWidget);
    expect(find.text('Time Correction'), findsNothing);
    expect(find.text('Approved'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Requests: + asks which kind of request', (tester) async {
    await pump(tester, const RequestsScreen());

    await tester.tap(find.byIcon(CupertinoIcons.add));
    await settle(tester);
    for (final kind in [
      'Time off',
      'Expense claim',
      'Overtime',
      'HR request',
    ]) {
      expect(
        find.descendant(
          of: find.byType(CupertinoActionSheet),
          matching: find.text(kind),
        ),
        findsOneWidget,
        reason: kind,
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('My Info: tabs switch, and Contact shows the real email', (
    tester,
  ) async {
    await pump(tester, const ProfileScreen());
    expect(find.text(currentEmployee.jobTitle), findsWidgets);

    await tester.tap(find.text('Contact'));
    await settle(tester);
    expect(find.text(currentEmployee.email), findsOneWidget);

    await tester.tap(find.text('Pay'));
    await settle(tester);
    expect(
      find.text(formatRupees(currentEmployee.grossMonthly)),
      findsOneWidget,
    );

    await tester.tap(find.text('Emergency'));
    await settle(tester);
    expect(find.text('Manage contacts & insurance'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

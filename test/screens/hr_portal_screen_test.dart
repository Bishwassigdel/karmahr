import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_first_flutter_app/l10n/app_localizations.dart';
import 'package:my_first_flutter_app/main.dart';
import 'package:my_first_flutter_app/screens/hr/hr_portal_screen.dart';
import 'package:my_first_flutter_app/screens/notifications_screen.dart';

Future<void> pumpHr(
  WidgetTester tester, {
  required double width,
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = Size(width, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MultiProvider(
      providers: appProviders(),
      child: CupertinoApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: const HrPortalScreen(),
      ),
    ),
  );
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  // A tab label inside the bottom bar (the same word can also appear in
  // page content).
  Finder tab(String label) => find.descendant(
    of: find.byType(CupertinoTabBar),
    matching: find.text(label),
  );

  testWidgets('wide screen shows the sidebar with every section', (
    tester,
  ) async {
    await pumpHr(tester, width: 1280);

    for (final label in [
      'Overview',
      'Employees',
      'Leave & Holidays',
      'Payroll',
      'Notices',
      'Reports',
    ]) {
      expect(find.text(label), findsWidgets, reason: label);
    }
    // The sidebar replaces the phone tab bar.
    expect(find.byType(CupertinoTabBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('clicking a sidebar section swaps the content', (tester) async {
    await pumpHr(tester, width: 1280);

    await tester.tap(find.text('Payroll'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Pay period'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('phone shows a bottom tab bar with five tabs', (tester) async {
    await pumpHr(tester, width: 390);

    expect(find.byType(CupertinoTabBar), findsOneWidget);
    for (final label in ['Home', 'Employees', 'Leave', 'Payroll', 'More']) {
      expect(tab(label), findsOneWidget, reason: label);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('phone: Home is titled KarmaHR and has the notification bell', (
    tester,
  ) async {
    await pumpHr(tester, width: 390);

    expect(
      find.descendant(
        of: find.byType(CupertinoNavigationBar),
        matching: find.text('KarmaHR'),
      ),
      findsOneWidget,
    );
    expect(find.byType(NotificationBell), findsOneWidget);

    // Other tabs are plain section pages, as on the employee side.
    await tester.tap(tab('Payroll'));
    await tester.pumpAndSettle();
    expect(find.byType(NotificationBell), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide screen has the notification bell too', (tester) async {
    await pumpHr(tester, width: 1280);

    expect(find.byType(NotificationBell), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('phone: tapping a tab shows that section', (tester) async {
    await pumpHr(tester, width: 390);

    await tester.tap(tab('Payroll'));
    await tester.pumpAndSettle();

    expect(find.text('Pay period'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('phone: More lists Notices and Reports, which open pages', (
    tester,
  ) async {
    await pumpHr(tester, width: 390);

    await tester.tap(tab('More'));
    await tester.pumpAndSettle();
    expect(find.text('Notices'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);

    await tester.tap(find.text('Reports'));
    await tester.pumpAndSettle();
    expect(find.text('Headcount'), findsOneWidget);
    // The tab bar stays visible on the pushed page.
    expect(find.byType(CupertinoTabBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('overview shows headcount and upcoming people events', (
    tester,
  ) async {
    await pumpHr(tester, width: 1280);

    expect(find.text('Departments'), findsOneWidget);
    expect(find.text('Employees by department'), findsOneWidget);
    expect(find.text('Birthdays & work anniversaries'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('every layout renders in Nepali without overflow', (
    tester,
  ) async {
    for (final width in [320.0, 768.0, 1280.0]) {
      await pumpHr(tester, width: width, locale: const Locale('ne'));
      expect(tester.takeException(), isNull, reason: 'width $width');
    }
  });

  testWidgets('phone More tab renders in Nepali at a narrow width', (
    tester,
  ) async {
    await pumpHr(tester, width: 320, locale: const Locale('ne'));

    await tester.tap(tab('थप'));
    await tester.pumpAndSettle();

    expect(find.text('लग आउट'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

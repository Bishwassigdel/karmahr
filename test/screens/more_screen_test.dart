import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_first_flutter_app/data/current_employee.dart';
import 'package:my_first_flutter_app/l10n/app_localizations.dart';
import 'package:my_first_flutter_app/main.dart';
import 'package:my_first_flutter_app/screens/apps_screen.dart';
import 'package:my_first_flutter_app/screens/main_nav_screen.dart';
import 'package:my_first_flutter_app/screens/profile_screen.dart';
import 'package:my_first_flutter_app/screens/settings_screen.dart';

Future<void> pumpEmployeeApp(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(393, 2400);
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
        home: const MainNavScreen(),
      ),
    ),
  );
  await settle(tester);
}

// Bounded settling: the Home tab has spinners that never stop.
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

  testWidgets('the tab bar has More where Apps used to be', (tester) async {
    await pumpEmployeeApp(tester);

    expect(tab('More'), findsOneWidget);
    expect(tab('Apps'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('More shows Profile, Apps, Settings and Log Out', (tester) async {
    await pumpEmployeeApp(tester);
    await tester.tap(tab('More'));
    await settle(tester);

    expect(find.text(currentEmployee.name), findsOneWidget);
    expect(find.text('Apps'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('More → Apps opens the full list of apps', (tester) async {
    await pumpEmployeeApp(tester);
    await tester.tap(tab('More'));
    await settle(tester);

    await tester.tap(find.text('Apps'));
    await settle(tester);

    expect(find.byType(AppsScreen), findsOneWidget);
    // The tab bar stays visible, so the user is still "in More".
    expect(find.byType(CupertinoTabBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('More → Profile and More → Settings open their screens', (
    tester,
  ) async {
    await pumpEmployeeApp(tester);
    await tester.tap(tab('More'));
    await settle(tester);

    await tester.tap(find.text(currentEmployee.name));
    await settle(tester);
    expect(find.byType(ProfileScreen), findsOneWidget);

    await tester.pageBack();
    await settle(tester);

    await tester.tap(find.text('Settings'));
    await settle(tester);
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('More → Log Out asks before logging out', (tester) async {
    await pumpEmployeeApp(tester);
    await tester.tap(tab('More'));
    await settle(tester);

    await tester.tap(find.text('Log Out'));
    await settle(tester);

    expect(find.text('Are you sure you want to log out?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('More reads in Nepali at a narrow width', (tester) async {
    tester.view.physicalSize = const Size(320, 2400);
    await pumpEmployeeApp(tester, locale: const Locale('ne'));
    await tester.tap(tab('थप'));
    await settle(tester);

    expect(find.text('एप्स'), findsOneWidget);
    expect(find.text('लग आउट'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

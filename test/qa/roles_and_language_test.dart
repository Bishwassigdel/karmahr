// QA: the demo role picker opens the right portal, logout signs out, and
// the language setting switches the app's text.

import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_first_flutter_app/l10n/app_localizations.dart';
import 'package:my_first_flutter_app/main.dart';
import 'package:my_first_flutter_app/screens/app_lock_gate.dart';
import 'package:my_first_flutter_app/screens/hr/hr_portal_screen.dart';
import 'package:my_first_flutter_app/screens/login_screen.dart';
import 'package:my_first_flutter_app/screens/main_nav_screen.dart';
import 'package:my_first_flutter_app/screens/settings_screen.dart';
import 'package:my_first_flutter_app/state/auth_state.dart';
import 'package:my_first_flutter_app/state/locale_state.dart';

// Like the real app: the locale follows LocaleState.
Future<BuildContext> pumpApp(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(393, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MultiProvider(
      providers: appProviders(),
      child: Consumer<LocaleState>(
        builder: (context, locale, _) => CupertinoApp(
          locale: locale.language.locale,
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
    ),
  );
  await settle(tester);
  return tester.element(find.byWidget(screen));
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

// State lookups go through the app root: the login screen's own context
// is gone once sign-in replaces it.
AuthState auth(WidgetTester tester) =>
    tester.element(find.byType(CupertinoApp)).read<AuthState>();

Future<void> signInAs(WidgetTester tester, String roleLabel) async {
  await tester.tap(find.text(roleLabel));
  await settle(tester);
  await tester.tap(find.text('Sign In'));
  await settle(tester);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Employee sign-in opens the employee app without a Team tab', (
    tester,
  ) async {
    await pumpApp(tester, const LoginScreen());
    await signInAs(tester, 'Employee');

    expect(auth(tester).role, UserRole.employee);
    expect(find.byType(MainNavScreen), findsOneWidget);
    expect(find.text('Team'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Manager sign-in adds a Team tab', (tester) async {
    await pumpApp(tester, const LoginScreen());
    await signInAs(tester, 'Manager');

    expect(auth(tester).role, UserRole.manager);
    await tester.tap(find.text('Team'));
    await settle(tester);
    expect(find.text('Manager tools are on the way'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('HR sign-in opens the HR portal, and logout signs out', (
    tester,
  ) async {
    await pumpApp(tester, const LoginScreen());
    await signInAs(tester, 'HR');

    expect(find.byType(HrPortalScreen), findsOneWidget);
    expect(find.text('Signed in as HR'), findsOneWidget);

    await tester.tap(find.text('Log Out'));
    await settle(tester);
    // The dialog's destructive button (the nav bar button is behind it).
    await tester.tap(find.text('Log Out').last);
    await settle(tester);

    expect(auth(tester).isSignedIn, isFalse);
    // Back to the start, behind the lock gate. (In a widget test the gate
    // stays on its loading spinner: the device check is a platform call.)
    expect(find.byType(AppLockGate), findsOneWidget);
    expect(find.byType(HrPortalScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('choosing नेपाली in Settings switches the text to Nepali', (
    tester,
  ) async {
    final context = await pumpApp(tester, const SettingsScreen());
    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.text('नेपाली'));
    await settle(tester);

    expect(context.read<LocaleState>().language, AppLanguage.nepali);
    expect(find.text('सेटिङ'), findsOneWidget);
    expect(find.text('भाषा'), findsOneWidget);
    // Language names stay in their own script whatever is selected.
    expect(find.text('English'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('login screen reads in Nepali when Nepali is chosen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'appLanguage': 'nepali'});
    await pumpApp(tester, const LoginScreen());

    expect(find.text('KarmaHR मा साइन इन गर्नुहोस्'), findsOneWidget);
    expect(find.text('प्रबन्धक'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

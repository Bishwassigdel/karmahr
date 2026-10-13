import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_first_flutter_app/data/current_employee.dart';
import 'package:my_first_flutter_app/l10n/app_localizations.dart';
import 'package:my_first_flutter_app/main.dart';
import 'package:my_first_flutter_app/screens/hr/hr_portal_screen.dart';
import 'package:my_first_flutter_app/screens/login_screen.dart';
import 'package:my_first_flutter_app/screens/main_nav_screen.dart';
import 'package:my_first_flutter_app/screens/owner/owner_portal_screen.dart';
import 'package:my_first_flutter_app/screens/welcome_screen.dart';
import 'package:my_first_flutter_app/state/auth_repository.dart';
import 'package:my_first_flutter_app/state/auth_state.dart';

/// A login system we control: no network, answers set by each test.
class FakeAuth implements AuthRepository {
  FakeAuth({this.result, this.failure, this.saved});

  final AppUser? result;
  final AuthFailure? failure;

  /// The person a saved session would bring back.
  final AppUser? saved;

  final signIns = <(String, String)>[];
  var signOuts = 0;

  /// When set, sign-in waits for it, to test the "waiting" state.
  Completer<void>? gate;

  @override
  bool get usesBackend => true;

  @override
  Future<AppUser> signIn(String email, String password) async {
    signIns.add((email, password));
    await gate?.future;
    if (failure != null) throw failure!;
    return result!;
  }

  @override
  Future<AppUser?> restoreSession() async => saved;

  @override
  Future<void> signOut() async => signOuts++;
  // The account methods (sign-up, passwords) aren't used by these tests.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AppUser person(UserRole role) =>
    AppUser(role: role, name: 'Test Person', companyId: 'c1');

Future<BuildContext> pump(
  WidgetTester tester,
  FakeAuth fake, {
  Widget home = const LoginScreen(),
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(430, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ...appProviders(),
        // Last, so it wins over the app's own repository.
        Provider<AuthRepository>.value(value: fake),
      ],
      child: CupertinoApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: home,
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
  return tester.element(find.byType(CupertinoApp));
}

Future<void> fillAndSignIn(
  WidgetTester tester, {
  String email = 'hari@karma.com',
  String password = 'secret123',
  String button = 'Sign In',
}) async {
  final fields = find.byType(CupertinoTextField);
  await tester.enterText(fields.at(0), email);
  await tester.enterText(fields.at(1), password);
  await tester.tap(find.text(button));
  await tester.pump();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    resetCurrentEmployee();
  });
  tearDown(resetCurrentEmployee);

  group('the login screen with a real backend', () {
    testWidgets('asks for an email and has no demo role picker', (
      tester,
    ) async {
      await pump(tester, FakeAuth());
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Staff ID'), findsNothing);
      expect(find.textContaining('Sign in as (demo)'), findsNothing);
      expect(
        find.byType(CupertinoSlidingSegmentedControl<UserRole>),
        findsNothing,
      );
    });

    testWidgets('empty fields are refused without calling the server', (
      tester,
    ) async {
      final fake = FakeAuth(result: person(UserRole.hr));
      await pump(tester, fake);
      await tester.tap(find.text('Sign In'));
      await tester.pump();
      expect(find.text('Enter your email and password.'), findsOneWidget);
      expect(fake.signIns, isEmpty);
    });

    testWidgets('the email is trimmed and sent with the password', (
      tester,
    ) async {
      final fake = FakeAuth(result: person(UserRole.hr));
      await pump(tester, fake);
      await fillAndSignIn(tester, email: '  hari@karma.com ');
      await tester.pumpAndSettle();
      expect(fake.signIns, [('hari@karma.com', 'secret123')]);
    });

    for (final c in [
      (UserRole.employee, find.byType(MainNavScreen), 'employee'),
      (UserRole.hr, find.byType(HrPortalScreen), 'HR'),
      (UserRole.owner, find.byType(OwnerPortalScreen), 'executive'),
    ]) {
      testWidgets('the ${c.$3} role opens its own portal', (tester) async {
        final ctx = await pump(tester, FakeAuth(result: person(c.$1)));
        await fillAndSignIn(tester);
        await tester.pumpAndSettle();
        expect(c.$2, findsOneWidget);
        expect(ctx.read<AuthState>().role, c.$1);
        expect(ctx.read<AuthState>().user?.name, 'Test Person');
      });
    }

    testWidgets('the employee app greets the person who signed in', (
      tester,
    ) async {
      final sita = AppUser(
        role: UserRole.employee,
        name: 'Sita Employee',
        companyId: 'c1',
        profile: EmployeeProfile(
          name: 'Sita Employee',
          employeeId: 'KD-2',
          jobTitle: 'Support Agent',
          department: 'Support',
          manager: 'Hari HR',
          joiningDate: DateTime(2025, 3, 1),
          employmentType: 'Full-Time',
          workLocation: 'Kathmandu',
          email: 'sita@karma.com',
          basicSalary: 30000,
          dearnessAllowance: 2000,
          transportAllowance: 1000,
        ),
      );
      await pump(tester, FakeAuth(result: sita));
      await fillAndSignIn(tester);
      await tester.pumpAndSettle();

      expect(find.byType(MainNavScreen), findsOneWidget);
      expect(find.textContaining('Sita'), findsWidgets);
      // Not the demo person.
      expect(
        find.textContaining(demoEmployee.name.split(' ').first),
        findsNothing,
      );
    });

    testWidgets('a wrong password says so and stays on the login screen', (
      tester,
    ) async {
      final ctx = await pump(
        tester,
        FakeAuth(
          failure: const AuthFailure(AuthFailureReason.wrongCredentials),
        ),
      );
      await fillAndSignIn(tester);
      await tester.pumpAndSettle();
      expect(find.text('Wrong email or password.'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(ctx.read<AuthState>().isSignedIn, isFalse);
    });

    testWidgets('a login with no profile explains what to do', (tester) async {
      await pump(
        tester,
        FakeAuth(failure: const AuthFailure(AuthFailureReason.noProfile)),
      );
      await fillAndSignIn(tester);
      await tester.pumpAndSettle();
      expect(find.textContaining('Ask your company admin'), findsOneWidget);
    });

    testWidgets('a deactivated account says so and stays signed out', (
      tester,
    ) async {
      final ctx = await pump(
        tester,
        FakeAuth(failure: const AuthFailure(AuthFailureReason.deactivated)),
      );
      await fillAndSignIn(tester);
      await tester.pumpAndSettle();
      expect(find.textContaining('has been deactivated'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(ctx.read<AuthState>().isSignedIn, isFalse);
    });

    testWidgets('a network problem says so, and you can try again', (
      tester,
    ) async {
      final fake = FakeAuth(
        failure: const AuthFailure(AuthFailureReason.network),
      );
      await pump(tester, fake);
      await fillAndSignIn(tester);
      await tester.pumpAndSettle();
      expect(find.textContaining('Check your internet'), findsOneWidget);
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();
      expect(fake.signIns.length, 2);
    });

    testWidgets('while waiting, a second tap does not sign in twice', (
      tester,
    ) async {
      final fake = FakeAuth(result: person(UserRole.hr))
        ..gate = Completer<void>();
      await pump(tester, fake);
      await fillAndSignIn(tester);
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      await tester.tap(find.byType(CupertinoButton).first, warnIfMissed: false);
      await tester.pump();
      expect(fake.signIns.length, 1);

      fake.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(HrPortalScreen), findsOneWidget);
    });

    testWidgets('an old error goes away when the next attempt starts', (
      tester,
    ) async {
      final fake = FakeAuth(
        failure: const AuthFailure(AuthFailureReason.wrongCredentials),
      )..gate = Completer<void>();
      await pump(tester, fake);
      await tester.tap(find.text('Sign In'));
      await tester.pump();
      expect(find.text('Enter your email and password.'), findsOneWidget);
      await fillAndSignIn(tester);
      expect(find.text('Enter your email and password.'), findsNothing);
      fake.gate!.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('messages and labels are in Nepali too', (tester) async {
      await pump(
        tester,
        FakeAuth(
          failure: const AuthFailure(AuthFailureReason.wrongCredentials),
        ),
        locale: const Locale('ne'),
      );
      expect(find.text('इमेल'), findsOneWidget);
      await fillAndSignIn(tester, button: 'साइन इन');
      await tester.pumpAndSettle();
      expect(find.text('इमेल वा पासवर्ड मिलेन।'), findsOneWidget);
    });
  });

  group('the login screen without a backend (demo)', () {
    testWidgets('keeps the Staff ID field and the role picker', (tester) async {
      tester.view.physicalSize = const Size(430, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MultiProvider(
          providers: appProviders(),
          child: const CupertinoApp(home: LoginScreen()),
        ),
      );
      await tester.pump();
      expect(find.text('Staff ID'), findsOneWidget);
      expect(
        find.byType(CupertinoSlidingSegmentedControl<UserRole>),
        findsOneWidget,
      );
    });
  });

  group('stay signed in', () {
    testWidgets('a saved session skips the welcome screen', (tester) async {
      final ctx = await pump(
        tester,
        FakeAuth(saved: person(UserRole.hr)),
        home: const WelcomeScreen(),
      );
      await tester.pumpAndSettle();
      expect(find.byType(HrPortalScreen), findsOneWidget);
      expect(find.byType(WelcomeScreen), findsNothing);
      expect(ctx.read<AuthState>().role, UserRole.hr);
    });

    testWidgets('each saved role goes straight to its own portal', (
      tester,
    ) async {
      await pump(
        tester,
        FakeAuth(saved: person(UserRole.owner)),
        home: const WelcomeScreen(),
      );
      await tester.pumpAndSettle();
      expect(find.byType(OwnerPortalScreen), findsOneWidget);
    });

    testWidgets('with no saved session the welcome screen stays', (
      tester,
    ) async {
      final ctx = await pump(tester, FakeAuth(), home: const WelcomeScreen());
      await tester.pumpAndSettle();
      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(ctx.read<AuthState>().isSignedIn, isFalse);
    });
  });
}

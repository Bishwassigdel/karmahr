import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_first_flutter_app/data/current_employee.dart';
import 'package:my_first_flutter_app/l10n/app_localizations.dart';
import 'package:my_first_flutter_app/main.dart';
import 'package:my_first_flutter_app/screens/account/activate_account_screen.dart';
import 'package:my_first_flutter_app/screens/account/change_password_screen.dart';
import 'package:my_first_flutter_app/screens/account/forgot_password_screen.dart';
import 'package:my_first_flutter_app/screens/hr/hr_employee_detail_screen.dart';
import 'package:my_first_flutter_app/screens/login_screen.dart';
import 'package:my_first_flutter_app/screens/main_nav_screen.dart';
import 'package:my_first_flutter_app/state/auth_repository.dart';
import 'package:my_first_flutter_app/state/auth_state.dart';
import 'package:my_first_flutter_app/state/employee_records_state.dart';
import 'package:my_first_flutter_app/state/employee_repository.dart';
import 'package:my_first_flutter_app/state/invite_repository.dart';

import '../helpers/fake_account.dart';

const employeeUser = AppUser(
  role: UserRole.employee,
  name: 'Sita Staff',
  companyId: 'c1',
);

Future<BuildContext> pumpAccount(
  WidgetTester tester,
  Widget home, {
  AccountFakeAuth? auth,
  InviteRepository? invites,
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(430, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ...appProviders(),
        Provider<AuthRepository>.value(value: auth ?? AccountFakeAuth()),
        Provider<InviteRepository>.value(
          value: invites ?? FakeInviteRepository(),
        ),
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

Future<void> typeInto(WidgetTester tester, List<String> texts) async {
  final fields = find.byType(CupertinoTextField);
  for (var i = 0; i < texts.length; i++) {
    await tester.enterText(fields.at(i), texts[i]);
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    resetCurrentEmployee();
  });
  tearDown(resetCurrentEmployee);

  group('activate an invited account', () {
    testWidgets('asks for a code, then signs the person in', (tester) async {
      final auth = AccountFakeAuth(signedUp: employeeUser);
      final ctx = await pumpAccount(
        tester,
        const ActivateAccountScreen(),
        auth: auth,
      );
      await typeInto(tester, ['sita@karma.com', 'longenough1', 'longenough1']);
      await tester.tap(find.text('Send code'));
      await tester.pumpAndSettle();

      expect(auth.calls, ['startSignUp sita@karma.com longenough1']);
      expect(find.textContaining('sita@karma.com'), findsOneWidget);

      await typeInto(tester, ['123456']);
      await tester.tap(find.text('Activate'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(auth.calls.last, 'finishSignUp sita@karma.com 123456');
      expect(ctx.read<AuthState>().user?.name, 'Sita Staff');
      expect(find.byType(MainNavScreen), findsOneWidget);
    });

    testWidgets('a short password is refused before anything is sent', (
      tester,
    ) async {
      final auth = AccountFakeAuth();
      await pumpAccount(tester, const ActivateAccountScreen(), auth: auth);
      await typeInto(tester, ['sita@karma.com', 'short', 'short']);
      await tester.tap(find.text('Send code'));
      await tester.pumpAndSettle();
      expect(find.text('Use at least 8 characters.'), findsOneWidget);
      expect(auth.calls, isEmpty);
    });

    testWidgets('mismatched passwords and a bad email are refused', (
      tester,
    ) async {
      final auth = AccountFakeAuth();
      await pumpAccount(tester, const ActivateAccountScreen(), auth: auth);
      await typeInto(tester, ['not-an-email', 'longenough1', 'longenough1']);
      await tester.tap(find.text('Send code'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid email address.'), findsOneWidget);

      await typeInto(tester, ['sita@karma.com', 'longenough1', 'different99']);
      await tester.tap(find.text('Send code'));
      await tester.pumpAndSettle();
      expect(find.text("The two passwords don't match."), findsOneWidget);
      expect(auth.calls, isEmpty);
    });

    testWidgets('a wrong code says so and stays on the code step', (
      tester,
    ) async {
      final auth = AccountFakeAuth()
        ..failFinish = const AuthFailure(AuthFailureReason.invalidCode);
      final ctx = await pumpAccount(
        tester,
        const ActivateAccountScreen(),
        auth: auth,
      );
      await typeInto(tester, ['sita@karma.com', 'longenough1', 'longenough1']);
      await tester.tap(find.text('Send code'));
      await tester.pumpAndSettle();
      await typeInto(tester, ['000000']);
      await tester.tap(find.text('Activate'));
      await tester.pumpAndSettle();

      expect(find.textContaining('wrong or has expired'), findsOneWidget);
      expect(ctx.read<AuthState>().isSignedIn, isFalse);
      expect(find.text('Send a new code'), findsOneWidget);
    });

    testWidgets('an email HR never invited explains what to do', (
      tester,
    ) async {
      final auth = AccountFakeAuth()
        ..failFinish = const AuthFailure(AuthFailureReason.noProfile);
      await pumpAccount(tester, const ActivateAccountScreen(), auth: auth);
      await typeInto(tester, ['x@karma.com', 'longenough1', 'longenough1']);
      await tester.tap(find.text('Send code'));
      await tester.pumpAndSettle();
      await typeInto(tester, ['123456']);
      await tester.tap(find.text('Activate'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Ask your company admin'), findsOneWidget);
    });

    testWidgets('works in Nepali', (tester) async {
      await pumpAccount(
        tester,
        const ActivateAccountScreen(),
        locale: const Locale('ne'),
      );
      expect(find.text('खाता सक्रिय गर्नुहोस्'), findsOneWidget);
      expect(find.text('कोड पठाउनुहोस्'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('forgot password', () {
    testWidgets('code, new password, then back to the login screen', (
      tester,
    ) async {
      final auth = AccountFakeAuth();
      await pumpAccount(
        tester,
        const CupertinoPageScaffold(child: SizedBox()),
        auth: auth,
      );
      final nav = tester.state<NavigatorState>(find.byType(Navigator));
      nav.push(
        CupertinoPageRoute<void>(builder: (_) => const ForgotPasswordScreen()),
      );
      await tester.pumpAndSettle();

      await typeInto(tester, ['hari@karma.com']);
      await tester.tap(find.text('Send code'));
      await tester.pumpAndSettle();
      expect(auth.calls, ['sendPasswordReset hari@karma.com']);

      await typeInto(tester, ['654321', 'brandnew123', 'brandnew123']);
      await tester.tap(find.text('Reset password').last);
      await tester.pumpAndSettle();
      expect(
        auth.calls.last,
        'resetPassword hari@karma.com 654321 brandnew123',
      );
      expect(find.text('Password changed'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(ForgotPasswordScreen), findsNothing);
    });

    testWidgets('a wrong code keeps the person on the screen', (tester) async {
      final auth = AccountFakeAuth()
        ..failReset = const AuthFailure(AuthFailureReason.invalidCode);
      await pumpAccount(tester, const ForgotPasswordScreen(), auth: auth);
      await typeInto(tester, ['hari@karma.com']);
      await tester.tap(find.text('Send code'));
      await tester.pumpAndSettle();
      await typeInto(tester, ['111111', 'brandnew123', 'brandnew123']);
      await tester.tap(find.text('Reset password').last);
      await tester.pumpAndSettle();
      expect(find.textContaining('wrong or has expired'), findsOneWidget);
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    });

    testWidgets('the login screen links to it, and to activation', (
      tester,
    ) async {
      await pumpAccount(tester, const LoginScreen());
      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
      Navigator.of(tester.element(find.byType(ForgotPasswordScreen))).pop();
      await tester.pumpAndSettle();

      await tester.tap(find.text('First time here? Activate your account'));
      await tester.pumpAndSettle();
      expect(find.byType(ActivateAccountScreen), findsOneWidget);
    });
  });

  group('change password', () {
    testWidgets('saves with the current password, then confirms', (
      tester,
    ) async {
      final auth = AccountFakeAuth();
      await pumpAccount(tester, const ChangePasswordScreen(), auth: auth);
      await typeInto(tester, ['oldpass1234', 'brandnew123', 'brandnew123']);
      await tester.tap(find.widgetWithText(CupertinoButton, 'Change password'));
      await tester.pumpAndSettle();
      expect(auth.calls, ['changePassword oldpass1234 brandnew123']);
      expect(find.text('Your password was changed.'), findsOneWidget);
    });

    testWidgets('a wrong current password is reported', (tester) async {
      final auth = AccountFakeAuth()
        ..failChange = const AuthFailure(AuthFailureReason.wrongCredentials);
      await pumpAccount(tester, const ChangePasswordScreen(), auth: auth);
      await typeInto(tester, ['wrongone123', 'brandnew123', 'brandnew123']);
      await tester.tap(find.widgetWithText(CupertinoButton, 'Change password'));
      await tester.pumpAndSettle();
      expect(find.text("Your current password isn't right."), findsOneWidget);
    });

    testWidgets(
      'the same password again is refused without asking the server',
      (tester) async {
        final auth = AccountFakeAuth();
        await pumpAccount(tester, const ChangePasswordScreen(), auth: auth);
        await typeInto(tester, ['samepass123', 'samepass123', 'samepass123']);
        await tester.tap(
          find.widgetWithText(CupertinoButton, 'Change password'),
        );
        await tester.pumpAndSettle();
        expect(
          find.textContaining('different from your current'),
          findsOneWidget,
        );
        expect(auth.calls, isEmpty);
      },
    );
  });

  group('HR invites an employee', () {
    Future<BuildContext> pumpDetail(
      WidgetTester tester,
      FakeInviteRepository invites, {
      String? staffId,
    }) async {
      final ctx = await pumpAccount(
        tester,
        HrEmployeeDetailScreen(employeeId: staffId ?? _firstActive(tester)),
        invites: invites,
      );
      await tester.pumpAndSettle();
      return ctx;
    }

    testWidgets('shows the status and sends the invite after asking', (
      tester,
    ) async {
      final invites = FakeInviteRepository();
      // The demo records have emails; find one to invite.
      final records = EmployeeRecordsState(repository: DemoEmployeeRepository())
          .active;
      final person = records.firstWhere((r) => r.email.isNotEmpty);
      await pumpDetail(tester, invites, staffId: person.id);

      expect(find.text('No login yet'), findsOneWidget);
      await tester.ensureVisible(find.text('Invite to sign in'));
      await tester.tap(find.text('Invite to sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Invite ${person.name}?'), findsOneWidget);
      await tester.tap(find.text('Invite').last);
      await tester.pumpAndSettle();

      expect(invites.calls, ['invite ${person.id} ${person.email}']);
      expect(
        find.textContaining('Waiting for them to activate'),
        findsOneWidget,
      );
      expect(find.text('Cancel invite'), findsOneWidget);
    });

    testWidgets('cancelling an invite puts it back to no login', (
      tester,
    ) async {
      final person = EmployeeRecordsState(repository: DemoEmployeeRepository())
          .active
          .first;
      final invites = FakeInviteRepository(
        AccountInfo(AccountStatus.invited, person.email),
      );
      await pumpDetail(tester, invites, staffId: person.id);
      await tester.ensureVisible(find.text('Cancel invite'));
      await tester.tap(find.text('Cancel invite'));
      await tester.pumpAndSettle();
      expect(invites.calls, ['cancel ${person.id}']);
      expect(find.text('No login yet'), findsOneWidget);
    });

    testWidgets('someone who already has a login can\'t be invited again', (
      tester,
    ) async {
      final person = EmployeeRecordsState(repository: DemoEmployeeRepository())
          .active
          .first;
      final invites = FakeInviteRepository(
        const AccountInfo(AccountStatus.active),
      );
      await pumpDetail(tester, invites, staffId: person.id);
      expect(find.text('Has a login'), findsOneWidget);
      expect(find.text('Invite to sign in'), findsNothing);
    });

    testWidgets('a failed invite is explained', (tester) async {
      final person = EmployeeRecordsState(repository: DemoEmployeeRepository())
          .active
          .firstWhere((r) => r.email.isNotEmpty);
      final invites = FakeInviteRepository()
        ..failNextWrite = const SaveFailure(SaveProblem.notAllowed);
      await pumpDetail(tester, invites, staffId: person.id);
      await tester.ensureVisible(find.text('Invite to sign in'));
      await tester.tap(find.text('Invite to sign in'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Invite').last);
      await tester.pumpAndSettle();
      expect(find.text("Couldn't save"), findsOneWidget);
      expect(invites.info.status, AccountStatus.none);
    });

    testWidgets('without a backend the section is not shown at all', (
      tester,
    ) async {
      final person = EmployeeRecordsState(repository: DemoEmployeeRepository())
          .active
          .first;
      await pumpAccount(
        tester,
        HrEmployeeDetailScreen(employeeId: person.id),
        invites: DemoInviteRepository(),
      );
      await tester.pumpAndSettle();
      expect(find.text('Invite to sign in'), findsNothing);
      expect(find.text('No login yet'), findsNothing);
    });
  });
}

String _firstActive(WidgetTester tester) =>
    EmployeeRecordsState(repository: DemoEmployeeRepository()).active.first.id;

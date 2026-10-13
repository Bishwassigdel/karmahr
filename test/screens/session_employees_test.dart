import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_first_flutter_app/data/current_employee.dart';
import 'package:my_first_flutter_app/l10n/app_localizations.dart';
import 'package:my_first_flutter_app/main.dart';
import 'package:my_first_flutter_app/screens/app_lock_gate.dart';
import 'package:my_first_flutter_app/screens/login_screen.dart';
import 'package:my_first_flutter_app/screens/logout.dart';
import 'package:my_first_flutter_app/screens/welcome_screen.dart';
import 'package:my_first_flutter_app/state/auth_repository.dart';
import 'package:my_first_flutter_app/state/employee_records_state.dart';
import 'package:my_first_flutter_app/state/auth_state.dart';

import '../helpers/fake_employee_repository.dart';

/// A login system we control.
class FakeAuth implements AuthRepository {
  FakeAuth({this.result, this.saved});
  final AppUser? result;
  final AppUser? saved;
  var signOuts = 0;

  @override
  bool get usesBackend => true;
  @override
  Future<AppUser> signIn(String email, String password) async => result!;
  @override
  Future<AppUser?> restoreSession() async => saved;
  @override
  Future<void> signOut() async => signOuts++;
  // The account methods (sign-up, passwords) aren't used by these tests.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const hrUser = AppUser(role: UserRole.hr, name: 'Hari Hr', companyId: 'c1');

late FakeEmployeeRepository repo;
late EmployeeRecordsState state;

Future<BuildContext> pump(
  WidgetTester tester,
  FakeAuth auth,
  Widget home,
) async {
  tester.view.physicalSize = const Size(430, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ...appProviders(),
        Provider<AuthRepository>.value(value: auth),
        ChangeNotifierProvider<EmployeeRecordsState>.value(value: state),
      ],
      child: CupertinoApp(
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

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    resetCurrentEmployee();
    repo = FakeEmployeeRepository(
      stored: [person('HT-001', 'Hari Hr'), person('HT-002', 'Sita Employee')],
    );
    state = EmployeeRecordsState(repository: repo);
  });
  tearDown(resetCurrentEmployee);

  testWidgets('nothing is loaded before anyone signs in', (tester) async {
    await pump(tester, FakeAuth(result: hrUser), const LoginScreen());
    expect(repo.loads, 0);
    expect(state.records, isEmpty);
  });

  testWidgets('signing in loads the company\'s people', (tester) async {
    await pump(tester, FakeAuth(result: hrUser), const LoginScreen());
    final fields = find.byType(CupertinoTextField);
    await tester.enterText(fields.at(0), 'hr@test.com');
    await tester.enterText(fields.at(1), 'secret-pass-1');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(repo.loads, greaterThanOrEqualTo(1));
    expect(state.records.map((r) => r.name), contains('Sita Employee'));
  });

  testWidgets('staying signed in loads them too', (tester) async {
    await pump(tester, FakeAuth(saved: hrUser), const WelcomeScreen());
    await tester.pumpAndSettle();
    expect(repo.loads, greaterThanOrEqualTo(1));
    expect(state.records.length, 2);
  });

  testWidgets('logging out empties the list and ends the real session', (
    tester,
  ) async {
    final auth = FakeAuth(saved: hrUser);
    final ctx = await pump(
      tester,
      auth,
      CupertinoPageScaffold(
        child: Builder(
          builder: (context) => CupertinoButton(
            onPressed: () => confirmLogout(context),
            child: const Text('Open logout'),
          ),
        ),
      ),
    );
    ctx.read<AuthState>().signInAs(hrUser);
    await state.refresh();
    expect(state.records.length, 2);

    await tester.tap(find.text('Open logout'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CupertinoDialogAction, 'Log Out'));
    // Not pumpAndSettle: the app-lock loading spinner animates forever.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }

    expect(state.records, isEmpty);
    expect(auth.signOuts, 1);
    expect(ctx.read<AuthState>().isSignedIn, isFalse);
    // Back to the entry route, which sits behind the app lock.
    expect(find.byType(AppLockGate), findsOneWidget);
  });

  testWidgets('a different company signing in next sees none of the last one', (
    tester,
  ) async {
    final ctx = await pump(tester, FakeAuth(saved: hrUser), const SizedBox());
    ctx.read<AuthState>().signInAs(hrUser);
    await state.refresh();
    expect(state.records.map((r) => r.name), contains('Hari Hr'));

    state.clearForSignOut(); // what logout does
    // The next company's database holds different people.
    repo.stored
      ..clear()
      ..add(person('ET-001', 'Binod Hr'));
    await state.refresh();
    expect(state.records.map((r) => r.name), ['Binod Hr']);
  });
}

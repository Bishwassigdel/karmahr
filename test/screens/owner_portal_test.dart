import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_first_flutter_app/data/company_demo.dart';
import 'package:my_first_flutter_app/domain/owner_insights.dart';
import 'package:my_first_flutter_app/l10n/app_localizations.dart';
import 'package:my_first_flutter_app/main.dart';
import 'package:my_first_flutter_app/screens/apps/widgets/karma_logo.dart';
import 'package:my_first_flutter_app/screens/apps/widgets/ui_kit.dart';
import 'package:my_first_flutter_app/screens/notifications_screen.dart';
import 'package:my_first_flutter_app/screens/owner/owner_activity_screen.dart';
import 'package:my_first_flutter_app/screens/owner/owner_department_screen.dart';
import 'package:my_first_flutter_app/screens/owner/owner_departments_screen.dart';
import 'package:my_first_flutter_app/screens/owner/owner_money_screen.dart';
import 'package:my_first_flutter_app/screens/owner/owner_overview_screen.dart';
import 'package:my_first_flutter_app/screens/owner/owner_people_screen.dart';
import 'package:my_first_flutter_app/screens/owner/owner_person_screen.dart';
import 'package:my_first_flutter_app/screens/owner/owner_portal_screen.dart';
import 'package:my_first_flutter_app/state/audit_log_state.dart';

// A fixed company, so the numbers on screen can be checked against it.
final demo = CompanyDemo.generate(today: DateTime(2026, 10, 5));

Future<void> pump(
  WidgetTester tester,
  Widget screen, {
  double width = 393,
  Locale locale = const Locale('en'),
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = Size(width, 3200);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ...appProviders(),
        // Innermost, so it replaces the app's own demo company.
        Provider<CompanyDemo>.value(value: demo),
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
        home: screen,
      ),
    ),
  );
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

T read<T>(WidgetTester tester) =>
    tester.element(find.byType(CupertinoApp)).read<T>();

Finder tab(String label) => find.descendant(
  of: find.byType(CupertinoTabBar),
  matching: find.text(label),
);

double top(WidgetTester tester, Finder f) => tester.getTopLeft(f.first).dy;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('the portal', () {
    testWidgets('a phone gets five tabs and the logo and bell on Overview', (
      tester,
    ) async {
      await pump(tester, const OwnerPortalScreen());

      for (final label in [
        'Overview',
        'Departments',
        'People',
        'Money',
        'More',
      ]) {
        expect(tab(label), findsOneWidget, reason: label);
      }
      expect(
        find.descendant(
          of: find.byType(CupertinoNavigationBar),
          matching: find.byType(KarmaLogo),
        ),
        findsOneWidget,
      );
      expect(find.byType(NotificationBell), findsOneWidget);
      expect(find.text('Signed in as CEO'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a wide screen gets the sidebar with every section', (
      tester,
    ) async {
      await pump(tester, const OwnerPortalScreen(), width: 1280);

      expect(find.byType(CupertinoTabBar), findsNothing);
      expect(find.byType(KarmaLogo), findsOneWidget);
      for (final label in [
        'Overview',
        'Departments',
        'People',
        'Money',
        'Activity',
      ]) {
        expect(find.text(label), findsWidgets, reason: label);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('sidebar entries swap the content', (tester) async {
      await pump(tester, const OwnerPortalScreen(), width: 1280);

      await tester.tap(find.text('Money'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(OwnerMoneyScreen), findsOneWidget);

      await tester.tap(find.text('Activity'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(OwnerActivityScreen), findsOneWidget);
    });

    testWidgets('More holds Activity, Settings and Log Out', (tester) async {
      await pump(tester, const OwnerPortalScreen());
      await tester.tap(tab('More'));
      await tester.pumpAndSettle();

      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);

      await tester.tap(find.text('Activity'));
      await tester.pumpAndSettle();
      expect(find.byType(OwnerActivityScreen), findsOneWidget);
    });
  });

  group('Overview', () {
    testWidgets('shows the headline numbers', (tester) async {
      await pump(tester, const OwnerOverviewScreen());

      expect(find.text('Headcount'), findsOneWidget);
      expect(find.text('${demo.people.length}'), findsOneWidget);
      expect(find.text('Plan ${demo.planFor()}'), findsOneWidget);
      expect(find.text('Progress score'), findsOneWidget);
      expect(find.text('${demo.progress().score}'), findsWidgets);
      expect(find.text('Attendance'), findsOneWidget);
      expect(find.text('Payroll this month'), findsOneWidget);
      expect(find.textContaining('crore'), findsWidgets);
      expect(find.text('Left in the last year'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'puts what needs attention first, struggling department on top',
      (tester) async {
        await pump(tester, const OwnerOverviewScreen());

        expect(find.text('Needs attention'), findsOneWidget);
        expect(
          find.textContaining('Customer Support is behind on progress'),
          findsOneWidget,
        );
        // The department alert comes before the HR items.
        expect(
          top(tester, find.textContaining('is behind on progress')),
          lessThan(top(tester, find.textContaining('waited over 3 days'))),
        );
      },
    );

    testWidgets('includes the HR portal\'s live items', (tester) async {
      await pump(tester, const OwnerOverviewScreen());

      // Two seeded requests are 3 or more days old.
      expect(find.text('2 requests have waited over 3 days'), findsOneWidget);
      expect(find.text('3 documents expiring soon'), findsOneWidget);
      expect(find.textContaining("isn't approved yet"), findsOneWidget);
    });

    testWidgets('lists departments lowest score first', (tester) async {
      await pump(tester, const OwnerOverviewScreen());

      expect(find.text('Department progress'), findsOneWidget);
      expect(find.text('Lowest score first'), findsOneWidget);
      expect(
        top(tester, find.text('Customer Support')),
        lessThan(top(tester, find.text('Finance'))),
      );
    });

    testWidgets('tapping an alert opens that department', (tester) async {
      await pump(tester, const OwnerOverviewScreen());

      await tester.tap(
        find.textContaining('Customer Support is behind on progress'),
      );
      await tester.pumpAndSettle();
      expect(find.byType(OwnerDepartmentScreen), findsOneWidget);
    });

    testWidgets('says the company is demo data', (tester) async {
      await pump(tester, const OwnerOverviewScreen());
      expect(
        find.textContaining('Demo company of ${demo.people.length} people'),
        findsOneWidget,
      );
    });

    testWidgets('on a wide screen an HR item opens the Activity section', (
      tester,
    ) async {
      await pump(tester, const OwnerPortalScreen(), width: 1280);
      await tester.tap(find.text('2 requests have waited over 3 days'));
      await tester.pumpAndSettle();
      expect(find.byType(OwnerActivityScreen), findsOneWidget);
    });

    testWidgets('on a phone a branch alert opens its people', (tester) async {
      await pump(tester, const OwnerOverviewScreen());
      final branchAlert = companyAttention(demo)
          .where((a) => a.kind == AttentionKind.branchAttendance);
      if (branchAlert.isEmpty) return; // none in this demo; nothing to tap
      await tester.tap(
        find.textContaining(
          '${branchAlert.first.name} attendance is ${branchAlert.first.value}%',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(OwnerPeopleScreen), findsOneWidget);
    });
  });

  group('Departments', () {
    testWidgets('lists all eight, worst first', (tester) async {
      await pump(tester, const OwnerDepartmentsScreen());

      for (final d in demo.depts) {
        expect(find.text(d.name), findsOneWidget, reason: d.name);
      }
      expect(
        top(tester, find.text('Customer Support')),
        lessThan(top(tester, find.text('Information Technology'))),
      );
      expect(find.text('Behind'), findsOneWidget);
      expect(find.text('On track'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the branch filter changes the numbers', (tester) async {
      await pump(tester, const OwnerDepartmentsScreen());
      final all = demo.progress(deptId: 'd-ops');
      expect(
        find.text('${all.headcount} of ${all.plan} planned'),
        findsOneWidget,
      );

      // Kathmandu: big enough that its figures are shown.
      await tester.tap(find.text('Kathmandu'));
      await tester.pumpAndSettle();

      final slice = demo.progress(deptId: 'd-ops', branchId: 'b-ktm');
      expect(
        find.text('${slice.headcount} of ${slice.plan} planned'),
        findsOneWidget,
      );
      expect(slice.headcount, lessThan(all.headcount));
    });

    testWidgets('a slice under five people shows no figures', (tester) async {
      // Find a department and branch that is too small to show.
      String? branchId;
      for (final b in demo.branches) {
        if (demo.depts.any(
          (d) => !largeEnoughToShow(
            demo.progress(deptId: d.id, branchId: b.id).headcount,
          ),
        )) {
          branchId = b.id;
          break;
        }
      }
      expect(branchId, isNotNull);

      await pump(tester, const OwnerDepartmentsScreen());
      await tester.tap(find.text(demo.branchById(branchId!).name));
      await tester.pumpAndSettle();

      expect(find.text('Fewer than $minGroupForStats people'), findsWidgets);
    });

    testWidgets('explains how the score is calculated', (tester) async {
      await pump(tester, const OwnerDepartmentsScreen());
      await tester.tap(find.text('How is progress calculated?'));
      await tester.pumpAndSettle();

      expect(find.textContaining('35% goals on track'), findsOneWidget);
      expect(find.textContaining('25% reviews completed'), findsOneWidget);
      expect(find.textContaining('20% training completed'), findsOneWidget);
      expect(find.textContaining('20% attendance'), findsOneWidget);
      expect(find.textContaining('Fewer than'), findsNothing);
      expect(find.textContaining('fewer than 5 people'), findsOneWidget);
    });

    testWidgets('tapping a department opens it', (tester) async {
      await pump(tester, const OwnerDepartmentsScreen());
      await tester.tap(find.text('Finance'));
      await tester.pumpAndSettle();
      expect(find.byType(OwnerDepartmentScreen), findsOneWidget);
    });
  });

  group('Department detail', () {
    testWidgets('shows score, the four parts, trend, branches and attrition', (
      tester,
    ) async {
      await pump(tester, const OwnerDepartmentScreen(deptId: 'd-support'));
      final p = demo.progress(deptId: 'd-support');

      expect(find.text('${p.score}'), findsWidgets);
      expect(find.text('Behind'), findsOneWidget);
      expect(find.text('Goals on track'), findsOneWidget);
      expect(find.text('Reviews completed'), findsOneWidget);
      expect(find.text('Training completed'), findsOneWidget);
      expect(find.text('Headcount, last 12 months'), findsOneWidget);
      expect(find.text('By branch'), findsOneWidget);
      for (final b in demo.branches) {
        expect(find.text(b.name), findsOneWidget, reason: b.name);
      }
      expect(find.textContaining('Left in the last year'), findsOneWidget);
      expect(find.textContaining('Joined in the last 90 days'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'a branch row opens that branch\'s slice, without a branch list',
      (tester) async {
        await pump(tester, const OwnerDepartmentScreen(deptId: 'd-ops'));
        await tester.tap(find.text('Kathmandu'));
        await tester.pumpAndSettle();

        expect(find.text('Operations · Kathmandu'), findsOneWidget);
        expect(find.text('By branch'), findsNothing);
      },
    );

    testWidgets('See the people opens this department\'s people', (
      tester,
    ) async {
      await pump(tester, const OwnerDepartmentScreen(deptId: 'd-legal'));
      await tester.scrollUntilVisible(
        find.text('See the people'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('See the people'));
      await tester.pumpAndSettle();

      expect(find.byType(OwnerPeopleScreen), findsOneWidget);
      expect(find.text('10 employees'), findsOneWidget);
    });

    testWidgets('a tiny slice shows no figures', (tester) async {
      String? branch;
      for (final b in demo.branches) {
        if (!largeEnoughToShow(
          demo.progress(deptId: 'd-legal', branchId: b.id).headcount,
        )) {
          branch = b.id;
          break;
        }
      }
      await pump(
        tester,
        OwnerDepartmentScreen(deptId: 'd-legal', branchId: branch),
      );
      expect(find.text('Fewer than $minGroupForStats people'), findsOneWidget);
      expect(find.text('Goals on track'), findsNothing);
    });
  });

  group('People', () {
    testWidgets('lists everyone and counts them', (tester) async {
      await pump(tester, const OwnerPeopleScreen());
      expect(find.text('${demo.people.length} employees'), findsOneWidget);
      expect(find.text('All departments'), findsOneWidget);
      expect(find.text('All branches'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('search narrows by name or role', (tester) async {
      await pump(tester, const OwnerPeopleScreen());
      final target = demo.people.firstWhere((p) => p.jobTitle == 'Auditor');

      await tester.enterText(find.byType(CupertinoSearchTextField), 'auditor');
      await tester.pumpAndSettle();

      final expected = demo.people.where((p) => p.jobTitle == 'Auditor').length;
      expect(
        find.text('$expected employee${expected == 1 ? '' : 's'}'),
        findsOneWidget,
      );
      expect(find.text(target.name), findsWidgets);

      await tester.enterText(find.byType(CupertinoSearchTextField), 'zzzz');
      await tester.pumpAndSettle();
      expect(find.text('No one matches.'), findsOneWidget);
    });

    testWidgets('can open already filtered to a department and branch', (
      tester,
    ) async {
      await pump(
        tester,
        const OwnerPeoplePage(initialDeptId: 'd-it', initialBranchId: 'b-ktm'),
      );
      final n = demo.peopleIn(deptId: 'd-it', branchId: 'b-ktm').length;
      expect(find.text('$n employee${n == 1 ? '' : 's'}'), findsOneWidget);
      expect(find.text('Information Technology'), findsOneWidget);
      expect(find.text('Kathmandu'), findsWidgets);
    });

    testWidgets('a long list is built as you scroll, not all at once', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(393, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ...appProviders(),
            Provider<CompanyDemo>.value(value: demo),
          ],
          child: const CupertinoApp(
            home: CupertinoPageScaffold(child: OwnerPeopleScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final built = find.byType(InitialsAvatar).evaluate().length;
      expect(built, lessThan(demo.people.length));
      expect(built, greaterThan(0));
    });

    testWidgets('tapping someone opens their page', (tester) async {
      await pump(tester, const OwnerPeopleScreen());
      final first =
          (demo.people.toList()..sort((a, b) => a.name.compareTo(b.name)))
              .first;
      await tester.tap(find.text(first.name).first);
      await tester.pumpAndSettle();
      expect(find.byType(OwnerPersonScreen), findsOneWidget);
    });
  });

  group('Person', () {
    final person = demo.people.first;

    testWidgets('shows how they are doing, with pay hidden', (tester) async {
      await pump(tester, OwnerPersonScreen(personId: person.id));

      expect(find.text(person.name), findsWidgets);
      expect(find.text('Attendance, last 30 days'), findsOneWidget);
      expect(find.text('${person.attendance}%'), findsOneWidget);
      expect(find.text('Goals this quarter'), findsOneWidget);
      expect(find.text('Monthly pay'), findsOneWidget);
      expect(find.text('Hidden'), findsOneWidget);
      expect(find.textContaining('Rs. '), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Show pay asks first, then shows it and logs it', (
      tester,
    ) async {
      await pump(tester, OwnerPersonScreen(personId: person.id));

      await tester.tap(find.text('Show pay'));
      await tester.pumpAndSettle();
      expect(find.text("Show ${person.name}'s pay?"), findsOneWidget);
      expect(
        find.text("Viewing someone's pay is recorded in the audit log."),
        findsOneWidget,
      );
      expect(read<AuditLogState>(tester).entries, isEmpty);

      await tester.tap(find.text('Show pay').last);
      await tester.pumpAndSettle();

      expect(find.textContaining('Rs. '), findsOneWidget);
      expect(find.text('Hidden'), findsNothing);
      expect(find.text('Hide pay'), findsOneWidget);
      final entry = read<AuditLogState>(tester).entries.single;
      expect(entry.action, AuditAction.payViewed);
      expect(entry.detail, person.name);
    });

    testWidgets('cancelling shows nothing and logs nothing', (tester) async {
      await pump(tester, OwnerPersonScreen(personId: person.id));
      await tester.tap(find.text('Show pay'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Hidden'), findsOneWidget);
      expect(read<AuditLogState>(tester).entries, isEmpty);
    });

    testWidgets('pay can be hidden again', (tester) async {
      await pump(tester, OwnerPersonScreen(personId: person.id));
      await tester.tap(find.text('Show pay'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show pay').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hide pay'));
      await tester.pumpAndSettle();
      expect(find.text('Hidden'), findsOneWidget);
      expect(find.text('Show pay'), findsOneWidget);
    });

    testWidgets('an unknown person shows a message, not an error', (
      tester,
    ) async {
      await pump(tester, const OwnerPersonScreen(personId: 'nobody'));
      expect(find.text('No one matches.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Money', () {
    testWidgets('shows payroll, change, per-employee average and splits', (
      tester,
    ) async {
      await pump(tester, const OwnerMoneyScreen());

      expect(find.text('Payroll this month'), findsOneWidget);
      expect(find.textContaining('vs last month'), findsOneWidget);
      expect(find.textContaining('Average per employee'), findsOneWidget);
      expect(find.text('Payroll, last 12 months'), findsOneWidget);
      expect(find.text('By department'), findsOneWidget);
      expect(find.text('By branch'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the biggest department is listed first', (tester) async {
      await pump(tester, const OwnerMoneyScreen());
      final byAmount = demo.depts.toList()
        ..sort(
          (a, b) => demo
              .payrollAt(0, deptId: b.id)
              .compareTo(demo.payrollAt(0, deptId: a.id)),
        );
      expect(
        top(tester, find.text(byAmount.first.name)),
        lessThan(top(tester, find.text(byAmount.last.name))),
      );
    });
  });

  group('Activity', () {
    testWidgets('lists what is waiting, longest first', (tester) async {
      await pump(tester, const OwnerActivityScreen());

      expect(find.text('Waiting for a decision'), findsOneWidget);
      // Ramesh's ID card request is the oldest, at 4 days.
      expect(find.text('4 days'), findsOneWidget);
      expect(
        top(tester, find.text('ID Card Reissue')),
        lessThan(top(tester, find.text('Phone / Internet · Rs. 1,200'))),
      );
    });

    testWidgets('says so when nothing has happened, then shows the log', (
      tester,
    ) async {
      await pump(tester, const OwnerActivityScreen());
      expect(find.text('Nothing has happened yet.'), findsOneWidget);

      read<AuditLogState>(tester)
          .log(AuditAction.payViewed, 'Sagar Rai', actor: 'Bishwas Sigdel');
      await tester.pumpAndSettle();
      expect(find.text('Pay viewed'), findsOneWidget);
      expect(find.text('Bishwas Sigdel: Sagar Rai'), findsOneWidget);
    });
  });

  group('no overflow, in either language, at narrow width and large text', () {
    final screens = <String, Widget Function()>{
      'portal': () => const OwnerPortalScreen(),
      'overview': () => const OwnerOverviewScreen(),
      'departments': () => const OwnerDepartmentsScreen(),
      'department': () => const OwnerDepartmentScreen(deptId: 'd-support'),
      'people': () => const OwnerPeoplePage(),
      'person': () => OwnerPersonScreen(personId: demo.people.first.id),
      'money': () => const OwnerMoneyScreen(),
      'activity': () => const OwnerActivityScreen(),
    };
    for (final locale in const [Locale('en'), Locale('ne')]) {
      screens.forEach((name, build) {
        testWidgets('$name ${locale.languageCode}', (tester) async {
          await pump(
            tester,
            build(),
            width: 320,
            locale: locale,
            textScale: 1.3,
          );
          expect(tester.takeException(), isNull);
        });
      });
    }
  });
}

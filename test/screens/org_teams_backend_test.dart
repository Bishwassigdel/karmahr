import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_first_flutter_app/l10n/app_localizations.dart';
import 'package:my_first_flutter_app/main.dart';
import 'package:my_first_flutter_app/screens/hr/hr_employee_form_screen.dart';
import 'package:my_first_flutter_app/screens/hr/hr_teams_screen.dart';
import 'package:my_first_flutter_app/state/employee_records_state.dart';
import 'package:my_first_flutter_app/state/employee_repository.dart';
import 'package:my_first_flutter_app/state/org_state.dart';
import 'package:my_first_flutter_app/state/teams_state.dart';

import '../helpers/employee_form.dart';
import '../helpers/fake_employee_repository.dart';
import '../helpers/fake_org_and_teams.dart';

late FakeEmployeeRepository people;
late FakeOrgRepository orgRepo;
late FakeTeamsRepository teamsRepo;
late EmployeeRecordsState records;
late OrgState org;
late TeamsState teams;

Future<void> pump(
  WidgetTester tester,
  Widget screen, {
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(393, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ...appProviders(),
        ChangeNotifierProvider<EmployeeRecordsState>.value(value: records),
        ChangeNotifierProvider<OrgState>.value(value: org),
        ChangeNotifierProvider<TeamsState>.value(value: teams),
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
  await tester.pumpAndSettle();
}

Future<void> fillPerson(WidgetTester tester) => fillForm(tester, {
  EmployeeField.name: 'Nima Sherpa',
  EmployeeField.jobTitle: 'Designer',
  EmployeeField.email: 'nima@test.com',
  EmployeeField.phone: '9841234567',
  EmployeeField.basic: '50000',
});

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    people = FakeEmployeeRepository(
      stored: [
        person('HT-003', 'Sita Employee'),
        person('HT-004', 'Ram Employee'),
      ],
    );
    orgRepo = FakeOrgRepository(
      departments: ['Support', 'Engineering'],
      branches: ['Kathmandu Head Office', 'Pokhara Office'],
    );
    teamsRepo = FakeTeamsRepository(
      stored: [
        const Team(
          id: 'uuid-a',
          name: 'Support Team',
          headId: 'HT-003',
          memberIds: ['HT-003', 'HT-004'],
        ),
      ],
    );
    records = EmployeeRecordsState(repository: people);
    org = OrgState(repository: orgRepo);
    teams = TeamsState(repository: teamsRepo);
    await records.refresh();
    await org.refresh();
  });

  group('the employee form picks department and branch from the lists', () {
    testWidgets('a new person starts with no department and the head office', (
      tester,
    ) async {
      await pump(tester, const HrEmployeeFormScreen());
      expect(find.text('Choose'), findsOneWidget); // department
      expect(find.text('Kathmandu Head Office'), findsOneWidget);
    });

    testWidgets('the department list is the company\'s own', (tester) async {
      await pump(tester, const HrEmployeeFormScreen());
      await tester.tap(find.text('Department'));
      await tester.pumpAndSettle();
      final sheet = find.byType(CupertinoActionSheet);
      for (final d in ['Engineering', 'Support', 'New department…']) {
        expect(
          find.descendant(of: sheet, matching: find.text(d)),
          findsOneWidget,
        );
      }
      // Nothing from the demo company.
      expect(
        find.descendant(of: sheet, matching: find.text('Finance')),
        findsNothing,
      );
    });

    testWidgets('a picked department and branch are what gets saved', (
      tester,
    ) async {
      await pump(tester, const HrEmployeeFormScreen());
      await fillPerson(tester);
      await pickInForm(tester, 'Department', 'Engineering');
      await pickInForm(tester, 'Work location', 'Pokhara Office');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final saved = people.stored.firstWhere((r) => r.name == 'Nima Sherpa');
      expect(saved.department, 'Engineering');
      expect(saved.workLocation, 'Pokhara Office');
    });

    testWidgets('saving without a department says so', (tester) async {
      await pump(tester, const HrEmployeeFormScreen());
      await fillPerson(tester);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a job title and a department.'), findsOneWidget);
      expect(people.calls, isEmpty);
    });

    testWidgets('a new department is saved as a record and chosen', (
      tester,
    ) async {
      await pump(tester, const HrEmployeeFormScreen());
      await pickInForm(tester, 'Department', 'Design');
      expect(orgRepo.departments, contains('Design'));
      expect(org.departments, contains('Design'));
      expect(find.text('Design'), findsOneWidget); // now the form's value
    });

    testWidgets('a new branch is saved as a record and chosen', (tester) async {
      await pump(tester, const HrEmployeeFormScreen());
      await pickInForm(
        tester,
        'Work location',
        'Lalitpur Office',
        newLabel: 'New branch…',
      );
      expect(orgRepo.branches, contains('Lalitpur Office'));
      expect(find.text('Lalitpur Office'), findsOneWidget);
    });

    testWidgets('a department that already exists is refused, with a reason', (
      tester,
    ) async {
      await pump(tester, const HrEmployeeFormScreen());
      await tester.tap(find.text('Department'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('New department…'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(CupertinoAlertDialog),
          matching: find.byType(CupertinoTextField),
        ),
        'support',
      );
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.textContaining('already used'), findsOneWidget);
      expect(
        orgRepo.departments.where((d) => d.toLowerCase() == 'support').length,
        1,
      );
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Choose'), findsOneWidget); // nothing was chosen
    });

    testWidgets('if adding fails, it says why and nothing is chosen', (
      tester,
    ) async {
      orgRepo.failNextWrite = const SaveFailure(SaveProblem.notAllowed);
      await pump(tester, const HrEmployeeFormScreen());
      await tester.tap(find.text('Department'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('New department…'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(CupertinoAlertDialog),
          matching: find.byType(CupertinoTextField),
        ),
        'Design',
      );
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      expect(find.textContaining("don't have permission"), findsOneWidget);
      expect(org.departments, isNot(contains('Design')));
    });

    testWidgets('editing keeps an older department even if the list lacks it', (
      tester,
    ) async {
      final old = person('HT-009', 'Old Timer', department: 'Legacy Dept');
      people.stored.add(old);
      await records.refresh();
      await pump(
        tester,
        HrEmployeeFormScreen(existing: records.byId('HT-009')),
      );
      expect(find.text('Legacy Dept'), findsOneWidget);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(
        people.stored.firstWhere((r) => r.id == 'HT-009').department,
        'Legacy Dept',
      );
    });

    testWidgets(
      'a department typed in other capitals uses the list\'s spelling',
      (tester) async {
        // A hired applicant arrives with "support" from the job posting.
        await pump(
          tester,
          const HrEmployeeFormScreen(initialDepartment: 'support'),
        );
        expect(find.text('Support'), findsOneWidget);
      },
    );

    testWidgets('the pickers work in Nepali', (tester) async {
      await pump(
        tester,
        const HrEmployeeFormScreen(),
        locale: const Locale('ne'),
      );
      await tester.tap(find.text('विभाग'));
      await tester.pumpAndSettle();
      expect(find.text('विभाग छान्नुहोस्'), findsOneWidget);
      expect(find.text('नयाँ विभाग…'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('teams on the backend', () {
    testWidgets('the Teams screen loads the saved teams when it opens', (
      tester,
    ) async {
      await pump(tester, const HrTeamsScreen());
      expect(find.text('Support Team'), findsOneWidget);
      expect(teamsRepo.loads, 1);
    });

    testWidgets('a new team is saved', (tester) async {
      await pump(tester, const HrTeamsScreen());
      await tester.tap(find.text('New team'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(CupertinoTextField), 'Sales');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(teamsRepo.stored.map((t) => t.name), contains('Sales'));
      expect(find.text('Sales'), findsOneWidget);
    });

    testWidgets('a team that fails to save says why and is not shown', (
      tester,
    ) async {
      await pump(tester, const HrTeamsScreen());
      teamsRepo.failNextWrite = const SaveFailure(SaveProblem.network);
      await tester.tap(find.text('New team'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(CupertinoTextField), 'Sales');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.textContaining("Couldn't reach the server"), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Sales'), findsNothing);
    });

    testWidgets('making someone head is saved', (tester) async {
      await pump(tester, const HrTeamsScreen());
      await tester.tap(find.text('Support Team'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ram Employee'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Make team head'));
      await tester.pumpAndSettle();
      expect(teamsRepo.stored.single.headId, 'HT-004');
      expect(teamsRepo.calls, contains('setHead uuid-a HT-004'));
    });

    testWidgets(
      'someone leading another team gets the named message, nothing sent',
      (tester) async {
        teamsRepo.stored.add(
          const Team(id: 'uuid-b', name: 'Night Shift', memberIds: ['HT-003']),
        );
        await pump(tester, const HrTeamsScreen());
        await tester.tap(find.text('Night Shift'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sita Employee'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Make team head'));
        await tester.pumpAndSettle();
        expect(
          find.textContaining('already leads Support Team'),
          findsOneWidget,
        );
        expect(teamsRepo.calls.where((c) => c.startsWith('setHead')), isEmpty);
      },
    );

    testWidgets('a failed load says so', (tester) async {
      teamsRepo.failLoad = true;
      await pump(tester, const HrTeamsScreen());
      expect(find.textContaining("Couldn't reach the server"), findsOneWidget);
    });
  });
}

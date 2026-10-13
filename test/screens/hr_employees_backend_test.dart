import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_first_flutter_app/l10n/app_localizations.dart';
import 'package:my_first_flutter_app/main.dart';
import 'package:my_first_flutter_app/screens/hr/hr_employee_detail_screen.dart';
import 'package:my_first_flutter_app/screens/hr/hr_employees_screen.dart';
import 'package:my_first_flutter_app/state/audit_log_state.dart';
import 'package:my_first_flutter_app/state/employee_records_state.dart';
import 'package:my_first_flutter_app/state/employee_repository.dart';

import '../helpers/employee_form.dart';
import '../helpers/fake_employee_repository.dart';

late FakeEmployeeRepository repo;
late EmployeeRecordsState state;

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
        // Last, so it wins over the app's own: this one talks to the fake.
        ChangeNotifierProvider<EmployeeRecordsState>.value(value: state),
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

/// A valid new employee, entered into the open form. The department is a
/// new one, added from the picker (labels in the form's language).
Future<void> fillValidForm(
  WidgetTester tester, {
  String name = 'Nima Sherpa',
  String departmentRow = 'Department',
  String newDepartment = 'New department…',
  String add = 'Add',
}) async {
  await fillForm(tester, {
    EmployeeField.name: name,
    EmployeeField.jobTitle: 'Designer',
    EmployeeField.email: 'nima.sherpa@karmahr.com',
    EmployeeField.phone: '9841234567',
    EmployeeField.basic: '50000',
    EmployeeField.dearness: '5000',
    EmployeeField.transport: '3000',
  });
  await pickInForm(
    tester,
    departmentRow,
    'Product',
    newLabel: newDepartment,
    addLabel: add,
  );
}

AuditLogState audit(WidgetTester tester) =>
    tester.element(find.byType(CupertinoApp)).read<AuditLogState>();

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repo = FakeEmployeeRepository(
      stored: [person('HT-001', 'Hari Hr'), person('HT-002', 'Sita Employee')],
    );
    state = EmployeeRecordsState(repository: repo);
  });

  group('the list', () {
    testWidgets('loads the company\'s people when it opens', (tester) async {
      await pump(tester, const HrEmployeesScreen());
      expect(find.text('Hari Hr'), findsOneWidget);
      expect(find.text('Sita Employee'), findsOneWidget);
      expect(find.text('2 employees'), findsOneWidget);
      expect(repo.loads, 1);
    });

    testWidgets('shows nobody from the demo company', (tester) async {
      await pump(tester, const HrEmployeesScreen());
      expect(find.text('Suresh Karki'), findsNothing);
    });

    testWidgets('the refresh button picks up someone added on another device', (
      tester,
    ) async {
      await pump(tester, const HrEmployeesScreen());
      expect(find.text('Ram Employee'), findsNothing);

      repo.stored.add(person('HT-003', 'Ram Employee')); // another phone
      await tester.tap(find.byIcon(CupertinoIcons.refresh));
      await tester.pumpAndSettle();

      expect(find.text('Ram Employee'), findsOneWidget);
      expect(find.text('3 employees'), findsOneWidget);
    });

    testWidgets('a deactivation made elsewhere shows after a refresh', (
      tester,
    ) async {
      await pump(tester, const HrEmployeesScreen());
      repo.stored[1] = repo.stored[1].copyWith(
        status: EmploymentStatus.inactive,
      );
      await tester.tap(find.byIcon(CupertinoIcons.refresh));
      await tester.pumpAndSettle();
      expect(find.text('Sita Employee'), findsNothing); // Active filter
      expect(find.text('1 employee'), findsOneWidget);
    });

    testWidgets('a failed load says so, and trying again recovers', (
      tester,
    ) async {
      repo.failLoad = true;
      await pump(tester, const HrEmployeesScreen());
      expect(
        find.textContaining("Couldn't load the employees"),
        findsOneWidget,
      );

      repo.failLoad = false;
      await tester.tap(find.byIcon(CupertinoIcons.refresh));
      await tester.pumpAndSettle();
      expect(find.textContaining("Couldn't load the employees"), findsNothing);
      expect(find.text('Hari Hr'), findsOneWidget);
    });

    testWidgets('the failure message is in Nepali too', (tester) async {
      repo.failLoad = true;
      await pump(tester, const HrEmployeesScreen(), locale: const Locale('ne'));
      expect(find.textContaining('लोड गर्न सकिएन'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('adding an employee', () {
    Future<void> openForm(WidgetTester tester) async {
      await pump(tester, const HrEmployeesScreen());
      await tester.tap(find.byIcon(CupertinoIcons.person_add));
      await tester.pumpAndSettle();
    }

    testWidgets('is saved to the database, then shown in the list', (
      tester,
    ) async {
      await openForm(tester);
      // The next free ID follows the company's own numbering.
      expect(find.text('Staff ID HT-003'), findsOneWidget);
      await fillValidForm(tester);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(repo.stored.map((r) => r.name), contains('Nima Sherpa'));
      expect(repo.stored.last.id, 'HT-003');
      expect(find.text('New employee'), findsNothing); // the form closed
      expect(find.text('Nima Sherpa'), findsOneWidget);
      expect(audit(tester).entries.first.action, AuditAction.employeeAdded);
    });

    testWidgets('a failed save keeps the form open, saves nothing, says why', (
      tester,
    ) async {
      await openForm(tester);
      await fillValidForm(tester);
      repo.failNextWrite = const SaveFailure(SaveProblem.network);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text("Couldn't save"), findsOneWidget);
      expect(find.textContaining("Couldn't reach the server"), findsOneWidget);
      expect(find.text('New employee'), findsOneWidget); // still open
      expect(repo.stored.length, 2);
      expect(state.byId('HT-003'), isNull);
      expect(
        audit(tester).entries,
        isEmpty,
      ); // nothing happened, nothing logged
    });

    testWidgets('after a failure, saving again works', (tester) async {
      await openForm(tester);
      await fillValidForm(tester);
      repo.failNextWrite = const SaveFailure(SaveProblem.network);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(repo.stored.map((r) => r.name), contains('Nima Sherpa'));
      expect(find.text('New employee'), findsNothing);
    });

    for (final c in [
      (SaveProblem.duplicateEmail, 'Another employee already has that email'),
      (SaveProblem.duplicateStaffId, 'That Staff ID has just been taken'),
      (SaveProblem.notAllowed, "You don't have permission"),
    ]) {
      testWidgets('${c.$1.name} gets its own message', (tester) async {
        await openForm(tester);
        await fillValidForm(tester);
        repo.failNextWrite = SaveFailure(c.$1);
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
        expect(find.textContaining(c.$2), findsOneWidget);
      });
    }

    testWidgets('a second tap while saving does not save twice', (
      tester,
    ) async {
      await openForm(tester);
      await fillValidForm(tester);
      await tester.tap(find.text('Save'));
      await tester.tap(find.text('Save'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(repo.calls.where((c) => c.startsWith('insert ')).length, 1);
    });

    testWidgets('bad details are refused before anything is sent', (
      tester,
    ) async {
      await openForm(tester);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text("Enter the employee's full name."), findsOneWidget);
      expect(repo.calls, isEmpty);
    });

    testWidgets('the save failure message is in Nepali too', (tester) async {
      await pump(tester, const HrEmployeesScreen(), locale: const Locale('ne'));
      await tester.tap(find.byIcon(CupertinoIcons.person_add));
      await tester.pumpAndSettle();
      await fillValidForm(
        tester,
        departmentRow: 'विभाग',
        newDepartment: 'नयाँ विभाग…',
        add: 'थप्नुहोस्',
      );
      repo.failNextWrite = const SaveFailure(SaveProblem.notAllowed);
      await tester.tap(find.text('सुरक्षित गर्नुहोस्'));
      await tester.pumpAndSettle();
      expect(find.text('सुरक्षित गर्न सकिएन'), findsOneWidget);
      expect(find.textContaining('अनुमति छैन'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('editing and deactivating', () {
    testWidgets('an edit is saved to the database', (tester) async {
      await pump(tester, const HrEmployeesScreen());
      await tester.tap(find.text('Sita Employee'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await fillForm(tester, {EmployeeField.jobTitle: 'Team Lead'});
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(
        repo.stored.firstWhere((r) => r.id == 'HT-002').jobTitle,
        'Team Lead',
      );
      expect(repo.calls, contains('update HT-002'));
    });

    testWidgets('deactivating is saved to the database', (tester) async {
      await state.refresh(); // the list screen normally does this
      await pump(tester, HrEmployeeDetailScreen(employeeId: 'HT-002'));
      await tester.tap(find.text('Deactivate employee'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(CupertinoDialogAction, 'Deactivate'),
      );
      await tester.pumpAndSettle();

      expect(repo.stored.firstWhere((r) => r.id == 'HT-002').isActive, isFalse);
      expect(
        audit(tester).entries.first.action,
        AuditAction.employeeDeactivated,
      );
    });

    testWidgets('a failed deactivation leaves them active and says why', (
      tester,
    ) async {
      await state.refresh(); // the list screen normally does this
      await pump(tester, HrEmployeeDetailScreen(employeeId: 'HT-002'));
      repo.failNextWrite = const SaveFailure(SaveProblem.notAllowed);
      await tester.tap(find.text('Deactivate employee'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(CupertinoDialogAction, 'Deactivate'),
      );
      await tester.pumpAndSettle();

      expect(find.text("Couldn't save"), findsOneWidget);
      expect(find.textContaining("don't have permission"), findsOneWidget);
      expect(state.byId('HT-002')!.isActive, isTrue);
      expect(repo.stored.firstWhere((r) => r.id == 'HT-002').isActive, isTrue);
      expect(audit(tester).entries, isEmpty);
    });
  });

  group('importing from a spreadsheet', () {
    Future<void> importText(WidgetTester tester, String text) async {
      await pump(tester, const HrEmployeesScreen());
      await tester.tap(find.byIcon(CupertinoIcons.arrow_down_doc));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(CupertinoTextField).last, text);
      await tester.tap(find.text('Import'));
      await tester.pumpAndSettle();
    }

    const good =
        'Nima Sherpa,Designer,Product,nima@test.com,9841234567,50000,5000,3000';

    testWidgets('good rows are saved to the database and listed', (
      tester,
    ) async {
      await importText(tester, good);
      expect(repo.stored.map((r) => r.name), contains('Nima Sherpa'));
      expect(repo.calls.last, 'insertMany HT-003');
      expect(find.text('Added 1 employee.'), findsOneWidget);
    });

    testWidgets('a failed save says why and adds nobody', (tester) async {
      repo.failNextWrite = const SaveFailure(SaveProblem.network);
      await pump(tester, const HrEmployeesScreen());
      await tester.tap(find.byIcon(CupertinoIcons.arrow_down_doc));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(CupertinoTextField).last, good);
      await tester.tap(find.text('Import'));
      await tester.pumpAndSettle();

      expect(find.text("Couldn't save"), findsOneWidget);
      expect(repo.stored.length, 2);
      expect(state.records.length, 2);
      expect(audit(tester).entries, isEmpty);
    });
  });
}

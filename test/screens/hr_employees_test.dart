import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_first_flutter_app/l10n/app_localizations.dart';
import 'package:my_first_flutter_app/main.dart';
import 'package:my_first_flutter_app/screens/employee_directory_screen.dart';
import 'package:my_first_flutter_app/screens/hr/hr_employee_detail_screen.dart';
import 'package:my_first_flutter_app/screens/hr/hr_employees_screen.dart';
import 'package:my_first_flutter_app/state/employee_records_state.dart';

Future<void> pump(
  WidgetTester tester,
  Widget screen, {
  double width = 393,
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = Size(width, 2400);
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
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

EmployeeRecordsState records(WidgetTester tester) =>
    tester.element(find.byType(CupertinoApp)).read<EmployeeRecordsState>();

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('lists active employees and a count', (tester) async {
    await pump(tester, const HrEmployeesScreen());

    expect(find.text('Suresh Karki'), findsOneWidget);
    expect(find.text('8 employees'), findsOneWidget);
    // The former employee is hidden under the default Active filter.
    expect(find.text('Dipesh Pandey'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the Inactive and All filters show former employees', (
    tester,
  ) async {
    await pump(tester, const HrEmployeesScreen());

    await tester.tap(find.text('Inactive'));
    await tester.pumpAndSettle();
    expect(find.text('Dipesh Pandey'), findsOneWidget);
    expect(find.text('Suresh Karki'), findsNothing);
    expect(find.text('1 employee'), findsOneWidget);

    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(find.text('9 employees'), findsOneWidget);
  });

  testWidgets('search narrows by name, role, department or staff ID', (
    tester,
  ) async {
    await pump(tester, const HrEmployeesScreen());

    await tester.enterText(find.byType(CupertinoSearchTextField), 'finance');
    await tester.pumpAndSettle();
    expect(find.text('Anita Shrestha'), findsOneWidget);
    expect(find.text('Suresh Karki'), findsNothing);

    await tester.enterText(find.byType(CupertinoSearchTextField), 'MB-24071');
    await tester.pumpAndSettle();
    expect(find.text('Bishwas Sigdel'), findsOneWidget);
    expect(find.text('1 employee'), findsOneWidget);

    await tester.enterText(find.byType(CupertinoSearchTextField), 'zzzz');
    await tester.pumpAndSettle();
    expect(find.text('No employees match.'), findsOneWidget);
  });

  testWidgets('tapping a person opens their record with tabs', (tester) async {
    await pump(tester, const HrEmployeesScreen());

    await tester.tap(find.text('Anita Shrestha'));
    await tester.pumpAndSettle();
    expect(find.byType(HrEmployeeDetailScreen), findsOneWidget);
    expect(find.text('Finance Officer'), findsWidgets);

    await tester.tap(find.text('Contact'));
    await tester.pumpAndSettle();
    expect(find.text('anita.shrestha@karmahr.com'), findsOneWidget);

    await tester.tap(find.text('Pay'));
    await tester.pumpAndSettle();
    expect(find.text('Gross per month'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('deactivating asks first, then hides them from the Directory', (
    tester,
  ) async {
    await pump(tester, const HrEmployeesScreen());
    await tester.tap(find.text('Bikash Lama'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Deactivate employee'));
    await tester.pumpAndSettle();
    expect(find.text('Deactivate Bikash Lama?'), findsOneWidget);

    await tester.tap(find.text('Deactivate'));
    await tester.pumpAndSettle();

    expect(
      records(tester).records.firstWhere((r) => r.name == 'Bikash Lama').status,
      EmploymentStatus.inactive,
    );
    expect(find.text('Reactivate employee'), findsOneWidget);
    expect(
      records(tester).directory.any((e) => e.name == 'Bikash Lama'),
      isFalse,
    );
  });

  testWidgets('cancelling the deactivate prompt changes nothing', (
    tester,
  ) async {
    await pump(tester, const HrEmployeesScreen());
    await tester.tap(find.text('Bikash Lama'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Deactivate employee'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(
      records(tester).records
          .firstWhere((r) => r.name == 'Bikash Lama')
          .isActive,
      isTrue,
    );
  });

  Future<void> fill(WidgetTester tester, Map<int, String> values) async {
    final fields = find.byType(CupertinoTextFormFieldRow);
    for (final entry in values.entries) {
      await tester.enterText(fields.at(entry.key), entry.value);
    }
    await tester.pumpAndSettle();
  }

  testWidgets('adding an employee: validation, then it appears everywhere', (
    tester,
  ) async {
    await pump(tester, const HrEmployeesScreen());
    await tester.tap(find.byIcon(CupertinoIcons.person_add));
    await tester.pumpAndSettle();
    expect(find.text('New employee'), findsOneWidget);

    // Empty save is refused with a reason, and nothing is added.
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text("Enter the employee's full name."), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(records(tester).records.length, 9);

    // Field order: name, job title, department, location, email, phone,
    // basic, dearness, transport.
    await fill(tester, {
      0: 'Nima Sherpa',
      1: 'Designer',
      2: 'Product',
      4: 'nima.sherpa@karmahr.com',
      5: '9841234567',
      6: '50000',
      7: '5000',
      8: '3000',
    });
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final added = records(tester).records
        .firstWhere((r) => r.name == 'Nima Sherpa');
    expect(added.department, 'Product');
    expect(added.grossMonthly, 58000);
    expect(added.isActive, isTrue);

    // Back on the list, and in the employee Directory.
    expect(find.text('Nima Sherpa'), findsOneWidget);
    expect(
      records(tester).directory.any((e) => e.name == 'Nima Sherpa'),
      isTrue,
    );
  });

  testWidgets('a bad phone number or email is refused', (tester) async {
    await pump(tester, const HrEmployeesScreen());
    await tester.tap(find.byIcon(CupertinoIcons.person_add));
    await tester.pumpAndSettle();

    await fill(tester, {
      0: 'Nima Sherpa',
      1: 'Designer',
      2: 'Product',
      4: 'not-an-email',
      5: '9841234567',
      6: '50000',
    });
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await fill(tester, {4: 'nima@karmahr.com', 5: '12345'});
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.textContaining('10-digit mobile number'), findsOneWidget);
    expect(records(tester).records.length, 9);
  });

  testWidgets('editing changes the record and the detail page follows', (
    tester,
  ) async {
    await pump(tester, const HrEmployeesScreen());
    await tester.tap(find.text('Anita Shrestha'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Edit employee'), findsOneWidget);

    await fill(tester, {1: 'Senior Finance Officer'});
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.byType(HrEmployeeDetailScreen), findsOneWidget);
    expect(find.text('Senior Finance Officer'), findsWidgets);
  });

  testWidgets('the employee Directory shows who HR has added', (tester) async {
    await pump(tester, const EmployeeDirectoryScreen());
    expect(find.text('Dipesh Pandey'), findsNothing);
    expect(find.text('Suresh Karki'), findsOneWidget);
  });

  testWidgets('renders in Nepali on a narrow phone', (tester) async {
    await pump(
      tester,
      const HrEmployeesScreen(),
      width: 320,
      locale: const Locale('ne'),
    );
    expect(find.text('सक्रिय'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

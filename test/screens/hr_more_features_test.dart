import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_first_flutter_app/l10n/app_localizations.dart';
import 'package:my_first_flutter_app/main.dart';
import 'package:my_first_flutter_app/screens/hr/hr_attendance_screen.dart';
import 'package:my_first_flutter_app/screens/hr/hr_employee_detail_screen.dart';
import 'package:my_first_flutter_app/screens/hr/hr_employee_form_screen.dart';
import 'package:my_first_flutter_app/screens/hr/hr_employees_screen.dart';
import 'package:my_first_flutter_app/screens/hr/hr_hiring_screen.dart';
import 'package:my_first_flutter_app/screens/hr/hr_review_cycle_screen.dart';
import 'package:my_first_flutter_app/screens/hr/hr_reports_screen.dart';
import 'package:my_first_flutter_app/screens/hr/hr_reviews_screen.dart';
import 'package:my_first_flutter_app/state/audit_log_state.dart';
import 'package:my_first_flutter_app/state/checklist_state.dart';
import 'package:my_first_flutter_app/state/employee_records_state.dart';
import 'package:my_first_flutter_app/state/hiring_state.dart';
import 'package:my_first_flutter_app/state/reviews_state.dart';

Future<void> pump(
  WidgetTester tester,
  Widget screen, {
  double width = 393,
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = Size(width, 3000);
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

T read<T>(WidgetTester tester) =>
    tester.element(find.byType(CupertinoApp)).read<T>();

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Attendance', () {
    testWidgets('opens on today with the four counts and a rate', (
      tester,
    ) async {
      await pump(tester, const HrAttendanceScreen());

      expect(find.textContaining('Today ·'), findsOneWidget);
      // Saturday is a weekly holiday; every other day shows the counts.
      if (DateTime.now().weekday != DateTime.saturday) {
        for (final label in ['Present', 'Late', 'Absent', 'On leave']) {
          expect(find.text(label), findsWidgets, reason: label);
        }
        expect(find.textContaining('% came to work'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('you can go back day by day but never past today', (
      tester,
    ) async {
      await pump(tester, const HrAttendanceScreen());

      // Forward from today does nothing.
      await tester.tap(find.byIcon(CupertinoIcons.chevron_right));
      await tester.pumpAndSettle();
      expect(find.textContaining('Today ·'), findsOneWidget);

      await tester.tap(find.byIcon(CupertinoIcons.chevron_left));
      await tester.pumpAndSettle();
      expect(find.textContaining('Today ·'), findsNothing);

      await tester.tap(find.byIcon(CupertinoIcons.chevron_right));
      await tester.pumpAndSettle();
      expect(find.textContaining('Today ·'), findsOneWidget);
    });

    testWidgets('a Saturday says it is the weekly holiday', (tester) async {
      await pump(tester, const HrAttendanceScreen());
      // Fourteen days back always includes a Saturday.
      var sawHoliday = false;
      for (var i = 0; i < 14 && !sawHoliday; i++) {
        if (find
            .text('Weekly holiday. Nobody is expected at work.')
            .evaluate()
            .isNotEmpty) {
          sawHoliday = true;
          break;
        }
        await tester.tap(find.byIcon(CupertinoIcons.chevron_left));
        await tester.pumpAndSettle();
      }
      sawHoliday =
          sawHoliday ||
          find
              .text('Weekly holiday. Nobody is expected at work.')
              .evaluate()
              .isNotEmpty;
      expect(sawHoliday, isTrue);
    });

    testWidgets('history stops 14 days back', (tester) async {
      await pump(tester, const HrAttendanceScreen());
      for (var i = 0; i < 14; i++) {
        await tester.tap(find.byIcon(CupertinoIcons.chevron_left));
        await tester.pumpAndSettle();
      }
      final label = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .whereType<String>()
          .firstWhere((s) => s.contains(','));
      await tester.tap(find.byIcon(CupertinoIcons.chevron_left));
      await tester.pumpAndSettle();
      expect(find.text(label), findsWidgets);
    });

    testWidgets('renders in Nepali on a narrow phone', (tester) async {
      await pump(
        tester,
        const HrAttendanceScreen(),
        width: 320,
        locale: const Locale('ne'),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('Review cycles', () {
    testWidgets('lists the cycles with progress', (tester) async {
      await pump(tester, const HrReviewsScreen());
      expect(find.text('Q1 2083/84 review'), findsOneWidget);
      expect(find.text('Q4 2082/83 review'), findsOneWidget);
      expect(find.text('3 of 8 completed'), findsOneWidget);
      expect(find.text('4 of 4 completed'), findsOneWidget);
    });

    testWidgets('a cycle shows everyone, furthest behind first, and advances', (
      tester,
    ) async {
      await pump(tester, const HrReviewCycleScreen(cycleId: 'c2'));

      expect(find.text('Not started'), findsOneWidget); // Manisha
      expect(find.text('Next step'), findsNWidgets(5)); // all but the 3 done

      await tester.tap(find.text('Next step').first);
      await tester.pumpAndSettle();

      // Manisha moved on, so nobody is "not started" any more.
      expect(find.text('Not started'), findsNothing);
      expect(read<ReviewsState>(tester).byId('c2')!.completed, 3);
    });

    testWidgets('advancing someone to the end raises the completed count', (
      tester,
    ) async {
      await pump(tester, const HrReviewCycleScreen(cycleId: 'c2'));
      final state = read<ReviewsState>(tester);
      state.advance('c2', 'MB-23102'); // manager done -> completed
      await tester.pumpAndSettle();
      expect(find.text('4 of 8 completed'), findsOneWidget);
      expect(find.text('Next step'), findsNWidgets(4));
    });

    testWidgets('starting a cycle suggests a name and logs it', (tester) async {
      await pump(tester, const HrReviewsScreen());
      await tester.tap(find.text('Start review cycle').first);
      await tester.pumpAndSettle();

      expect(
        find.text('Starts a review for all 8 active employees.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final reviews = read<ReviewsState>(tester);
      expect(reviews.cycles.length, 3);
      expect(reviews.cycles.first.total, 8);
      expect(
        read<AuditLogState>(tester).entries.single.action,
        AuditAction.reviewStarted,
      );
    });

    testWidgets('a blank name is refused', (tester) async {
      await pump(tester, const HrReviewsScreen());
      await tester.tap(find.text('Start review cycle').first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(CupertinoTextField), '   ');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a name for the review cycle.'), findsOneWidget);
      expect(read<ReviewsState>(tester).cycles.length, 2);
    });

    testWidgets('renders in Nepali on a narrow phone', (tester) async {
      await pump(
        tester,
        const HrReviewCycleScreen(cycleId: 'c2'),
        width: 320,
        locale: const Locale('ne'),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('Hiring', () {
    testWidgets('lists jobs with applicants and openings', (tester) async {
      await pump(tester, const HrHiringScreen());

      expect(find.text('Senior Accountant'), findsOneWidget);
      expect(find.textContaining('2 applicants · 1 opening'), findsOneWidget);
      expect(find.text('Closed'), findsOneWidget);
      expect(find.text('Open'), findsNWidgets(2));
    });

    testWidgets('a new job needs details, then appears and is logged', (
      tester,
    ) async {
      await pump(tester, const HrHiringScreen());
      await tester.tap(find.text('New job').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(
        find.text('Enter a job title, a department and at least one opening.'),
        findsOneWidget,
      );
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      final fields = find.byType(CupertinoTextField);
      await tester.enterText(fields.at(0), 'Driver');
      await tester.enterText(fields.at(1), 'Operations');
      await tester.tap(find.byIcon(CupertinoIcons.plus_circle));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final job = read<HiringState>(tester).jobs
          .firstWhere((j) => j.title == 'Driver');
      expect(job.openings, 2);
      expect(find.text('Driver'), findsOneWidget);
      expect(
        read<AuditLogState>(tester).entries.single.action,
        AuditAction.jobPosted,
      );
    });

    testWidgets('openings cannot go below one', (tester) async {
      await pump(tester, const HrHiringScreen());
      await tester.tap(find.text('New job').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(CupertinoIcons.minus_circle));
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('a job shows its applicants and moves them along', (
      tester,
    ) async {
      await pump(tester, const HrHiringScreen());
      await tester.tap(find.text('Senior Accountant'));
      await tester.pumpAndSettle();

      expect(find.text('APPLICANTS'), findsOneWidget);
      expect(find.text('Sunita Pandey'), findsOneWidget);
      expect(find.text('Interview'), findsOneWidget);

      // Rajan is at "Applied": move him on.
      expect(find.text('Applied'), findsOneWidget);
      // Listed in stage order, so Rajan (Applied) is the first button.
      await tester.tap(find.text('Next stage').first);
      await tester.pumpAndSettle();
      expect(find.text('Applied'), findsNothing);
      expect(find.text('Screening'), findsOneWidget);
    });

    testWidgets('reject ends it, and the buttons go away', (tester) async {
      await pump(tester, const HrHiringScreen());
      await tester.tap(find.text('Senior Accountant'));
      await tester.pumpAndSettle();

      expect(find.text('Reject'), findsNWidgets(2));
      await tester.tap(find.text('Reject').last);
      await tester.pumpAndSettle();

      expect(find.text('Rejected'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
    });

    testWidgets('adding an applicant needs a name', (tester) async {
      await pump(tester, const HrHiringScreen());
      await tester.tap(find.text('Senior Accountant'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add applicant').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text("Enter the applicant's name."), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(CupertinoTextField).first,
        'Dipak Rana',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Dipak Rana'), findsOneWidget);
      expect(read<HiringState>(tester).applicantsFor('j1').length, 3);
    });

    testWidgets('closing a job can be undone', (tester) async {
      await pump(tester, const HrHiringScreen());
      await tester.tap(find.text('Senior Accountant'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Close job'));
      await tester.pumpAndSettle();
      expect(read<HiringState>(tester).jobById('j1')!.isOpen, isFalse);
      expect(find.text('Reopen job'), findsOneWidget);

      await tester.tap(find.text('Reopen job'));
      await tester.pumpAndSettle();
      expect(read<HiringState>(tester).jobById('j1')!.isOpen, isTrue);
    });

    testWidgets('hiring someone offers to add them as an employee, prefilled', (
      tester,
    ) async {
      await pump(tester, const HrHiringScreen());
      // The closed Office Assistant job has one hired applicant.
      await tester.tap(find.text('Office Assistant'));
      await tester.pumpAndSettle();
      expect(find.text('Hired'), findsOneWidget);

      await tester.tap(find.text('Add as employee'));
      await tester.pumpAndSettle();

      expect(find.byType(HrEmployeeFormScreen), findsOneWidget);
      final fields = tester
          .widgetList<CupertinoTextFormFieldRow>(
            find.byType(CupertinoTextFormFieldRow),
          )
          .map((f) => f.controller!.text)
          .toList();
      expect(fields[0], 'Pooja Thapa'); // name
      expect(fields[1], 'Office Assistant'); // job title
      expect(fields[2], 'Operations'); // department
      expect(fields[4], 'pooja.thapa@example.com'); // email
    });

    testWidgets('reaching "hired" is logged', (tester) async {
      await pump(tester, const HrHiringScreen());
      await tester.tap(find.text('Flutter Developer'));
      await tester.pumpAndSettle();

      // Anil is at "Offer": one more step hires him.
      expect(find.text('Offer'), findsOneWidget);
      // Kriti (Screening) is listed first, Anil (Offer) second.
      await tester.tap(find.text('Next stage').last);
      await tester.pumpAndSettle();

      expect(find.text('Hired'), findsOneWidget);
      expect(
        read<AuditLogState>(tester).entries.single.action,
        AuditAction.applicantHired,
      );
    });
  });

  group('Org chart', () {
    testWidgets('the toggle swaps the list for the reporting tree', (
      tester,
    ) async {
      await pump(tester, const HrEmployeesScreen());
      expect(find.text('8 employees'), findsOneWidget);

      await tester.tap(find.byIcon(CupertinoIcons.person_3));
      await tester.pumpAndSettle();

      expect(find.text('8 employees'), findsNothing);
      expect(find.textContaining('7 direct reports'), findsOneWidget);
      expect(find.text('Suresh Karki'), findsOneWidget);
      expect(find.text('Bishwas Sigdel'), findsOneWidget);

      await tester.tap(find.byIcon(CupertinoIcons.list_bullet));
      await tester.pumpAndSettle();
      expect(find.text('8 employees'), findsOneWidget);
    });

    testWidgets('tapping a person in the chart opens their record', (
      tester,
    ) async {
      await pump(tester, const HrEmployeesScreen());
      await tester.tap(find.byIcon(CupertinoIcons.person_3));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Anita Shrestha'));
      await tester.pumpAndSettle();
      expect(find.byType(HrEmployeeDetailScreen), findsOneWidget);
    });

    testWidgets('a deactivated person leaves the chart', (tester) async {
      await pump(tester, const HrEmployeesScreen());
      read<EmployeeRecordsState>(tester)
          .setStatus('MB-23102', EmploymentStatus.inactive);
      await tester.tap(find.byIcon(CupertinoIcons.person_3));
      await tester.pumpAndSettle();

      expect(find.text('Bikash Lama'), findsNothing);
      expect(find.textContaining('6 direct reports'), findsOneWidget);
    });
  });

  group('CSV import', () {
    Future<void> openImport(WidgetTester tester) async {
      await pump(tester, const HrEmployeesScreen());
      await tester.tap(find.byIcon(CupertinoIcons.arrow_down_doc));
      await tester.pumpAndSettle();
    }

    testWidgets('adds good rows, reports the bad ones, and logs it', (
      tester,
    ) async {
      await openImport(tester);
      // The search box is a text field too; the sheet's field comes after it.
      await tester.enterText(
        find.byType(CupertinoTextField).last,
        'Nima Sherpa,Designer,Product,nima@karmahr.com,9841234567,50000,5000,3000\n'
        'Too,Few\n'
        'Bad Email,Job,Dept,nope,9841234567,50000,0,0',
      );
      await tester.tap(find.text('Import'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Added 1 employee.'), findsOneWidget);
      expect(find.textContaining('2 rows were skipped:'), findsOneWidget);
      expect(find.textContaining('Line 2: needs 8 columns'), findsOneWidget);
      expect(
        find.textContaining('Line 3: Enter a valid email'),
        findsOneWidget,
      );
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('Nima Sherpa'), findsOneWidget);
      expect(
        read<AuditLogState>(tester).entries.single.action,
        AuditAction.employeesImported,
      );
    });

    testWidgets('empty input says there is nothing to import', (tester) async {
      await openImport(tester);
      await tester.tap(find.text('Import'));
      await tester.pumpAndSettle();
      expect(find.text('There is nothing to import.'), findsOneWidget);
      expect(read<EmployeeRecordsState>(tester).records.length, 9);
    });

    testWidgets('if every row is bad nothing is added or logged', (
      tester,
    ) async {
      await openImport(tester);
      await tester.enterText(find.byType(CupertinoTextField).last, 'garbage');
      await tester.tap(find.text('Import'));
      await tester.pumpAndSettle();

      expect(find.textContaining('No employees added.'), findsOneWidget);
      expect(read<AuditLogState>(tester).entries, isEmpty);
    });

    testWidgets('cancelling imports nothing', (tester) async {
      await openImport(tester);
      await tester.enterText(
        find.byType(CupertinoTextField).last,
        'Nima,Designer,Product,nima@karmahr.com,9841234567,50000,0,0',
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(read<EmployeeRecordsState>(tester).records.length, 9);
    });
  });

  group('Tasks tab', () {
    testWidgets('shows both checklists with progress', (tester) async {
      await pump(tester, const HrEmployeeDetailScreen(employeeId: 'MB-24012'));
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();

      expect(find.text('ONBOARDING'), findsOneWidget);
      expect(find.text('OFFBOARDING'), findsOneWidget);
      expect(find.text('2 of 5 done'), findsOneWidget); // onboarding
      expect(find.text('0 of 5 done'), findsOneWidget); // offboarding
      expect(tester.takeException(), isNull);
    });

    testWidgets('ticking a step updates the count, and it can be unticked', (
      tester,
    ) async {
      await pump(tester, const HrEmployeeDetailScreen(employeeId: 'MB-24012'));
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Issue laptop and equipment'));
      await tester.pumpAndSettle();
      expect(find.text('3 of 5 done'), findsOneWidget);
      expect(
        read<ChecklistState>(tester)
            .isDone('MB-24012', ChecklistItem.issueEquipment),
        isTrue,
      );

      await tester.tap(find.text('Issue laptop and equipment'));
      await tester.pumpAndSettle();
      expect(find.text('2 of 5 done'), findsOneWidget);
    });

    testWidgets('renders in Nepali on a narrow phone', (tester) async {
      await pump(
        tester,
        const HrEmployeeDetailScreen(employeeId: 'MB-24012'),
        width: 320,
        locale: const Locale('ne'),
      );
      await tester.tap(find.text('कार्यहरू'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('Audit log filters and export', () {
    void seedLog(WidgetTester tester) {
      final log = read<AuditLogState>(tester);
      log.log(AuditAction.employeeAdded, 'Nima', actor: 'Asha');
      log.log(AuditAction.payrollRun, 'Ashwin 2083', actor: 'Asha');
      log.log(AuditAction.requestApproved, 'Sita: Leave', actor: 'Asha');
      log.log(AuditAction.noticePublished, 'Picnic', actor: 'Asha');
    }

    testWidgets('chips narrow the log to one kind of change', (tester) async {
      await pump(tester, const HrReportsScreen());
      seedLog(tester);
      await tester.pumpAndSettle();
      expect(find.text('Employee added'), findsOneWidget);
      expect(find.text('Payroll calculated'), findsOneWidget);

      await tester.tap(find.text('Payroll'));
      await tester.pumpAndSettle();
      expect(find.text('Payroll calculated'), findsOneWidget);
      expect(find.text('Employee added'), findsNothing);

      await tester.tap(find.text('People'));
      await tester.pumpAndSettle();
      expect(find.text('Employee added'), findsOneWidget);
      expect(find.text('Payroll calculated'), findsNothing);

      await tester.tap(find.text('Company'));
      await tester.pumpAndSettle();
      expect(find.text('Notice published'), findsOneWidget);

      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      expect(find.text('Employee added'), findsOneWidget);
      expect(find.text('Notice published'), findsOneWidget);
    });

    testWidgets('a filter with nothing in it says so', (tester) async {
      await pump(tester, const HrReportsScreen());
      read<AuditLogState>(tester)
          .log(AuditAction.employeeAdded, 'Nima', actor: 'Asha');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Payroll'));
      await tester.pumpAndSettle();
      expect(find.text('Nothing has happened yet.'), findsOneWidget);
    });

    testWidgets('the audit log can be copied as CSV', (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      await pump(tester, const HrReportsScreen());
      seedLog(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Copy audit log as CSV').last);
      await tester.pumpAndSettle();

      expect(copied, startsWith('When,Actor,Action,Detail'));
      expect(copied, contains('payrollRun'));
      expect(copied!.split('\n').length, 5);
    });
  });
}

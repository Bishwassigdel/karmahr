import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_first_flutter_app/domain/nepal/bs_dates.dart';
import 'package:my_first_flutter_app/l10n/app_localizations.dart';
import 'package:my_first_flutter_app/main.dart';
import 'package:my_first_flutter_app/screens/hr/hr_employees_screen.dart';
import 'package:my_first_flutter_app/screens/hr/hr_leave_screen.dart';
import 'package:my_first_flutter_app/screens/hr/hr_notices_screen.dart';
import 'package:my_first_flutter_app/screens/hr/hr_payroll_screen.dart';
import 'package:my_first_flutter_app/screens/hr/hr_reports_screen.dart';
import 'package:my_first_flutter_app/state/audit_log_state.dart';
import 'package:my_first_flutter_app/state/employee_records_state.dart';
import 'package:my_first_flutter_app/state/hr_inbox_state.dart';
import 'package:my_first_flutter_app/state/payroll_state.dart';

Future<void> pump(
  WidgetTester tester,
  Widget screen, {
  double width = 393,
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = Size(width, 3200);
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

  group('Reports screen', () {
    testWidgets('shows headcount, requests, payroll and an empty log', (
      tester,
    ) async {
      await pump(tester, const HrReportsScreen());

      expect(find.text('Headcount'), findsOneWidget);
      expect(find.text('8 employees'), findsOneWidget);
      expect(find.text('Human Resources'), findsOneWidget);
      expect(find.text('Full-Time'), findsOneWidget);
      // A card heading, and an audit-log filter chip.
      expect(find.text('Requests'), findsNWidgets(2));
      expect(find.text('No payroll has been run yet.'), findsOneWidget);
      expect(find.text('Nothing has happened yet.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('request counts follow decisions', (tester) async {
      await pump(tester, const HrReportsScreen());
      // 7 pending (a bare "6" appears nowhere else on this screen).
      expect(find.text('6'), findsNothing);
      read<HrInboxState>(tester).decide('r1', InboxStatus.approved);
      await tester.pumpAndSettle();
      expect(find.text('6'), findsOneWidget);
    });

    testWidgets('the latest payroll appears once one is run', (tester) async {
      await pump(tester, const HrReportsScreen());
      final today = bsToday();
      read<PayrollState>(tester).calculate(
        today.year,
        today.month,
        read<EmployeeRecordsState>(tester).records,
      );
      await tester.pumpAndSettle();

      expect(find.text('No payroll has been run yet.'), findsNothing);
      expect(find.text('Net pay'), findsOneWidget);
    });

    testWidgets('exporting copies the employee list as CSV', (tester) async {
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
      await tester.tap(find.text('Copy employee list as CSV'));
      await tester.pumpAndSettle();

      expect(copied, startsWith('Staff ID,Name,Job title'));
      expect(copied, contains('Bishwas Sigdel'));
      expect(find.text('Copied'), findsOneWidget);
    });

    testWidgets('lists audit entries newest first, translated', (tester) async {
      await pump(tester, const HrReportsScreen());
      final log = read<AuditLogState>(tester);
      log.log(AuditAction.employeeAdded, 'Nima Sherpa', actor: 'Asha Rai');
      log.log(AuditAction.payrollApproved, 'Ashwin 2083', actor: 'Asha Rai');
      await tester.pumpAndSettle();

      expect(find.text('Employee added'), findsOneWidget);
      expect(find.text('Payroll approved'), findsOneWidget);
      expect(find.text('Asha Rai: Nima Sherpa'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Payroll approved')).dy,
        lessThan(tester.getTopLeft(find.text('Employee added')).dy),
      );
    });

    testWidgets('renders in Nepali on a narrow phone, with a log entry', (
      tester,
    ) async {
      await pump(
        tester,
        const HrReportsScreen(),
        width: 320,
        locale: const Locale('ne'),
      );
      read<AuditLogState>(
        tester,
      ).log(AuditAction.noticePublished, 'Salary day moved', actor: 'Asha Rai');
      await tester.pumpAndSettle();
      expect(find.text('सूचना प्रकाशित भयो'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  // The other screens write to the log; check the real flows do.
  group('HR actions are recorded', () {
    List<AuditAction> actions(WidgetTester tester) =>
        read<AuditLogState>(tester).entries.map((e) => e.action).toList();

    testWidgets('approving and rejecting a request', (tester) async {
      await pump(tester, const HrLeaveScreen());

      await tester.tap(find.text('Approve').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reject').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reject').last);
      await tester.pumpAndSettle();

      expect(actions(tester), [
        AuditAction.requestRejected,
        AuditAction.requestApproved,
      ]);
      // The oldest waiting request (Ramesh's ID card) is approved first.
      expect(
        read<AuditLogState>(tester).entries.last.detail,
        'Ramesh Thapa: ID Card Reissue',
      );
    });

    testWidgets('deactivating an employee', (tester) async {
      await pump(tester, const HrEmployeesScreen());
      await tester.tap(find.text('Bikash Lama'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deactivate employee'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deactivate'));
      await tester.pumpAndSettle();

      expect(actions(tester), [AuditAction.employeeDeactivated]);
      expect(read<AuditLogState>(tester).entries.single.detail, 'Bikash Lama');
    });

    testWidgets('adding an employee', (tester) async {
      await pump(tester, const HrEmployeesScreen());
      await tester.tap(find.byIcon(CupertinoIcons.person_add));
      await tester.pumpAndSettle();

      final fields = find.byType(CupertinoTextFormFieldRow);
      for (final (i, v) in [
        (0, 'Nima Sherpa'),
        (1, 'Designer'),
        (2, 'Product'),
        (4, 'nima@karmahr.com'),
        (5, '9841234567'),
        (6, '50000'),
      ]) {
        await tester.enterText(fields.at(i), v);
      }
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(actions(tester), [AuditAction.employeeAdded]);
    });

    testWidgets('running, approving and paying payroll', (tester) async {
      await pump(tester, const HrPayrollScreen());

      await tester.tap(find.text('Run payroll'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Approve payroll'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Approve payroll').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mark as paid'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mark as paid').last);
      await tester.pumpAndSettle();

      expect(actions(tester), [
        AuditAction.payrollPaid,
        AuditAction.payrollApproved,
        AuditAction.payrollRun,
      ]);
    });

    testWidgets('publishing and deleting a notice', (tester) async {
      await pump(tester, const HrNoticesScreen());

      await tester.tap(find.text('New notice'));
      await tester.pumpAndSettle();
      final fields = find.byType(CupertinoTextField);
      await tester.enterText(fields.at(0), 'Salary day moved');
      await tester.enterText(fields.at(1), 'On the 25th.');
      await tester.tap(find.text('Publish'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(CupertinoIcons.trash).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(actions(tester), [
        AuditAction.noticeDeleted,
        AuditAction.noticePublished,
      ]);
    });

    testWidgets('a cancelled action leaves no trace', (tester) async {
      await pump(tester, const HrLeaveScreen());
      await tester.tap(find.text('Reject').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(actions(tester), isEmpty);
    });
  });
}

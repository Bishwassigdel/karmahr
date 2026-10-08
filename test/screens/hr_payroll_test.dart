import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_first_flutter_app/domain/nepal/bs_dates.dart';
import 'package:my_first_flutter_app/l10n/app_localizations.dart';
import 'package:my_first_flutter_app/main.dart';
import 'package:my_first_flutter_app/screens/hr/hr_overview_screen.dart';
import 'package:my_first_flutter_app/screens/hr/hr_payroll_screen.dart';
import 'package:my_first_flutter_app/state/payroll_state.dart';

Future<void> pump(
  WidgetTester tester,
  Widget screen, {
  double width = 393,
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = Size(width, 2600);
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

PayrollState payroll(WidgetTester tester) =>
    tester.element(find.byType(CupertinoApp)).read<PayrollState>();

PayrollRun? currentRun(WidgetTester tester) {
  final today = bsToday();
  return payroll(tester).runFor(today.year, today.month);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('starts with a prompt to run this month', (tester) async {
    await pump(tester, const HrPayrollScreen());

    expect(find.text('Pay period'), findsOneWidget);
    expect(find.textContaining("hasn't been run yet"), findsOneWidget);
    expect(find.text('Run payroll'), findsOneWidget);
    expect(find.text('Approve payroll'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Run payroll shows a draft with totals and a line per person', (
    tester,
  ) async {
    await pump(tester, const HrPayrollScreen());

    await tester.tap(find.text('Run payroll'));
    await tester.pumpAndSettle();

    expect(currentRun(tester)!.status, PayrollStatus.draft);
    expect(find.text('Draft'), findsOneWidget);
    expect(find.text('Net pay'), findsOneWidget);
    expect(find.text('Bishwas Sigdel'), findsOneWidget);
    expect(find.text('Approve payroll'), findsOneWidget);
    expect(find.text('Recalculate'), findsOneWidget);
    expect(find.text('Dipesh Pandey'), findsNothing); // inactive
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a person shows their breakdown', (tester) async {
    await pump(tester, const HrPayrollScreen());
    await tester.tap(find.text('Run payroll'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bishwas Sigdel'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Income tax (TDS)'), findsOneWidget);
    expect(find.textContaining('Social security (SSF)'), findsOneWidget);
    expect(find.textContaining('Rs. 52,500'), findsWidgets); // his gross
  });

  testWidgets('approving asks first, then freezes the run', (tester) async {
    await pump(tester, const HrPayrollScreen());
    await tester.tap(find.text('Run payroll'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Approve payroll'));
    await tester.pumpAndSettle();
    expect(find.textContaining('figures are frozen'), findsOneWidget);

    // Cancel: still a draft.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(currentRun(tester)!.status, PayrollStatus.draft);

    await tester.tap(find.text('Approve payroll'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Approve payroll').last);
    await tester.pumpAndSettle();

    expect(currentRun(tester)!.status, PayrollStatus.approved);
    // Once approved there is nothing left to recalculate or approve.
    expect(find.text('Recalculate'), findsNothing);
    expect(find.text('Approve payroll'), findsNothing);
    expect(find.text('Mark as paid'), findsOneWidget);
  });

  testWidgets('Mark as paid finishes the run', (tester) async {
    await pump(tester, const HrPayrollScreen());
    await tester.tap(find.text('Run payroll'));
    await tester.pumpAndSettle();
    final today = bsToday();
    payroll(tester).approve(today.year, today.month);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mark as paid'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mark as paid').last);
    await tester.pumpAndSettle();

    expect(currentRun(tester)!.status, PayrollStatus.paid);
    expect(find.text('Mark as paid'), findsNothing);
    expect(find.text('Paid'), findsOneWidget);
  });

  // Records what the app copies to the clipboard.
  String? Function() captureClipboard(WidgetTester tester) {
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
    return () => copied;
  }

  Future<void> runAndOpenExport(WidgetTester tester) async {
    await pump(tester, const HrPayrollScreen());
    await tester.tap(find.text('Run payroll'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Export'));
    await tester.pumpAndSettle();
  }

  testWidgets('Export offers the register, TDS and SSF reports', (
    tester,
  ) async {
    final copied = captureClipboard(tester);
    await runAndOpenExport(tester);

    expect(find.text('Payroll register (CSV)'), findsOneWidget);
    expect(find.text('TDS report (CSV)'), findsOneWidget);
    expect(find.text('SSF contribution report (CSV)'), findsOneWidget);

    await tester.tap(find.text('Payroll register (CSV)'));
    await tester.pumpAndSettle();

    expect(copied(), startsWith('Staff ID,Name,Gross'));
    expect(copied(), contains('Bishwas Sigdel'));
    expect(find.text('Copied'), findsOneWidget);
  });

  testWidgets('the bank file waits until the payroll is approved', (
    tester,
  ) async {
    await runAndOpenExport(tester);

    expect(find.text('Bank transfer file (CSV)'), findsNothing);
    expect(
      find.text('Approve the payroll first to export the bank file.'),
      findsOneWidget,
    );
  });

  testWidgets('once approved, the bank file lists account, name and amount', (
    tester,
  ) async {
    final copied = captureClipboard(tester);
    await pump(tester, const HrPayrollScreen());
    await tester.tap(find.text('Run payroll'));
    await tester.pumpAndSettle();
    final today = bsToday();
    payroll(tester).approve(today.year, today.month);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Export'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bank transfer file (CSV)'));
    await tester.pumpAndSettle();

    expect(copied(), startsWith('Bank,Account number,Name,Amount'));
    expect(copied(), contains('Nabil Bank'));
    expect(copied(), contains('Bishwas Sigdel'));
  });

  testWidgets('the TDS and SSF reports are copied', (tester) async {
    final copied = captureClipboard(tester);
    await runAndOpenExport(tester);

    await tester.tap(find.text('TDS report (CSV)'));
    await tester.pumpAndSettle();
    expect(copied(), startsWith('Staff ID,Name,Gross,Taxable (annual),Tax'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Export'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SSF contribution report (CSV)'));
    await tester.pumpAndSettle();
    expect(copied(), startsWith('Staff ID,Name,Gross,Employee contribution'));
  });

  testWidgets('a payslip PDF is offered only after approval', (tester) async {
    await pump(tester, const HrPayrollScreen());
    await tester.tap(find.text('Run payroll'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bishwas Sigdel'));
    await tester.pumpAndSettle();
    expect(find.text('Share payslip (PDF)'), findsNothing);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    final today = bsToday();
    payroll(tester).approve(today.year, today.month);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bishwas Sigdel'));
    await tester.pumpAndSettle();
    expect(find.text('Share payslip (PDF)'), findsOneWidget);
  });

  testWidgets('Needs-your-action lists payroll until it is approved', (
    tester,
  ) async {
    await pump(tester, const HrOverviewScreen());
    expect(find.textContaining("isn't approved yet"), findsOneWidget);

    final today = bsToday();
    payroll(tester)
      ..calculate(today.year, today.month, const [])
      ..approve(today.year, today.month);
    await tester.pumpAndSettle();

    expect(find.textContaining("isn't approved yet"), findsNothing);
  });

  testWidgets('renders in Nepali on a narrow phone, run and unrun', (
    tester,
  ) async {
    await pump(
      tester,
      const HrPayrollScreen(),
      width: 320,
      locale: const Locale('ne'),
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('तलब चलाउनुहोस्'));
    await tester.pumpAndSettle();
    expect(find.text('मस्यौदा'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

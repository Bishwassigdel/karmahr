import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_first_flutter_app/domain/nepal/bs_dates.dart';
import 'package:my_first_flutter_app/l10n/app_localizations.dart';
import 'package:my_first_flutter_app/main.dart';
import 'package:my_first_flutter_app/screens/hr/hr_leave_screen.dart';
import 'package:my_first_flutter_app/screens/hr/hr_overview_screen.dart';
import 'package:my_first_flutter_app/screens/hr/hr_portal_screen.dart';
import 'package:my_first_flutter_app/state/company_holidays_state.dart';
import 'package:my_first_flutter_app/state/employee_documents_state.dart';
import 'package:my_first_flutter_app/state/hr_inbox_state.dart';
import 'package:my_first_flutter_app/state/payroll_state.dart';

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

T read<T>(WidgetTester tester) =>
    tester.element(find.byType(CupertinoApp)).read<T>();

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Approvals', () {
    testWidgets('shows what is waiting, oldest first, and decided ones', (
      tester,
    ) async {
      await pump(tester, const HrLeaveScreen());

      expect(find.text('7 requests are waiting for you'), findsOneWidget);
      expect(find.text('Sita Gurung'), findsOneWidget);
      expect(find.text('DECIDED'), findsOneWidget);
      expect(find.text('Approved'), findsOneWidget);
      expect(find.text('Rejected'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Approve decides immediately and moves it to Decided', (
      tester,
    ) async {
      await pump(tester, const HrLeaveScreen());

      await tester.tap(find.text('Approve').first);
      await tester.pumpAndSettle();

      expect(read<HrInboxState>(tester).pendingCount, 6);
      expect(find.text('6 requests are waiting for you'), findsOneWidget);
      expect(find.text('Approved'), findsNWidgets(2));
    });

    testWidgets('Reject asks first; cancelling changes nothing', (
      tester,
    ) async {
      await pump(tester, const HrLeaveScreen());

      await tester.tap(find.text('Reject').first);
      await tester.pumpAndSettle();
      expect(find.text('Reject this request?'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(read<HrInboxState>(tester).pendingCount, 7);
    });

    testWidgets('confirming a rejection records it', (tester) async {
      await pump(tester, const HrLeaveScreen());

      await tester.tap(find.text('Reject').first);
      await tester.pumpAndSettle();
      // Two "Reject" now: the card's button and the dialog's. The dialog
      // is on top, so it is the last one.
      await tester.tap(find.text('Reject').last);
      await tester.pumpAndSettle();

      final inbox = read<HrInboxState>(tester);
      expect(inbox.pendingCount, 6);
      expect(
        inbox.items.where((i) => i.status == InboxStatus.rejected).length,
        2,
      );
    });

    testWidgets('the kind filter narrows the list', (tester) async {
      await pump(tester, const HrLeaveScreen());

      // "Overtime" is both a filter chip and part of a card title, so look
      // for the chip among the filter labels.
      await tester.tap(find.text('Overtime').first);
      await tester.pumpAndSettle();

      expect(find.text('Bikash Lama'), findsOneWidget);
      expect(find.text('Sita Gurung'), findsNothing);
      // The total waiting count is unaffected by the filter.
      expect(find.text('7 requests are waiting for you'), findsOneWidget);
    });

    testWidgets('clearing every request shows the caught-up message', (
      tester,
    ) async {
      await pump(tester, const HrLeaveScreen());
      final inbox = read<HrInboxState>(tester);
      for (final item in inbox.pending) {
        inbox.decide(item.id, InboxStatus.approved);
      }
      await tester.pumpAndSettle();

      expect(find.text('Nothing is waiting for you'), findsOneWidget);
      expect(find.textContaining("You're all caught up"), findsOneWidget);
    });
  });

  group('Policy', () {
    testWidgets('lists every leave type with its rules', (tester) async {
      await pump(tester, const HrLeaveScreen());
      await tester.tap(find.text('Policy'));
      await tester.pumpAndSettle();

      expect(find.text('Home Leave'), findsOneWidget);
      expect(find.text('Sick Leave'), findsOneWidget);
      expect(find.textContaining('days a year'), findsWidgets);
      expect(find.textContaining('placeholders'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Holidays', () {
    testWidgets('shows company and public holidays', (tester) async {
      await pump(tester, const HrLeaveScreen());
      await tester.tap(find.text('Holidays'));
      await tester.pumpAndSettle();

      expect(find.text('Company Foundation Day'), findsOneWidget);
      expect(find.text('Annual Picnic'), findsOneWidget);
      expect(find.text('UPCOMING PUBLIC HOLIDAYS'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('adding a holiday needs a name, then appears in the list', (
      tester,
    ) async {
      await pump(tester, const HrLeaveScreen());
      await tester.tap(find.text('Holidays'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add company holiday'));
      await tester.pumpAndSettle();

      // Save with no name is refused.
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a name for the holiday.'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(read<CompanyHolidaysState>(tester).holidays.length, 2);

      await tester.enterText(find.byType(CupertinoTextField), 'Teej Day');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Teej Day'), findsOneWidget);
      expect(read<CompanyHolidaysState>(tester).holidays.length, 3);
    });

    testWidgets('removing a holiday asks first', (tester) async {
      await pump(tester, const HrLeaveScreen());
      await tester.tap(find.text('Holidays'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(CupertinoIcons.minus_circle).first);
      await tester.pumpAndSettle();
      expect(find.text('Remove Company Foundation Day?'), findsOneWidget);

      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      expect(find.text('Company Foundation Day'), findsNothing);
      expect(read<CompanyHolidaysState>(tester).holidays.length, 1);
    });
  });

  group('Overview "Needs your action"', () {
    testWidgets('counts the requests waiting', (tester) async {
      await pump(tester, const HrOverviewScreen());
      expect(find.text('Needs your action'), findsOneWidget);
      expect(find.text('7 requests to review'), findsOneWidget);
    });

    testWidgets('says all clear when nothing is pending', (tester) async {
      await pump(tester, const HrOverviewScreen());
      final inbox = read<HrInboxState>(tester);
      for (final item in inbox.pending) {
        inbox.decide(item.id, InboxStatus.approved);
      }
      // Expiring documents are something to do too, until they are gone.
      final docs = read<EmployeeDocumentsState>(tester);
      for (final d in docs.expiringSoon()) {
        docs.remove(d.id);
      }
      // This month's payroll is also something to do, until it is approved.
      final today = bsToday();
      read<PayrollState>(tester)
        ..calculate(today.year, today.month, const [])
        ..approve(today.year, today.month);
      await tester.pumpAndSettle();
      expect(find.text('Nothing needs your action.'), findsOneWidget);
    });

    testWidgets('tapping it opens Leave & Holidays on a wide screen', (
      tester,
    ) async {
      await pump(tester, const HrPortalScreen(), width: 1280);

      await tester.tap(find.text('7 requests to review'));
      await tester.pumpAndSettle();

      expect(find.byType(HrLeaveScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping it switches to the Leave tab on a phone', (
      tester,
    ) async {
      await pump(tester, const HrPortalScreen());

      await tester.tap(find.text('7 requests to review'));
      await tester.pumpAndSettle();

      expect(find.byType(HrLeaveScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('every tab renders in Nepali on a narrow phone', (tester) async {
    await pump(
      tester,
      const HrLeaveScreen(),
      width: 320,
      locale: const Locale('ne'),
    );
    for (final tab in ['नीति', 'बिदाहरू', 'स्वीकृति']) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: tab);
    }
  });
}

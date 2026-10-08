import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_first_flutter_app/l10n/app_localizations.dart';
import 'package:my_first_flutter_app/main.dart';
import 'package:my_first_flutter_app/screens/hr/hr_employee_detail_screen.dart';
import 'package:my_first_flutter_app/screens/hr/hr_overview_screen.dart';
import 'package:my_first_flutter_app/state/audit_log_state.dart';
import 'package:my_first_flutter_app/state/employee_documents_state.dart';

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

T read<T>(WidgetTester tester) =>
    tester.element(find.byType(CupertinoApp)).read<T>();

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Docs tab', () {
    testWidgets('lists documents with their expiry', (tester) async {
      // Prakash Adhikari: a work permit that has already expired.
      await pump(tester, const HrEmployeeDetailScreen(employeeId: 'MB-23088'));
      await tester.tap(find.text('Docs'));
      await tester.pumpAndSettle();

      expect(find.text('Work permit'), findsOneWidget);
      expect(find.textContaining('Expired'), findsOneWidget);
      expect(find.text('Add document'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('says so when there are none', (tester) async {
      // Anita Shrestha has no documents on file.
      await pump(tester, const HrEmployeeDetailScreen(employeeId: 'MB-22015'));
      await tester.tap(find.text('Docs'));
      await tester.pumpAndSettle();
      expect(find.text('No documents on file.'), findsOneWidget);
    });

    testWidgets('adding needs a name, then lists it and logs it', (
      tester,
    ) async {
      await pump(tester, const HrEmployeeDetailScreen(employeeId: 'MB-22015'));
      await tester.tap(find.text('Docs'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add document'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a name for the document.'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(CupertinoTextField), 'PAN card');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('PAN card'), findsOneWidget);
      expect(
        read<EmployeeDocumentsState>(tester).forEmployee('MB-22015').length,
        1,
      );
      expect(
        read<AuditLogState>(tester).entries.single.action,
        AuditAction.documentAdded,
      );
    });

    testWidgets('removing asks first', (tester) async {
      await pump(tester, const HrEmployeeDetailScreen(employeeId: 'MB-23088'));
      await tester.tap(find.text('Docs'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(CupertinoIcons.minus_circle));
      await tester.pumpAndSettle();
      expect(find.text('Remove "Work permit"?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Work permit'), findsOneWidget);

      await tester.tap(find.byIcon(CupertinoIcons.minus_circle));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      expect(find.text('Work permit'), findsNothing);
      expect(
        read<AuditLogState>(tester).entries.single.action,
        AuditAction.documentRemoved,
      );
    });
  });

  group('Letters', () {
    testWidgets('offers the three letters', (tester) async {
      await pump(tester, const HrEmployeeDetailScreen(employeeId: 'MB-24071'));

      await tester.tap(find.text('Letters'));
      await tester.pumpAndSettle();

      expect(find.text('Appointment letter'), findsOneWidget);
      expect(find.text('Experience letter'), findsOneWidget);
      expect(find.text('Salary certificate'), findsOneWidget);
      expect(find.text('Bishwas Sigdel'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('choosing one opens the PDF share options', (tester) async {
      await pump(tester, const HrEmployeeDetailScreen(employeeId: 'MB-24071'));
      await tester.tap(find.text('Letters'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Appointment letter'));
      await tester.pumpAndSettle();

      // The PDF actions sheet is titled with the letter's name.
      expect(find.text('Appointment letter'), findsOneWidget);
      expect(find.byType(CupertinoActionSheet), findsOneWidget);
    });
  });

  group('Needs your action: documents', () {
    testWidgets('counts documents expiring soon', (tester) async {
      await pump(tester, const HrOverviewScreen());
      expect(find.text('3 documents expiring soon'), findsOneWidget);
    });

    testWidgets('the row disappears when none are expiring', (tester) async {
      await pump(tester, const HrOverviewScreen());
      final docs = read<EmployeeDocumentsState>(tester);
      for (final d in docs.expiringSoon()) {
        docs.remove(d.id);
      }
      await tester.pumpAndSettle();
      expect(find.textContaining('documents expiring'), findsNothing);
    });
  });

  testWidgets('the Docs tab renders in Nepali on a narrow phone', (
    tester,
  ) async {
    await pump(
      tester,
      const HrEmployeeDetailScreen(employeeId: 'MB-23088'),
      width: 320,
      locale: const Locale('ne'),
    );
    await tester.tap(find.text('कागजात'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

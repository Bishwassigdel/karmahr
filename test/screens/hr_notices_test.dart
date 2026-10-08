import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_first_flutter_app/l10n/app_localizations.dart';
import 'package:my_first_flutter_app/main.dart';
import 'package:my_first_flutter_app/screens/hr/hr_notices_screen.dart';
import 'package:my_first_flutter_app/screens/notices_screen.dart';
import 'package:my_first_flutter_app/state/notices_state.dart';

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

NoticesState notices(WidgetTester tester) =>
    tester.element(find.byType(CupertinoApp)).read<NoticesState>();

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('lists the current notices with their category', (tester) async {
    await pump(tester, const HrNoticesScreen());

    expect(find.text('Office Closed for Dashain'), findsOneWidget);
    expect(find.text('Holiday'), findsWidgets);
    expect(find.text('Urgent'), findsWidgets);
    expect(find.text('New notice'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('publishing needs a title and some text', (tester) async {
    await pump(tester, const HrNoticesScreen());
    await tester.tap(find.text('New notice'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Publish'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a title for the notice.'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(CupertinoTextField).first, 'Hello');
    await tester.tap(find.text('Publish'));
    await tester.pumpAndSettle();
    expect(find.text('Write the text of the notice.'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    final before = notices(tester).notices.length;
    expect(before, 4);
  });

  testWidgets('a published notice appears first, and employees see it too', (
    tester,
  ) async {
    await pump(tester, const HrNoticesScreen());
    await tester.tap(find.text('New notice'));
    await tester.pumpAndSettle();

    final fields = find.byType(CupertinoTextField);
    await tester.enterText(fields.at(0), 'Salary day moved');
    await tester.enterText(fields.at(1), 'Salary will be paid on the 25th.');
    await tester.tap(find.text('Publish'));
    await tester.pumpAndSettle();

    // Back on HR's list, at the top.
    expect(find.text('Salary day moved'), findsOneWidget);
    expect(notices(tester).notices.first.title, 'Salary day moved');

    // The employee's own Notices screen reads the same list.
    Navigator.push(
      tester.element(find.byType(HrNoticesScreen)),
      CupertinoPageRoute<void>(builder: (_) => const NoticesScreen()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Salary day moved'), findsOneWidget);
  });

  testWidgets('the category picker changes the published category', (
    tester,
  ) async {
    await pump(tester, const HrNoticesScreen());
    await tester.tap(find.text('New notice'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('General'));
    await tester.pumpAndSettle();
    // Drag the wheel to the next entry ("Urgent") and confirm.
    await tester.drag(find.byType(CupertinoPicker), const Offset(0, -40));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    final fields = find.byType(CupertinoTextField);
    await tester.enterText(fields.at(0), 'Fire drill');
    await tester.enterText(fields.at(1), 'Friday at 11.');
    await tester.tap(find.text('Publish'));
    await tester.pumpAndSettle();

    expect(notices(tester).notices.first.category, 'Urgent');
  });

  testWidgets('deleting asks first', (tester) async {
    await pump(tester, const HrNoticesScreen());

    await tester.tap(find.byIcon(CupertinoIcons.trash).first);
    await tester.pumpAndSettle();
    expect(find.text('Delete "Office Closed for Dashain"?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(notices(tester).notices.length, 4);

    await tester.tap(find.byIcon(CupertinoIcons.trash).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Office Closed for Dashain'), findsNothing);
    expect(notices(tester).notices.length, 3);
  });

  testWidgets('shows a message when there are no notices', (tester) async {
    await pump(tester, const HrNoticesScreen());
    final state = notices(tester);
    for (final n in state.notices) {
      state.remove(n);
    }
    await tester.pumpAndSettle();
    expect(find.text('No notices yet.'), findsOneWidget);
  });

  testWidgets('renders in Nepali on a narrow phone', (tester) async {
    await pump(
      tester,
      const HrNoticesScreen(),
      width: 320,
      locale: const Locale('ne'),
    );
    expect(find.text('नयाँ सूचना'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

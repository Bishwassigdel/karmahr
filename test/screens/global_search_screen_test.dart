import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:my_first_flutter_app/screens/global_search_screen.dart';
import 'package:my_first_flutter_app/state/hr_request_state.dart';
import 'package:my_first_flutter_app/state/leave_state.dart';

Widget _wrapped() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => LeaveState()),
      ChangeNotifierProvider(create: (_) => HrRequestState()),
    ],
    child: const CupertinoApp(home: GlobalSearchScreen()),
  );
}

void main() {
  testWidgets('shows a hint and no results with an empty query', (
    tester,
  ) async {
    await tester.pumpWidget(_wrapped());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.textContaining('Search across the Employee Directory'),
      findsOneWidget,
    );
  });

  testWidgets('finds a known employee by a partial, case-insensitive name', (
    tester,
  ) async {
    await tester.pumpWidget(_wrapped());
    await tester.enterText(find.byType(CupertinoSearchTextField), 'suresh');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Suresh Karki'), findsOneWidget);
  });

  testWidgets('finds a known notice by a word from its body', (tester) async {
    await tester.pumpWidget(_wrapped());
    await tester.enterText(find.byType(CupertinoSearchTextField), 'dashain');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Office Closed for Dashain'), findsOneWidget);
  });

  testWidgets('shows a no-results message for a query matching nothing', (
    tester,
  ) async {
    await tester.pumpWidget(_wrapped());
    await tester.enterText(
      find.byType(CupertinoSearchTextField),
      'zzz_nomatch_zzz',
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('No results for'), findsOneWidget);
  });

  testWidgets('finds a seeded leave request by its leave type', (
    tester,
  ) async {
    await tester.pumpWidget(_wrapped());
    // LeaveState's seed data includes a 'Sick Leave' entry.
    await tester.enterText(find.byType(CupertinoSearchTextField), 'sick');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Sick Leave'), findsWidgets);
  });
}

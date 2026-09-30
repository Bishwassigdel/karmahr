import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:my_first_flutter_app/screens/insights_screen.dart';
import 'package:my_first_flutter_app/state/kudos_state.dart';
import 'package:my_first_flutter_app/state/leave_balance_state.dart';
import 'package:my_first_flutter_app/state/leave_state.dart';

Widget _wrapped() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => LeaveState()),
      ChangeNotifierProvider(create: (_) => LeaveBalanceState()),
      ChangeNotifierProvider(create: (_) => KudosState()),
    ],
    child: const CupertinoApp(home: InsightsScreen()),
  );
}

void main() {
  testWidgets('renders all three sections with real charts', (tester) async {
    await tester.pumpWidget(_wrapped());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Leave Used This Fiscal Year'), findsOneWidget);
    expect(find.text('Attendance This Week'), findsOneWidget);
    expect(find.byType(BarChart), findsOneWidget);
    expect(find.byType(LineChart), findsOneWidget);

    // The leaderboard sits below the fold on the default test viewport.
    await tester.scrollUntilVisible(
      find.text('Kudos Leaderboard'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Kudos Leaderboard'), findsOneWidget);
  });

  testWidgets('leaderboard ranks the seeded kudos recipient with points', (
    tester,
  ) async {
    await tester.pumpWidget(_wrapped());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('10 pts'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    // KudosState's seed gives Bishwas Sigdel 10 points and Sita Gurung 0,
    // so Bishwas must be ranked #1.
    expect(find.text('10 pts'), findsOneWidget);
    expect(find.text('#1'), findsOneWidget);
  });
}

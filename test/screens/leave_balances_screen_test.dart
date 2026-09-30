import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:my_first_flutter_app/screens/leave_balances_screen.dart';
import 'package:my_first_flutter_app/state/leave_balance_state.dart';
import 'package:my_first_flutter_app/state/leave_state.dart';

void main() {
  testWidgets(
    'renders without throwing and shows the Home Leave summary + '
    'per-type breakdown wired to LeaveBalanceState',
    (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LeaveState()),
            ChangeNotifierProvider(create: (_) => LeaveBalanceState()),
          ],
          child: const CupertinoApp(home: LeaveBalancesScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Leave & Balances'), findsOneWidget);
      // "Home Leave" appears more than once (the summary subtitle, the
      // per-type breakdown row, and the leave-type picker option) — just
      // confirm it's present, not an exact count.
      expect(find.text('Home Leave'), findsWidgets);
      expect(find.text('All Leave Balances'), findsOneWidget);
      // One row per policy-tracked leave type from leavePolicies.
      expect(find.text('Sick Leave'), findsWidgets);
      expect(find.text('Unpaid Leave'), findsWidgets);
    },
  );
}

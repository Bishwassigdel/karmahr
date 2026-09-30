import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';

import 'package:my_first_flutter_app/screens/apps/tasks/tasks_module_screen.dart';
import 'package:my_first_flutter_app/screens/apps/widgets/refreshable_list_view.dart';
import 'package:my_first_flutter_app/screens/apps/widgets/skeleton.dart';

void main() {
  testWidgets('Tasks shows a shimmer skeleton while loading, then the list', (
    tester,
  ) async {
    await tester.pumpWidget(const CupertinoApp(home: TasksModuleScreen()));

    // First frame: fetchMyTasks() is still in its simulated 600ms fetch.
    expect(find.byType(SkeletonList), findsOneWidget);
    expect(find.byType(Shimmer), findsOneWidget);

    // Advance past the fetch. (Not pumpAndSettle before this point — the
    // shimmer animates forever while it's on screen, by design.)
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.byType(SkeletonList), findsNothing);
    expect(find.text('Submit Q3 Expense Report'), findsOneWidget);
  });

  testWidgets('pulling down past the threshold calls onRefresh', (
    tester,
  ) async {
    var refreshed = false;

    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: RefreshableListView(
            onRefresh: () async => refreshed = true,
            children: const [SizedBox(height: 60, child: Text('row'))],
          ),
        ),
      ),
    );

    await tester.drag(find.text('row'), const Offset(0, 300));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(refreshed, isTrue);
  });
}

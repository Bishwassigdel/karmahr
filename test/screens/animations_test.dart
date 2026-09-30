import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_flutter_app/screens/apps/widgets/staggered_entrance.dart';
import 'package:my_first_flutter_app/screens/notices_screen.dart';

double _opacityOf(WidgetTester tester) => tester
    .widget<FadeTransition>(
      find.descendant(
        of: find.byType(StaggeredEntrance),
        matching: find.byType(FadeTransition),
      ),
    )
    .opacity
    .value;

void main() {
  testWidgets('StaggeredEntrance starts invisible and ends fully visible', (
    tester,
  ) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: StaggeredEntrance(index: 3, child: Text('item')),
      ),
    );
    expect(_opacityOf(tester), 0);

    await tester.pumpAndSettle();
    expect(_opacityOf(tester), 1);
  });

  testWidgets('StaggeredEntrance skips the animation under Reduce Motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: CupertinoApp(
          home: StaggeredEntrance(index: 3, child: Text('item')),
        ),
      ),
    );
    await tester.pump();

    expect(_opacityOf(tester), 1);
  });

  testWidgets('opening a notice flies its category pill into the detail', (
    tester,
  ) async {
    await tester.pumpWidget(const CupertinoApp(home: NoticesScreen()));
    await tester.pumpAndSettle();

    // One Hero per visible notice card, each with a distinct tag —
    // duplicate tags would throw as soon as the route transition starts.
    expect(find.byType(Hero), findsWidgets);

    await tester.tap(find.text('Office Closed for Dashain'));
    await tester.pump(); // start the route transition
    await tester.pump(const Duration(milliseconds: 150)); // mid-flight
    expect(tester.takeException(), isNull);

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Notice'), findsOneWidget); // detail nav title
    expect(find.text('Holiday'), findsOneWidget); // the pill landed
  });
}

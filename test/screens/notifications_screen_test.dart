import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_first_flutter_app/screens/notifications_screen.dart';
import 'package:my_first_flutter_app/state/notification_state.dart';
import 'package:my_first_flutter_app/state/push_notification_state.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('bell shows the unread count and opens the inbox', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => NotificationState(),
        child: const CupertinoApp(
          home: CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              trailing: NotificationBell(),
            ),
            child: SizedBox(),
          ),
        ),
      ),
    );

    expect(find.text('2'), findsOneWidget); // seeded unread count

    await tester.tap(find.byType(NotificationBell));
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Company Notices'), findsOneWidget);
    expect(find.text('You received kudos!'), findsOneWidget);
  });

  testWidgets('tapping an item marks it read; "Mark all read" clears all', (
    tester,
  ) async {
    final state = NotificationState();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const CupertinoApp(home: NotificationsScreen()),
      ),
    );

    await tester.tap(find.text('You received kudos!'));
    await tester.pump();
    expect(state.unreadCount, 1);

    await tester.tap(find.text('Mark all read'));
    await tester.pump();
    expect(state.unreadCount, 0);
    // The button hides itself once there's nothing left to mark.
    expect(find.text('Mark all read'), findsNothing);
  });

  testWidgets(
    'notifyUser() always records in the inbox, even with push disabled',
    (tester) async {
      final inbox = NotificationState();
      final push = PushNotificationState();
      // Let PushNotificationState's real async init finish (see
      // app_lock_gate_test.dart for why runAsync is needed).
      await tester.runAsync(() async {
        for (var i = 0; i < 50 && !push.isLoaded; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 5));
        }
      });
      expect(push.enabled, isFalse);

      late BuildContext captured;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: inbox),
            ChangeNotifierProvider.value(value: push),
          ],
          child: CupertinoApp(
            home: Builder(
              builder: (context) {
                captured = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      notifyUser(
        captured,
        kind: AppNotificationKind.leave,
        title: 'Sick Leave request submitted',
        body: 'Pending approval.',
      );

      expect(inbox.items.first.title, 'Sick Leave request submitted');
      expect(inbox.unreadCount, 3);
    },
  );
}

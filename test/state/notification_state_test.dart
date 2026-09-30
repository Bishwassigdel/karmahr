import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_flutter_app/screens/notifications_screen.dart';
import 'package:my_first_flutter_app/state/notification_state.dart';

void main() {
  group('NotificationState', () {
    test('seed data starts with two unread items', () {
      expect(NotificationState().unreadCount, 2);
    });

    test('add() puts the new item at the top, unread', () {
      final state = NotificationState();
      state.add(
        kind: AppNotificationKind.leave,
        title: 'Newest',
        body: 'body',
      );

      expect(state.items.first.title, 'Newest');
      expect(state.items.first.isRead, isFalse);
      expect(state.unreadCount, 3);
    });

    test('markRead() is idempotent and only notifies on a real change', () {
      final state = NotificationState();
      var notifications = 0;
      state.addListener(() => notifications++);

      final unread = state.items.firstWhere((n) => !n.isRead);
      state.markRead(unread);
      state.markRead(unread);

      expect(state.unreadCount, 1);
      expect(notifications, 1);
    });

    test('markAllRead() clears the badge count', () {
      final state = NotificationState()..markAllRead();
      expect(state.unreadCount, 0);
    });

    test('reset() drops this session and restores the seed', () {
      final state = NotificationState()
        ..add(kind: AppNotificationKind.kudos, title: 'x', body: 'y')
        ..markAllRead()
        ..reset();

      expect(state.items.any((n) => n.title == 'x'), isFalse);
      expect(state.unreadCount, 2);
    });
  });

  group('relativeTime', () {
    final now = DateTime(2026, 9, 30, 12);

    test('under a minute reads "Just now"', () {
      expect(relativeTime(now.subtract(const Duration(seconds: 20)), now: now),
          'Just now');
    });

    test('minutes, hours, and days use compact units', () {
      expect(relativeTime(now.subtract(const Duration(minutes: 5)), now: now),
          '5m');
      expect(relativeTime(now.subtract(const Duration(hours: 3)), now: now),
          '3h');
      expect(relativeTime(now.subtract(const Duration(days: 2)), now: now),
          '2d');
    });
  });
}

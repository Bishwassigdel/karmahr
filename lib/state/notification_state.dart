// The in-app notification inbox — everything the app has told the user,
// newest first, with read/unread tracking for the Dashboard bell badge.
//
// Deliberately separate from PushNotificationState (the device-level
// banner/lock-screen notifications): the inbox ALWAYS records an event,
// even when the user has push notifications turned off or denied
// permission. Those are two different questions — "did it happen?"
// vs. "should my phone buzz about it?" — and conflating them would mean
// turning off push silently loses history too.
//
// Pure in-memory ChangeNotifier, same pattern as LeaveState — no
// platform channels, so it's trivially unit-testable.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'push_notification_state.dart';

enum AppNotificationKind { leave, hrRequest, kudos, reminder, notice, system }

IconData notificationIcon(AppNotificationKind kind) {
  switch (kind) {
    case AppNotificationKind.leave:
      return CupertinoIcons.airplane;
    case AppNotificationKind.hrRequest:
      return CupertinoIcons.doc_on_doc_fill;
    case AppNotificationKind.kudos:
      return CupertinoIcons.heart_fill;
    case AppNotificationKind.reminder:
      return CupertinoIcons.alarm_fill;
    case AppNotificationKind.notice:
      return CupertinoIcons.speaker_2_fill;
    case AppNotificationKind.system:
      return CupertinoIcons.info_circle_fill;
  }
}

CupertinoDynamicColor notificationColor(AppNotificationKind kind) {
  switch (kind) {
    case AppNotificationKind.leave:
      return CupertinoColors.systemRed;
    case AppNotificationKind.hrRequest:
      return CupertinoColors.systemOrange;
    case AppNotificationKind.kudos:
      return CupertinoColors.systemPink;
    case AppNotificationKind.reminder:
      return CupertinoColors.systemPurple;
    case AppNotificationKind.notice:
      return CupertinoColors.systemIndigo;
    case AppNotificationKind.system:
      return CupertinoColors.systemBlue;
  }
}

class AppNotification {
  final AppNotificationKind kind;
  final String title;
  final String body;
  final DateTime createdAt;

  // Not final — flips in place when the user opens it, without
  // replacing the object (same idea as KudosPost.reactionCount).
  bool isRead;

  AppNotification({
    required this.kind,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });
}

class NotificationState extends ChangeNotifier {
  final List<AppNotification> _items = _seed();

  // A few realistic entries so the bell badge and inbox demonstrate
  // themselves on first launch, instead of an empty screen.
  static List<AppNotification> _seed() => [
    AppNotification(
      kind: AppNotificationKind.kudos,
      title: 'You received kudos!',
      body: 'Suresh Karki recognized you for Great Work (+10 pts).',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    AppNotification(
      kind: AppNotificationKind.notice,
      title: 'New notice: Office Closed for Dashain',
      body: 'The office will remain closed from Ashwin 19 to Ashwin 23.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    AppNotification(
      kind: AppNotificationKind.system,
      title: 'Welcome to KarmaHR',
      body: 'Turn on push notifications in Settings to get reminders.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      isRead: true,
    ),
  ];

  List<AppNotification> get items => List.unmodifiable(_items);

  int get unreadCount => _items.where((n) => !n.isRead).length;

  void add({
    required AppNotificationKind kind,
    required String title,
    required String body,
  }) {
    _items.insert(
      0,
      AppNotification(
        kind: kind,
        title: title,
        body: body,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void markRead(AppNotification notification) {
    if (notification.isRead) return;
    notification.isRead = true;
    notifyListeners();
  }

  void markAllRead() {
    var changed = false;
    for (final n in _items) {
      if (!n.isRead) {
        n.isRead = true;
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  // Called on logout — same reason as every other state's reset():
  // the next person on this device mustn't see this user's history.
  void reset() {
    _items
      ..clear()
      ..addAll(_seed());
    notifyListeners();
  }
}

/// One call for "tell the user something happened": always records it in
/// the in-app inbox, and ALSO fires a device notification if (and only
/// if) the user has push notifications enabled. Call sites use this
/// instead of touching the two states separately, so the "inbox always,
/// push only when allowed" rule lives in exactly one place.
void notifyUser(
  BuildContext context, {
  required AppNotificationKind kind,
  required String title,
  required String body,
}) {
  context.read<NotificationState>().add(kind: kind, title: title, body: body);
  context.read<PushNotificationState>().show(title: title, body: body);
}

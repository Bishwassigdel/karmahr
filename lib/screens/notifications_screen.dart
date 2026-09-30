// The notification inbox the Dashboard bell opens. Newest first, unread
// ones marked with a dot; tapping one marks it read. Company Notices
// (which the bell used to open directly) stay one tap away via the row
// at the top, so nothing that was reachable before is lost.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../state/notification_state.dart';
import '../theme/app_colors.dart';
import 'notices_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NotificationState>();
    final items = state.items;
    final subtleTextColor = CupertinoColors.systemGrey.resolveFrom(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Notifications'),
        trailing: state.unreadCount == 0
            ? null
            : CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                onPressed: () =>
                    context.read<NotificationState>().markAllRead(),
                child: const Text('Mark all read'),
              ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.speaker_2),
                  title: const Text('Company Notices'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const NoticesScreen(),
                    ),
                  ),
                ),
              ],
            ),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Text(
                    "You're all caught up.",
                    style: TextStyle(color: subtleTextColor),
                  ),
                ),
              )
            else
              CupertinoListSection.insetGrouped(
                header: const Text('RECENT'),
                children: [
                  for (final n in items) _NotificationTile(notification: n),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final color = notificationColor(notification.kind).resolveFrom(context);
    final subtleTextColor = CupertinoColors.systemGrey.resolveFrom(context);

    return CupertinoListTile(
      leadingSize: 36,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          shape: BoxShape.circle,
        ),
        child: Icon(
          notificationIcon(notification.kind),
          color: color,
          size: 18,
        ),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w700,
        ),
      ),
      subtitle: Text(
        notification.body,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      additionalInfo: Text(
        relativeTime(notification.createdAt),
        style: TextStyle(fontSize: 12, color: subtleTextColor),
      ),
      trailing: notification.isRead
          ? null
          : Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: AppColors.karmaRed,
                shape: BoxShape.circle,
              ),
            ),
      onTap: () => context.read<NotificationState>().markRead(notification),
    );
  }
}

/// "Just now" / "5m" / "3h" / "2d" — compact enough for a list row.
String relativeTime(DateTime time, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).difference(time);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m';
  if (diff.inDays < 1) return '${diff.inHours}h';
  return '${diff.inDays}d';
}

/// The Dashboard bell, with a red unread-count badge. Lives here (not in
/// dashboard_screen.dart) so the badge logic sits next to the inbox it
/// belongs to.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<NotificationState>().unreadCount;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: () => Navigator.push(
        context,
        CupertinoPageRoute(builder: (context) => const NotificationsScreen()),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(CupertinoIcons.bell),
          if (unread > 0)
            Positioned(
              right: -6,
              top: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                constraints: const BoxConstraints(minWidth: 17),
                decoration: BoxDecoration(
                  color: AppColors.karmaRed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  unread > 9 ? '9+' : '$unread',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

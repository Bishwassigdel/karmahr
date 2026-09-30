// The one check-in/check-out action both the Dashboard card and the
// Attendance module call. Before this, each screen had its own copy of
// the same if/else — adding notifications to both would have meant two
// copies of that logic drifting apart, so it lives here once instead.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'attendance_state.dart';
import 'notification_state.dart';
import 'push_notification_state.dart';

void toggleAttendance(BuildContext context) {
  final attendance = context.read<AttendanceState>();
  final push = context.read<PushNotificationState>();

  if (attendance.isCheckedIn) {
    attendance.checkOut();
    // The "remember to check out" reminder is pointless once you have.
    push.cancelCheckoutReminder();
    notifyUser(
      context,
      kind: AppNotificationKind.reminder,
      title: 'Checked out at ${attendance.checkOutTime}',
      body: 'Have a good evening! Your day has been recorded.',
    );
  } else {
    attendance.checkIn();
    // A real scheduled OS notification — fires 9 hours from now even if
    // the app is closed, unless check-out cancels it first.
    push.scheduleCheckoutReminder();
    notifyUser(
      context,
      kind: AppNotificationKind.reminder,
      title: 'Checked in at ${attendance.checkInTime}',
      body: push.enabled
          ? "We'll remind you to check out in 9 hours."
          : 'Turn on push notifications in Settings to get a '
                'check-out reminder.',
    );
  }
}

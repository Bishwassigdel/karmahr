// Device-level notifications (banners, lock screen, sound) via
// flutter_local_notifications — the "should the phone buzz?" half of
// notifications. The "did it happen?" half is NotificationState's inbox.
//
// Same shape as AppLockState: a persisted on/off preference, an
// isLoaded flag, and every platform call wrapped so a failure (plugin
// not registered, permission denied, unsupported platform, the test
// environment) degrades to "no device notification" — never a crash,
// and never a hang on startup.
//
// Frontend-only, but these are REAL local notifications: scheduled
// reminders fire even with the app closed, because the OS holds them,
// not this process. No push server is involved — a backend would only
// be needed for events that originate on another device (e.g. a
// manager approving leave from their own phone).

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

const _prefsKey = 'pushNotificationsEnabled';

// Fixed IDs for the reminders that must be cancellable/replaceable by
// identity — re-checking-in replaces the previous checkout reminder
// instead of stacking a second one.
const _checkoutReminderId = 1001;
const _eventReminderIdBase = 2000;

const _details = NotificationDetails(
  android: AndroidNotificationDetails(
    'karmahr_general',
    'KarmaHR',
    channelDescription: 'Leave, request, and reminder notifications',
    importance: Importance.high,
    priority: Priority.high,
  ),
  iOS: DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  ),
  macOS: DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  ),
);

class PushNotificationState extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _enabled = false;
  bool get enabled => _enabled;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  // Whether the plugin actually initialized on this platform. If not,
  // Settings can explain why the toggle does nothing instead of
  // silently failing.
  bool _pluginReady = false;
  bool get pluginReady => _pluginReady;

  // Immediate notifications get sequential IDs so several in a row don't
  // overwrite each other in the notification center.
  int _nextId = 100;

  PushNotificationState() {
    _init();
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _enabled = prefs.getBool(_prefsKey) ?? false;
    } catch (_) {
      _enabled = false;
    }

    // Catch-all (not just `on Exception`) on purpose: on an unsupported
    // platform or in tests the plugin can fail with an Error, not only
    // an Exception, and whatever the cause, the answer is the same —
    // device notifications are unavailable, the app carries on.
    try {
      tzdata.initializeTimeZones();
      const darwin = DarwinInitializationSettings(
        // Don't prompt at launch — permission is asked for only when the
        // user actually flips the toggle in Settings, so the system
        // prompt appears with context instead of out of nowhere.
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: darwin,
        macOS: darwin,
      );
      _pluginReady = await _plugin.initialize(settings: settings) ?? false;
    } catch (_) {
      _pluginReady = false;
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<bool> _requestPermission() async {
    try {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (ios != null) {
        return await ios.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        // null on Android 12 and below, where there's no runtime
        // notification permission at all — that means "allowed".
        return await android.requestNotificationsPermission() ?? true;
      }
      final macos = _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >();
      if (macos != null) {
        return await macos.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Turning ON asks the OS for permission first and only persists
  /// "enabled" if it's granted — returns false if denied, so Settings
  /// can tell the user where to fix it. Turning OFF also cancels every
  /// scheduled reminder, so "off" really means silent.
  Future<bool> setEnabled(bool value) async {
    if (value) {
      if (!_pluginReady) return false;
      final granted = await _requestPermission();
      if (!granted) return false;
    } else {
      try {
        await _plugin.cancelAll();
      } catch (_) {}
    }

    _enabled = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, value);
    } catch (_) {}
    return true;
  }

  /// Shows a device notification right now — silently does nothing when
  /// disabled or unavailable. Fire-and-forget by design: no call site
  /// should ever wait on, or fail because of, a notification.
  Future<void> show({required String title, required String body}) async {
    if (!_enabled || !_pluginReady) return;
    try {
      await _plugin.show(
        id: _nextId++,
        title: title,
        body: body,
        notificationDetails: _details,
      );
    } catch (_) {}
  }

  /// Schedules a "don't forget to check out" reminder [after] from now,
  /// replacing any previous one. Called on check-in.
  Future<void> scheduleCheckoutReminder({
    Duration after = const Duration(hours: 9),
  }) async {
    await _schedule(
      id: _checkoutReminderId,
      title: 'Time to check out?',
      body:
          'You checked in ${after.inHours} hours ago. Remember to check '
          'out in KarmaHR before you leave.',
      at: DateTime.now().add(after),
    );
  }

  /// Called on check-out — the reminder is pointless once you have.
  Future<void> cancelCheckoutReminder() async {
    try {
      await _plugin.cancel(id: _checkoutReminderId);
    } catch (_) {}
  }

  /// Schedules a reminder for a calendar event: 9 AM the day before if
  /// that's still ahead, otherwise 9 AM on the day itself. Returns the
  /// moment it was scheduled for, or null if both are already past (or
  /// notifications are off/unavailable) — the caller shows the reason.
  Future<DateTime?> scheduleEventReminder({
    required int eventKey,
    required String title,
    required DateTime eventDate,
  }) async {
    if (!_enabled || !_pluginReady) return null;

    final now = DateTime.now();
    final dayBefore = DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day - 1,
      9,
    );
    final dayOf = DateTime(eventDate.year, eventDate.month, eventDate.day, 9);
    final at = dayBefore.isAfter(now)
        ? dayBefore
        : (dayOf.isAfter(now) ? dayOf : null);
    if (at == null) return null;

    final ok = await _schedule(
      id: _eventReminderIdBase + (eventKey.abs() % 100000),
      title: at == dayOf ? 'Today: $title' : 'Tomorrow: $title',
      body: 'Reminder from your KarmaHR calendar.',
      at: at,
    );
    return ok ? at : null;
  }

  Future<bool> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime at,
  }) async {
    if (!_enabled || !_pluginReady) return false;
    try {
      // TZDateTime.from takes the absolute instant, so the notification
      // fires at the right moment even though tz.local is left at its
      // UTC default (no device-timezone lookup package needed).
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(at, tz.local),
        notificationDetails: _details,
        // Inexact: no SCHEDULE_EXACT_ALARM permission needed on Android
        // 12+, and a reminder a few minutes late is fine for this.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}

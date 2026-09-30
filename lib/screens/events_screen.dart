// 1. IMPORTS
import 'package:flutter/cupertino.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:provider/provider.dart';

import 'apps/widgets/ui_kit.dart';
import 'give_kudos_screen.dart';
import 'holiday_calendar_screen.dart';
import 'leave_planner_screen.dart';
import '../data/team_data.dart';
import '../state/event_rsvp_state.dart';
import '../data/calendar_data.dart';
import '../state/notification_state.dart';
import '../state/push_notification_state.dart';
import '../theme/app_colors.dart';

// 2. EVENTS SCREEN
//
// Holidays (from the HR calendar), company events you can RSVP to,
// coworkers' birthdays and work anniversaries, and long-break ideas —
// with a filter so each can be seen on its own.
enum _EventsFilter { all, holidays, company }

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  _EventsFilter _filter = _EventsFilter.all;

  @override
  Widget build(BuildContext context) {
    final showHolidays = _filter != _EventsFilter.company;
    final showCompany = _filter != _EventsFilter.holidays;

    // Pull the upcoming markers once — both the countdown card and the
    // list below read from this same list, so they can never disagree.
    final upcoming = getUpcomingMarkers(
      limit: 5,
      typesFilter: {
        if (showHolidays) ...{
          MarkerType.governmentHoliday,
          MarkerType.companyHoliday,
        },
        if (showCompany) MarkerType.companyEvent,
      },
    );

    final today = dateOnly(DateTime.now());
    final horizon = DateTime(today.year, today.month, today.day + 30);
    final companyEvents = demoCompanyEvents()
        .where(
          (e) => !e.startsAt.isBefore(today) && e.startsAt.isBefore(horizon),
        )
        .toList();
    final celebrations =
        demoCelebrations()
            .where((c) => !c.date.isBefore(today) && c.date.isBefore(horizon))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    final bridges = upcomingBridges(limit: 3);

    final cardBackground = CupertinoColors.systemBackground.resolveFrom(
      context,
    );

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Events')),
      child: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<_EventsFilter>(
                  groupValue: _filter,
                  children: const {
                    _EventsFilter.all: Text('All'),
                    _EventsFilter.holidays: Text('Holidays'),
                    _EventsFilter.company: Text('Company'),
                  },
                  onValueChanged: (f) => setState(() => _filter = f ?? _filter),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. DAYS-UNTIL COUNTDOWN CARD
            if (upcoming.isNotEmpty)
              _buildCountdownCard(upcoming.first, cardBackground),

            // 4. COMPANY EVENTS — with RSVP
            if (showCompany)
              CupertinoListSection.insetGrouped(
                header: const Text('COMPANY EVENTS'),
                children: companyEvents.isEmpty
                    ? const [
                        CupertinoListTile(
                          title: Text('No company events coming up.'),
                        ),
                      ]
                    : [
                        for (final e in companyEvents)
                          _CompanyEventTile(event: e),
                      ],
              ),

            // 5. BIRTHDAYS & WORK ANNIVERSARIES
            if (showCompany)
              CupertinoListSection.insetGrouped(
                header: const Text('CELEBRATIONS'),
                children: celebrations.isEmpty
                    ? const [
                        CupertinoListTile(
                          title: Text('No celebrations this month.'),
                        ),
                      ]
                    : [
                        for (final c in celebrations)
                          _CelebrationTile(celebration: c),
                      ],
              ),

            // 6. LONG BREAKS — from the Leave Planner's bridge finder
            if (showHolidays && bridges.isNotEmpty)
              CupertinoListSection.insetGrouped(
                header: const Text('LONG BREAKS AHEAD'),
                children: [
                  for (final b in bridges)
                    BridgeSuggestionTile(
                      suggestion: b,
                      onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => const LeavePlannerScreen(),
                        ),
                      ),
                    ),
                ],
              ),

            // 7. CALENDAR
            CupertinoListSection.insetGrouped(
              header: const Text('CALENDAR'),
              children: [
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.calendar_today),
                  title: const Text('HR Calendar'),
                  trailing: const Icon(CupertinoIcons.chevron_right, size: 18),
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const HolidayCalendarScreen(),
                      ),
                    );
                  },
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.airplane),
                  title: const Text('Leave Planner'),
                  trailing: const Icon(CupertinoIcons.chevron_right, size: 18),
                  onTap: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => const LeavePlannerScreen(),
                    ),
                  ),
                ),
              ],
            ),

            // 8. UPCOMING HOLIDAYS / CALENDAR EVENTS
            CupertinoListSection.insetGrouped(
              header: Text(
                showHolidays ? 'UPCOMING HOLIDAYS' : 'ON THE HR CALENDAR',
              ),
              children: upcoming.isEmpty
                  ? [
                      const CupertinoListTile(
                        title: Text('Nothing scheduled right now.'),
                      ),
                    ]
                  : upcoming
                        .map((item) => _buildUpcomingTile(context, item))
                        .toList(),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // 6. COUNTDOWN CARD
  //
  // Shows "X days until <event>" for whichever upcoming marker is
  // soonest. Both dates are truncated to year/month/day before
  // subtracting, so partial days never cause an off-by-one.
  Widget _buildCountdownCard(UpcomingMarker next, Color cardBackground) {
    final today = NepaliDateTime.now();
    final todayOnly = NepaliDateTime(today.year, today.month, today.day);
    final daysUntil = next.date.difference(todayOnly).inDays;

    final countdownLabel = daysUntil == 0
        ? 'Today'
        : daysUntil == 1
        ? 'Tomorrow'
        : '$daysUntil days away';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.karmaRed,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(
              iconFor(next.marker.type),
              color: CupertinoColors.white,
              size: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    countdownLabel,
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    next.marker.title,
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 7. ONE ROW IN THE "UPCOMING" LIST
  Widget _buildUpcomingTile(BuildContext context, UpcomingMarker item) {
    final adDate = item.date.toDateTime();
    final dateLabel = '${adMonths[adDate.month - 1]} ${adDate.day}';

    return CupertinoListTile(
      leading: Icon(iconFor(item.marker.type)),
      title: Text(item.marker.title),
      subtitle: Text('$dateLabel · ${labelFor(item.marker.type)}'),
      trailing: const Icon(CupertinoIcons.chevron_right, size: 18),
      onTap: () => _showEventDetail(context, item),
    );
  }

  // 8. EVENT DETAIL SHEET, WITH "ADD TO CALENDAR"
  void _showEventDetail(BuildContext context, UpcomingMarker item) {
    final adDate = item.date.toDateTime();
    final bsLabel =
        '${NepaliDateFormat('MMMMM', Language.nepali).format(item.date)} '
        '${NepaliUnicode.convert('${item.date.day}')}, '
        '${NepaliDateFormat('y', Language.nepali).format(item.date)}';
    final adLabel =
        '${adMonths[adDate.month - 1]} ${adDate.day}, ${adDate.year}';

    showCupertinoModalPopup(
      context: context,
      // sheetContext, not context: the sheet's own context is gone once
      // it's popped, but "Remind Me" still needs to read Providers and
      // show a result dialog afterwards — that has to use the screen's.
      builder: (sheetContext) {
        return CupertinoActionSheet(
          title: Text(
            item.marker.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          message: Text(
            '$bsLabel  ($adLabel)\n\n'
            '${labelFor(item.marker.type)}\n\n'
            '${item.marker.description}',
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(sheetContext).pop();
                _remindMe(context, item);
              },
              child: const Text('Remind Me'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(sheetContext).pop();
                _addToPhoneCalendar(item);
              },
              child: const Text('Add to Calendar'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(sheetContext).pop(),
            child: const Text('Close'),
          ),
        );
      },
    );
  }

  // 8b. "REMIND ME" — A REAL SCHEDULED LOCAL NOTIFICATION
  //
  // Unlike "Add to Calendar" (which hands off to another app), this is
  // KarmaHR's own reminder: 9 AM the day before, or the morning of if
  // that's already passed. The OS holds it, so it fires with the app
  // closed.
  Future<void> _remindMe(BuildContext context, UpcomingMarker item) async {
    final push = context.read<PushNotificationState>();
    final notifications = context.read<NotificationState>();
    final adDate = item.date.toDateTime();

    String message;
    if (!push.enabled) {
      message = 'Turn on Push Notifications in Settings first, then try again.';
    } else {
      final at = await push.scheduleEventReminder(
        // Stable across app restarts (unlike String.hashCode), so
        // setting a reminder for the same event twice replaces it
        // instead of creating a duplicate.
        eventKey:
            item.date.year * 10000 + item.date.month * 100 + item.date.day,
        title: item.marker.title,
        eventDate: adDate,
      );
      if (at == null) {
        message = "It's too late to schedule a reminder for this one.";
      } else {
        message =
            "We'll remind you on ${adMonths[at.month - 1]} ${at.day} "
            'at 9:00 AM.';
        notifications.add(
          kind: AppNotificationKind.reminder,
          title: 'Reminder set: ${item.marker.title}',
          body: message,
        );
      }
    }

    if (!context.mounted) return;
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Remind Me'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // 9. "ADD TO CALENDAR" — HANDS OFF TO THE PHONE'S OWN CALENDAR APP
  //
  // add_2_calendar opens the device's native calendar (Google
  // Calendar / Apple Calendar) with this event pre-filled, so the
  // user just taps "Save" there — we never need calendar
  // permissions ourselves.
  void _addToPhoneCalendar(UpcomingMarker item) {
    final startDate = item.date.toDateTime();
    // Treat every holiday/event as a full-day entry — one day after
    // the start covers that as the required endDate.
    final endDate = startDate.add(const Duration(days: 1));

    final event = Event(
      title: item.marker.title,
      description: item.marker.description,
      startDate: startDate,
      endDate: endDate,
      allDay: true,
    );

    Add2Calendar.addEvent2Cal(event);
  }
}

// ============================================================
// COMPANY EVENT ROW + RSVP SHEET
// ============================================================
class _CompanyEventTile extends StatelessWidget {
  final CompanyEvent event;

  const _CompanyEventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final rsvps = context.watch<EventRsvpState>();
    final mine = rsvps.rsvpFor(event.id);
    final green = CupertinoColors.systemGreen.resolveFrom(context);

    return CupertinoListTile(
      leading: const Icon(CupertinoIcons.star_fill, color: AppColors.karmaRed),
      title: Text(event.title),
      subtitle: Text(
        '${dayDate(event.startsAt)}, ${clockTime(event.startsAt)} · '
        '${rsvps.goingCount(event)} going',
      ),
      additionalInfo: mine == null
          ? const TileInfo('RSVP')
          : TileInfo(
              rsvpLabel(mine),
              style: TextStyle(
                color: mine == Rsvp.going ? green : null,
                fontWeight: FontWeight.w600,
              ),
            ),
      trailing: const CupertinoListTileChevron(),
      onTap: () => _open(context),
    );
  }

  void _open(BuildContext context) {
    final rsvps = context.read<EventRsvpState>();
    final mine = rsvps.rsvpFor(event.id);

    CupertinoActionSheetAction option(Rsvp r, BuildContext sheetContext) {
      return CupertinoActionSheetAction(
        isDefaultAction: mine == r,
        onPressed: () {
          Navigator.pop(sheetContext);
          rsvps.setRsvp(event.id, r);
          if (r == Rsvp.going) {
            notifyUser(
              context,
              kind: AppNotificationKind.reminder,
              title: "You're going: ${event.title}",
              body:
                  '${dayDate(event.startsAt)} at ${clockTime(event.startsAt)} · ${event.venue}',
            );
          }
        },
        child: Text(mine == r ? '✓ ${rsvpLabel(r)}' : rsvpLabel(r)),
      );
    }

    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        message: Text(
          '${dayDate(event.startsAt)} at ${clockTime(event.startsAt)}\n'
          '${event.venue}\n\n${event.description}\n\n'
          '${rsvps.goingCount(event)} people going',
        ),
        actions: [
          for (final r in Rsvp.values) option(r, sheetContext),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(sheetContext);
              Add2Calendar.addEvent2Cal(
                Event(
                  title: event.title,
                  description: event.description,
                  location: event.venue,
                  startDate: event.startsAt,
                  endDate: event.startsAt.add(const Duration(hours: 2)),
                ),
              );
            },
            child: const Text('Add to Calendar'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(sheetContext),
          child: const Text('Close'),
        ),
      ),
    );
  }
}

// ============================================================
// BIRTHDAY / WORK ANNIVERSARY ROW
// ============================================================
class _CelebrationTile extends StatelessWidget {
  final Celebration celebration;

  const _CelebrationTile({required this.celebration});

  @override
  Widget build(BuildContext context) {
    final c = celebration;
    final isToday = c.date == dateOnly(DateTime.now());
    final what = c.kind == CelebrationKind.birthday
        ? '🎂 Birthday'
        : '🎉 ${c.years} year${c.years == 1 ? '' : 's'} at KarmaHR';

    return CupertinoListTile(
      leadingSize: 36,
      leading: InitialsAvatar(initials: c.initials, size: 36),
      title: Text(c.name),
      subtitle: Text(what),
      additionalInfo: TileInfo(
        isToday ? 'Today' : shortDate(c.date),
        style: TextStyle(
          color: isToday ? AppColors.karmaRed : null,
          fontWeight: isToday ? FontWeight.bold : null,
        ),
      ),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        onPressed: () => Navigator.push(
          context,
          CupertinoPageRoute(builder: (_) => const GiveKudosScreen()),
        ),
        child: const Text('Wish', style: TextStyle(fontSize: 14)),
      ),
    );
  }
}

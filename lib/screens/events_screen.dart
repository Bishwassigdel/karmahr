// 1. IMPORTS
import 'package:flutter/cupertino.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:nepali_utils/nepali_utils.dart';

import 'holiday_calendar_screen.dart';
import '../data/calendar_data.dart';
import '../theme/app_colors.dart';

// 2. EVENTS SCREEN
class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Pull the next 5 upcoming markers once — both the countdown
    // card and the list below read from this same list, so they
    // can never disagree with each other.
    final upcoming = getUpcomingMarkers(limit: 5);

    final cardBackground = CupertinoColors.systemBackground.resolveFrom(
      context,
    );

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Events')),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 20),

            // 3. DAYS-UNTIL COUNTDOWN CARD
            //
            // Only shown when there's at least one upcoming marker.
            if (upcoming.isNotEmpty)
              _buildCountdownCard(upcoming.first, cardBackground),

            const SizedBox(height: 20),

            // 4. CALENDAR SECTION (same link as before)
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
              ],
            ),

            const SizedBox(height: 20),

            // 5. UPCOMING EVENTS LIST
            CupertinoListSection.insetGrouped(
              header: const Text('UPCOMING'),
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
      builder: (context) {
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
                Navigator.of(context).pop();
                _addToPhoneCalendar(item);
              },
              child: const Text('Add to Calendar'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        );
      },
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

// Shared calendar data model + demo dataset, used by both
// HolidayCalendarScreen (the full monthly grid view) and
// EventsScreen (the upcoming-events summary + countdown).
//
// Keeping this in one place means both screens always show the
// exact same holidays/events — no risk of the two getting out of
// sync. When a real backend is added later, only THIS file needs
// to change (swap `demoMarkers` for an API call); neither screen's
// UI code needs to be touched.

import 'package:flutter/cupertino.dart';
import 'package:nepali_utils/nepali_utils.dart';

/// The five kinds of day a company/HR calendar needs to show.
enum MarkerType {
  governmentHoliday,
  companyHoliday,
  myLeave,
  present,
  companyEvent,
}

/// Human-readable label for a marker type, e.g. for chips/legends.
String labelFor(MarkerType type) {
  switch (type) {
    case MarkerType.governmentHoliday:
      return 'Government Holiday';
    case MarkerType.companyHoliday:
      return 'Company Holiday';
    case MarkerType.myLeave:
      return 'My Leave';
    case MarkerType.present:
      return 'Present';
    case MarkerType.companyEvent:
      return 'Company Event';
  }
}

/// Icon shown alongside a marker type.
IconData iconFor(MarkerType type) {
  switch (type) {
    case MarkerType.governmentHoliday:
      return CupertinoIcons.gift;
    case MarkerType.companyHoliday:
      return CupertinoIcons.building_2_fill;
    case MarkerType.myLeave:
      return CupertinoIcons.airplane;
    case MarkerType.present:
      return CupertinoIcons.checkmark_seal_fill;
    case MarkerType.companyEvent:
      return CupertinoIcons.star_fill;
  }
}

/// One marked day on the calendar (a holiday, event, leave day, etc).
class DayMarker {
  final MarkerType type;
  final String title;
  final String description;

  const DayMarker({
    required this.type,
    required this.title,
    required this.description,
  });
}

/// Builds the lookup key used by [demoMarkers], e.g. "2083-5-19".
String markerKey(int year, int month, int day) => '$year-$month-$day';

/// Demo/placeholder data only, keyed by "year-month-day" in the BS
/// calendar. Swap this map for a real API-backed repository later —
/// nothing else in the app needs to change, since both screens read
/// through the helpers here instead of touching this map directly.
const Map<String, DayMarker> demoMarkers = {
  // जेठ (Jestha)
  '2083-2-1': DayMarker(
    type: MarkerType.governmentHoliday,
    title: 'गणतन्त्र दिवस',
    description: 'Republic Day — public holiday across Nepal.',
  ),
  // साउन (Shrawan)
  '2083-4-5': DayMarker(
    type: MarkerType.companyHoliday,
    title: 'नाग पञ्चमी',
    description:
        'Bank-declared holiday for the traditional Naag Panchami festival.',
  ),
  // भदौ (Bhadra)
  '2083-5-1': DayMarker(
    type: MarkerType.present,
    title: 'Present',
    description: 'Checked in and completed a full working day.',
  ),
  '2083-5-2': DayMarker(
    type: MarkerType.present,
    title: 'Present',
    description: 'Checked in and completed a full working day.',
  ),
  '2083-5-3': DayMarker(
    type: MarkerType.present,
    title: 'Present',
    description: 'Checked in and completed a full working day.',
  ),
  '2083-5-4': DayMarker(
    type: MarkerType.present,
    title: 'Present',
    description: 'Checked in and completed a full working day.',
  ),
  '2083-5-8': DayMarker(
    type: MarkerType.myLeave,
    title: 'Sick Leave',
    description: 'Approved sick leave.',
  ),
  '2083-5-19': DayMarker(
    type: MarkerType.governmentHoliday,
    title: 'हरितालिका तीज',
    description: 'Public holiday observed across Nepal.',
  ),
  '2083-5-27': DayMarker(
    type: MarkerType.governmentHoliday,
    title: 'इन्द्र जात्रा',
    description: 'Traditional festival and public holiday.',
  ),
  // असोज (Ashwin)
  '2083-6-5': DayMarker(
    type: MarkerType.companyEvent,
    title: 'वार्षिक साधारण सभा (AGM)',
    description: "Company-wide annual general meeting at the head office.",
  ),
  '2083-6-19': DayMarker(
    type: MarkerType.governmentHoliday,
    title: 'विजया दशमी (दशैं)',
    description:
        "Nepal's biggest festival, marking the victory of good over evil.",
  ),
  // कार्तिक (Kartik)
  '2083-7-5': DayMarker(
    type: MarkerType.governmentHoliday,
    title: 'लक्ष्मी पूजा (तिहार)',
    description: "Nepal's festival of lights.",
  ),
  // पुष (Poush)
  '2083-9-17': DayMarker(
    type: MarkerType.governmentHoliday,
    title: 'नयाँ वर्ष (जनवरी १)',
    description: 'English New Year — public holiday.',
  ),
  // माघ (Magh)
  '2083-10-1': DayMarker(
    type: MarkerType.governmentHoliday,
    title: 'माघे संक्रान्ति',
    description: 'Traditional festival marking the start of Magh.',
  ),
  // फागुन (Falgun)
  '2083-11-14': DayMarker(
    type: MarkerType.governmentHoliday,
    title: 'होली (फागु पूर्णिमा)',
    description: 'Festival of colors — public holiday.',
  ),
};

/// AD month names, shared by every screen that shows an
/// AD-equivalent date label (e.g. "September 2026").
const adMonths = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// One marker resolved to an actual calendar date — used for the
/// "upcoming events" list and the "days until" countdown, where we
/// need real, sortable dates rather than just a lookup key.
class UpcomingMarker {
  final NepaliDateTime date;
  final DayMarker marker;

  const UpcomingMarker({required this.date, required this.marker});
}

/// Returns the next [limit] markers from today onward (inclusive),
/// sorted soonest-first. Pass [typesFilter] to only include certain
/// marker types (e.g. just holidays, skipping "Present" days).
List<UpcomingMarker> getUpcomingMarkers({
  int limit = 5,
  Set<MarkerType>? typesFilter,
}) {
  final today = NepaliDateTime.now();
  final todayOnly = NepaliDateTime(today.year, today.month, today.day);

  final results = <UpcomingMarker>[];

  demoMarkers.forEach((key, marker) {
    if (typesFilter != null && !typesFilter.contains(marker.type)) return;

    final parts = key.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    final date = NepaliDateTime(year, month, day);

    // Only include today or future dates — past events don't belong
    // in an "upcoming" list.
    if (!date.isBefore(todayOnly)) {
      results.add(UpcomingMarker(date: date, marker: marker));
    }
  });

  // Soonest date first.
  results.sort((a, b) => a.date.compareTo(b.date));

  return results.take(limit).toList();
}

/// The public or company holiday on an AD date, or null for a normal day.
/// Leave-day math (Leave Planner, the leave-balance estimate) only counts
/// real holidays as free — "Present" or "My Leave" markers don't make a
/// day free.
String? holidayNameOn(DateTime adDate) {
  final bs = adDate.toNepaliDateTime();
  final marker = demoMarkers[markerKey(bs.year, bs.month, bs.day)];
  if (marker == null) return null;
  final isHoliday =
      marker.type == MarkerType.governmentHoliday ||
      marker.type == MarkerType.companyHoliday;
  return isHoliday ? marker.title : null;
}

/// The next Vijaya Dashami (the main Dashain day) on the HR calendar, as
/// an AD date — or null if the calendar doesn't have one coming up.
DateTime? nextDashainDate() {
  final upcoming = getUpcomingMarkers(
    limit: 50,
    typesFilter: {MarkerType.governmentHoliday},
  );
  for (final m in upcoming) {
    if (m.marker.title.contains('दशैं')) return m.date.toDateTime();
  }
  return null;
}

// Leave planning math: "how many leave days will this trip actually
// cost me?" and "where can 1–2 leave days buy a long break?"
//
// Pure Dart. Holidays come in through a lookup function rather than being
// read from calendar_data directly, so this works with the demo calendar
// today and a real holiday API later — and tests can pass in any
// calendar they like.
//
// Nepal's weekly holiday is Saturday only (not a two-day weekend), which
// is exactly why bridges matter here: one well-placed leave day next to
// a festival can double a break.

/// Returns a holiday's name for a date, or null if it's a normal day.
typedef HolidayLookup = String? Function(DateTime day);

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

// Adding Duration(days: 1) can land on 23:00 or 01:00 across a DST change;
// constructing the calendar date directly never drifts.
DateTime _nextDay(DateTime d) => DateTime(d.year, d.month, d.day + 1);

class LeaveEstimate {
  final int calendarDays;
  final int weeklyOffDays;
  final List<(DateTime, String)> holidays;
  final int leaveDaysNeeded;

  const LeaveEstimate({
    required this.calendarDays,
    required this.weeklyOffDays,
    required this.holidays,
    required this.leaveDaysNeeded,
  });
}

/// Days of leave a [start]–[end] trip costs (inclusive), skipping the
/// weekly holiday and public holidays — those are free.
LeaveEstimate estimateLeave({
  required DateTime start,
  required DateTime end,
  required HolidayLookup holidayName,
  Set<int> weeklyOff = const {DateTime.saturday},
}) {
  var day = _dateOnly(start);
  final last = _dateOnly(end);
  if (last.isBefore(day)) {
    return const LeaveEstimate(
      calendarDays: 0,
      weeklyOffDays: 0,
      holidays: [],
      leaveDaysNeeded: 0,
    );
  }

  var calendarDays = 0;
  var weeklyOffDays = 0;
  var leaveDays = 0;
  final holidays = <(DateTime, String)>[];

  while (!day.isAfter(last)) {
    calendarDays++;
    final holiday = holidayName(day);
    if (weeklyOff.contains(day.weekday)) {
      // A festival on a Saturday doesn't save a day — Saturday was off
      // anyway — so it's counted as the weekly holiday, not twice.
      weeklyOffDays++;
    } else if (holiday != null) {
      holidays.add((day, holiday));
    } else {
      leaveDays++;
    }
    day = _nextDay(day);
  }

  return LeaveEstimate(
    calendarDays: calendarDays,
    weeklyOffDays: weeklyOffDays,
    holidays: holidays,
    leaveDaysNeeded: leaveDays,
  );
}

class BridgeSuggestion {
  /// The working days to request as leave.
  final DateTime leaveStart;
  final DateTime leaveEnd;

  /// The whole continuous break that leave produces.
  final DateTime breakStart;
  final DateTime breakEnd;

  final int leaveDays;
  final int totalDaysOff;

  /// Public holidays inside the break, for the "why" line in the UI.
  final List<String> holidayNames;

  const BridgeSuggestion({
    required this.leaveStart,
    required this.leaveEnd,
    required this.breakStart,
    required this.breakEnd,
    required this.leaveDays,
    required this.totalDaysOff,
    required this.holidayNames,
  });

  /// Days off gained per leave day spent — the ranking signal.
  double get efficiency => totalDaysOff / leaveDays;
}

/// Finds places where taking 1–[maxLeaveDays] working days joins two
/// blocks of days off into one break of at least [minBreakDays], within
/// [horizonDays] from [from]. Every suggestion includes at least one
/// public holiday — with a one-day weekend, two Saturdays are never
/// close enough to bridge on their own.
List<BridgeSuggestion> findBridges({
  required DateTime from,
  required HolidayLookup holidayName,
  int horizonDays = 150,
  int maxLeaveDays = 2,
  int minBreakDays = 3,
  Set<int> weeklyOff = const {DateTime.saturday},
}) {
  // 1. Classify every day in the window as off (weekly holiday or public
  // holiday) or working.
  final days = <DateTime>[];
  final off = <bool>[];
  final names = <String?>[];
  var day = _dateOnly(from);
  for (var i = 0; i < horizonDays; i++) {
    final holiday = holidayName(day);
    days.add(day);
    off.add(weeklyOff.contains(day.weekday) || holiday != null);
    names.add(weeklyOff.contains(day.weekday) ? null : holiday);
    day = _nextDay(day);
  }

  // 2. Group consecutive off days into blocks: [startIndex, endIndex].
  final blocks = <(int, int)>[];
  var i = 0;
  while (i < days.length) {
    if (!off[i]) {
      i++;
      continue;
    }
    final start = i;
    while (i + 1 < days.length && off[i + 1]) {
      i++;
    }
    blocks.add((start, i));
    i++;
  }

  // 3. A short run of working days between two off blocks is a bridge.
  final suggestions = <BridgeSuggestion>[];
  for (var b = 0; b + 1 < blocks.length; b++) {
    final (aStart, aEnd) = blocks[b];
    final (bStart, bEnd) = blocks[b + 1];
    final gap = bStart - aEnd - 1;
    if (gap < 1 || gap > maxLeaveDays) continue;

    final total = bEnd - aStart + 1;
    if (total < minBreakDays) continue;

    final holidayNames = [
      for (var k = aStart; k <= bEnd; k++)
        if (names[k] != null) names[k]!,
    ];
    if (holidayNames.isEmpty) continue;

    suggestions.add(
      BridgeSuggestion(
        leaveStart: days[aEnd + 1],
        leaveEnd: days[bStart - 1],
        breakStart: days[aStart],
        breakEnd: days[bEnd],
        leaveDays: gap,
        totalDaysOff: total,
        holidayNames: holidayNames,
      ),
    );
  }

  // Soonest first: people plan the next opportunity, and the UI shows
  // the efficiency on each row anyway.
  suggestions.sort((x, y) => x.leaveStart.compareTo(y.leaveStart));
  return suggestions;
}

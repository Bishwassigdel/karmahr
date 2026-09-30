// Nepal's fiscal / leave / payroll year: Shrawan 1 → Ashad-end (BS).
// That's BS month 4 of one year through BS month 3 of the next —
// NOT January–December. Every leave-balance and payroll screen that
// needs "this year's" numbers should filter through this, not raw
// calendar years, or the numbers will be wrong for every Nepali user.
//
// Pure Dart, no Flutter import — easy to unit test, safe to reuse
// from a payroll/tax layer later.

import 'package:nepali_utils/nepali_utils.dart';

/// One Nepali fiscal year, identified by its starting BS year.
/// e.g. `NepaliFiscalYear(2083)` is FY 2083/84 (Shrawan 2083 → Ashad 2084).
class NepaliFiscalYear {
  final int startYear;

  const NepaliFiscalYear(this.startYear);

  /// Which fiscal year a given BS date falls in.
  /// BS months 1–3 (Baisakh–Ashad) belong to the PREVIOUS fiscal year's
  /// startYear; months 4–12 (Shrawan–Chaitra) belong to the current one.
  factory NepaliFiscalYear.of(NepaliDateTime date) {
    return NepaliFiscalYear(date.month >= 4 ? date.year : date.year - 1);
  }

  /// The fiscal year "today" (device clock) falls in.
  factory NepaliFiscalYear.current() =>
      NepaliFiscalYear.of(NepaliDateTime.now());

  /// Shrawan 1 of [startYear] — always a valid BS date (day 1 of a month
  /// is never affected by variable month lengths).
  NepaliDateTime get start => NepaliDateTime(startYear, 4, 1);

  /// Ashad-end of [startYear + 1]. Ashad (BS month 3) has 31 or 32 days
  /// depending on the year, and that length isn't knowable by simple
  /// arithmetic — it comes from nepali_utils' calendar table. Rather than
  /// hardcoding a day count, step back one AD day from NEXT fiscal year's
  /// Shrawan 1 (itself always valid), then convert back to BS. This works
  /// for any year nepali_utils supports, without a lookup table of our own.
  NepaliDateTime get end {
    final nextFiscalYearStart = NepaliDateTime(startYear + 1, 4, 1);
    final oneDayBefore = nextFiscalYearStart.toDateTime().subtract(
      const Duration(days: 1),
    );
    return oneDayBefore.toNepaliDateTime();
  }

  /// Nepali fiscal quarter (1–4) a BS date falls in: Q1 is Shrawan–Ashwin,
  /// Q2 Kartik–Poush, Q3 Magh–Chaitra, Q4 Baisakh–Ashad. Goals and reviews
  /// follow the fiscal year here, not January–December.
  static int quarterOf(NepaliDateTime date) {
    final monthsSinceShrawan = (date.month - 4) % 12; // Dart % is non-negative
    return monthsSinceShrawan ~/ 3 + 1;
  }

  /// Human label for UI, e.g. "2083/84". Always two digits after the
  /// slash, including a rollover like "2099/00" — plain `% 100` would
  /// print "2099/0" there instead.
  String get label {
    final endYearSuffix = (startYear + 1) % 100;
    return '$startYear/${endYearSuffix.toString().padLeft(2, '0')}';
  }

  /// Whether [date] (BS) falls within this fiscal year, inclusive.
  /// Comparison is done via the underlying AD instant, since NepaliDateTime
  /// doesn't define isBefore/isAfter against arbitrary BS dates directly.
  bool contains(NepaliDateTime date) {
    final instant = date.toDateTime();
    return !instant.isBefore(start.toDateTime()) &&
        !instant.isAfter(end.toDateTime());
  }

  /// Convenience for AD dates (e.g. LeaveRequest.startDate), since most
  /// existing app state stores plain DateTime, not NepaliDateTime.
  bool containsAdDate(DateTime adDate) => contains(adDate.toNepaliDateTime());

  /// Number of calendar days between [start] and [end], inclusive.
  /// Useful as the denominator for "days elapsed so far this FY" style
  /// progress calculations.
  int get totalDays =>
      end.toDateTime().difference(start.toDateTime()).inDays + 1;

  /// Number of days from [start] up to and including [date], clamped to
  /// this fiscal year's range. Returns 0 if [date] is before [start].
  int daysElapsedAt(NepaliDateTime date) {
    final instant = date.toDateTime();
    if (instant.isBefore(start.toDateTime())) return 0;
    final clamped = instant.isAfter(end.toDateTime())
        ? end.toDateTime()
        : instant;
    return clamped.difference(start.toDateTime()).inDays + 1;
  }

  @override
  bool operator ==(Object other) =>
      other is NepaliFiscalYear && other.startYear == startYear;

  @override
  int get hashCode => startYear.hashCode;

  @override
  String toString() => 'FY $label';
}

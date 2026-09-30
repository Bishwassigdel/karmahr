// Overtime pay and limits.
//
// NOTE(hr-review): placeholder rules modeled on Labour Act 2074 —
// overtime paid at 1.5× the basic hourly rate, capped at 4 hours a day
// and 24 hours a week, with the hourly rate taken as monthly basic ÷ 30
// days ÷ 8 hours. Verify the multiplier, caps, and the hourly-rate basis
// against the Act and the company bylaw before paying anyone from this.

const overtimeMultiplier = 1.5;
const overtimeMaxHoursPerDay = 4.0;
const overtimeMaxHoursPerWeek = 24.0;

double hourlyBasicRate(double monthlyBasic) => monthlyBasic / 30 / 8;

double overtimePay({required double monthlyBasic, required double hours}) =>
    hourlyBasicRate(monthlyBasic) * overtimeMultiplier * hours;

/// Human-readable problems with a request, empty when it's within limits.
/// [hoursThisWeek] must already include the request being checked.
List<String> overtimeWarnings({
  required double hoursThatDay,
  required double hoursThisWeek,
}) {
  String fmt(double h) =>
      h == h.roundToDouble() ? h.toStringAsFixed(0) : h.toStringAsFixed(1);
  return [
    if (hoursThatDay > overtimeMaxHoursPerDay)
      '${fmt(hoursThatDay)} hours exceeds the daily overtime limit of '
          '${fmt(overtimeMaxHoursPerDay)} hours.',
    if (hoursThisWeek > overtimeMaxHoursPerWeek)
      'This brings the week to ${fmt(hoursThisWeek)} overtime hours, over '
          'the weekly limit of ${fmt(overtimeMaxHoursPerWeek)}.',
  ];
}

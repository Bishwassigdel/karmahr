// Dashain festival allowance (चाडपर्व खर्च) estimate.
//
// NOTE(hr-review): placeholder rule — customary/contractual practice is
// commonly one month's basic salary, pro-rated by completed months of
// service for anyone who hasn't completed a year by the festival. It is
// NOT a single fixed statutory figure; verify against the company bylaw
// before showing an employee a number they'll plan around.

class FestivalBonusEstimate {
  final double amount;
  final int monthsOfService;
  final bool prorated;

  const FestivalBonusEstimate({
    required this.amount,
    required this.monthsOfService,
    required this.prorated,
  });
}

/// Whole months from [from] to [to] — a month only counts once its
/// day-of-month has been reached, so Jan 31 → Feb 28 is 0, not 1.
int completedMonthsBetween(DateTime from, DateTime to) {
  var months = (to.year - from.year) * 12 + (to.month - from.month);
  if (to.day < from.day) months--;
  return months < 0 ? 0 : months;
}

FestivalBonusEstimate estimateDashainBonus({
  required double basicSalary,
  required DateTime joiningDate,
  required DateTime festivalDate,
}) {
  final months = completedMonthsBetween(joiningDate, festivalDate);
  if (months >= 12) {
    return FestivalBonusEstimate(
      amount: basicSalary,
      monthsOfService: months,
      prorated: false,
    );
  }
  return FestivalBonusEstimate(
    amount: basicSalary * months / 12,
    monthsOfService: months,
    prorated: true,
  );
}

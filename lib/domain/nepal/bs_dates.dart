// AD -> BS conversion that doesn't depend on the phone's timezone.
//
// nepali_utils' DateTime.toNepaliDateTime() (and NepaliDateTime.now(), which
// uses it) counts days between two LOCAL times, so daylight saving and old
// timezone offsets make it land a day off outside Nepal (US, New Zealand).
// Its BS -> AD direction (NepaliDateTime.toDateTime()) is plain counting and
// timezone-safe. So: take the library's answer as a guess, check it with
// the safe direction, and step it by however many days it's off.

import 'package:nepali_utils/nepali_utils.dart';

/// The BS date of [ad]'s calendar day, in any device timezone.
NepaliDateTime bsFromAd(DateTime ad) {
  final target = DateTime.utc(ad.year, ad.month, ad.day);
  final g = ad.toNepaliDateTime();
  var bs = NepaliDateTime(g.year, g.month, g.day);

  final back = bs.toDateTime();
  final off = target
      .difference(DateTime.utc(back.year, back.month, back.day))
      .inDays;
  return bsAddDays(bs, off);
}

/// Today's BS date (the device's local calendar day).
NepaliDateTime bsToday([DateTime? now]) => bsFromAd(now ?? DateTime.now());

/// [d] moved by [days] calendar days, using BS month lengths only.
/// Use this instead of NepaliDateTime.add(), which has the same timezone
/// problem as toNepaliDateTime().
NepaliDateTime bsAddDays(NepaliDateTime d, int days) {
  var y = d.year, m = d.month, day = d.day;
  for (; days > 0; days--) {
    if (day < NepaliDateTime(y, m).totalDays) {
      day++;
    } else {
      day = 1;
      if (++m > 12) (m, y) = (1, y + 1);
    }
  }
  for (; days < 0; days++) {
    if (day > 1) {
      day--;
    } else {
      if (--m < 1) (m, y) = (12, y - 1);
      day = NepaliDateTime(y, m).totalDays;
    }
  }
  return NepaliDateTime(y, m, day);
}

/// "Ashwin 19, 2083" (or the same in Devanagari when [nepali] is true).
String bsLabel(NepaliDateTime d, {bool nepali = false}) {
  return NepaliDateFormat(
    'MMMM d, y',
    nepali ? Language.nepali : Language.english,
  ).format(d);
}

/// "Ashwin 2083" (or in Devanagari when [nepali] is true).
String bsMonthLabel(int year, int month, {bool nepali = false}) {
  return NepaliDateFormat(
    'MMMM y',
    nepali ? Language.nepali : Language.english,
  ).format(NepaliDateTime(year, month, 1));
}

/// A BS year and month, e.g. Ashwin 2083 = (2083, 6).
typedef BsMonth = ({int year, int month});

/// Every BS month of [today]'s fiscal year (Shrawan to Ashad), from the
/// start of the year up to and including [today]'s month. Oldest first.
List<BsMonth> fiscalMonthsUpTo(NepaliDateTime today) {
  final startYear = today.month >= 4 ? today.year : today.year - 1;
  final months = <BsMonth>[];
  var year = startYear;
  var month = 4;
  while (year < today.year || (year == today.year && month <= today.month)) {
    months.add((year: year, month: month));
    if (++month > 12) {
      month = 1;
      year++;
    }
  }
  return months;
}

/// The last calendar day of a BS month, as an AD date.
DateTime bsMonthEndAd(int year, int month) {
  final first = NepaliDateTime(year, month, 1);
  final last = bsAddDays(first, first.totalDays - 1);
  return last.toDateTime();
}

import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_utils/nepali_utils.dart';

import 'package:my_first_flutter_app/domain/nepal/bs_dates.dart';

// These must pass in ANY device timezone. CI runs them in Nepal time; run
// `TZ=America/New_York flutter test test/domain` to check the far side.
// NepaliDateTime has no value equality, so compare the parts.
List<int> ymd(NepaliDateTime d) => [d.year, d.month, d.day];

void main() {
  test('a calendar day converts to the same BS day at any hour', () {
    for (final hour in [0, 6, 12, 23]) {
      final bs = bsFromAd(DateTime(2027, 7, 17, hour));
      expect([bs.year, bs.month, bs.day], [2084, 4, 1], reason: 'hour $hour');
    }
  });

  test('the result has no time of day', () {
    final bs = bsFromAd(DateTime(2027, 7, 17, 15, 30));
    expect([bs.hour, bs.minute], [0, 0]);
  });

  test('round-trips with NepaliDateTime.toDateTime()', () {
    final bs = NepaliDateTime(2083, 6, 15);
    final back = bsFromAd(bs.toDateTime());
    expect([back.year, back.month, back.day], [2083, 6, 15]);
  });

  test('bsToday uses the given local day', () {
    final bs = bsToday(DateTime(2027, 7, 17, 23, 59));
    expect([bs.year, bs.month, bs.day], [2084, 4, 1]);
  });

  test('bsAddDays crosses month and year ends both ways', () {
    final lastOfAshad = bsAddDays(NepaliDateTime(2084, 4, 1), -1);
    expect(lastOfAshad.month, 3);
    expect(ymd(bsAddDays(lastOfAshad, 1)), [2084, 4, 1]);

    final newYear = bsAddDays(NepaliDateTime(2083, 12, 1), 40);
    expect(newYear.year, 2084);
    expect(ymd(bsAddDays(newYear, -40)), [2083, 12, 1]);
  });
}

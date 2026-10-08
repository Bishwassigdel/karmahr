import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_utils/nepali_utils.dart';

import 'package:my_first_flutter_app/domain/nepal/bs_dates.dart';
import 'package:my_first_flutter_app/domain/nepal/fiscal_year.dart';

void main() {
  group('NepaliFiscalYear.of', () {
    test('a date in Shrawan (month 4) belongs to that same startYear', () {
      final fy = NepaliFiscalYear.of(NepaliDateTime(2083, 4, 1));
      expect(fy.startYear, 2083);
    });

    test('a date in Chaitra (month 12) belongs to that same startYear', () {
      final fy = NepaliFiscalYear.of(NepaliDateTime(2083, 12, 15));
      expect(fy.startYear, 2083);
    });

    test('a date in Baisakh (month 1) belongs to the PREVIOUS startYear', () {
      final fy = NepaliFiscalYear.of(NepaliDateTime(2084, 1, 1));
      expect(fy.startYear, 2083);
    });

    test(
      'a date in Ashad (month 3) still belongs to the previous startYear',
      () {
        final fy = NepaliFiscalYear.of(NepaliDateTime(2084, 3, 1));
        expect(fy.startYear, 2083);
      },
    );
  });

  group('NepaliFiscalYear boundaries', () {
    test('start is always Shrawan 1', () {
      const fy = NepaliFiscalYear(2083);
      expect(fy.start.year, 2083);
      expect(fy.start.month, 4);
      expect(fy.start.day, 1);
    });

    test('end falls in Ashad of the following year', () {
      const fy = NepaliFiscalYear(2083);
      expect(fy.end.year, 2084);
      expect(fy.end.month, 3);
    });

    test('end is exactly one AD day before the next fiscal year starts', () {
      const fy = NepaliFiscalYear(2083);
      final nextStart = const NepaliFiscalYear(2084).start.toDateTime();
      final gap = nextStart.difference(fy.end.toDateTime()).inDays;
      expect(gap, 1);
    });

    test('label formats as "start/end-2-digit"', () {
      expect(const NepaliFiscalYear(2083).label, '2083/84');
    });

    test('label pads the century rollover instead of dropping a digit', () {
      // startYear 2099 rolls into 2100 → last two digits are "00", not "0".
      expect(const NepaliFiscalYear(2099).label, '2099/00');
    });
  });

  group('NepaliFiscalYear.contains', () {
    const fy = NepaliFiscalYear(2083);

    test('the first day of the fiscal year is included', () {
      expect(fy.contains(fy.start), isTrue);
    });

    test('the last day of the fiscal year is included', () {
      expect(fy.contains(fy.end), isTrue);
    });

    test('a day just before the fiscal year starts is excluded', () {
      final dayBefore = fy.start.subtract(const Duration(days: 1));
      expect(fy.contains(dayBefore), isFalse);
    });

    test('a day just after the fiscal year ends is excluded', () {
      final dayAfter = bsAddDays(fy.end, 1);
      expect(fy.contains(dayAfter), isFalse);
    });

    test('a clearly mid-year date is included', () {
      expect(fy.contains(NepaliDateTime(2083, 8, 10)), isTrue);
    });
  });

  group('NepaliFiscalYear.containsAdDate', () {
    test('converts an AD DateTime before comparing', () {
      const fy = NepaliFiscalYear(2083);
      final adDate = fy.start.toDateTime().add(const Duration(days: 5));
      expect(fy.containsAdDate(adDate), isTrue);
    });
  });

  group('NepaliFiscalYear.daysElapsedAt', () {
    const fy = NepaliFiscalYear(2083);

    test('is 1 on the very first day', () {
      expect(fy.daysElapsedAt(fy.start), 1);
    });

    test('equals totalDays on the last day', () {
      expect(fy.daysElapsedAt(fy.end), fy.totalDays);
    });

    test('is 0 for a date before the fiscal year starts', () {
      final before = fy.start.subtract(const Duration(days: 10));
      expect(fy.daysElapsedAt(before), 0);
    });

    test('clamps to totalDays for a date after the fiscal year ends', () {
      final after = fy.end.add(const Duration(days: 30));
      expect(fy.daysElapsedAt(after), fy.totalDays);
    });
  });

  group('equality', () {
    test('two instances with the same startYear are equal', () {
      expect(const NepaliFiscalYear(2083), const NepaliFiscalYear(2083));
    });

    test('different startYears are not equal', () {
      expect(const NepaliFiscalYear(2083), isNot(const NepaliFiscalYear(2084)));
    });
  });
}

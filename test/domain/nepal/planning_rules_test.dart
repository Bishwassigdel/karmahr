import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_utils/nepali_utils.dart';

import 'package:my_first_flutter_app/domain/nepal/festival_bonus.dart';
import 'package:my_first_flutter_app/domain/nepal/fiscal_year.dart';
import 'package:my_first_flutter_app/domain/nepal/leave_planner.dart';
import 'package:my_first_flutter_app/domain/nepal/overtime.dart';
import 'package:my_first_flutter_app/domain/nepal/payroll_calculator.dart';
import 'package:my_first_flutter_app/domain/nepal/tax_slabs.dart';

// A fixed test calendar. Oct 3 and Oct 10 2026 are Saturdays.
HolidayLookup _calendar(Map<DateTime, String> holidays) =>
    (day) => holidays[DateTime(day.year, day.month, day.day)];

void main() {
  group('estimateLeave', () {
    test('skips Saturday and public holidays', () {
      // Mon Sep 21 – Sun Sep 27 2026; Sat 26 off, Wed 23 a holiday.
      final e = estimateLeave(
        start: DateTime(2026, 9, 21),
        end: DateTime(2026, 9, 27),
        holidayName: _calendar({DateTime(2026, 9, 23): 'Festival'}),
      );
      expect(e.calendarDays, 7);
      expect(e.weeklyOffDays, 1);
      expect(e.holidays.length, 1);
      expect(e.leaveDaysNeeded, 5);
    });

    test('a holiday on a Saturday saves nothing extra', () {
      final e = estimateLeave(
        start: DateTime(2026, 9, 21),
        end: DateTime(2026, 9, 27),
        holidayName: _calendar({DateTime(2026, 9, 26): 'Festival'}),
      );
      expect(e.holidays, isEmpty);
      expect(e.leaveDaysNeeded, 6);
    });

    test('an end before the start costs nothing', () {
      final e = estimateLeave(
        start: DateTime(2026, 9, 27),
        end: DateTime(2026, 9, 21),
        holidayName: _calendar({}),
      );
      expect(e.leaveDaysNeeded, 0);
    });
  });

  group('findBridges', () {
    test('Thursday holiday + Friday leave → Thu–Sat break', () {
      final bridges = findBridges(
        from: DateTime(2026, 9, 28),
        horizonDays: 10,
        holidayName: _calendar({DateTime(2026, 10, 1): 'Festival'}),
      );
      expect(bridges.length, 1);
      final b = bridges.single;
      expect(b.leaveStart, DateTime(2026, 10, 2));
      expect(b.leaveDays, 1);
      expect(b.breakStart, DateTime(2026, 10, 1));
      expect(b.breakEnd, DateTime(2026, 10, 3));
      expect(b.totalDaysOff, 3);
      expect(b.holidayNames, ['Festival']);
    });

    test('Wednesday holiday + two leave days → four-day break', () {
      final b = findBridges(
        from: DateTime(2026, 10, 4),
        horizonDays: 10,
        holidayName: _calendar({DateTime(2026, 10, 7): 'Festival'}),
      ).single;
      expect(b.leaveStart, DateTime(2026, 10, 8));
      expect(b.leaveEnd, DateTime(2026, 10, 9));
      expect(b.totalDaysOff, 4);
      expect(b.efficiency, 2);
    });

    test('Saturdays alone never produce a bridge', () {
      expect(
        findBridges(from: DateTime(2026, 9, 1), holidayName: _calendar({})),
        isEmpty,
      );
    });
  });

  group('Dashain bonus', () {
    test('a full year of service earns a full month of basic', () {
      final e = estimateDashainBonus(
        basicSalary: 45000,
        joiningDate: DateTime(2024, 1, 12),
        festivalDate: DateTime(2026, 10, 20),
      );
      expect(e.amount, 45000);
      expect(e.prorated, isFalse);
    });

    test('under a year is pro-rated by completed months', () {
      final e = estimateDashainBonus(
        basicSalary: 45000,
        joiningDate: DateTime(2026, 4, 20),
        festivalDate: DateTime(2026, 10, 25),
      );
      expect(e.monthsOfService, 6);
      expect(e.amount, 22500);
      expect(e.prorated, isTrue);
    });

    test('a month only counts once its day is reached', () {
      expect(completedMonthsBetween(DateTime(2026, 1, 31), DateTime(2026, 2, 28)), 0);
      expect(completedMonthsBetween(DateTime(2026, 1, 15), DateTime(2026, 2, 15)), 1);
    });
  });

  group('overtime', () {
    test('pays 1.5x the basic hourly rate', () {
      expect(hourlyBasicRate(45000), 187.5);
      expect(overtimePay(monthlyBasic: 45000, hours: 2), 562.5);
    });

    test('warns past the daily and weekly limits only', () {
      expect(overtimeWarnings(hoursThatDay: 3, hoursThisWeek: 20), isEmpty);
      expect(overtimeWarnings(hoursThatDay: 5, hoursThisWeek: 20).length, 1);
      expect(overtimeWarnings(hoursThatDay: 4, hoursThisWeek: 26).length, 1);
    });
  });

  group('fiscal quarter', () {
    test('follows Shrawan–Ashad, not January–December', () {
      int q(int month) => NepaliFiscalYear.quarterOf(NepaliDateTime(2083, month, 1));
      expect(q(4), 1); // Shrawan
      expect(q(6), 1); // Ashwin
      expect(q(7), 2); // Kartik
      expect(q(10), 3); // Magh
      expect(q(1), 4); // Baisakh
      expect(q(3), 4); // Ashad
    });
  });

  group('tax deduction caps', () {
    PayrollResult pay({double cit = 0, double insurance = 0}) => computePayroll(
      PayrollInput(
        basicSalary: 100000,
        allowances: 0,
        filingStatus: FilingStatus.single,
        fiscalStartYear: 2082,
        citContribution: cit,
        insurancePremium: insurance,
      ),
    );

    test('CIT beyond the retirement cap saves no further tax', () {
      final atCap = pay(cit: 50000);
      final beyond = pay(cit: 60000);
      expect(atCap.retirementCapReached, isTrue);
      // One third of 1.2M = 400,000 — lower than the Rs 500,000 cap.
      expect(atCap.taxableAnnualIncome, 800000);
      expect(beyond.monthlyTax, atCap.monthlyTax);
      // ...but the extra CIT still leaves the paycheck.
      expect(beyond.netMonthly, lessThan(atCap.netMonthly));
    });

    test('insurance premium is deductible only up to the cap', () {
      final r = pay(insurance: 5000); // 60,000 a year vs a 40,000 cap
      expect(r.insuranceCapReached, isTrue);
      expect(pay(insurance: 3000).insuranceCapReached, isFalse);
    });
  });
}

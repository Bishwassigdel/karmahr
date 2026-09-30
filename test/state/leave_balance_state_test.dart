import 'package:flutter_test/flutter_test.dart';
import 'package:nepali_utils/nepali_utils.dart';

import 'package:my_first_flutter_app/domain/nepal/fiscal_year.dart';
import 'package:my_first_flutter_app/state/leave_balance_state.dart';
import 'package:my_first_flutter_app/state/leave_state.dart';

LeaveRequest _request({
  required String leaveType,
  required String durationType,
  required DateTime startDate,
  DateTime? endDate,
  int? leaveHours,
  LeaveRequestStatus status = LeaveRequestStatus.approved,
}) {
  return LeaveRequest(
    leaveType: leaveType,
    durationType: durationType,
    startDate: startDate,
    endDate: endDate ?? startDate,
    leaveHours: leaveHours,
    leaveStartTime: null,
    reason: 'test',
    status: status,
  );
}

void main() {
  final state = LeaveBalanceState();

  group('daysFor', () {
    test('a full-day request spanning 3 calendar days counts as 3 days', () {
      final r = _request(
        leaveType: 'Home Leave',
        durationType: 'Full Day',
        startDate: DateTime(2026, 8, 1),
        endDate: DateTime(2026, 8, 3),
      );
      expect(state.daysFor(r), 3);
    });

    test('a single-day full-day request counts as 1 day', () {
      final r = _request(
        leaveType: 'Home Leave',
        durationType: 'Full Day',
        startDate: DateTime(2026, 8, 1),
      );
      expect(state.daysFor(r), 1);
    });

    test('a half-day request (either half) counts as 0.5 days', () {
      final first = _request(
        leaveType: 'Home Leave',
        durationType: 'First Half Day',
        startDate: DateTime(2026, 8, 1),
      );
      final second = _request(
        leaveType: 'Home Leave',
        durationType: 'Second Half Day',
        startDate: DateTime(2026, 8, 1),
      );
      expect(state.daysFor(first), 0.5);
      expect(state.daysFor(second), 0.5);
    });

    test('hours leave converts using an 8-hour working day', () {
      final r = _request(
        leaveType: 'Unpaid Leave',
        durationType: 'Hours Leave',
        startDate: DateTime(2026, 8, 1),
        leaveHours: 4,
      );
      expect(state.daysFor(r), 0.5);
    });
  });

  group('estimatedWorkingDays', () {
    test('a single Saturday counts as zero working days', () {
      // 2083-05-01 BS is a Monday, so 2083-05-06 is the following Saturday.
      final saturday = NepaliDateTime(2083, 5, 6);
      expect(saturday.weekday, 7);
      expect(state.estimatedWorkingDays(saturday, saturday), 0);
    });

    test('a known government holiday from demoMarkers is excluded', () {
      // 2083-02-01 BS (गणतन्त्र दिवस) is seeded as a government holiday
      // and is not a Saturday.
      final holiday = NepaliDateTime(2083, 2, 1);
      expect(holiday.weekday, isNot(7));
      expect(state.estimatedWorkingDays(holiday, holiday), 0);
    });

    test('a plain non-holiday weekday counts as one working day', () {
      // 2083-05-01 BS is seeded as MarkerType.present (an ordinary
      // working day) in the demo calendar, and is not a Saturday.
      final weekday = NepaliDateTime(2083, 5, 1);
      expect(weekday.weekday, isNot(7));
      expect(state.estimatedWorkingDays(weekday, weekday), 1);
    });

    test('a reversed range (through before from) yields zero', () {
      final from = NepaliDateTime(2083, 5, 10);
      final through = NepaliDateTime(2083, 5, 1);
      expect(state.estimatedWorkingDays(from, through), 0);
    });
  });

  group('balancesFor', () {
    test('an approved request outside the fiscal year is not counted', () {
      final fy = const NepaliFiscalYear(2083);
      final requests = [
        _request(
          leaveType: 'Sick Leave',
          durationType: 'Full Day',
          // Well before FY 2083/84 (Shrawan 2083) starts.
          startDate: DateTime(2025, 1, 1),
        ),
      ];

      final sick = state.balanceFor('Sick Leave', requests, fiscalYear: fy);
      expect(sick, isNotNull);
      expect(sick!.used, 0);
      expect(sick.entitled, 12); // full flat grant, untouched
    });

    test('an approved request inside the fiscal year reduces remaining', () {
      final fy = const NepaliFiscalYear(2083);
      final requests = [
        _request(
          leaveType: 'Sick Leave',
          durationType: 'Full Day',
          startDate: fy.start.toDateTime().add(const Duration(days: 5)),
        ),
      ];

      final sick = state.balanceFor('Sick Leave', requests, fiscalYear: fy);
      expect(sick!.used, 1);
      expect(sick.remaining, sick.entitled - 1);
    });

    test('a pending request reduces remaining but not used', () {
      final fy = const NepaliFiscalYear(2083);
      final requests = [
        _request(
          leaveType: 'Sick Leave',
          durationType: 'Full Day',
          startDate: fy.start.toDateTime().add(const Duration(days: 5)),
          status: LeaveRequestStatus.pending,
        ),
      ];

      final sick = state.balanceFor('Sick Leave', requests, fiscalYear: fy);
      expect(sick!.used, 0);
      expect(sick.pending, 1);
      expect(sick.remaining, sick.entitled - 1);
    });

    test('a rejected request does not affect used, pending, or remaining', () {
      final fy = const NepaliFiscalYear(2083);
      final requests = [
        _request(
          leaveType: 'Sick Leave',
          durationType: 'Full Day',
          startDate: fy.start.toDateTime().add(const Duration(days: 5)),
          status: LeaveRequestStatus.rejected,
        ),
      ];

      final sick = state.balanceFor('Sick Leave', requests, fiscalYear: fy);
      expect(sick!.used, 0);
      expect(sick.pending, 0);
      expect(sick.remaining, sick.entitled);
    });

    test('remaining never goes negative even if over-requested', () {
      final fy = const NepaliFiscalYear(2083);
      final requests = List.generate(
        20,
        (i) => _request(
          leaveType: 'Sick Leave',
          durationType: 'Full Day',
          startDate: fy.start.toDateTime().add(Duration(days: i)),
        ),
      );

      final sick = state.balanceFor('Sick Leave', requests, fiscalYear: fy);
      expect(sick!.used, 20); // more than the 12-day grant
      expect(sick.remaining, 0); // clamped, not negative
    });

    test('an unrecognized leave type returns null', () {
      final fy = const NepaliFiscalYear(2083);
      expect(state.balanceFor('Sabbatical', [], fiscalYear: fy), isNull);
    });

    test('balancesFor returns one entry per known policy', () {
      final fy = const NepaliFiscalYear(2083);
      final all = state.balancesFor([], fiscalYear: fy);
      expect(all.length, 7);
    });
  });
}

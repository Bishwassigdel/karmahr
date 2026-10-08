// Computes REAL leave balances from the Nepali fiscal year + leave
// policy table + whatever's actually been submitted in LeaveState —
// instead of the hardcoded numbers leave_balances_screen.dart used to
// carry directly.
//
// Frontend-only for now: there's no real attendance history to accrue
// against, so "days worked so far this fiscal year" is ESTIMATED from
// the calendar (weekdays minus Saturdays minus known holidays) rather
// than counted from real check-ins. That estimator is the one function
// a future backend should replace — everything downstream of it
// (accrual, caps, remaining-days math) stays the same.

import 'package:flutter/foundation.dart';
import 'package:nepali_utils/nepali_utils.dart';

import '../domain/nepal/bs_dates.dart';

import '../data/calendar_data.dart';
import '../domain/nepal/fiscal_year.dart';
import '../domain/nepal/leave_policy.dart';
import 'leave_state.dart';

/// One leave type's computed standing for a fiscal year.
class LeaveBalance {
  final String type;

  /// Total days earned/granted so far this fiscal year (for accrual
  /// types, this grows as [daysWorkedSoFar] grows; for flat-grant types
  /// it's the full annual amount from day one).
  final double entitled;

  /// Approved requests of this type within the fiscal year.
  final double used;

  /// Requests of this type still awaiting approval.
  final double pending;

  final double carryForwardCap;
  final bool paid;

  const LeaveBalance({
    required this.type,
    required this.entitled,
    required this.used,
    required this.pending,
    required this.carryForwardCap,
    required this.paid,
  });

  /// What's left to request, after approved AND pending requests are
  /// both accounted for (so the employee can't over-request while a
  /// prior request is still pending approval).
  double get remaining {
    final left = entitled - used - pending;
    return left < 0 ? 0 : left;
  }

  /// Approved-but-unused days beyond the carry-forward cap — these lapse
  /// at Ashad-end unless used before then. 0 for types with no cap risk.
  double get atRiskOfLapsing {
    final unused = entitled - used;
    if (unused <= carryForwardCap) return 0;
    return unused - carryForwardCap;
  }
}

class LeaveBalanceState extends ChangeNotifier {
  /// Counts a Saturday (Nepal's weekly holiday) or a government/company
  /// holiday from the shared calendar data as a non-working day. Everything
  /// else between [from] and [through] (inclusive) counts as worked.
  ///
  /// This is a stand-in for real attendance history — it assumes the
  /// employee worked every non-holiday weekday, which is obviously not
  /// always true. Replace with a real attendance-based count once a
  /// backend exists.
  @visibleForTesting
  int estimatedWorkingDays(NepaliDateTime from, NepaliDateTime through) {
    if (through.toDateTime().isBefore(from.toDateTime())) return 0;

    var count = 0;
    var day = from;
    while (!day.toDateTime().isAfter(through.toDateTime())) {
      const saturday = 7; // NepaliDateTime.weekday: 1=Sunday ... 7=Saturday
      final marker = demoMarkers[markerKey(day.year, day.month, day.day)];
      final isHoliday =
          marker?.type == MarkerType.governmentHoliday ||
          marker?.type == MarkerType.companyHoliday;
      if (day.weekday != saturday && !isHoliday) {
        count++;
      }
      day = bsAddDays(day, 1);
    }
    return count;
  }

  /// Days of leave a single request represents, for balance math.
  /// Half-day types count 0.5; hourly leave is converted assuming an
  /// 8-hour working day; everything else counts whole calendar days
  /// between start and end, inclusive.
  @visibleForTesting
  double daysFor(LeaveRequest request) {
    switch (request.durationType) {
      case 'First Half Day':
      case 'Second Half Day':
        return 0.5;
      case 'Hours Leave':
        final hours = request.leaveHours ?? 0;
        return hours / 8;
      default:
        final span = request.endDate.difference(request.startDate).inDays + 1;
        return span < 1 ? 1 : span.toDouble();
    }
  }

  /// Computes a [LeaveBalance] for every known leave type, using
  /// [requests] (normally `LeaveState.requests`) filtered to [fiscalYear]
  /// (defaults to the current one).
  List<LeaveBalance> balancesFor(
    List<LeaveRequest> requests, {
    NepaliFiscalYear? fiscalYear,
  }) {
    final fy = fiscalYear ?? NepaliFiscalYear.current();
    final today = bsToday();
    final asOf = fy.contains(today) ? today : fy.end;
    final workedSoFar = estimatedWorkingDays(fy.start, asOf);

    final requestsInFy = requests.where((r) => fy.containsAdDate(r.startDate));

    return leavePolicies.values.map((policy) {
      final entitled = policy.isAccrualBased
          ? workedSoFar / policy.accrualPerWorkedDays!
          : policy.annualGrant!;

      final ofType = requestsInFy.where((r) => r.leaveType == policy.type);
      final used = ofType
          .where((r) => r.status == LeaveRequestStatus.approved)
          .fold(0.0, (sum, r) => sum + daysFor(r));
      final pending = ofType
          .where((r) => r.status == LeaveRequestStatus.pending)
          .fold(0.0, (sum, r) => sum + daysFor(r));

      return LeaveBalance(
        type: policy.type,
        entitled: entitled,
        used: used,
        pending: pending,
        carryForwardCap: policy.carryForwardCap,
        paid: policy.paid,
      );
    }).toList();
  }

  /// Convenience for a single leave type, or null if it's not a type
  /// tracked in [leavePolicies].
  LeaveBalance? balanceFor(
    String leaveType,
    List<LeaveRequest> requests, {
    NepaliFiscalYear? fiscalYear,
  }) {
    final all = balancesFor(requests, fiscalYear: fiscalYear);
    for (final b in all) {
      if (b.type == leaveType) return b;
    }
    return null;
  }
}

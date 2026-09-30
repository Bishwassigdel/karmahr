// Overtime requests, plus the weekly running total the limit check needs.

import 'package:flutter/foundation.dart';

import '../data/current_employee.dart';
import '../domain/nepal/overtime.dart';

enum OvertimeStatus { pending, approved, rejected }

class OvertimeRequest {
  final DateTime date;
  final double hours;
  final String reason;
  final OvertimeStatus status;

  const OvertimeRequest({
    required this.date,
    required this.hours,
    required this.reason,
    required this.status,
  });

  double get estimatedPay =>
      overtimePay(monthlyBasic: currentEmployee.basicSalary, hours: hours);
}

/// Sunday that starts the Nepali work week (Sun–Fri, Saturday off)
/// containing [day].
DateTime workWeekStart(DateTime day) {
  final d = DateTime(day.year, day.month, day.day);
  final daysSinceSunday = d.weekday % 7; // Sunday = 7 → 0
  return DateTime(d.year, d.month, d.day - daysSinceSunday);
}

class OvertimeState extends ChangeNotifier {
  final List<OvertimeRequest> _requests = _seed();

  static List<OvertimeRequest> _seed() {
    final now = DateTime.now();
    return [
      OvertimeRequest(
        date: DateTime(now.year, now.month, now.day - 8),
        hours: 3,
        reason: 'Payroll close — month-end reconciliation.',
        status: OvertimeStatus.approved,
      ),
    ];
  }

  List<OvertimeRequest> get requests => List.unmodifiable(_requests);

  /// Non-rejected overtime already requested in [day]'s work week — what
  /// the weekly limit is checked against.
  double hoursInWeekOf(DateTime day) {
    final start = workWeekStart(day);
    final end = DateTime(start.year, start.month, start.day + 7);
    return _requests
        .where(
          (r) =>
              r.status != OvertimeStatus.rejected &&
              !r.date.isBefore(start) &&
              r.date.isBefore(end),
        )
        .fold(0, (sum, r) => sum + r.hours);
  }

  void submit(OvertimeRequest request) {
    _requests.insert(0, request);
    notifyListeners();
  }

  void reset() {
    _requests
      ..clear()
      ..addAll(_seed());
    notifyListeners();
  }
}

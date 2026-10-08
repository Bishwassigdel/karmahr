// Demo attendance for the HR portal. Worked out from the employee's ID and
// the date, so a given person on a given day always has the same result, and
// no history needs storing. Replace with the real attendance table later.
//
// Saturday is Nepal's weekly holiday: nobody is expected, so there is no
// roster for it.

import '../state/employee_records_state.dart';

enum DayStatus { present, late, absent, onLeave }

class DayAttendance {
  final EmployeeRecord employee;
  final DayStatus status;

  /// When they arrived; null if absent or on leave.
  final DateTime? checkIn;

  const DayAttendance({
    required this.employee,
    required this.status,
    this.checkIn,
  });
}

/// How many days back HR can look.
const attendanceHistoryDays = 14;

/// Who was where on [day]. Null for the weekly holiday. Only people who had
/// already joined are listed; a day in the future has nobody.
List<DayAttendance>? rosterFor(DateTime day, Iterable<EmployeeRecord> staff) {
  final d = DateTime(day.year, day.month, day.day);
  if (d.weekday == DateTime.saturday) return null;

  final entries = <DayAttendance>[];
  for (final e in staff) {
    if (!e.isActive || e.joiningDate.isAfter(d)) continue;

    // 0-19, always the same for this person on this day.
    var h = day.year * 372 + day.month * 31 + day.day;
    for (final c in e.id.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    final roll = h % 20;

    if (roll == 0) {
      entries.add(DayAttendance(employee: e, status: DayStatus.absent));
    } else if (roll == 1) {
      entries.add(DayAttendance(employee: e, status: DayStatus.onLeave));
    } else if (roll <= 3) {
      // Late: 9:16 to 9:55.
      entries.add(
        DayAttendance(
          employee: e,
          status: DayStatus.late,
          checkIn: DateTime(d.year, d.month, d.day, 9, 16 + (h % 40)),
        ),
      );
    } else {
      // On time: 8:45 to 9:10.
      entries.add(
        DayAttendance(
          employee: e,
          status: DayStatus.present,
          checkIn: DateTime(d.year, d.month, d.day, 8, 45 + (h % 26)),
        ),
      );
    }
  }
  return entries;
}

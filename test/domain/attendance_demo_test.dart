import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_flutter_app/data/attendance_demo.dart';
import 'package:my_first_flutter_app/state/employee_records_state.dart';

void main() {
  final staff = EmployeeRecordsState().records;
  // A Sunday and a Saturday in 2026.
  final sunday = DateTime(2026, 10, 4);
  final saturday = DateTime(2026, 10, 3);

  test('Saturday is the weekly holiday: no roster at all', () {
    expect(saturday.weekday, DateTime.saturday);
    expect(rosterFor(saturday, staff), isNull);
  });

  test('a working day lists every active employee, and not the inactive', () {
    final roster = rosterFor(sunday, staff)!;
    expect(roster.length, 8);
    expect(roster.any((e) => e.employee.name == 'Dipesh Pandey'), isFalse);
  });

  test('the same person on the same day always gets the same result', () {
    final a = rosterFor(sunday, staff)!;
    final b = rosterFor(sunday, staff)!;
    expect(
      [for (final e in a) '${e.employee.id}:${e.status.name}'],
      [for (final e in b) '${e.employee.id}:${e.status.name}'],
    );
  });

  test('the time of day on the date does not change the result', () {
    final morning = rosterFor(DateTime(2026, 10, 4, 6), staff)!;
    final night = rosterFor(DateTime(2026, 10, 4, 23, 59), staff)!;
    expect(
      [for (final e in morning) e.status],
      [for (final e in night) e.status],
    );
  });

  test('someone who has not joined yet is not listed', () {
    final newJoiner = staff.first.copyWith(joiningDate: DateTime(2026, 12, 1));
    final roster = rosterFor(sunday, [newJoiner])!;
    expect(roster, isEmpty);
  });

  test('present and late people have a check-in, others do not', () {
    for (var d = 0; d < 14; d++) {
      final day = DateTime(2026, 9, 20).add(Duration(days: d));
      for (final e in rosterFor(day, staff) ?? <DayAttendance>[]) {
        final came =
            e.status == DayStatus.present || e.status == DayStatus.late;
        expect(e.checkIn != null, came, reason: '${e.employee.name} $day');
      }
    }
  });

  test('on-time arrivals are by 9:10, late ones after 9:15', () {
    for (var d = 0; d < 28; d++) {
      final day = DateTime(2026, 9, 1).add(Duration(days: d));
      for (final e in rosterFor(day, staff) ?? <DayAttendance>[]) {
        final t = e.checkIn;
        if (t == null) continue;
        final minutes = t.hour * 60 + t.minute;
        if (e.status == DayStatus.present) {
          expect(minutes, lessThanOrEqualTo(9 * 60 + 10));
        }
        if (e.status == DayStatus.late) {
          expect(minutes, greaterThan(9 * 60 + 15));
        }
        expect(
          t.year == day.year && t.month == day.month && t.day == day.day,
          isTrue,
        );
      }
    }
  });

  test('over a month most people come on time, but not everyone, always', () {
    var present = 0, other = 0;
    for (var d = 0; d < 28; d++) {
      final day = DateTime(2026, 9, 1).add(Duration(days: d));
      for (final e in rosterFor(day, staff) ?? <DayAttendance>[]) {
        e.status == DayStatus.present ? present++ : other++;
      }
    }
    expect(present, greaterThan(other * 2));
    expect(other, greaterThan(0));
  });
}

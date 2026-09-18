import 'package:flutter/cupertino.dart';

// 1. STATUS
//
// The four attendance states a single day can have. Each maps to its
// own color/label so every screen renders them consistently.
enum AttendanceDayStatus { present, absent, late, halfDay }

String attendanceStatusLabel(AttendanceDayStatus status) {
  switch (status) {
    case AttendanceDayStatus.present:
      return 'Present';
    case AttendanceDayStatus.absent:
      return 'Absent';
    case AttendanceDayStatus.late:
      return 'Late';
    case AttendanceDayStatus.halfDay:
      return 'Half-day';
  }
}

CupertinoDynamicColor attendanceStatusColor(AttendanceDayStatus status) {
  switch (status) {
    case AttendanceDayStatus.present:
      return CupertinoColors.systemGreen;
    case AttendanceDayStatus.absent:
      return CupertinoColors.systemRed;
    case AttendanceDayStatus.late:
      return CupertinoColors.systemOrange;
    case AttendanceDayStatus.halfDay:
      return CupertinoColors.systemYellow;
  }
}

// 2. ATTENDANCE RECORD
//
// One day's attendance entry. `employeeId` is included even though
// this employee-facing screen only ever shows "me" — it's what lets a
// future HR Portal reuse this exact model to show every employee's
// records instead of introducing a second, parallel data shape.
class AttendanceRecord {
  final String employeeId;
  final DateTime date;
  final AttendanceDayStatus status;
  final String? checkInTime;
  final String? checkOutTime;
  final String? workingHours;

  const AttendanceRecord({
    required this.employeeId,
    required this.date,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    this.workingHours,
  });
}

// 3. DUMMY DATA SOURCE
//
// Stands in for a real repository/API call. Swap the body of this one
// function for a real fetch later — every screen that calls it stays
// unchanged.
Future<List<AttendanceRecord>> fetchMyAttendanceHistory() async {
  await Future.delayed(const Duration(milliseconds: 600));

  const employeeId = 'MB-24071';
  final today = DateTime.now();

  const statuses = [
    AttendanceDayStatus.present,
    AttendanceDayStatus.present,
    AttendanceDayStatus.late,
    AttendanceDayStatus.present,
    AttendanceDayStatus.halfDay,
    AttendanceDayStatus.absent,
    AttendanceDayStatus.present,
    AttendanceDayStatus.present,
    AttendanceDayStatus.present,
    AttendanceDayStatus.late,
  ];

  return List.generate(statuses.length, (index) {
    final date = today.subtract(Duration(days: index + 1));
    final status = statuses[index];

    if (status == AttendanceDayStatus.absent) {
      return AttendanceRecord(
        employeeId: employeeId,
        date: date,
        status: status,
      );
    }

    final checkIn = status == AttendanceDayStatus.late ? '10:32 AM' : '9:55 AM';
    final checkOut = status == AttendanceDayStatus.halfDay ? '1:15 PM' : '6:05 PM';
    final hours = status == AttendanceDayStatus.halfDay ? '3h 20m' : '8h 10m';

    return AttendanceRecord(
      employeeId: employeeId,
      date: date,
      status: status,
      checkInTime: checkIn,
      checkOutTime: checkOut,
      workingHours: hours,
    );
  });
}

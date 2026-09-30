import 'package:flutter/cupertino.dart';

// ChangeNotifier is Provider's base class for "shareable state."
// This one object lives above Dashboard AND Attendance in the widget
// tree, so both screens read from and write to the SAME data —
// instead of each screen keeping its own private, disconnected copy.
class AttendanceState extends ChangeNotifier {
  bool isCheckedIn = false;
  bool isCheckedOut = false;
  String? checkInTime;
  String? checkOutTime;

  // The real instants behind the display strings above — needed for
  // "hours worked today", which a string like "9:02 AM" can't give.
  DateTime? checkedInAt;
  DateTime? checkedOutAt;

  /// Hours worked, once checked out; null before that.
  Duration? get workedToday => (checkedInAt != null && checkedOutAt != null)
      ? checkedOutAt!.difference(checkedInAt!)
      : null;

  void checkIn() {
    isCheckedIn = true;
    checkedInAt = DateTime.now();
    checkInTime = _formatTime(checkedInAt!);
    notifyListeners(); // tells every screen watching this to rebuild
  }

  void checkOut() {
    isCheckedIn = false;
    isCheckedOut = true;
    checkedOutAt = DateTime.now();
    checkOutTime = _formatTime(checkedOutAt!);
    notifyListeners();
  }

  // Wipes today's check-in/out. Called on logout so the next person to
  // use this device doesn't inherit the previous user's session.
  void reset() {
    isCheckedIn = false;
    isCheckedOut = false;
    checkInTime = null;
    checkOutTime = null;
    checkedInAt = null;
    checkedOutAt = null;
    notifyListeners();
  }

  String _formatTime(DateTime time) {
    int hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour = hour - 12;
    }
    return '$hour:$minute $period';
  }
}

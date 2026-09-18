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

  void checkIn() {
    isCheckedIn = true;
    checkInTime = _formatTime(DateTime.now());
    notifyListeners(); // tells every screen watching this to rebuild
  }

  void checkOut() {
    isCheckedOut = true;
    checkOutTime = _formatTime(DateTime.now());
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

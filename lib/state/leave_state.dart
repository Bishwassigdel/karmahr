import 'package:flutter/cupertino.dart';

// Moved here from leave_balances_screen.dart — this used to only
// exist in one of the two screens, which was part of why they
// couldn't agree on request status. Now both screens import it from
// here instead of each defining their own copy.
enum LeaveRequestStatus { pending, approved, rejected }

String leaveStatusLabel(LeaveRequestStatus status) {
  switch (status) {
    case LeaveRequestStatus.pending:
      return 'Pending';
    case LeaveRequestStatus.approved:
      return 'Approved';
    case LeaveRequestStatus.rejected:
      return 'Rejected';
  }
}

// Returns the raw (unresolved) dynamic color — callers must call
// .resolveFrom(context) before use, same rule as everywhere else.
CupertinoDynamicColor leaveStatusColor(LeaveRequestStatus status) {
  switch (status) {
    case LeaveRequestStatus.pending:
      return CupertinoColors.systemOrange;
    case LeaveRequestStatus.approved:
      return CupertinoColors.systemGreen;
    case LeaveRequestStatus.rejected:
      return CupertinoColors.systemRed;
  }
}

// One submitted leave request. Previously TWO different classes with
// this exact same name existed — one in leave_screen.dart (status as
// a raw String), one in leave_balances_screen.dart (status as this
// enum). This is now the ONE real version both screens share.
class LeaveRequest {
  final String leaveType;
  final String durationType;
  final DateTime startDate;
  final DateTime endDate;
  final int? leaveHours;
  final DateTime? leaveStartTime;
  final String reason;
  final LeaveRequestStatus status;

  const LeaveRequest({
    required this.leaveType,
    required this.durationType,
    required this.startDate,
    required this.endDate,
    required this.leaveHours,
    required this.leaveStartTime,
    required this.reason,
    required this.status,
  });
}

// The shared Provider state — same ChangeNotifier pattern as
// AttendanceState. Both leave_screen.dart and
// leave_balances_screen.dart read `requests` from here and call
// `submitLeave()` here, so a submission from either screen is
// immediately visible on both.
class LeaveState extends ChangeNotifier {
  // Seeded with the same three demo examples that used to live only
  // in leave_balances_screen.dart, so Pending/Approved/Rejected are
  // all visible right away.
  final List<LeaveRequest> _requests = _seed();

  static List<LeaveRequest> _seed() => [
    LeaveRequest(
      leaveType: 'Sick Leave',
      durationType: 'Full Day',
      startDate: DateTime.now().subtract(const Duration(days: 20)),
      endDate: DateTime.now().subtract(const Duration(days: 19)),
      leaveHours: null,
      leaveStartTime: null,
      reason: 'Fever and cold, advised rest by doctor.',
      status: LeaveRequestStatus.approved,
    ),
    LeaveRequest(
      leaveType: 'Home Leave',
      durationType: 'First Half Day',
      startDate: DateTime.now().subtract(const Duration(days: 8)),
      endDate: DateTime.now().subtract(const Duration(days: 8)),
      leaveHours: null,
      leaveStartTime: null,
      reason: 'Family function at home.',
      status: LeaveRequestStatus.rejected,
    ),
    LeaveRequest(
      leaveType: 'Unpaid Leave',
      durationType: 'Hours Leave',
      startDate: DateTime.now().subtract(const Duration(days: 2)),
      endDate: DateTime.now().subtract(const Duration(days: 2)),
      leaveHours: 3,
      leaveStartTime: DateTime(2026, 1, 1, 14, 0),
      reason: 'Bank work at Nepal Rastra Bank.',
      status: LeaveRequestStatus.pending,
    ),
  ];

  // Unmodifiable so screens can only change data through
  // submitLeave() below, never by mutating the list directly.
  List<LeaveRequest> get requests => List.unmodifiable(_requests);

  void submitLeave(LeaveRequest request) {
    _requests.insert(0, request);
    notifyListeners(); // tells both screens watching this to rebuild
  }

  // Called on logout — drops everything submitted this session and
  // returns to the demo seed, so the next user doesn't see it.
  void reset() {
    _requests
      ..clear()
      ..addAll(_seed());
    notifyListeners();
  }
}

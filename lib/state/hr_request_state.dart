import 'package:flutter/cupertino.dart';

// RequestStatus, RequestCategory, the label/icon helpers, and
// HrRequest all moved here from request_screen.dart — same reason
// LeaveRequest moved to leave_state.dart: this data needs to be
// readable from more than one screen (request_screen.dart AND the
// new "My Requests" summary screen), which a private State class
// can't do.

enum RequestStatus { pending, approved, rejected }

String hrStatusLabel(RequestStatus status) {
  switch (status) {
    case RequestStatus.pending:
      return 'Pending';
    case RequestStatus.approved:
      return 'Approved';
    case RequestStatus.rejected:
      return 'Rejected';
  }
}

CupertinoDynamicColor hrStatusColor(RequestStatus status) {
  switch (status) {
    case RequestStatus.pending:
      return CupertinoColors.systemOrange;
    case RequestStatus.approved:
      return CupertinoColors.systemGreen;
    case RequestStatus.rejected:
      return CupertinoColors.systemRed;
  }
}

enum RequestCategory {
  timeCorrection,
  salaryAdvance,
  idCardReissue,
  addressUpdate,
  generalInquiry,
}

String hrCategoryLabel(RequestCategory category) {
  switch (category) {
    case RequestCategory.timeCorrection:
      return 'Time Correction';
    case RequestCategory.salaryAdvance:
      return 'Salary Advance';
    case RequestCategory.idCardReissue:
      return 'ID Card Reissue';
    case RequestCategory.addressUpdate:
      return 'Address/Contact Update';
    case RequestCategory.generalInquiry:
      return 'General Inquiry (HR Helpdesk)';
  }
}

IconData hrCategoryIcon(RequestCategory category) {
  switch (category) {
    case RequestCategory.timeCorrection:
      return CupertinoIcons.time;
    case RequestCategory.salaryAdvance:
      return CupertinoIcons.money_dollar;
    case RequestCategory.idCardReissue:
      return CupertinoIcons.creditcard;
    case RequestCategory.addressUpdate:
      return CupertinoIcons.location_solid;
    case RequestCategory.generalInquiry:
      return CupertinoIcons.chat_bubble_2;
  }
}

class HrRequest {
  final RequestCategory category;
  final RequestStatus status;
  final String notes;
  final String? timeIssueType;
  final DateTime? issueDate;
  final DateTime? correctedTime;
  final double? amount;
  final String? reissueReason;
  final String? newAddress;
  final String? newPhone;
  final String? subject;

  const HrRequest({
    required this.category,
    required this.status,
    required this.notes,
    this.timeIssueType,
    this.issueDate,
    this.correctedTime,
    this.amount,
    this.reissueReason,
    this.newAddress,
    this.newPhone,
    this.subject,
  });
}

// Shared Provider state — same ChangeNotifier pattern as LeaveState
// and AttendanceState.
class HrRequestState extends ChangeNotifier {
  final List<HrRequest> _requests = _seed();

  static List<HrRequest> _seed() => [
    HrRequest(
      category: RequestCategory.timeCorrection,
      status: RequestStatus.approved,
      notes: 'Forgot to check out before leaving for a client site visit.',
      timeIssueType: 'Missing Check-out',
      issueDate: DateTime.now().subtract(const Duration(days: 6)),
      correctedTime: DateTime(2026, 1, 1, 18, 5),
    ),
    HrRequest(
      category: RequestCategory.salaryAdvance,
      status: RequestStatus.pending,
      notes: 'Medical expense for a family member.',
      amount: 15000,
    ),
  ];

  List<HrRequest> get requests => List.unmodifiable(_requests);

  void submitRequest(HrRequest request) {
    _requests.insert(0, request);
    notifyListeners();
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

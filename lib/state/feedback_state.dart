import 'package:flutter/cupertino.dart';

// ============================================================
// FEEDBACK TYPE
// ============================================================
//
// A fixed set of categories (not free text) — same reasoning as
// RequestCategory in hr_request_state.dart: it keeps the data
// consistent and scannable for HR later, instead of employees
// typing wildly different labels for the same kind of feedback.
enum FeedbackType {
  suggestion,
  workplaceConcern,
  managerTeamFeedback,
  companyPolicy,
  other,
}

// Human-readable label — shown in the picker and on submitted cards.
String feedbackTypeLabel(FeedbackType type) {
  switch (type) {
    case FeedbackType.suggestion:
      return 'Suggestion';
    case FeedbackType.workplaceConcern:
      return 'Workplace Concern';
    case FeedbackType.managerTeamFeedback:
      return 'Manager/Team Feedback';
    case FeedbackType.companyPolicy:
      return 'Company Policy';
    case FeedbackType.other:
      return 'Other';
  }
}

// One icon per type — purely visual, used in the picker + history rows.
IconData feedbackTypeIcon(FeedbackType type) {
  switch (type) {
    case FeedbackType.suggestion:
      return CupertinoIcons.lightbulb;
    case FeedbackType.workplaceConcern:
      return CupertinoIcons.exclamationmark_triangle;
    case FeedbackType.managerTeamFeedback:
      return CupertinoIcons.person_2;
    case FeedbackType.companyPolicy:
      return CupertinoIcons.doc_text;
    case FeedbackType.other:
      return CupertinoIcons.ellipsis_circle;
  }
}

// ============================================================
// FEEDBACK ITEM
// ============================================================
//
// IMPORTANT: notice there is NO "fromName" / "authorName" field here
// — unlike KudosPost or HrRequest, which both know who submitted them.
// That absence IS the anonymity: the identity of whoever wrote this
// is never captured in the first place, so there's nothing to leak
// later, even by accident (no "logged in as X" stamp, nothing).
class FeedbackItem {
  final FeedbackType type;
  final String message;
  final String? details; // optional extra context — null if left blank
  final DateTime submittedAt;

  FeedbackItem({
    required this.type,
    required this.message,
    this.details,
    required this.submittedAt,
  });
}

// ============================================================
// FEEDBACK STATE
// ============================================================
//
// Same ChangeNotifier + Provider pattern as LeaveState, HrRequestState,
// KudosState, AttendanceState: one shared instance created once in
// main.dart, then watched/read from whichever screen needs it.
//
// A NOTE ON "ANONYMOUS" IN THIS DEMO APP:
// There's no backend yet, so this list only ever lives in this one
// phone's memory for this one app session — it resets when the app
// fully restarts. In a real backend, this table would sit in HR's
// database with genuinely no employee ID column at all. Keeping a
// local echo here just lets you SEE that submitting worked — it's
// still not tied to any identity, matching the real design.
class FeedbackState extends ChangeNotifier {
  final List<FeedbackItem> _items = [];

  // .unmodifiable — screens can only change this data through
  // submitFeedback() below, never by mutating the list directly.
  // Same defensive pattern used by every other *State class here.
  List<FeedbackItem> get items => List.unmodifiable(_items);

  void submitFeedback({
    required FeedbackType type,
    required String message,
    String? details,
  }) {
    _items.insert(
      0, // newest first — same convention as submitLeave/submitRequest
      FeedbackItem(
        type: type,
        message: message,
        // Treat a blank/whitespace-only details field the same as
        // "nothing entered" — avoids storing an empty string that
        // would just render as a pointless blank line in the UI.
        details: (details == null || details.trim().isEmpty)
            ? null
            : details.trim(),
        submittedAt: DateTime.now(),
      ),
    );

    // Tells every widget watching this state (context.watch<FeedbackState>())
    // to rebuild — this is what makes the "Recently Submitted" list
    // below the form update instantly, with no manual setState needed
    // anywhere else in the app.
    notifyListeners();
  }

  // Called on logout. Without this, the next person to sign in on this
  // device would see the previous user's anonymous feedback — which
  // defeats the entire point of the feature.
  void clear() {
    _items.clear();
    notifyListeners();
  }
}

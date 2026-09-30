// Everything that must happen to this user's data on logout, in ONE
// place. It used to be a hand-maintained list of reset() calls inside the
// Dashboard's logout dialog — every new feature had to remember to add
// itself there, and forgetting meant the next person on this device would
// see the previous user's data. Adding a new per-user state now means
// adding one line here, next to all the others.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'app_lock_state.dart';
import 'attendance_state.dart';
import 'document_wallet_state.dart';
import 'emergency_info_state.dart';
import 'event_rsvp_state.dart';
import 'expense_state.dart';
import 'feedback_state.dart';
import 'goals_state.dart';
import 'hr_request_state.dart';
import 'kudos_state.dart';
import 'leave_state.dart';
import 'notification_state.dart';
import 'onboarding_state.dart';
import 'overtime_state.dart';
import 'safety_state.dart';
import 'survey_state.dart';
import 'training_state.dart';

void resetSession(BuildContext context) {
  context.read<AttendanceState>().reset();
  context.read<LeaveState>().reset();
  context.read<HrRequestState>().reset();
  context.read<KudosState>().reset();
  context.read<FeedbackState>().clear();
  context.read<NotificationState>().reset();
  context.read<ExpenseState>().reset();
  context.read<OvertimeState>().reset();
  context.read<DocumentWalletState>().reset();
  context.read<EmergencyInfoState>().reset();
  context.read<OnboardingState>().reset();
  context.read<TrainingState>().reset();
  context.read<GoalsState>().reset();
  context.read<SurveyState>().reset();
  context.read<SafetyState>().reset();
  context.read<EventRsvpState>().reset();
  // Last: re-lock, so the next person has to authenticate before
  // reaching anything — even without the app ever being fully closed.
  context.read<AppLockState>().lock();
}

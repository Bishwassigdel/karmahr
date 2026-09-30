// QA: the new features' actual behavior, driven through the UI with the
// app's real provider list — not just "does it render".

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_first_flutter_app/data/team_data.dart';
import 'package:my_first_flutter_app/main.dart';
import 'package:my_first_flutter_app/screens/dashboard_screen.dart';
import 'package:my_first_flutter_app/screens/events_screen.dart';
import 'package:my_first_flutter_app/screens/expense_claims_screen.dart';
import 'package:my_first_flutter_app/screens/leave_planner_screen.dart';
import 'package:my_first_flutter_app/screens/main_nav_screen.dart';
import 'package:my_first_flutter_app/screens/pulse_survey_screen.dart';
import 'package:my_first_flutter_app/screens/safety_checkin_screen.dart';
import 'package:my_first_flutter_app/screens/shifts_overtime_screen.dart';
import 'package:my_first_flutter_app/state/document_wallet_state.dart';
import 'package:my_first_flutter_app/state/emergency_info_state.dart';
import 'package:my_first_flutter_app/state/event_rsvp_state.dart';
import 'package:my_first_flutter_app/state/expense_state.dart';
import 'package:my_first_flutter_app/state/goals_state.dart';
import 'package:my_first_flutter_app/state/notification_state.dart';
import 'package:my_first_flutter_app/state/onboarding_state.dart';
import 'package:my_first_flutter_app/state/overtime_state.dart';
import 'package:my_first_flutter_app/state/safety_state.dart';
import 'package:my_first_flutter_app/state/session.dart';
import 'package:my_first_flutter_app/state/survey_state.dart';
import 'package:my_first_flutter_app/state/training_state.dart';

// Renders [screen] under the real providers and returns a context below
// them, for reading/priming state.
Future<BuildContext> pumpApp(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(393, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MultiProvider(
      providers: appProviders(),
      child: CupertinoApp(home: screen),
    ),
  );
  await settle(tester);
  return tester.element(find.byWidget(screen));
}

// Bounded settling: some screens have endless animations (spinners).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('expense claim: empty submit is blocked with a reason', (tester) async {
    final context = await pumpApp(tester, const NewExpenseClaimScreen());
    final before = context.read<ExpenseState>().claims.length;

    await tester.tap(find.text('Submit Claim'));
    await settle(tester);

    expect(find.text('Almost there'), findsOneWidget);
    expect(context.read<ExpenseState>().claims.length, before);
  });

  testWidgets('overtime: over the daily limit shows a warning and blocks submit', (
    tester,
  ) async {
    final context = await pumpApp(tester, const OvertimeRequestScreen());
    final before = context.read<OvertimeState>().requests.length;

    // 2h default → tap + six times → 5h, past the 4h daily limit.
    for (var i = 0; i < 6; i++) {
      await tester.tap(find.byIcon(CupertinoIcons.plus_circle));
      await tester.pump();
    }
    expect(find.textContaining('exceeds the daily overtime limit'), findsOneWidget);

    await tester.tap(find.text('Submit'));
    await settle(tester);
    expect(find.text('Over the Limit'), findsOneWidget);
    expect(context.read<OvertimeState>().requests.length, before);
  });

  testWidgets("safety drill: I'm Safe records the answer and the inbox", (
    tester,
  ) async {
    final context = await pumpApp(tester, const SafetyCheckInScreen());
    await tester.tap(find.text('Practice with a drill'));
    await settle(tester);
    expect(find.text("I'm Safe"), findsOneWidget);

    await tester.tap(find.text("I'm Safe"));
    await settle(tester);

    final safety = context.read<SafetyState>();
    expect(safety.response, SafetyResponse.safe);
    expect(safety.awaitingMyResponse, isFalse);
    expect(find.text('✓ You marked yourself safe.'), findsOneWidget);
    expect(context.read<NotificationState>().items.first.title, 'Marked safe');
  });

  testWidgets('pulse: one tap checks in, then shows team results', (tester) async {
    final context = await pumpApp(tester, const PulseSurveyScreen());
    final before = context.read<SurveyState>().moodResponses;

    await tester.tap(find.text('🙂'));
    await settle(tester);

    final survey = context.read<SurveyState>();
    expect(survey.hasCheckedInThisWeek, isTrue);
    expect(survey.moodResponses, before + 1);
    expect(find.textContaining('Thanks for checking in'), findsOneWidget);

    // A second tap can't vote twice.
    survey.checkIn(0);
    expect(survey.moodResponses, before + 1);
  });

  testWidgets('RSVP Going adds you to the attendee count', (tester) async {
    final context = await pumpApp(tester, const EventsScreen());
    final event = demoCompanyEvents().first;
    final rsvps = context.read<EventRsvpState>();
    final before = rsvps.goingCount(event);

    await tester.tap(find.text(event.title));
    await settle(tester);
    await tester.tap(find.text('Going'));
    await settle(tester);

    expect(rsvps.rsvpFor(event.id), Rsvp.going);
    expect(rsvps.goingCount(event), before + 1);
  });

  testWidgets('leave planner: picking a long-break idea shows its cost', (
    tester,
  ) async {
    await pumpApp(tester, const LeavePlannerScreen());
    final bridges = upcomingBridges();
    if (bridges.isEmpty) {
      // Nothing to plan in the demo calendar right now — the section
      // must say so rather than render empty.
      expect(find.textContaining('No bridge opportunities'), findsOneWidget);
      return;
    }
    await tester.tap(find.byType(BridgeSuggestionTile).first);
    await settle(tester);
    expect(find.textContaining('of leave'), findsWidgets);
    expect(find.text('Apply for this leave'), findsOneWidget);
  });

  testWidgets('dashboard surfaces overdue training in Needs Your Attention', (
    tester,
  ) async {
    await pumpApp(tester, const DashboardScreen());
    expect(find.text('Needs Your Attention'), findsOneWidget);
    expect(find.textContaining('Overdue training'), findsOneWidget);
  });

  testWidgets('startup reminders post overdue training to the inbox ONCE', (
    tester,
  ) async {
    final context = await pumpApp(tester, const MainNavScreen());
    final inbox = context.read<NotificationState>();
    int reminders() =>
        inbox.items.where((n) => n.title.startsWith('Training overdue')).length;

    expect(reminders(), 1);
    // Asking again in the same session hands out nothing new.
    expect(
      context.read<TrainingState>().takeOverdueToAnnounce(DateTime.now()),
      isEmpty,
    );
  });

  testWidgets('logout (resetSession) restores every per-user state', (
    tester,
  ) async {
    final context = await pumpApp(tester, const SizedBox());

    // Dirty every new state...
    context.read<SafetyState>().startDrill();
    context.read<SurveyState>().checkIn(4);
    context.read<EventRsvpState>().setRsvp('town-hall', Rsvp.going);
    context.read<GoalsState>().add(title: 'x', keyResult: 'y');
    context.read<DocumentWalletState>().add(type: WalletDocType.other, title: 't', number: '123456');
    context.read<EmergencyInfoState>().add(name: 'n', relation: 'r', phone: '9800000000');
    final onboarding = context.read<OnboardingState>();
    onboarding.toggle(onboarding.tasks.last);
    context.read<TrainingState>().takeOverdueToAnnounce(DateTime.now());

    // ...then log out. Any state missing a provider would throw here.
    resetSession(context);

    expect(context.read<SafetyState>().isActive, isFalse);
    expect(context.read<SurveyState>().hasCheckedInThisWeek, isFalse);
    expect(context.read<EventRsvpState>().rsvpFor('town-hall'), isNull);
    expect(context.read<GoalsState>().goals.any((g) => g.title == 'x'), isFalse);
    expect(context.read<DocumentWalletState>().documents.any((d) => d.title == 't'), isFalse);
    expect(context.read<EmergencyInfoState>().contacts.any((c) => c.name == 'n'), isFalse);
    expect(context.read<OnboardingState>().tasks.last.done, isFalse);
    // Training reminders are re-armed for the next person's session.
    expect(
      context.read<TrainingState>().takeOverdueToAnnounce(DateTime.now()),
      isNotEmpty,
    );
  });
}

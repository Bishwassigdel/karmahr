import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:my_first_flutter_app/l10n/app_localizations.dart';
import 'package:my_first_flutter_app/main.dart';
import 'package:my_first_flutter_app/screens/hr/hr_teams_screen.dart';
import 'package:my_first_flutter_app/state/audit_log_state.dart';
import 'package:my_first_flutter_app/state/employee_records_state.dart';
import 'package:my_first_flutter_app/state/teams_state.dart';

Future<BuildContext> pumpTeams(
  WidgetTester tester, {
  Widget home = const HrTeamsScreen(),
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(430, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MultiProvider(
      providers: appProviders(),
      child: CupertinoApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: home,
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
  return tester.element(find.byType(CupertinoApp));
}

void main() {
  testWidgets('an empty list explains what to do', (tester) async {
    await pumpTeams(tester);
    expect(find.textContaining('No teams yet'), findsOneWidget);
  });

  testWidgets('HR can make a team, and the audit log records it', (
    tester,
  ) async {
    final ctx = await pumpTeams(tester);
    await tester.tap(find.text('New team'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(CupertinoTextField), 'Support A');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final teams = ctx.read<TeamsState>().teams;
    expect(teams.map((t) => t.name), ['Support A']);
    expect(find.text('Support A'), findsOneWidget);
    expect(find.textContaining('No head yet'), findsOneWidget);
    expect(
      ctx.read<AuditLogState>().entries.first.action,
      AuditAction.teamCreated,
    );
  });

  testWidgets('a duplicate or blank name is refused with a message', (
    tester,
  ) async {
    final ctx = await pumpTeams(tester);
    ctx.read<TeamsState>().create('Support A');
    await tester.pump();

    await tester.tap(find.text('New team'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(CupertinoTextField), 'support a');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.textContaining('no other team uses'), findsOneWidget);
    expect(ctx.read<TeamsState>().teams.length, 1);
  });

  testWidgets(
    'the page of a team that no longer exists is blank, not a crash',
    (tester) async {
      final ctx = await pumpTeams(
        tester,
        home: const HrTeamDetailScreen(teamId: 'T-99'),
      );
      expect(ctx.read<TeamsState>().teams, isEmpty);
      expect(find.byType(CupertinoListTile), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('tapping a member offers head and remove actions', (
    tester,
  ) async {
    final ctx = await pumpTeams(tester);
    final people = ctx.read<EmployeeRecordsState>().active;
    final teams = ctx.read<TeamsState>();
    final team = teams.create('Support A')!;
    teams.addMember(team.id, people[0].id);
    teams.addMember(team.id, people[1].id);
    await tester.pump();

    await tester.tap(find.text('Support A'));
    await tester.pumpAndSettle();

    // Make the second person head.
    await tester.tap(find.text(people[1].name));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Make team head'));
    await tester.pumpAndSettle();
    expect(teams.byId(team.id)!.headId, people[1].id);
    expect(find.text('Team head'), findsOneWidget);

    // Remove the head: the team has no head again.
    await tester.tap(find.text(people[1].name));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove from team'));
    await tester.pumpAndSettle();
    expect(teams.byId(team.id)!.headId, isEmpty);
    expect(teams.byId(team.id)!.memberIds, [people[0].id]);
    expect(find.textContaining('no head yet'), findsOneWidget);
  });

  testWidgets('a person who already leads a team cannot lead a second', (
    tester,
  ) async {
    final ctx = await pumpTeams(tester);
    final people = ctx.read<EmployeeRecordsState>().active;
    final teams = ctx.read<TeamsState>();
    final a = teams.create('Support A')!;
    final b = teams.create('Sales')!;
    teams.addMember(a.id, people[0].id);
    teams.addMember(b.id, people[0].id);
    teams.setHead(a.id, people[0].id);
    await tester.pump();

    await tester.tap(find.text('Sales'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(people[0].name));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Make team head'));
    await tester.pumpAndSettle();

    expect(find.textContaining('can lead only one team'), findsOneWidget);
    expect(teams.byId(b.id)!.headId, isEmpty);
  });

  testWidgets('a deactivated head is not shown as the team head', (
    tester,
  ) async {
    final ctx = await pumpTeams(tester);
    final people = ctx.read<EmployeeRecordsState>().active;
    final teams = ctx.read<TeamsState>();
    final team = teams.create('Support A')!;
    teams.addMember(team.id, people[0].id);
    teams.setHead(team.id, people[0].id);
    await tester.pump();
    expect(find.textContaining(people[0].name), findsOneWidget);

    ctx.read<EmployeeRecordsState>().setStatus(
      people[0].id,
      EmploymentStatus.inactive,
    );
    await tester.pump();
    expect(find.textContaining(people[0].name), findsNothing);
    expect(find.textContaining('No head yet'), findsOneWidget);
  });

  testWidgets('deleting a team asks first, then removes it', (tester) async {
    final ctx = await pumpTeams(tester);
    final teams = ctx.read<TeamsState>();
    teams.create('Support A');
    await tester.pump();

    await tester.tap(find.text('Support A'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete team'));
    await tester.pumpAndSettle();
    expect(find.text('Delete Support A?'), findsOneWidget);
    await tester.tap(find.widgetWithText(CupertinoDialogAction, 'Delete team'));
    await tester.pumpAndSettle();

    expect(teams.teams, isEmpty);
    expect(find.textContaining('No teams yet'), findsOneWidget);
    expect(
      ctx.read<AuditLogState>().entries.first.action,
      AuditAction.teamDeleted,
    );
  });

  testWidgets('works in Nepali without overflow at large text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final ctx = await pumpTeams(tester, locale: const Locale('ne'));
    final people = ctx.read<EmployeeRecordsState>().active;
    final teams = ctx.read<TeamsState>();
    final team = teams.create('बिक्री टोली')!;
    teams.addMember(team.id, people[0].id);
    teams.setHead(team.id, people[0].id);
    await tester.pump();
    expect(find.text('नयाँ टोली'), findsOneWidget);

    await tester.tap(find.text('बिक्री टोली'));
    await tester.pumpAndSettle();
    expect(find.text('टोली प्रमुख'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

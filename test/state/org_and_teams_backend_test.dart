import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_flutter_app/state/employee_repository.dart';
import 'package:my_first_flutter_app/state/org_state.dart';
import 'package:my_first_flutter_app/state/teams_state.dart';

import '../helpers/fake_org_and_teams.dart';

void main() {
  group('departments and branches (OrgState)', () {
    late FakeOrgRepository repo;
    late OrgState org;

    setUp(() {
      repo = FakeOrgRepository();
      org = OrgState(repository: repo);
    });

    test(
      'with a backend it starts empty, then loads the company\'s lists',
      () async {
        expect(org.departments, isEmpty);
        await org.refresh();
        expect(org.departments, ['Engineering', 'Support']); // A to Z
        expect(org.branches, ['Kathmandu Head Office']);
      },
    );

    test('without one, it has the demo company\'s lists', () {
      final demo = OrgState();
      expect(demo.departments, containsAll(['Finance', 'Operations']));
      expect(demo.branches, contains('Kathmandu Head Office'));
    });

    test('adding a department saves it, then lists it', () async {
      await org.refresh();
      expect(await org.addDepartment('  Sales  '), isNull);
      expect(repo.departments, contains('Sales'));
      expect(org.departments, contains('Sales'));
    });

    test(
      'a name it already has, in any capitals, is refused, not added twice',
      () async {
        await org.refresh();
        final f = await org.addDepartment('support');
        expect(f?.problem, SaveProblem.duplicateName);
        expect(
          repo.departments.where((d) => d.toLowerCase() == 'support').length,
          1,
        );
      },
    );

    test('a blank name is refused', () async {
      expect((await org.addBranch('   '))?.problem, SaveProblem.duplicateName);
    });

    test('if saving fails, the list does not change', () async {
      await org.refresh();
      repo.failNextWrite = const SaveFailure(SaveProblem.notAllowed);
      final f = await org.addBranch('Pokhara Office');
      expect(f?.problem, SaveProblem.notAllowed);
      expect(org.branches, isNot(contains('Pokhara Office')));
    });

    test('a failed load keeps the lists it had', () async {
      await org.refresh();
      repo.failLoad = true;
      await org.refresh();
      expect(org.departments, ['Engineering', 'Support']);
    });

    test(
      'logging out forgets a real company\'s lists, but not the demo\'s',
      () async {
        await org.refresh();
        org.clearForSignOut();
        expect(org.departments, isEmpty);
        final demo = OrgState()..clearForSignOut();
        expect(demo.departments, isNotEmpty);
      },
    );

    test('canonical gives the list\'s own spelling', () async {
      await org.refresh();
      expect(org.canonical('support', org.departments), 'Support');
      expect(org.canonical('Unknown', org.departments), 'Unknown');
    });
  });

  group('teams with a backend (TeamsState)', () {
    late FakeTeamsRepository repo;
    late TeamsState teams;

    setUp(() async {
      repo = FakeTeamsRepository(
        stored: [
          const Team(
            id: 'uuid-a',
            name: 'Support Team',
            headId: 'HT-003',
            memberIds: ['HT-003', 'HT-004'],
          ),
        ],
      );
      teams = TeamsState(repository: repo);
    });

    test('starts empty, then loads the company\'s teams', () async {
      expect(teams.teams, isEmpty);
      await teams.refresh();
      expect(teams.teams.single.name, 'Support Team');
      expect(teams.teams.single.headId, 'HT-003');
    });

    test('a new team gets the id the database gave it', () async {
      await teams.refresh();
      expect(await teams.createAndSave('Sales'), isNull);
      expect(teams.teams.map((t) => t.id), contains('uuid-1'));
      expect(repo.stored.map((t) => t.name), contains('Sales'));
    });

    test('teams survive a restart: a new state loads what was saved', () async {
      await teams.refresh();
      await teams.createAndSave('Sales');
      final later = TeamsState(repository: repo); // the app opened again
      await later.refresh();
      expect(later.teams.map((t) => t.name), ['Support Team', 'Sales']);
    });

    test('the same rules apply before anything is sent', () async {
      await teams.refresh();
      expect(
        (await teams.createAndSave('support team'))?.problem,
        SaveProblem.duplicateName,
      );
      expect(
        (await teams.createAndSave('  '))?.problem,
        SaveProblem.duplicateName,
      );
      expect(
        (await teams.addMemberAndSave('uuid-a', 'HT-003'))?.problem,
        SaveProblem.conflict,
      );
      expect(
        (await teams.setHeadAndSave('uuid-a', 'HT-999'))?.problem,
        SaveProblem.conflict,
      );
      expect(repo.calls, isEmpty, reason: 'nothing reached the database');
    });

    test('adding, heading, removing and deleting are all saved', () async {
      await teams.refresh();
      await teams.addMemberAndSave('uuid-a', 'HT-005');
      await teams.setHeadAndSave('uuid-a', 'HT-005');
      await teams.removeMemberAndSave('uuid-a', 'HT-003');
      expect(repo.calls, [
        'addMember uuid-a HT-005',
        'setHead uuid-a HT-005',
        'removeMember uuid-a HT-003',
      ]);
      expect(teams.byId('uuid-a')!.headId, 'HT-005');
      expect(teams.byId('uuid-a')!.memberIds, ['HT-004', 'HT-005']);
      await teams.deleteAndSave('uuid-a');
      expect(teams.teams, isEmpty);
      expect(repo.stored, isEmpty);
    });

    test('renaming and clearing the head are saved', () async {
      await teams.refresh();
      await teams.renameAndSave('uuid-a', 'Help Desk');
      await teams.clearHeadAndSave('uuid-a');
      expect(repo.stored.single.name, 'Help Desk');
      expect(repo.stored.single.headId, isEmpty);
      expect(teams.byId('uuid-a')!.headId, isEmpty);
    });

    test('if a save fails, the screen goes back to what is stored', () async {
      await teams.refresh();
      repo.failNextWrite = const SaveFailure(SaveProblem.network);
      final f = await teams.addMemberAndSave('uuid-a', 'HT-005');
      expect(f?.problem, SaveProblem.network);
      await Future<void>.delayed(Duration.zero); // the reload
      expect(teams.byId('uuid-a')!.memberIds, ['HT-003', 'HT-004']);
      expect(repo.loads, 2);
    });

    test('a failed create adds nothing', () async {
      await teams.refresh();
      repo.failNextWrite = const SaveFailure(SaveProblem.notAllowed);
      expect(
        (await teams.createAndSave('Sales'))?.problem,
        SaveProblem.notAllowed,
      );
      await Future<void>.delayed(Duration.zero);
      expect(teams.teams.map((t) => t.name), ['Support Team']);
    });

    test(
      'a person who leads one team cannot be made head of another',
      () async {
        await teams.refresh();
        await teams.createAndSave('Sales');
        final sales = teams.teams.firstWhere((t) => t.name == 'Sales');
        await teams.addMemberAndSave(sales.id, 'HT-003');
        final f = await teams.setHeadAndSave(sales.id, 'HT-003');
        expect(f?.problem, SaveProblem.conflict);
        expect(repo.calls.where((c) => c.startsWith('setHead')), isEmpty);
      },
    );

    test('a failed load says so and keeps what it had', () async {
      await teams.refresh();
      repo.failLoad = true;
      await teams.refresh();
      expect(teams.loadFailed, isTrue);
      expect(teams.teams, isNotEmpty);
    });

    test('logging out forgets a real company\'s teams', () async {
      await teams.refresh();
      teams.clearForSignOut();
      expect(teams.teams, isEmpty);
    });

    test('the demo (no backend) still numbers its own teams', () async {
      final demo = TeamsState();
      expect(await demo.createAndSave('Sales'), isNull);
      expect(demo.teams.single.id, 'T-1');
      expect(await demo.addMemberAndSave('T-1', 'A'), isNull);
      expect(await demo.setHeadAndSave('T-1', 'A'), isNull);
      expect(demo.canAssign('A', 'A'), isTrue);
    });
  });
}

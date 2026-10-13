import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_flutter_app/state/teams_state.dart';

void main() {
  late TeamsState state;
  late Team team;

  setUp(() {
    state = TeamsState();
    team = state.create('Support A')!;
    for (final id in ['A', 'B', 'C', 'D']) {
      state.addMember(team.id, id);
    }
  });

  Team now() => state.byId(team.id)!;

  group('making teams', () {
    test('a new team starts empty with no head', () {
      final t = state.create('Sales')!;
      expect(t.memberIds, isEmpty);
      expect(t.headId, isEmpty);
    });

    test('a blank name is refused', () {
      expect(state.create('   '), isNull);
    });

    test('two teams cannot share a name, even in different case', () {
      expect(state.create('support a'), isNull);
      expect(state.teams.length, 1);
    });

    test('rename works, but not to a name another team has', () {
      state.create('Sales');
      expect(state.rename(team.id, 'Help Desk'), isTrue);
      expect(now().name, 'Help Desk');
      expect(state.rename(team.id, 'sales'), isFalse);
      expect(state.rename(team.id, ' '), isFalse);
    });

    test('keeping its own name when renaming is fine', () {
      expect(state.rename(team.id, 'Support A'), isTrue);
    });
  });

  group('members', () {
    test('the same person cannot be added twice', () {
      expect(state.addMember(team.id, 'A'), isFalse);
      expect(now().memberIds, ['A', 'B', 'C', 'D']);
    });

    test('an unknown team changes nothing', () {
      expect(state.addMember('nope', 'A'), isFalse);
      expect(state.removeMember('nope', 'A'), isFalse);
    });

    test('removing someone who is not in the team does nothing', () {
      expect(state.removeMember(team.id, 'Z'), isFalse);
    });

    test('a person can be in more than one team', () {
      final other = state.create('Sales')!;
      state.addMember(other.id, 'B');
      expect(state.teamsOf('B').length, 2);
    });
  });

  group('the head', () {
    test('only a member can be made head', () {
      expect(state.setHead(team.id, 'Z'), isFalse);
      expect(now().headId, isEmpty);
      expect(state.setHead(team.id, 'A'), isTrue);
      expect(now().headId, 'A');
    });

    test('removing the head leaves the team with no head', () {
      state.setHead(team.id, 'A');
      state.removeMember(team.id, 'A');
      expect(now().headId, isEmpty);
      expect(now().memberIds, ['B', 'C', 'D']);
    });

    test('the head can be changed to another member', () {
      state.setHead(team.id, 'A');
      state.setHead(team.id, 'B');
      expect(now().headId, 'B');
      expect(state.teamHeadedBy('A'), isNull);
    });

    test('clearing the head works', () {
      state.setHead(team.id, 'A');
      state.clearHead(team.id);
      expect(now().headId, isEmpty);
    });

    test('a person can lead only one team', () {
      final other = state.create('Sales')!;
      state.addMember(other.id, 'A');
      state.setHead(team.id, 'A');
      expect(state.setHead(other.id, 'A'), isFalse);
      expect(state.byId(other.id)!.headId, isEmpty);
      expect(state.teamHeadedBy('A')!.id, team.id);
    });
  });

  group('who can assign work', () {
    test('the head can assign to every member of the team', () {
      state.setHead(team.id, 'A');
      expect(state.canAssign('A', 'B'), isTrue);
      expect(state.canAssign('A', 'C'), isTrue);
      expect(state.canAssign('A', 'D'), isTrue);
    });

    test('a head cannot assign to someone outside the team', () {
      state.setHead(team.id, 'A');
      expect(state.canAssign('A', 'Z'), isFalse);
    });

    test('a plain member cannot assign to anyone', () {
      state.setHead(team.id, 'A');
      expect(state.canAssign('B', 'C'), isFalse);
    });

    test('a team with no head lets nobody assign', () {
      expect(state.canAssign('A', 'B'), isFalse);
    });

    test('someone removed from the team can no longer be assigned to', () {
      state.setHead(team.id, 'A');
      state.removeMember(team.id, 'B');
      expect(state.canAssign('A', 'B'), isFalse);
    });

    test('a head who is removed can no longer assign', () {
      state.setHead(team.id, 'A');
      state.removeMember(team.id, 'A');
      expect(state.canAssign('A', 'B'), isFalse);
    });
  });

  test('deleting a team removes it and its head rights', () {
    state.setHead(team.id, 'A');
    state.delete(team.id);
    expect(state.teams, isEmpty);
    expect(state.canAssign('A', 'B'), isFalse);
  });

  test('listeners hear about a change, but not about a refused one', () {
    var calls = 0;
    state.addListener(() => calls++);
    state.addMember(team.id, 'A'); // already in: refused
    expect(calls, 0);
    state.setHead(team.id, 'A');
    expect(calls, 1);
  });
}

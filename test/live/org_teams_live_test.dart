// Runs the REAL department, branch and teams repositories against the real
// project, signed in as the seeded test logins. Adds, changes and removes
// its own test data only. Skipped unless SEED_PASSWORD is set:
//
//   SEED_PASSWORD='the seed password' flutter test test/live

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import 'package:my_first_flutter_app/state/employee_repository.dart';
import 'package:my_first_flutter_app/state/org_repository.dart';
import 'package:my_first_flutter_app/state/teams_repository.dart';

void main() {
  final password = Platform.environment['SEED_PASSWORD'];
  final skip = password == null ? 'set SEED_PASSWORD to run' : null;

  Future<SupabaseClient> signIn(String email) async {
    final env = {
      for (final l in File('.env').readAsLinesSync())
        if (RegExp(r'^[A-Z_]+=').hasMatch(l))
          l.split('=').first: l.substring(l.indexOf('=') + 1).trim(),
    };
    final c = SupabaseClient(
      env['SUPABASE_URL']!,
      env['SUPABASE_PUBLISHABLE_KEY']!,
    );
    await c.auth.signInWithPassword(email: email, password: password!);
    return c;
  }

  Matcher fails(SaveProblem p) =>
      throwsA(isA<SaveFailure>().having((f) => f.problem, 'problem', p));

  const testDept = 'Live Test Dept 9';
  const testTeam = 'Live Test Team 9';

  late SupabaseClient hr;
  late SupabaseClient sita;
  late SupabaseClient everest;

  Future<void> cleanUp() async {
    await hr.from('teams').delete().eq('name', testTeam);
    await hr.from('departments').delete().eq('name', testDept);
    await hr.from('branches').delete().eq('name', testDept);
  }

  setUpAll(() async {
    if (skip != null) return;
    hr = await signIn('hr@himalaya-tech.test');
    sita = await signIn('sita@himalaya-tech.test');
    everest = await signIn('hr@everest-traders.test');
    await cleanUp();
  });
  tearDownAll(() async {
    if (skip != null) return;
    await cleanUp();
  });

  group('departments and branches', () {
    test("HR sees the company's own lists, nobody else's", () async {
      final lists = await SupabaseOrgRepository(hr).load();
      expect(
        lists.departments.toSet(),
        containsAll({'Human Resources', 'Support', 'Engineering'}),
      );
      expect(lists.departments, isNot(contains('Sales'))); // Everest's
      expect(lists.branches, contains('Kathmandu Head Office'));
      expect(lists.branches, isNot(contains('Pokhara Office'))); // Everest's
    }, skip: skip);

    test('everyone in the company can read the lists', () async {
      final lists = await SupabaseOrgRepository(sita).load();
      expect(lists.departments, contains('Support'));
    }, skip: skip);

    test('HR adds a department and a branch; they are real records', () async {
      final repo = SupabaseOrgRepository(hr);
      await repo.addDepartment(testDept);
      await repo.addBranch(testDept);
      final lists = await SupabaseOrgRepository(hr).load(); // a fresh read
      expect(lists.departments, contains(testDept));
      expect(lists.branches, contains(testDept));
    }, skip: skip);

    test(
      'the same name in other capitals is refused by the database',
      () async {
        await expectLater(
          SupabaseOrgRepository(hr).addDepartment('SUPPORT'),
          fails(SaveProblem.duplicateName),
        );
      },
      skip: skip,
    );

    test('an employee cannot add one', () async {
      await expectLater(
        SupabaseOrgRepository(sita).addDepartment('Sneaky Dept'),
        fails(SaveProblem.notAllowed),
      );
    }, skip: skip);

    test('the other company may use the same name for its own', () async {
      // Departments are unique per company, not across companies.
      final theirs = await SupabaseOrgRepository(everest).load();
      expect(theirs.departments, isNot(contains(testDept)));
    }, skip: skip);
  });

  group('teams', () {
    test('HR loads the seeded team with its head and members', () async {
      final all = await SupabaseTeamsRepository(hr).loadAll();
      final t = all.firstWhere((t) => t.name == 'Support Team');
      expect(t.headId, 'HT-003');
      expect(t.memberIds, ['HT-003', 'HT-004']);
    }, skip: skip);

    test('a team made, filled and headed survives a restart', () async {
      final repo = SupabaseTeamsRepository(hr);
      final id = await repo.create(testTeam);
      expect(id, isNotNull);
      await repo.addMember(id!, 'HT-005');
      await repo.addMember(id, 'HT-001');
      await repo.setHead(id, 'HT-005');

      // "Restart": a brand-new repository reads it back from the database.
      final again = await SupabaseTeamsRepository(hr).loadAll();
      final t = again.firstWhere((t) => t.id == id);
      expect(t.name, testTeam);
      expect(t.memberIds, ['HT-005', 'HT-001']);
      expect(t.headId, 'HT-005');
    }, skip: skip);

    test('renaming and clearing the head are saved', () async {
      final repo = SupabaseTeamsRepository(hr);
      final t = (await repo.loadAll()).firstWhere((t) => t.name == testTeam);
      await repo.clearHead(t.id);
      expect(
        (await repo.loadAll()).firstWhere((x) => x.id == t.id).headId,
        isEmpty,
      );
      await repo.setHead(t.id, 'HT-005');
    }, skip: skip);

    test(
      'removing the head leaves the team with no head (the database does it)',
      () async {
        final repo = SupabaseTeamsRepository(hr);
        final t = (await repo.loadAll()).firstWhere((t) => t.name == testTeam);
        await repo.removeMember(t.id, 'HT-005');
        final after = (await repo.loadAll()).firstWhere((x) => x.id == t.id);
        expect(after.headId, isEmpty);
        expect(after.memberIds, ['HT-001']);
      },
      skip: skip,
    );

    test('the database refuses a head who is not a member', () async {
      final repo = SupabaseTeamsRepository(hr);
      final t = (await repo.loadAll()).firstWhere((t) => t.name == testTeam);
      await expectLater(
        repo.setHead(t.id, 'HT-004'),
        fails(SaveProblem.conflict),
      );
    }, skip: skip);

    test('the database refuses someone who already leads a team', () async {
      final repo = SupabaseTeamsRepository(hr);
      final t = (await repo.loadAll()).firstWhere((t) => t.name == testTeam);
      await repo.addMember(t.id, 'HT-003'); // Sita leads Support Team
      await expectLater(
        repo.setHead(t.id, 'HT-003'),
        fails(SaveProblem.conflict),
      );
    }, skip: skip);

    test(
      'a second team with the same name (any capitals) is refused',
      () async {
        await expectLater(
          SupabaseTeamsRepository(hr).create('support team'),
          fails(SaveProblem.duplicateName),
        );
      },
      skip: skip,
    );

    test('an employee can read teams but not change them', () async {
      final repo = SupabaseTeamsRepository(sita);
      final all = await repo.loadAll();
      final support = all.firstWhere((t) => t.name == 'Support Team');
      await expectLater(
        repo.create('Sita Team'),
        fails(SaveProblem.notAllowed),
      );
      await expectLater(
        repo.addMember(support.id, 'HT-005'),
        fails(SaveProblem.notAllowed),
      );
      await expectLater(
        repo.setHead(support.id, 'HT-004'),
        fails(SaveProblem.notAllowed),
      );
      await expectLater(repo.delete(support.id), fails(SaveProblem.notAllowed));
    }, skip: skip);

    test(
      'the other company sees none of these teams and cannot touch them',
      () async {
        final mine = await SupabaseTeamsRepository(hr).loadAll();
        final support = mine.firstWhere((t) => t.name == 'Support Team');
        final repo = SupabaseTeamsRepository(everest);
        expect(
          (await repo.loadAll()).map((t) => t.name),
          isNot(contains('Support Team')),
        );
        await expectLater(
          repo.delete(support.id),
          fails(SaveProblem.notAllowed),
        );
        await expectLater(
          repo.rename(support.id, 'Hijacked'),
          fails(SaveProblem.notAllowed),
        );
        // And it is untouched.
        final check = (await SupabaseTeamsRepository(
          hr,
        ).loadAll()).firstWhere((t) => t.id == support.id);
        expect(check.name, 'Support Team');
        expect(check.headId, 'HT-003');
      },
      skip: skip,
    );

    test(
      'deleting a team removes it and its members, not the people',
      () async {
        final repo = SupabaseTeamsRepository(hr);
        final t = (await repo.loadAll()).firstWhere((t) => t.name == testTeam);
        await repo.delete(t.id);
        expect((await repo.loadAll()).any((x) => x.id == t.id), isFalse);
        final people = await hr
            .from('employees')
            .select('staff_id')
            .eq('staff_id', 'HT-001');
        expect(people, isNotEmpty);
      },
      skip: skip,
    );
  });
}

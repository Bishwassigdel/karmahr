// Runs the REAL SupabaseEmployeeRepository against the real project, signed
// in as the seeded test logins (supabase/seed/dev_seed.sql). It adds a test
// employee, edits and deactivates them, tries the things each role must not
// be able to do, then removes everything it made.
//
// Skipped unless a password is given, so normal test runs and CI ignore it:
//
//   SEED_PASSWORD='the seed password' flutter test test/live
//
// It needs the project URL and publishable key from .env.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import 'package:my_first_flutter_app/state/employee_records_state.dart';
import 'package:my_first_flutter_app/state/employee_repository.dart';
import 'package:my_first_flutter_app/state/supabase_employee_repository.dart';

import '../helpers/fake_employee_repository.dart' show person;

void main() {
  final password = Platform.environment['SEED_PASSWORD'];
  final skip = password == null ? 'set SEED_PASSWORD to run' : null;

  Map<String, String> env() => {
    for (final l in File('.env').readAsLinesSync())
      if (RegExp(r'^[A-Z_]+=').hasMatch(l))
        l.split('=').first: l.substring(l.indexOf('=') + 1).trim(),
  };

  Future<(SupabaseClient, SupabaseEmployeeRepository)> signIn(
    String email,
  ) async {
    final e = env();
    final client = SupabaseClient(
      e['SUPABASE_URL']!,
      e['SUPABASE_PUBLISHABLE_KEY']!,
    );
    await client.auth.signInWithPassword(email: email, password: password!);
    return (client, SupabaseEmployeeRepository(client));
  }

  const hrA = 'hr@himalaya-tech.test';
  const hrB = 'hr@everest-traders.test';
  const sita = 'sita@himalaya-tech.test';
  const testId = 'HT-LIVE-1';
  const testDept = 'Live Test Department';

  late SupabaseClient hrClient;
  late SupabaseEmployeeRepository hrRepo;

  Future<void> cleanUp() async {
    await hrClient.from('employees').delete().eq('staff_id', testId);
    await hrClient.from('employees').delete().eq('staff_id', 'HT-LIVE-2');
    await hrClient.from('departments').delete().eq('name', testDept);
  }

  setUpAll(() async {
    if (skip != null) return;
    (hrClient, hrRepo) = await signIn(hrA);
    await cleanUp(); // in case an earlier run stopped half-way
  });
  tearDownAll(() async {
    if (skip != null) return;
    await cleanUp();
  });

  group('HR of Himalaya', () {
    test(
      'loads the company with names, departments, managers and pay',
      () async {
        final all = await hrRepo.loadAll();
        final byId = {for (final r in all) r.id: r};
        // The seeded people (HR may have added more while testing the app).
        expect(
          all.map((r) => r.name),
          containsAll([
            'Hari Hr',
            'Eka Exec',
            'Sita Employee',
            'Ram Employee',
            'Gita Employee',
          ]),
        );
        expect(all.map((r) => r.name), isNot(contains('Mina Employee')));
        final s = byId['HT-003']!;
        expect(s.department, 'Support');
        expect(s.manager, 'Hari Hr');
        expect(s.basicSalary, 30000);
        expect(s.joiningDate, DateTime(2025, 3, 1));
        expect(s.isActive, isTrue);
      },
      skip: skip,
    );

    test(
      'adds an employee, with a brand-new department made on the way',
      () async {
        final record = person(
          'HT-LIVE-1',
          'Live Test Person',
          department: testDept,
          manager: 'Hari Hr',
          email: 'live.test@himalaya-tech.test',
        );
        await hrRepo.insert(record);

        final saved = (await hrRepo.loadAll()).firstWhere(
          (r) => r.id == testId,
        );
        expect(saved.name, 'Live Test Person');
        expect(saved.department, testDept);
        expect(saved.manager, 'Hari Hr');
        expect(saved.basicSalary, 30000);
      },
      skip: skip,
    );

    test(
      'a department typed in other capitals reuses the existing one',
      () async {
        await hrRepo.update(
          (await hrRepo.loadAll())
              .firstWhere((r) => r.id == testId)
              .copyWith(department: 'support'),
        );
        final saved = (await hrRepo.loadAll()).firstWhere(
          (r) => r.id == testId,
        );
        expect(saved.department, 'Support'); // the one that already existed
        final count = await hrClient
            .from('departments')
            .select('id')
            .ilike('name', 'support');
        expect(count.length, 1, reason: 'no duplicate department was made');
      },
      skip: skip,
    );

    test('edits an employee', () async {
      final r = (await hrRepo.loadAll()).firstWhere((r) => r.id == testId);
      await hrRepo.update(
        r.copyWith(jobTitle: 'Live Test Lead', basicSalary: 41000),
      );
      final saved = (await hrRepo.loadAll()).firstWhere((r) => r.id == testId);
      expect(saved.jobTitle, 'Live Test Lead');
      expect(saved.basicSalary, 41000);
    }, skip: skip);

    test('deactivates and reactivates', () async {
      await hrRepo.setStatus(testId, EmploymentStatus.inactive);
      expect(
        (await hrRepo.loadAll()).firstWhere((r) => r.id == testId).isActive,
        isFalse,
      );
      await hrRepo.setStatus(testId, EmploymentStatus.active);
      expect(
        (await hrRepo.loadAll()).firstWhere((r) => r.id == testId).isActive,
        isTrue,
      );
    }, skip: skip);

    test('a taken Staff ID is refused with the right reason', () async {
      await expectLater(
        hrRepo.insert(person('HT-003', 'Imposter', email: 'imposter@test.com')),
        throwsA(
          isA<SaveFailure>().having(
            (f) => f.problem,
            'problem',
            SaveProblem.duplicateStaffId,
          ),
        ),
      );
    }, skip: skip);

    test('a taken email is refused with the right reason', () async {
      await expectLater(
        hrRepo.insert(
          person('HT-LIVE-2', 'Imposter', email: 'sita@himalaya-tech.test'),
        ),
        throwsA(
          isA<SaveFailure>().having(
            (f) => f.problem,
            'problem',
            SaveProblem.duplicateEmail,
          ),
        ),
      );
    }, skip: skip);

    test('an import is all or nothing', () async {
      await expectLater(
        hrRepo.insertMany([
          person('HT-LIVE-2', 'Fine Person', email: 'fine@himalaya-tech.test'),
          person('HT-003', 'Clashes', email: 'clash@test.com'), // taken ID
        ]),
        throwsA(isA<SaveFailure>()),
      );
      final all = await hrRepo.loadAll();
      expect(
        all.any((r) => r.id == 'HT-LIVE-2'),
        isFalse,
        reason: 'the good row must not be saved alone',
      );
    }, skip: skip);
  });

  group('an ordinary employee (Sita)', () {
    late SupabaseEmployeeRepository repo;
    setUpAll(() async {
      if (skip != null) return;
      (_, repo) = await signIn(sita);
    });

    test('sees every colleague, but pay only on their own record', () async {
      final all = await repo.loadAll();
      expect(
        all.map((r) => r.name),
        containsAll(['Hari Hr', 'Ram Employee', 'Sita Employee']),
      );
      expect(all.firstWhere((r) => r.id == 'HT-003').basicSalary, 30000); // own
      expect(
        all.firstWhere((r) => r.id == 'HT-004').basicSalary,
        0,
        reason: "Ram's pay hidden",
      );
      expect(
        all.firstWhere((r) => r.id == 'HT-001').basicSalary,
        0,
        reason: "Hari's pay hidden",
      );
    }, skip: skip);

    test('still gets department and manager names for colleagues', () async {
      final ram = (await repo.loadAll()).firstWhere((r) => r.id == 'HT-004');
      expect(ram.department, 'Support');
      expect(ram.manager, 'Hari Hr');
    }, skip: skip);

    test('cannot add an employee', () async {
      await expectLater(
        repo.insert(person('HT-LIVE-2', 'Sneaky', email: 'sneaky@test.com')),
        throwsA(
          isA<SaveFailure>().having(
            (f) => f.problem,
            'problem',
            SaveProblem.notAllowed,
          ),
        ),
      );
    }, skip: skip);

    test('cannot change a colleague, or give themselves a raise', () async {
      final ram = (await repo.loadAll()).firstWhere((r) => r.id == 'HT-004');
      await expectLater(
        repo.update(ram.copyWith(jobTitle: 'Hacked')),
        throwsA(
          isA<SaveFailure>().having(
            (f) => f.problem,
            'problem',
            SaveProblem.notAllowed,
          ),
        ),
      );
      final me = (await repo.loadAll()).firstWhere((r) => r.id == 'HT-003');
      await expectLater(
        repo.update(me.copyWith(basicSalary: 999999)),
        throwsA(isA<SaveFailure>()),
      );
      await expectLater(
        repo.setStatus('HT-004', EmploymentStatus.inactive),
        throwsA(
          isA<SaveFailure>().having(
            (f) => f.problem,
            'problem',
            SaveProblem.notAllowed,
          ),
        ),
      );
      // And nothing changed.
      final check = await hrRepo.loadAll();
      expect(
        check.firstWhere((r) => r.id == 'HT-004').jobTitle,
        'Support Agent',
      );
      expect(check.firstWhere((r) => r.id == 'HT-003').basicSalary, 30000);
      expect(check.firstWhere((r) => r.id == 'HT-004').isActive, isTrue);
    }, skip: skip);
  });

  group('HR of the other company (Everest)', () {
    late SupabaseEmployeeRepository repo;
    setUpAll(() async {
      if (skip != null) return;
      (_, repo) = await signIn(hrB);
    });

    test('sees only their own company', () async {
      final all = await repo.loadAll();
      expect(all.map((r) => r.name).toSet(), {'Binod Hr', 'Mina Employee'});
    }, skip: skip);

    test('cannot touch the other company\'s people', () async {
      final fake = person('HT-003', 'Takeover', department: 'Support');
      await expectLater(
        repo.update(fake),
        throwsA(
          isA<SaveFailure>().having(
            (f) => f.problem,
            'problem',
            SaveProblem.notAllowed,
          ),
        ),
      );
      await expectLater(
        repo.setStatus('HT-004', EmploymentStatus.inactive),
        throwsA(isA<SaveFailure>()),
      );
      final check = await hrRepo.loadAll();
      expect(check.firstWhere((r) => r.id == 'HT-003').name, 'Sita Employee');
      expect(check.firstWhere((r) => r.id == 'HT-004').isActive, isTrue);
    }, skip: skip);

    test('a Staff ID used in the other company is free here', () async {
      // Staff IDs are unique per company, so Everest may use HT-LIVE-1 too.
      await repo.insert(
        person(
          'HT-LIVE-1',
          'Everest Person',
          department: 'Sales',
          email: 'ep@everest-traders.test',
        ),
      );
      final theirs = (await repo.loadAll()).firstWhere(
        (r) => r.id == 'HT-LIVE-1',
      );
      expect(theirs.name, 'Everest Person');
      // ...and it is not the Himalaya one.
      final ours = (await hrRepo.loadAll()).firstWhere(
        (r) => r.id == 'HT-LIVE-1',
      );
      expect(ours.name, 'Live Test Person');
      // Clean up Everest's test row (it is theirs, so use their client).
      final e = env();
      final c = SupabaseClient(
        e['SUPABASE_URL']!,
        e['SUPABASE_PUBLISHABLE_KEY']!,
      );
      await c.auth.signInWithPassword(email: hrB, password: password!);
      await c.from('employees').delete().eq('staff_id', 'HT-LIVE-1');
    }, skip: skip);
  });
}

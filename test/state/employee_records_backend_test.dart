import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_flutter_app/state/employee_records_state.dart';
import 'package:my_first_flutter_app/state/employee_repository.dart';

import '../helpers/fake_employee_repository.dart';

void main() {
  late FakeEmployeeRepository repo;
  late EmployeeRecordsState state;

  setUp(() {
    repo = FakeEmployeeRepository(
      stored: [person('HT-001', 'Hari Hr'), person('HT-002', 'Sita Employee')],
    );
    state = EmployeeRecordsState(repository: repo);
  });

  group('with a backend', () {
    test('starts empty: the demo people never mix with a real company', () {
      expect(state.records, isEmpty);
      expect(state.directory, isEmpty);
    });

    test('refresh loads the company\'s people', () async {
      await state.refresh();
      expect(state.records.map((r) => r.name), ['Hari Hr', 'Sita Employee']);
      expect(state.directory.length, 2);
      expect(state.loadFailed, isFalse);
      expect(state.isLoading, isFalse);
    });

    test(
      'refresh replaces the list, so a person added elsewhere appears',
      () async {
        await state.refresh();
        repo.stored.add(person('HT-003', 'Ram Employee')); // another device
        await state.refresh();
        expect(state.records.length, 3);
        expect(state.byId('HT-003')?.name, 'Ram Employee');
      },
    );

    test('refresh drops someone removed elsewhere', () async {
      await state.refresh();
      repo.stored.removeWhere((r) => r.id == 'HT-002');
      await state.refresh();
      expect(state.byId('HT-002'), isNull);
    });

    test(
      'isLoading is true while loading, and listeners hear both ends',
      () async {
        final gate = repo.loadGate = Completer<void>();
        var heard = 0;
        state.addListener(() => heard++);
        final done = state.refresh();
        expect(state.isLoading, isTrue);
        gate.complete();
        await done;
        expect(state.isLoading, isFalse);
        expect(heard, greaterThanOrEqualTo(2));
      },
    );

    test('a failed load keeps what was on screen and says it failed', () async {
      await state.refresh();
      repo.failLoad = true;
      await state.refresh();
      expect(state.loadFailed, isTrue);
      expect(state.records.length, 2);
      expect(state.isLoading, isFalse);
    });

    test('the next load that works clears the failure', () async {
      repo.failLoad = true;
      await state.refresh();
      expect(state.loadFailed, isTrue);
      repo.failLoad = false;
      await state.refresh();
      expect(state.loadFailed, isFalse);
    });
  });

  group('saving', () {
    setUp(() async => state.refresh());

    test('a new person is saved first, then shown', () async {
      final failure = await state.addAndSave(person('HT-003', 'Ram Employee'));
      expect(failure, isNull);
      expect(repo.stored.map((r) => r.id), contains('HT-003'));
      expect(state.byId('HT-003'), isNotNull);
    });

    test('if the save fails, nothing appears on screen', () async {
      repo.failNextWrite = const SaveFailure(SaveProblem.network);
      final failure = await state.addAndSave(person('HT-003', 'Ram Employee'));
      expect(failure?.problem, SaveProblem.network);
      expect(state.byId('HT-003'), isNull);
      expect(repo.stored.length, 2);
    });

    test('each reason for failing is passed back as it was', () async {
      for (final p in SaveProblem.values) {
        repo.failNextWrite = SaveFailure(p);
        final failure = await state.addAndSave(person('HT-9', 'Nobody'));
        expect(failure?.problem, p);
      }
    });

    test('a taken Staff ID reloads, so the next try gets a free one', () async {
      repo.stored.add(person('HT-003', 'Added on another device'));
      final loadsBefore = repo.loads;
      repo.failNextWrite = const SaveFailure(SaveProblem.duplicateStaffId);
      await state.addAndSave(person('HT-003', 'Ram Employee'));
      await Future<void>.delayed(Duration.zero);
      expect(repo.loads, greaterThan(loadsBefore));
      expect(state.nextId(), 'HT-004');
    });

    test('other failures do not trigger a reload', () async {
      final loadsBefore = repo.loads;
      repo.failNextWrite = const SaveFailure(SaveProblem.duplicateEmail);
      await state.addAndSave(person('HT-003', 'Ram Employee'));
      await Future<void>.delayed(Duration.zero);
      expect(repo.loads, loadsBefore);
    });

    test('an edit is saved first, then shown', () async {
      final failure = await state.updateAndSave(
        state.byId('HT-002')!.copyWith(jobTitle: 'Team Lead'),
      );
      expect(failure, isNull);
      expect(
        repo.stored.firstWhere((r) => r.id == 'HT-002').jobTitle,
        'Team Lead',
      );
      expect(state.byId('HT-002')!.jobTitle, 'Team Lead');
    });

    test('a failed edit leaves the old details on screen', () async {
      repo.failNextWrite = const SaveFailure(SaveProblem.notAllowed);
      final failure = await state.updateAndSave(
        state.byId('HT-002')!.copyWith(jobTitle: 'Team Lead'),
      );
      expect(failure?.problem, SaveProblem.notAllowed);
      expect(state.byId('HT-002')!.jobTitle, 'Support Agent');
    });

    test('deactivating is saved first, then shown', () async {
      final failure = await state.setStatusAndSave(
        'HT-002',
        EmploymentStatus.inactive,
      );
      expect(failure, isNull);
      expect(repo.calls, contains('setStatus HT-002 inactive'));
      expect(state.byId('HT-002')!.isActive, isFalse);
      expect(
        state.directory.map((e) => e.name),
        isNot(contains('Sita Employee')),
      );
    });

    test('a failed deactivation leaves the person active', () async {
      repo.failNextWrite = const SaveFailure(SaveProblem.network);
      final failure = await state.setStatusAndSave(
        'HT-002',
        EmploymentStatus.inactive,
      );
      expect(failure, isNotNull);
      expect(state.byId('HT-002')!.isActive, isTrue);
    });
  });

  group('importing from a spreadsheet', () {
    const csv =
        '''Name,Job title,Department,Email,Phone,Basic,Dearness,Transport
Nima Sherpa,Designer,Product,nima@test.com,9841234567,50000,5000,3000
Pema Lama,Analyst,Finance,pema@test.com,9851234567,48000,4000,2000
Bad Row,Only,Three''';

    setUp(() async => state.refresh());

    test(
      'good rows are saved together, in one go, with consecutive IDs',
      () async {
        final r = await state.importCsvAndSave(csv);
        expect(r.failure, isNull);
        expect(r.result.added, 2);
        expect(r.result.skipped.length, 1);
        expect(repo.calls.last, 'insertMany HT-003,HT-004');
        expect(state.byId('HT-003')!.name, 'Nima Sherpa');
        expect(state.byId('HT-004')!.name, 'Pema Lama');
      },
    );

    test('if saving fails, none of them is added', () async {
      repo.failNextWrite = const SaveFailure(SaveProblem.network);
      final r = await state.importCsvAndSave(csv);
      expect(r.failure?.problem, SaveProblem.network);
      expect(r.result.added, 0);
      expect(r.result.skipped.length, 1); // the bad row is still reported
      expect(state.records.length, 2);
      expect(repo.stored.length, 2);
    });

    test('a spreadsheet with no good rows saves nothing at all', () async {
      final r = await state.importCsvAndSave('Name,Job title\nOnly,Two');
      expect(r.result.added, 0);
      expect(r.failure, isNull);
      expect(repo.calls.where((c) => c.startsWith('insertMany')), isEmpty);
    });
  });

  group('signing out', () {
    test('forgets every record, so the next person never sees them', () async {
      await state.refresh();
      expect(state.records, isNotEmpty);
      state.clearForSignOut();
      expect(state.records, isEmpty);
      expect(state.directory, isEmpty);
    });

    test('a load still on its way cannot bring the old company back', () async {
      final gate = repo.loadGate = Completer<void>();
      final slow = state.refresh();
      state.clearForSignOut(); // they log out while it loads
      gate.complete();
      await slow;
      expect(state.records, isEmpty);
      expect(state.isLoading, isFalse);
    });

    test('the demo keeps its people (company data is not per-user)', () {
      final demo = EmployeeRecordsState();
      final before = demo.records.length;
      demo.clearForSignOut();
      expect(demo.records.length, before);
      expect(before, greaterThan(0));
    });
  });

  group('the demo (no backend)', () {
    test('refresh does nothing and the saving methods still work', () async {
      final demo = EmployeeRecordsState();
      final before = demo.records.length;
      await demo.refresh();
      expect(demo.records.length, before);
      expect(demo.isLoading, isFalse);

      final failure = await demo.addAndSave(
        person(demo.nextId(), 'Demo Person'),
      );
      expect(failure, isNull);
      expect(demo.records.length, before + 1);
    });
  });

  group('the next Staff ID keeps the company\'s own style', () {
    test('a company numbering HT-005 gets HT-006, keeping the zeros', () async {
      repo.stored.add(person('HT-005', 'Gita Employee'));
      await state.refresh();
      expect(state.nextId(), 'HT-006');
    });

    test('five-digit demo IDs still count up as before', () {
      expect(EmployeeRecordsState().nextId(), 'MB-24072');
    });

    test('an empty company starts at MB-1', () {
      expect(state.nextId(), 'MB-1');
    });

    test('a batch about to be added is counted too', () async {
      await state.refresh();
      expect(
        state.nextId([person('HT-003', 'A'), person('HT-004', 'B')]),
        'HT-005',
      );
    });

    test('IDs without a dash or number do not break it', () async {
      repo.stored.add(person('legacy', 'Old Record'));
      await state.refresh();
      expect(state.nextId(), 'HT-003');
    });
  });
}

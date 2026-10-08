import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_flutter_app/data/current_employee.dart';
import 'package:my_first_flutter_app/domain/nepal/tax_slabs.dart';
import 'package:my_first_flutter_app/state/employee_records_state.dart';

EmployeeRecord _record(String id, {String name = 'Test Person'}) {
  return EmployeeRecord(
    id: id,
    name: name,
    jobTitle: 'Analyst',
    department: 'Finance',
    manager: '',
    joiningDate: DateTime(2025, 1, 1),
    employmentType: 'Full-Time',
    workLocation: 'Kathmandu Head Office',
    email: 'test@karmahr.com',
    phone: '+977 9812345678',
    basicSalary: 40000,
    dearnessAllowance: 4000,
    transportAllowance: 2000,
    filingStatus: FilingStatus.single,
  );
}

void main() {
  group('EmployeeRecordsState', () {
    test('starts with active and inactive employees', () {
      final state = EmployeeRecordsState();
      expect(state.records.length, 9);
      expect(state.active.length, 8);
    });

    test("the signed-in demo employee's record matches his profile", () {
      final record = EmployeeRecordsState().byId(currentEmployee.employeeId)!;
      expect(record.name, currentEmployee.name);
      expect(record.basicSalary, currentEmployee.basicSalary);
      expect(record.dearnessAllowance, currentEmployee.dearnessAllowance);
      expect(record.transportAllowance, currentEmployee.transportAllowance);
      expect(record.grossMonthly, currentEmployee.grossMonthly);
    });

    test('add puts the person in the directory and notifies', () {
      final state = EmployeeRecordsState();
      var notified = 0;
      state.addListener(() => notified++);

      state.add(_record('MB-99999', name: 'Nima Sherpa'));

      expect(state.byId('MB-99999'), isNotNull);
      expect(state.directory.any((e) => e.name == 'Nima Sherpa'), isTrue);
      expect(notified, 1);
    });

    test('nextId is one more than the highest number in use', () {
      final state = EmployeeRecordsState();
      state.add(_record('MB-30000'));
      expect(state.nextId(), 'MB-30001');
    });

    test('deactivating removes from the directory, keeps the record', () {
      final state = EmployeeRecordsState();
      final before = state.directory.length;

      state.setStatus('MB-24071', EmploymentStatus.inactive);

      expect(state.directory.length, before - 1);
      expect(state.byId('MB-24071')!.isActive, isFalse);
      expect(state.records.length, 9);

      state.setStatus('MB-24071', EmploymentStatus.active);
      expect(state.directory.length, before);
    });

    test('update replaces the record in place', () {
      final state = EmployeeRecordsState();
      final original = state.byId('MB-24071')!;
      state.update(original.copyWith(jobTitle: 'HR Lead'));

      expect(state.byId('MB-24071')!.jobTitle, 'HR Lead');
      expect(state.records.length, 9);
      expect(state.byId('MB-24071')!.id, 'MB-24071');
    });

    test('directory hands out the same objects between changes', () {
      final state = EmployeeRecordsState();
      expect(identical(state.directory.first, state.directory.first), isTrue);
      expect(identical(state.directory, state.directory), isTrue);
    });

    test('setting the same status again does not notify', () {
      final state = EmployeeRecordsState();
      var notified = 0;
      state.addListener(() => notified++);
      state.setStatus('MB-24071', EmploymentStatus.active);
      expect(notified, 0);
    });

    test('initials come from the first two words of the name', () {
      expect(_record('x', name: 'Suresh Karki').initials, 'SK');
      expect(_record('x', name: '  nima  ').initials, 'N');
      expect(_record('x', name: 'A B C').initials, 'AB');
    });
  });

  group('importCsv', () {
    const good =
        'Nima Sherpa,Designer,Product,nima@karmahr.com,9841234567,50000,5000,3000';

    test('adds each good row as an active employee with a fresh ID', () {
      final state = EmployeeRecordsState();
      final result = state.importCsv(
        '$good\nAsha Rai,Analyst,Finance,asha@karmahr.com,9851234567,40000,0,0',
      );

      expect(result.added, 2);
      expect(result.skipped, isEmpty);
      expect(state.records.length, 11);
      final nima = state.records.firstWhere((r) => r.name == 'Nima Sherpa');
      expect(nima.isActive, isTrue);
      expect(nima.grossMonthly, 58000);
      expect(
        nima.id,
        isNot(state.records.firstWhere((r) => r.name == 'Asha Rai').id),
      );
    });

    test('a header row is skipped', () {
      final state = EmployeeRecordsState();
      final result = state.importCsv(
        'Name,Job title,Department,Email,Phone,Basic,DA,Transport\n$good',
      );
      expect(result.added, 1);
      expect(result.skipped, isEmpty);
    });

    test('tabs (a spreadsheet paste) work like commas', () {
      final state = EmployeeRecordsState();
      final result = state.importCsv(good.replaceAll(',', '\t'));
      expect(result.added, 1);
    });

    test('a quoted cell can hold a comma', () {
      final state = EmployeeRecordsState();
      state.importCsv(
        '"Sherpa, Nima",Designer,Product,nima@karmahr.com,9841234567,50000,0,0',
      );
      expect(state.records.any((r) => r.name == 'Sherpa, Nima'), isTrue);
    });

    test('blank lines and Windows line endings are fine', () {
      final state = EmployeeRecordsState();
      final result = state.importCsv('\r\n$good\r\n\r\n');
      expect(result.added, 1);
    });

    test('bad rows are skipped with their line number and reason, good ones still go in', () {
      final state = EmployeeRecordsState();
      final result = state.importCsv(
        [
          good, // line 1: fine
          'Too,Few,Columns', // line 2
          ',Designer,Product,a@b.com,9841234567,50000,0,0', // 3: no name
          'A,,Product,a@b.com,9841234567,50000,0,0', // 4: no job
          'A,Job,Dept,not-an-email,9841234567,50000,0,0', // 5
          'A,Job,Dept,a@b.com,12345,50000,0,0', // 6: phone
          'A,Job,Dept,a@b.com,9841234567,0,0,0', // 7: salary
          'A,Job,Dept,a@b.com,9841234567,50000,abc,0', // 8: allowance
        ].join('\n'),
      );

      expect(result.added, 1);
      expect(
        [for (final s in result.skipped) (s.line, s.problem)],
        [
          (2, ImportProblem.columns),
          (3, ImportProblem.name),
          (4, ImportProblem.job),
          (5, ImportProblem.email),
          (6, ImportProblem.phone),
          (7, ImportProblem.salary),
          (8, ImportProblem.salary),
        ],
      );
    });

    test('if nothing is valid, nothing changes and nobody is told', () {
      final state = EmployeeRecordsState();
      var notified = 0;
      state.addListener(() => notified++);
      final result = state.importCsv('garbage');
      expect(result.added, 0);
      expect(state.records.length, 9);
      expect(notified, 0);
    });

    test('the people added show up in the directory', () {
      final state = EmployeeRecordsState();
      state.importCsv(good);
      expect(state.directory.any((e) => e.name == 'Nima Sherpa'), isTrue);
    });

    test('everyone is dated as joining on the given day', () {
      final state = EmployeeRecordsState();
      state.importCsv(good, today: DateTime(2026, 10, 5, 17));
      final nima = state.records.firstWhere((r) => r.name == 'Nima Sherpa');
      expect(nima.joiningDate, DateTime(2026, 10, 5));
    });
  });
}

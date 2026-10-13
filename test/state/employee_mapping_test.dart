import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_flutter_app/domain/nepal/tax_slabs.dart';
import 'package:my_first_flutter_app/state/employee_mapping.dart';
import 'package:my_first_flutter_app/state/employee_records_state.dart';

void main() {
  // A full `employees` row, as the database sends it.
  Map<String, dynamic> row() => {
    'id': 'uuid-1',
    'staff_id': 'HT-003',
    'name': 'Sita Employee',
    'job_title': 'Support Agent',
    'department_id': 'd-1',
    'manager_id': 'uuid-0',
    'joining_date': '2025-03-01',
    'employment_type': 'Full-Time',
    'work_location': 'Kathmandu',
    'email': 'sita@test.com',
    'phone': '9841234567',
    'basic_salary': 30000,
    'dearness_allowance': 2000.5,
    'transport_allowance': '1000.00', // text, as some drivers send numerics
    'filing_status': 'married',
    'status': 'inactive',
    'bank_name': 'NIC Asia',
    'account_number': '12345',
  };

  group('rowToRecord', () {
    test('a full row becomes the matching record', () {
      final r = rowToRecord(row(), department: 'Support', manager: 'Hari Hr');
      expect(r.id, 'HT-003'); // the Staff ID, not the database uuid
      expect(r.name, 'Sita Employee');
      expect(r.department, 'Support');
      expect(r.manager, 'Hari Hr');
      expect(r.joiningDate, DateTime(2025, 3, 1));
      expect(r.filingStatus, FilingStatus.married);
      expect(r.status, EmploymentStatus.inactive);
      expect(r.bankName, 'NIC Asia');
      expect(r.accountNumber, '12345');
    });

    test('pay arrives as a whole number, a decimal or text', () {
      final r = rowToRecord(row());
      expect(r.basicSalary, 30000);
      expect(r.dearnessAllowance, 2000.5);
      expect(r.transportAllowance, 1000);
      expect(r.grossMonthly, 33000.5);
    });

    test(
      'a colleague-directory row (no pay) gives zero pay, never an error',
      () {
        final directoryRow = {
          'id': 'uuid-2',
          'staff_id': 'HT-004',
          'name': 'Ram Employee',
          'job_title': 'Support Agent',
          'department_id': 'd-1',
          'manager_id': null,
          'joining_date': '2025-06-16',
          'employment_type': 'Full-Time',
          'work_location': 'Kathmandu',
          'email': 'ram@test.com',
          'phone': '',
          'status': 'active',
        };
        final r = rowToRecord(directoryRow);
        expect(r.basicSalary, 0);
        expect(r.grossMonthly, 0);
        expect(r.filingStatus, FilingStatus.single);
        expect(r.bankName, isEmpty);
        expect(r.manager, isEmpty);
        expect(r.isActive, isTrue);
      },
    );

    test('missing optional text becomes empty, not null', () {
      final r = rowToRecord({
        ...row(),
        'work_location': null,
        'email': null,
        'phone': null,
        'bank_name': null,
      });
      expect(r.workLocation, isEmpty);
      expect(r.email, isEmpty);
      expect(r.phone, isEmpty);
      expect(r.bankName, isEmpty);
    });

    test('an unknown filing status or status falls back safely', () {
      final r = rowToRecord({...row(), 'filing_status': 'x', 'status': 'x'});
      expect(r.filingStatus, FilingStatus.single);
      expect(r.status, EmploymentStatus.active);
    });
  });

  group('recordToChanges and recordToNewRow', () {
    final record = rowToRecord(row(), department: 'Support', manager: 'Hari');

    test('every editable field is written, with the ids passed in', () {
      final c = recordToChanges(record, departmentId: 'd-9', managerId: 'm-9');
      expect(c['name'], 'Sita Employee');
      expect(c['department_id'], 'd-9');
      expect(c['manager_id'], 'm-9');
      expect(c['basic_salary'], 30000);
      expect(c['filing_status'], 'married');
      expect(c['status'], 'inactive');
      expect(c['account_number'], '12345');
    });

    test('the Staff ID and company are never part of an update', () {
      final c = recordToChanges(record, departmentId: null, managerId: null);
      expect(c.containsKey('staff_id'), isFalse);
      expect(c.containsKey('company_id'), isFalse);
      expect(c['department_id'], isNull);
      expect(c['manager_id'], isNull);
    });

    test('a new row adds the company and the Staff ID', () {
      final n = recordToNewRow(
        record,
        companyId: 'co-1',
        departmentId: null,
        managerId: null,
      );
      expect(n['company_id'], 'co-1');
      expect(n['staff_id'], 'HT-003');
      expect(n['name'], 'Sita Employee');
    });

    test('dates are written as year-month-day with leading zeros', () {
      final c = recordToChanges(
        record.copyWith(joiningDate: DateTime(2026, 1, 5)),
        departmentId: null,
        managerId: null,
      );
      expect(c['joining_date'], '2026-01-05');
    });

    test('a record survives the trip out and back', () {
      final out = recordToNewRow(
        record,
        companyId: 'co-1',
        departmentId: 'd-1',
        managerId: 'uuid-0',
      );
      final back = rowToRecord(out, department: 'Support', manager: 'Hari');
      expect(back.id, record.id);
      expect(back.name, record.name);
      expect(back.joiningDate, record.joiningDate);
      expect(back.basicSalary, record.basicSalary);
      expect(back.filingStatus, record.filingStatus);
      expect(back.status, record.status);
      expect(back.accountNumber, record.accountNumber);
    });
  });
}

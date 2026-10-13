// Turns an employee between the app's shape (EmployeeRecord) and a database
// row (the `employees` table), in plain Dart so it can be tested without a
// network.
//
// Two differences the app lives with for now:
//  - The app calls a person's department, branch (work location) and manager
//    by NAME; the database links them by id. The repository looks the ids up when saving, and the
//    names back up when loading.
//  - The app's record id is the Staff ID (e.g. "HT-003"); the database's own
//    id is a uuid the app never needs to see.

import '../domain/nepal/tax_slabs.dart' show FilingStatus;
import 'employee_records_state.dart';

/// The columns [rowToRecord] reads from a full `employees` row.
const employeeColumns =
    'id, staff_id, name, job_title, department_id, branch_id, manager_id, '
    'joining_date, '
    'employment_type, work_location, email, phone, basic_salary, '
    'dearness_allowance, transport_allowance, filing_status, status, '
    'bank_name, account_number';

/// A database row as an app record. [row] may be a full `employees` row or a
/// colleague-directory row (which has no pay, filing or bank columns: those
/// come out as zero, single and empty). [department], [manager] and
/// [branch] are the names already looked up from their ids; without a
/// branch, the row's own work_location text is used.
EmployeeRecord rowToRecord(
  Map<String, dynamic> row, {
  String department = '',
  String manager = '',
  String? branch,
}) {
  double money(Object? v) => switch (v) {
    num() => v.toDouble(),
    String() => double.tryParse(v) ?? 0,
    _ => 0,
  };
  String text(String key) => (row[key] as String?) ?? '';

  return EmployeeRecord(
    id: row['staff_id'] as String,
    name: row['name'] as String,
    jobTitle: row['job_title'] as String,
    department: department,
    manager: manager,
    joiningDate: DateTime.parse(row['joining_date'] as String),
    employmentType: text('employment_type'),
    workLocation: branch ?? text('work_location'),
    email: text('email'),
    phone: text('phone'),
    basicSalary: money(row['basic_salary']),
    dearnessAllowance: money(row['dearness_allowance']),
    transportAllowance: money(row['transport_allowance']),
    filingStatus: row['filing_status'] == 'married'
        ? FilingStatus.married
        : FilingStatus.single,
    status: row['status'] == 'inactive'
        ? EmploymentStatus.inactive
        : EmploymentStatus.active,
    bankName: text('bank_name'),
    accountNumber: text('account_number'),
  );
}

/// An app record as a database row. Everything except the company and the
/// Staff ID, which are fixed when a person is added.
Map<String, dynamic> recordToChanges(
  EmployeeRecord r, {
  required String? departmentId,
  required String? managerId,
  String? branchId,
}) {
  String two(int n) => n.toString().padLeft(2, '0');
  return {
    'name': r.name,
    'job_title': r.jobTitle,
    'department_id': departmentId,
    'manager_id': managerId,
    'branch_id': branchId,
    'joining_date':
        '${r.joiningDate.year}-${two(r.joiningDate.month)}-${two(r.joiningDate.day)}',
    'employment_type': r.employmentType,
    'work_location': r.workLocation,
    'email': r.email,
    'phone': r.phone,
    'basic_salary': r.basicSalary,
    'dearness_allowance': r.dearnessAllowance,
    'transport_allowance': r.transportAllowance,
    'filing_status': r.filingStatus == FilingStatus.married
        ? 'married'
        : 'single',
    'status': r.isActive ? 'active' : 'inactive',
    'bank_name': r.bankName,
    'account_number': r.accountNumber,
  };
}

/// A new person's full row: the changes plus company and Staff ID.
Map<String, dynamic> recordToNewRow(
  EmployeeRecord r, {
  required String companyId,
  required String? departmentId,
  required String? managerId,
  String? branchId,
}) => {
  'company_id': companyId,
  'staff_id': r.id,
  ...recordToChanges(
    r,
    departmentId: departmentId,
    managerId: managerId,
    branchId: branchId,
  ),
};

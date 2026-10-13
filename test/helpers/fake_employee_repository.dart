import 'dart:async';

import 'package:my_first_flutter_app/domain/nepal/tax_slabs.dart';
import 'package:my_first_flutter_app/state/employee_records_state.dart';
import 'package:my_first_flutter_app/state/employee_repository.dart';

/// A stand-in for the database: it keeps records in a list, so a test can
/// see what was "saved", and it can be told to fail or to wait.
class FakeEmployeeRepository implements EmployeeRepository {
  FakeEmployeeRepository({List<EmployeeRecord>? stored})
    : stored = stored ?? [];

  /// What the "database" holds.
  final List<EmployeeRecord> stored;

  /// When set, the next write throws this (then it is cleared).
  SaveFailure? failNextWrite;

  /// When true, loading throws.
  bool failLoad = false;

  /// When set, loading waits for it, so a test can interleave things.
  Completer<void>? loadGate;

  int loads = 0;
  final calls = <String>[];

  @override
  bool get usesBackend => true;

  @override
  Future<List<EmployeeRecord>> loadAll() async {
    loads++;
    await loadGate?.future;
    if (failLoad) throw Exception('offline');
    return List.of(stored);
  }

  void _maybeFail() {
    final f = failNextWrite;
    if (f != null) {
      failNextWrite = null;
      throw f;
    }
  }

  @override
  Future<void> insert(EmployeeRecord record) async {
    calls.add('insert ${record.id}');
    _maybeFail();
    stored.add(record);
  }

  @override
  Future<void> insertMany(List<EmployeeRecord> records) async {
    calls.add('insertMany ${records.map((r) => r.id).join(',')}');
    _maybeFail();
    stored.addAll(records);
  }

  @override
  Future<void> update(EmployeeRecord record) async {
    calls.add('update ${record.id}');
    _maybeFail();
    final i = stored.indexWhere((r) => r.id == record.id);
    if (i >= 0) stored[i] = record;
  }

  @override
  Future<void> setStatus(String employeeId, EmploymentStatus status) async {
    calls.add('setStatus $employeeId ${status.name}');
    _maybeFail();
    final i = stored.indexWhere((r) => r.id == employeeId);
    if (i >= 0) stored[i] = stored[i].copyWith(status: status);
  }
}

EmployeeRecord person(
  String id,
  String name, {
  String department = 'Support',
  String manager = '',
  EmploymentStatus status = EmploymentStatus.active,
  String email = '',
}) => EmployeeRecord(
  id: id,
  name: name,
  jobTitle: 'Support Agent',
  department: department,
  manager: manager,
  joiningDate: DateTime(2025, 3, 1),
  employmentType: 'Full-Time',
  workLocation: 'Kathmandu',
  email: email.isEmpty
      ? '${name.split(' ').first.toLowerCase()}@test.com'
      : email,
  phone: '9841234567',
  basicSalary: 30000,
  dearnessAllowance: 2000,
  transportAllowance: 1000,
  filingStatus: FilingStatus.single,
  status: status,
);

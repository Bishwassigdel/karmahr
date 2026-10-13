// Where employee records are stored, behind one interface.
//
// Two implementations:
//  - SupabaseEmployeeRepository: the company's real records in the database
//    (used when the app was started with keys, see config/env.dart)
//  - DemoEmployeeRepository: no storage; EmployeeRecordsState keeps its
//    built-in demo people (used by tests, CI and anyone running without .env)
//
// EmployeeRecordsState is still the one place screens read from. It asks the
// repository to load and save, and only changes what it shows once a save
// has really worked.

import 'employee_records_state.dart' show EmployeeRecord, EmploymentStatus;

/// Why a save didn't happen, so the screen can say something useful.
enum SaveProblem {
  /// Another employee already has this Staff ID (two people added at once).
  duplicateStaffId,

  /// Another employee already has this email.
  duplicateEmail,

  /// Something else already has this name (a team, a department...).
  duplicateName,

  /// Someone changed the same thing at the same moment, or it breaks a rule
  /// (e.g. a team head who is no longer a member). Reload and try again.
  conflict,

  /// The database refused: the signed-in person isn't allowed to do this.
  notAllowed,

  /// Couldn't reach the server, or something unexpected went wrong.
  network,
}

class SaveFailure implements Exception {
  final SaveProblem problem;

  const SaveFailure(this.problem);

  @override
  String toString() => 'SaveFailure($problem)';
}

abstract class EmployeeRepository {
  /// True when records live in a database. False means [EmployeeRecordsState]
  /// keeps its built-in demo records and nothing is loaded or saved.
  bool get usesBackend;

  /// Everyone in the signed-in person's company. Anyone can see their
  /// colleagues; only HR, Company Admin and Executive also get pay and bank
  /// details (the database decides, not the app). Throws on failure.
  Future<List<EmployeeRecord>> loadAll();

  /// The next four throw [SaveFailure] when the save doesn't happen.
  Future<void> insert(EmployeeRecord record);

  /// All or nothing: either every record is saved or none is.
  Future<void> insertMany(List<EmployeeRecord> records);

  Future<void> update(EmployeeRecord record);

  Future<void> setStatus(String employeeId, EmploymentStatus status);
}

/// Used when there is no backend: nothing to load, nothing to save.
class DemoEmployeeRepository implements EmployeeRepository {
  @override
  bool get usesBackend => false;

  @override
  Future<List<EmployeeRecord>> loadAll() async => const [];

  @override
  Future<void> insert(EmployeeRecord record) async {}

  @override
  Future<void> insertMany(List<EmployeeRecord> records) async {}

  @override
  Future<void> update(EmployeeRecord record) async {}

  @override
  Future<void> setStatus(String employeeId, EmploymentStatus status) async {}
}

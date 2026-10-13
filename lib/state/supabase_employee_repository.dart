// The company's employee records, in Supabase. See employee_repository.dart.
//
// Row Level Security (Day 5) does the real protecting: HR, Company Admin and
// Executive read every record in their company, HR alone writes, and
// everyone else sees colleagues only through company_directory(), which has
// no pay or bank columns. This class just asks; the database decides.

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:supabase_flutter/supabase_flutter.dart'
    show PostgrestException, Supabase, SupabaseClient;

import 'employee_mapping.dart';
import 'employee_records_state.dart';
import 'employee_repository.dart';
import 'supabase_company.dart';

class SupabaseEmployeeRepository implements EmployeeRepository {
  SupabaseEmployeeRepository([this._injected]);

  final SupabaseClient? _injected;

  SupabaseClient get _client => _injected ?? Supabase.instance.client;

  static void _log(String what, Object error) =>
      debugPrint('KarmaHR employees: $what -> $error');

  @override
  bool get usesBackend => true;

  @override
  Future<List<EmployeeRecord>> loadAll() async {
    final departments = await _client.from('departments').select('id, name');
    final departmentName = {
      for (final d in departments) d['id'] as String: d['name'] as String,
    };
    final branches = await _client.from('branches').select('id, name');
    final branchName = {
      for (final b in branches) b['id'] as String: b['name'] as String,
    };

    // Everyone, without pay: what any colleague may see.
    final directory = await _client.rpc('company_directory') as List;
    // The full records the database lets this person read: all of them for
    // HR and Executive, only their own for an ordinary employee.
    final full = await _client.from('employees').select(employeeColumns);
    final fullById = {for (final r in full) r['id'] as String: r};
    final nameById = {
      for (final p in directory) p['id'] as String: p['name'] as String,
    };

    return [
      for (final p in directory.cast<Map<String, dynamic>>())
        rowToRecord(
          fullById[p['id']] ?? p,
          department: departmentName[p['department_id']] ?? '',
          manager: nameById[p['manager_id']] ?? '',
          branch: branchName[p['branch_id']],
        ),
    ];
  }

  @override
  Future<void> insert(EmployeeRecord record) => insertMany([record]);

  @override
  Future<void> insertMany(List<EmployeeRecord> records) async {
    if (records.isEmpty) return;
    try {
      final companyId = await companyIdOf(_client);
      final rows = [
        for (final r in records)
          recordToNewRow(
            r,
            companyId: companyId,
            departmentId: await findOrMakeNamed(
              _client,
              'departments',
              r.department,
            ),
            managerId: await _managerId(r.manager),
            branchId: await findOrMakeNamed(
              _client,
              'branches',
              r.workLocation,
            ),
          ),
      ];
      await _client.from('employees').insert(rows);
    } on SaveFailure {
      rethrow;
    } on PostgrestException catch (e) {
      throw _failure('add', e);
    } catch (e) {
      _log('add failed', e);
      throw const SaveFailure(SaveProblem.network);
    }
  }

  @override
  Future<void> update(EmployeeRecord record) async {
    try {
      final changes = recordToChanges(
        record,
        departmentId: await findOrMakeNamed(
          _client,
          'departments',
          record.department,
        ),
        managerId: await _managerId(record.manager),
        branchId: await findOrMakeNamed(
          _client,
          'branches',
          record.workLocation,
        ),
      );
      await _write(record.id, changes);
    } on SaveFailure {
      rethrow;
    } on PostgrestException catch (e) {
      throw _failure('update', e);
    } catch (e) {
      _log('update failed', e);
      throw const SaveFailure(SaveProblem.network);
    }
  }

  @override
  Future<void> setStatus(String employeeId, EmploymentStatus status) async {
    try {
      await _write(employeeId, {
        'status': status == EmploymentStatus.active ? 'active' : 'inactive',
      });
    } on SaveFailure {
      rethrow; // e.g. "not allowed": keep the real reason
    } on PostgrestException catch (e) {
      throw _failure('change status', e);
    } catch (e) {
      _log('change status failed', e);
      throw const SaveFailure(SaveProblem.network);
    }
  }

  /// Updates one person by Staff ID. Row Level Security quietly hides rows
  /// the person may not change, so an update that matched nothing means
  /// "not allowed" (or the record is gone), not success.
  Future<void> _write(String staffId, Map<String, dynamic> changes) async {
    final updated = await _client
        .from('employees')
        .update(changes)
        .eq('staff_id', staffId)
        .select('id');
    if (updated.isEmpty) throw const SaveFailure(SaveProblem.notAllowed);
  }

  /// The employee with this name, as the manager's id (or null for none).
  Future<String?> _managerId(String name) async {
    final wanted = name.trim();
    if (wanted.isEmpty) return null;
    final rows = await _client
        .from('employees')
        .select('id')
        .eq('name', wanted)
        .limit(1);
    return rows.isEmpty ? null : rows.first['id'] as String;
  }

  SaveFailure _failure(String doing, PostgrestException e) {
    _log("couldn't $doing", '${e.code} ${e.message}');
    return failureFrom(e);
  }
}

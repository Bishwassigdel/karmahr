// Where the company's departments and branches are stored. Two versions,
// like the employee repository: Supabase with a real login, the demo's own
// lists without one.

import 'package:supabase_flutter/supabase_flutter.dart'
    show PostgrestException, Supabase, SupabaseClient;

import 'employee_repository.dart' show SaveFailure, SaveProblem;
import 'supabase_company.dart';

abstract class OrgRepository {
  bool get usesBackend;

  /// The company's department and branch names. Throws on failure.
  Future<({List<String> departments, List<String> branches})> load();

  /// Adds one. Throws [SaveFailure].
  Future<void> addDepartment(String name);
  Future<void> addBranch(String name);
}

class DemoOrgRepository implements OrgRepository {
  @override
  bool get usesBackend => false;

  @override
  Future<({List<String> departments, List<String> branches})> load() async =>
      (departments: const <String>[], branches: const <String>[]);

  @override
  Future<void> addDepartment(String name) async {}

  @override
  Future<void> addBranch(String name) async {}
}

class SupabaseOrgRepository implements OrgRepository {
  SupabaseOrgRepository([this._injected]);

  final SupabaseClient? _injected;

  SupabaseClient get _client => _injected ?? Supabase.instance.client;

  @override
  bool get usesBackend => true;

  @override
  Future<({List<String> departments, List<String> branches})> load() async {
    final d = await _client.from('departments').select('name');
    final b = await _client.from('branches').select('name');
    return (
      departments: [for (final r in d) r['name'] as String],
      branches: [for (final r in b) r['name'] as String],
    );
  }

  @override
  Future<void> addDepartment(String name) => _add('departments', name);

  @override
  Future<void> addBranch(String name) => _add('branches', name);

  Future<void> _add(String table, String name) async {
    try {
      await _client.from(table).insert({
        'company_id': await companyIdOf(_client),
        'name': name.trim(),
      });
    } on SaveFailure {
      rethrow;
    } on PostgrestException catch (e) {
      throw failureFrom(e);
    } catch (_) {
      throw const SaveFailure(SaveProblem.network);
    }
  }
}

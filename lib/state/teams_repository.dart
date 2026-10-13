// Where teams are stored. Two versions, like employees: Supabase with a real
// login, nothing (in-memory only) without one.
//
// In the app a team's members and head are Staff IDs ("HT-003"); in the
// database they are employee uuids. The Supabase version translates, using
// the colleague directory (which everyone may read).

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:supabase_flutter/supabase_flutter.dart'
    show PostgrestException, Supabase, SupabaseClient;

import 'employee_repository.dart' show SaveFailure, SaveProblem;
import 'supabase_company.dart';
import 'teams_state.dart' show Team;

abstract class TeamsRepository {
  bool get usesBackend;

  Future<List<Team>> loadAll();

  /// Makes a team and returns its id (null without a backend: the app
  /// numbers it itself). The rest throw [SaveFailure] when they don't happen.
  Future<String?> create(String name);
  Future<void> rename(String teamId, String name);
  Future<void> addMember(String teamId, String employeeId);
  Future<void> removeMember(String teamId, String employeeId);
  Future<void> setHead(String teamId, String employeeId);
  Future<void> clearHead(String teamId);
  Future<void> delete(String teamId);
}

class DemoTeamsRepository implements TeamsRepository {
  @override
  bool get usesBackend => false;
  @override
  Future<List<Team>> loadAll() async => const [];
  @override
  Future<String?> create(String name) async => null;
  @override
  Future<void> rename(String teamId, String name) async {}
  @override
  Future<void> addMember(String teamId, String employeeId) async {}
  @override
  Future<void> removeMember(String teamId, String employeeId) async {}
  @override
  Future<void> setHead(String teamId, String employeeId) async {}
  @override
  Future<void> clearHead(String teamId) async {}
  @override
  Future<void> delete(String teamId) async {}
}

class SupabaseTeamsRepository implements TeamsRepository {
  SupabaseTeamsRepository([this._injected]);

  final SupabaseClient? _injected;

  SupabaseClient get _client => _injected ?? Supabase.instance.client;

  @override
  bool get usesBackend => true;

  /// Staff ID -> uuid and back, from the colleague directory.
  Future<({Map<String, String> uuid, Map<String, String> staff})> _ids() async {
    final directory = await _client.rpc('company_directory') as List;
    return (
      uuid: {
        for (final p in directory) p['staff_id'] as String: p['id'] as String,
      },
      staff: {
        for (final p in directory) p['id'] as String: p['staff_id'] as String,
      },
    );
  }

  @override
  Future<List<Team>> loadAll() async {
    final ids = await _ids();
    final rows = await _client
        .from('teams')
        .select(
          // Two links join teams and team_members (membership, and "the head
          // must be a member"), so name the membership one.
          'id, name, head_employee_id, '
          'team_members!team_members_company_id_team_id_fkey'
          '(employee_id, added_at)',
        )
        .order('created_at');
    return [
      for (final t in rows)
        Team(
          id: t['id'] as String,
          name: t['name'] as String,
          headId: ids.staff[t['head_employee_id']] ?? '',
          memberIds: [
            for (final m
                in ((t['team_members'] as List).cast<Map>().toList()..sort(
                  (a, b) => (a['added_at'] as String).compareTo(
                    b['added_at'] as String,
                  ),
                )))
              ?ids.staff[m['employee_id']],
          ],
        ),
    ];
  }

  @override
  Future<String?> create(String name) => _guard('create', () async {
    final row = await _client
        .from('teams')
        .insert({'company_id': await companyIdOf(_client), 'name': name})
        .select('id')
        .single();
    return row['id'] as String;
  });

  @override
  Future<void> rename(String teamId, String name) => _guard('rename', () async {
    await _changeTeam(teamId, {'name': name});
  });

  @override
  Future<void> addMember(String teamId, String employeeId) =>
      _guard('add member', () async {
        await _client.from('team_members').insert({
          'company_id': await companyIdOf(_client),
          'team_id': teamId,
          'employee_id': await _uuidOf(employeeId),
        });
      });

  @override
  Future<void> removeMember(String teamId, String employeeId) =>
      _guard('remove member', () async {
        // The database clears the head too, if this was the head.
        final gone = await _client
            .from('team_members')
            .delete()
            .eq('team_id', teamId)
            .eq('employee_id', await _uuidOf(employeeId))
            .select('team_id');
        if (gone.isEmpty) throw const SaveFailure(SaveProblem.notAllowed);
      });

  @override
  Future<void> setHead(String teamId, String employeeId) =>
      _guard('set head', () async {
        await _changeTeam(teamId, {
          'head_employee_id': await _uuidOf(employeeId),
        });
      });

  @override
  Future<void> clearHead(String teamId) => _guard('clear head', () async {
    await _changeTeam(teamId, {'head_employee_id': null});
  });

  @override
  Future<void> delete(String teamId) => _guard('delete', () async {
    final gone = await _client
        .from('teams')
        .delete()
        .eq('id', teamId)
        .select('id');
    if (gone.isEmpty) throw const SaveFailure(SaveProblem.notAllowed);
  });

  Future<String> _uuidOf(String staffId) async {
    final uuid = (await _ids()).uuid[staffId];
    // Not in this company's directory: not someone this person may add.
    if (uuid == null) throw const SaveFailure(SaveProblem.notAllowed);
    return uuid;
  }

  /// Row Level Security hides rows the person may not change, so an update
  /// that matched nothing means "not allowed", not success.
  Future<void> _changeTeam(String teamId, Map<String, dynamic> changes) async {
    final updated = await _client
        .from('teams')
        .update(changes)
        .eq('id', teamId)
        .select('id');
    if (updated.isEmpty) throw const SaveFailure(SaveProblem.notAllowed);
  }

  Future<T> _guard<T>(String doing, Future<T> Function() work) async {
    try {
      return await work();
    } on SaveFailure {
      rethrow;
    } on PostgrestException catch (e) {
      debugPrint('KarmaHR teams: couldn\'t $doing -> ${e.code} ${e.message}');
      throw failureFrom(e);
    } catch (e) {
      debugPrint('KarmaHR teams: couldn\'t $doing -> $e');
      throw const SaveFailure(SaveProblem.network);
    }
  }
}

import 'package:my_first_flutter_app/state/employee_repository.dart';
import 'package:my_first_flutter_app/state/org_repository.dart';
import 'package:my_first_flutter_app/state/teams_repository.dart';
import 'package:my_first_flutter_app/state/teams_state.dart';

/// A stand-in for the departments and branches tables.
class FakeOrgRepository implements OrgRepository {
  FakeOrgRepository({List<String>? departments, List<String>? branches})
    : departments = departments ?? ['Support', 'Engineering'],
      branches = branches ?? ['Kathmandu Head Office'];

  final List<String> departments;
  final List<String> branches;
  SaveFailure? failNextWrite;
  bool failLoad = false;
  int loads = 0;

  @override
  bool get usesBackend => true;

  @override
  Future<({List<String> departments, List<String> branches})> load() async {
    loads++;
    if (failLoad) throw Exception('offline');
    return (departments: List.of(departments), branches: List.of(branches));
  }

  void _maybeFail() {
    final f = failNextWrite;
    failNextWrite = null;
    if (f != null) throw f;
  }

  @override
  Future<void> addDepartment(String name) async {
    _maybeFail();
    departments.add(name);
  }

  @override
  Future<void> addBranch(String name) async {
    _maybeFail();
    branches.add(name);
  }
}

/// A stand-in for the teams tables. Team ids are made like a database's.
class FakeTeamsRepository implements TeamsRepository {
  FakeTeamsRepository({List<Team>? stored}) : stored = stored ?? [];

  final List<Team> stored;
  SaveFailure? failNextWrite;
  bool failLoad = false;
  int loads = 0;
  int _next = 0;
  final calls = <String>[];

  @override
  bool get usesBackend => true;

  void _maybeFail() {
    final f = failNextWrite;
    failNextWrite = null;
    if (f != null) throw f;
  }

  void _replace(Team t) => stored[stored.indexWhere((x) => x.id == t.id)] = t;
  Team _byId(String id) => stored.firstWhere((t) => t.id == id);

  @override
  Future<List<Team>> loadAll() async {
    loads++;
    if (failLoad) throw Exception('offline');
    return List.of(stored);
  }

  @override
  Future<String?> create(String name) async {
    calls.add('create $name');
    _maybeFail();
    final id = 'uuid-${++_next}';
    stored.add(Team(id: id, name: name));
    return id;
  }

  @override
  Future<void> rename(String teamId, String name) async {
    calls.add('rename $teamId $name');
    _maybeFail();
    _replace(_byId(teamId).copyWith(name: name));
  }

  @override
  Future<void> addMember(String teamId, String employeeId) async {
    calls.add('addMember $teamId $employeeId');
    _maybeFail();
    final t = _byId(teamId);
    _replace(t.copyWith(memberIds: [...t.memberIds, employeeId]));
  }

  @override
  Future<void> removeMember(String teamId, String employeeId) async {
    calls.add('removeMember $teamId $employeeId');
    _maybeFail();
    final t = _byId(teamId);
    _replace(
      t.copyWith(
        memberIds: [
          for (final m in t.memberIds)
            if (m != employeeId) m,
        ],
        headId: t.headId == employeeId ? '' : t.headId,
      ),
    );
  }

  @override
  Future<void> setHead(String teamId, String employeeId) async {
    calls.add('setHead $teamId $employeeId');
    _maybeFail();
    _replace(_byId(teamId).copyWith(headId: employeeId));
  }

  @override
  Future<void> clearHead(String teamId) async {
    calls.add('clearHead $teamId');
    _maybeFail();
    _replace(_byId(teamId).copyWith(headId: ''));
  }

  @override
  Future<void> delete(String teamId) async {
    calls.add('delete $teamId');
    _maybeFail();
    stored.removeWhere((t) => t.id == teamId);
  }
}

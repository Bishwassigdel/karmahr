// Teams HR sets up: a name, some members and one head. The head is the
// person who can assign tasks to the members. COMPANY data, so logout does
// not reset it (see session.dart).
//
// People are stored by staff ID, never by name, so renaming someone in
// Employees doesn't break their team.

import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart';

import 'employee_repository.dart' show SaveFailure, SaveProblem;
import 'teams_repository.dart';

class Team {
  final String id;
  final String name;

  /// Staff ID of the head; empty when the team has none.
  final String headId;
  final List<String> memberIds;

  const Team({
    required this.id,
    required this.name,
    this.headId = '',
    this.memberIds = const [],
  });

  bool hasMember(String employeeId) => memberIds.contains(employeeId);

  Team copyWith({String? name, String? headId, List<String>? memberIds}) {
    return Team(
      id: id,
      name: name ?? this.name,
      headId: headId ?? this.headId,
      memberIds: memberIds ?? this.memberIds,
    );
  }
}

class TeamsState extends ChangeNotifier {
  TeamsState({TeamsRepository? repository})
    : _repository = repository ?? DemoTeamsRepository();

  final TeamsRepository _repository;
  final List<Team> _teams = [];
  int _counter = 0;
  int _generation = 0;

  bool _loadFailed = false;
  bool get loadFailed => _loadFailed;

  /// Loads the company's teams (nothing to do without a backend). Call it
  /// after signing in and when the Teams screen opens.
  Future<void> refresh() async {
    if (!_repository.usesBackend) return;
    final started = _generation;
    try {
      final loaded = await _repository.loadAll();
      if (started != _generation) return; // signed out meanwhile
      _teams
        ..clear()
        ..addAll(loaded);
      _loadFailed = false;
    } catch (_) {
      if (started != _generation) return;
      _loadFailed = true;
    }
    notifyListeners();
  }

  /// A real company's teams must not outlive the login. (The demo keeps its
  /// own, like the rest of its company data.)
  void clearForSignOut() {
    if (!_repository.usesBackend) return;
    _generation++;
    _teams.clear();
    _loadFailed = false;
    notifyListeners();
  }

  // ---- Saving. Each of these checks the same rules as the plain methods
  // below, saves, and only then changes what the screen shows. If the save
  // fails the teams are reloaded, so the screen shows what is really stored.
  // They return why it failed, or null when it worked.

  Future<SaveFailure?> createAndSave(String name) async {
    final n = name.trim();
    if (n.isEmpty || _nameTaken(n)) {
      return const SaveFailure(SaveProblem.duplicateName);
    }
    final String? id;
    try {
      id = await _repository.create(n);
    } on SaveFailure catch (failure) {
      return _reloadAfter(failure);
    }
    _counter++;
    _teams.add(Team(id: id ?? 'T-$_counter', name: n));
    notifyListeners();
    return null;
  }

  Future<SaveFailure?> renameAndSave(String teamId, String name) {
    final team = byId(teamId);
    final n = name.trim();
    if (team == null || n.isEmpty || _nameTaken(n, exceptId: teamId)) {
      return Future.value(const SaveFailure(SaveProblem.duplicateName));
    }
    return _save(() => _repository.rename(teamId, n), () => rename(teamId, n));
  }

  Future<SaveFailure?> addMemberAndSave(String teamId, String employeeId) {
    final team = byId(teamId);
    if (team == null || team.hasMember(employeeId)) {
      return Future.value(const SaveFailure(SaveProblem.conflict));
    }
    return _save(
      () => _repository.addMember(teamId, employeeId),
      () => addMember(teamId, employeeId),
    );
  }

  Future<SaveFailure?> removeMemberAndSave(String teamId, String employeeId) {
    final team = byId(teamId);
    if (team == null || !team.hasMember(employeeId)) {
      return Future.value(const SaveFailure(SaveProblem.conflict));
    }
    return _save(
      () => _repository.removeMember(teamId, employeeId),
      () => removeMember(teamId, employeeId),
    );
  }

  /// Same rules as [setHead]: a member, and nobody leads two teams. The
  /// screen checks "leads another team" first, to say so by name.
  Future<SaveFailure?> setHeadAndSave(String teamId, String employeeId) {
    final team = byId(teamId);
    final leads = teamHeadedBy(employeeId);
    if (team == null ||
        !team.hasMember(employeeId) ||
        (leads != null && leads.id != teamId)) {
      return Future.value(const SaveFailure(SaveProblem.conflict));
    }
    return _save(
      () => _repository.setHead(teamId, employeeId),
      () => setHead(teamId, employeeId),
    );
  }

  Future<SaveFailure?> clearHeadAndSave(String teamId) =>
      _save(() => _repository.clearHead(teamId), () => clearHead(teamId));

  Future<SaveFailure?> deleteAndSave(String teamId) =>
      _save(() => _repository.delete(teamId), () => delete(teamId));

  Future<SaveFailure?> _save(
    Future<void> Function() save,
    void Function() apply,
  ) async {
    try {
      await save();
    } on SaveFailure catch (failure) {
      return _reloadAfter(failure);
    }
    apply();
    return null;
  }

  SaveFailure _reloadAfter(SaveFailure failure) {
    unawaited(refresh());
    return failure;
  }

  List<Team> get teams => List.unmodifiable(_teams);

  Team? byId(String id) {
    for (final t in _teams) {
      if (t.id == id) return t;
    }
    return null;
  }

  bool _nameTaken(String name, {String? exceptId}) {
    final wanted = name.trim().toLowerCase();
    return _teams.any(
      (t) => t.id != exceptId && t.name.trim().toLowerCase() == wanted,
    );
  }

  /// Makes a new empty team. Returns it, or null when the name is blank or
  /// another team already has it.
  Team? create(String name) {
    final n = name.trim();
    if (n.isEmpty || _nameTaken(n)) return null;
    _counter++;
    final team = Team(id: 'T-$_counter', name: n);
    _teams.add(team);
    notifyListeners();
    return team;
  }

  bool rename(String teamId, String name) {
    final n = name.trim();
    final team = byId(teamId);
    if (team == null || n.isEmpty || _nameTaken(n, exceptId: teamId)) {
      return false;
    }
    _replace(team.copyWith(name: n));
    return true;
  }

  /// Adds a person. False if the team is unknown or they are already in it.
  bool addMember(String teamId, String employeeId) {
    final team = byId(teamId);
    if (team == null || team.hasMember(employeeId)) return false;
    _replace(team.copyWith(memberIds: [...team.memberIds, employeeId]));
    return true;
  }

  /// Takes a person out. If they were the head, the team has no head again.
  bool removeMember(String teamId, String employeeId) {
    final team = byId(teamId);
    if (team == null || !team.hasMember(employeeId)) return false;
    _replace(
      team.copyWith(
        memberIds: [
          for (final id in team.memberIds)
            if (id != employeeId) id,
        ],
        headId: team.headId == employeeId ? '' : team.headId,
      ),
    );
    return true;
  }

  /// Makes a member the head. The head must already be a member, and a
  /// person can lead only one team: both rules return false.
  bool setHead(String teamId, String employeeId) {
    final team = byId(teamId);
    if (team == null || !team.hasMember(employeeId)) return false;
    final leads = teamHeadedBy(employeeId);
    if (leads != null && leads.id != teamId) return false;
    _replace(team.copyWith(headId: employeeId));
    return true;
  }

  void clearHead(String teamId) {
    final team = byId(teamId);
    if (team == null || team.headId.isEmpty) return;
    _replace(team.copyWith(headId: ''));
  }

  void delete(String teamId) {
    if (_teams.any((t) => t.id == teamId)) {
      _teams.removeWhere((t) => t.id == teamId);
      notifyListeners();
    }
  }

  /// The team this person leads, if any.
  Team? teamHeadedBy(String employeeId) {
    for (final t in _teams) {
      if (t.headId == employeeId) return t;
    }
    return null;
  }

  /// Every team this person belongs to.
  List<Team> teamsOf(String employeeId) => [
    for (final t in _teams)
      if (t.hasMember(employeeId)) t,
  ];

  /// Whether [assignerId] may give [assigneeId] a task: only the head of a
  /// team the assignee belongs to, and only within that team. (HR can assign
  /// to anyone; that rule lives with the tasks, not here.)
  bool canAssign(String assignerId, String assigneeId) {
    final led = teamHeadedBy(assignerId);
    return led != null && led.hasMember(assigneeId);
  }

  void _replace(Team team) {
    final i = _teams.indexWhere((t) => t.id == team.id);
    _teams[i] = team;
    notifyListeners();
  }
}

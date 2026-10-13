// The company's departments and branches, as lists HR picks from. With a
// backend they are real records (loaded after sign-in); without one, the
// demo company's own lists. COMPANY data: logout keeps the demo's lists, but
// forgets a real company's (the next person may be from another company).

import 'package:flutter/foundation.dart';

import 'employee_repository.dart' show SaveFailure, SaveProblem;
import 'org_repository.dart';

/// The demo company's lists, matching the demo employees.
const demoDepartments = [
  'Finance',
  'Human Resources',
  'Information Technology',
  'Operations',
];
const demoBranches = [
  'Kathmandu Head Office',
  'Lalitpur Branch',
  'Pokhara Branch',
];

class OrgState extends ChangeNotifier {
  OrgState({OrgRepository? repository})
    : _repository = repository ?? DemoOrgRepository() {
    if (!_repository.usesBackend) {
      _departments.addAll(demoDepartments);
      _branches.addAll(demoBranches);
    }
  }

  final OrgRepository _repository;
  final List<String> _departments = [];
  final List<String> _branches = [];
  int _generation = 0;

  /// A to Z.
  List<String> get departments => _sorted(_departments);
  List<String> get branches => _sorted(_branches);

  static List<String> _sorted(List<String> names) => List.unmodifiable(
    [...names]..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())),
  );

  Future<void> refresh() async {
    if (!_repository.usesBackend) return;
    final started = _generation;
    try {
      final loaded = await _repository.load();
      if (started != _generation) return; // signed out meanwhile
      _departments
        ..clear()
        ..addAll(loaded.departments);
      _branches
        ..clear()
        ..addAll(loaded.branches);
      notifyListeners();
    } catch (_) {
      // Keep what we have; the form still works with it.
    }
  }

  void clearForSignOut() {
    if (!_repository.usesBackend) return;
    _generation++;
    _departments.clear();
    _branches.clear();
    notifyListeners();
  }

  /// Adds a department. Returns why not, or null when it worked. A name that
  /// already exists (any capitals) is refused rather than added twice.
  Future<SaveFailure?> addDepartment(String name) =>
      _add(name, _departments, _repository.addDepartment);

  Future<SaveFailure?> addBranch(String name) =>
      _add(name, _branches, _repository.addBranch);

  Future<SaveFailure?> _add(
    String name,
    List<String> into,
    Future<void> Function(String) save,
  ) async {
    final n = name.trim();
    final taken = into.any((x) => x.toLowerCase() == n.toLowerCase());
    if (n.isEmpty || taken) {
      return const SaveFailure(SaveProblem.duplicateName);
    }
    try {
      await save(n);
    } on SaveFailure catch (failure) {
      return failure;
    }
    into.add(n);
    notifyListeners();
    return null;
  }

  /// The real spelling of [name] if the list has it under other capitals,
  /// else [name] as given.
  String canonical(String name, List<String> list) {
    for (final x in list) {
      if (x.toLowerCase() == name.trim().toLowerCase()) return x;
    }
    return name;
  }
}

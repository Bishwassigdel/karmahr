// Turns the flat employee list into a reporting tree, using each person's
// manager name. Pure Dart, so it can be tested without any screen.

import '../state/employee_records_state.dart';

/// One person in the chart, with how deep they sit and how many people
/// report to them directly.
class OrgNode {
  final EmployeeRecord person;

  /// 0 for someone at the top.
  final int depth;
  final int directReports;

  const OrgNode(this.person, this.depth, this.directReports);
}

/// The chart as a flat list in reading order: each person followed by
/// everyone who reports to them (and so on down), siblings A to Z.
///
/// Only [people] who are listed take part. Someone is at the top when they
/// have no manager, or their manager is not in the list (for example a
/// manager who has left). A loop in the data (A manages B, B manages A) can
/// never repeat anyone: each person appears at most once.
List<OrgNode> buildOrgChart(Iterable<EmployeeRecord> people) {
  final all = people.toList();
  final byName = <String, List<EmployeeRecord>>{};
  for (final p in all) {
    byName.putIfAbsent(p.manager, () => []).add(p);
  }

  final names = {for (final p in all) p.name};
  bool isTop(EmployeeRecord p) =>
      p.manager.isEmpty || !names.contains(p.manager);

  List<EmployeeRecord> reportsOf(EmployeeRecord p) =>
      (byName[p.name] ?? const <EmployeeRecord>[])
          .where((r) => r.id != p.id)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

  final result = <OrgNode>[];
  final seen = <String>{};

  void visit(EmployeeRecord p, int depth) {
    if (!seen.add(p.id)) return;
    final reports = reportsOf(p);
    result.add(OrgNode(p, depth, reports.length));
    for (final r in reports) {
      visit(r, depth + 1);
    }
  }

  final tops = all.where(isTop).toList()
    ..sort((a, b) => a.name.compareTo(b.name));
  for (final t in tops) {
    visit(t, 0);
  }
  // Anyone still unseen is in a loop with no way in from the top (A and B
  // managing each other). Show them at the top rather than lose them.
  for (final p in all) {
    if (!seen.contains(p.id)) visit(p, 0);
  }
  return result;
}

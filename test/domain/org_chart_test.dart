import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_flutter_app/domain/nepal/tax_slabs.dart';
import 'package:my_first_flutter_app/domain/org_chart.dart';
import 'package:my_first_flutter_app/state/employee_records_state.dart';

EmployeeRecord p(String name, {String manager = ''}) => EmployeeRecord(
  id: 'id-$name',
  name: name,
  jobTitle: 'Role',
  department: 'Dept',
  manager: manager,
  joiningDate: DateTime(2024, 1, 1),
  employmentType: 'Full-Time',
  workLocation: 'HQ',
  email: '$name@x.com',
  phone: '9800000000',
  basicSalary: 1,
  dearnessAllowance: 0,
  transportAllowance: 0,
  filingStatus: FilingStatus.single,
);

List<String> names(List<OrgNode> nodes) => [
  for (final n in nodes) '${'-' * n.depth}${n.person.name}',
];

void main() {
  test('people appear under their manager, siblings A to Z', () {
    final nodes = buildOrgChart([
      p('Zara', manager: 'Asha'),
      p('Asha'),
      p('Bimal', manager: 'Asha'),
      p('Chandra', manager: 'Bimal'),
    ]);
    expect(names(nodes), ['Asha', '-Bimal', '--Chandra', '-Zara']);
  });

  test('depth and direct report counts are right', () {
    final nodes = buildOrgChart([
      p('Asha'),
      p('Bimal', manager: 'Asha'),
      p('Chandra', manager: 'Asha'),
      p('Dev', manager: 'Bimal'),
    ]);
    OrgNode of(String n) => nodes.firstWhere((x) => x.person.name == n);
    expect(of('Asha').directReports, 2);
    expect(of('Bimal').directReports, 1);
    expect(of('Chandra').directReports, 0);
    expect(of('Dev').depth, 2);
  });

  test('several people at the top are listed A to Z', () {
    expect(names(buildOrgChart([p('Mina'), p('Asha'), p('Zed')])), [
      'Asha',
      'Mina',
      'Zed',
    ]);
  });

  test('a manager who is not in the list puts their report at the top', () {
    // e.g. the manager has been deactivated.
    final nodes = buildOrgChart([p('Bimal', manager: 'Gone Person')]);
    expect(names(nodes), ['Bimal']);
  });

  test('a loop in the data cannot repeat anyone or hang', () {
    final nodes = buildOrgChart([p('A', manager: 'B'), p('B', manager: 'A')]);
    expect(nodes.length, 2);
    expect({for (final n in nodes) n.person.name}, {'A', 'B'});
  });

  test('someone who is their own manager appears once', () {
    final nodes = buildOrgChart([p('Solo', manager: 'Solo')]);
    expect(names(nodes), ['Solo']);
  });

  test('everyone is listed exactly once', () {
    final people = [
      p('Asha'),
      p('Bimal', manager: 'Asha'),
      p('Chandra', manager: 'Bimal'),
      p('Dev', manager: 'Asha'),
      p('Eva', manager: 'Nobody'),
    ];
    final nodes = buildOrgChart(people);
    expect(nodes.length, people.length);
    expect({for (final n in nodes) n.person.id}.length, people.length);
  });

  test('an empty company is an empty chart', () {
    expect(buildOrgChart(const []), isEmpty);
  });

  test('the demo company: the HR Manager is at the top over everyone', () {
    final nodes = buildOrgChart(EmployeeRecordsState().active);
    expect(nodes.first.person.name, 'Suresh Karki');
    expect(nodes.first.depth, 0);
    expect(nodes.skip(1).every((n) => n.depth == 1), isTrue);
    expect(nodes.first.directReports, nodes.length - 1);
  });
}

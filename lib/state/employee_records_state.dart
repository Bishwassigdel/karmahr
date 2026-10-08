// The company's employee records, as HR manages them. This is COMPANY data,
// not one user's, so logout does not reset it (see session.dart).
//
// Everything else that lists people (the Directory, Kudos, search) reads
// [EmployeeRecordsState.directory], so an employee HR adds or deactivates
// shows up or disappears everywhere at once.

import 'package:flutter/foundation.dart';

import '../data/current_employee.dart' show EmployeeProfile;
import '../data/employee_directory_data.dart';
import '../domain/employee_validation.dart';
import '../domain/nepal/tax_slabs.dart';

enum EmploymentStatus { active, inactive }

/// Why a CSV row was not imported.
enum ImportProblem { columns, name, job, email, phone, salary }

/// What a CSV import did: how many people were added, and which rows
/// (1-based line numbers of the pasted text) were skipped and why.
class CsvImportResult {
  final int added;
  final List<({int line, ImportProblem problem})> skipped;

  const CsvImportResult(this.added, this.skipped);
}

/// Offered in the employee form. Stored as plain strings, like job titles.
const employmentTypes = ['Full-Time', 'Part-Time', 'Contract', 'Intern'];

class EmployeeRecord {
  final String id; // staff ID, e.g. "MB-24071"
  final String name;
  final String jobTitle;
  final String department;

  /// Name of this person's manager; empty when they have none.
  final String manager;
  final DateTime joiningDate;
  final String employmentType;
  final String workLocation;
  final String email;
  final String phone;

  // Monthly, in NPR.
  final double basicSalary;
  final double dearnessAllowance;
  final double transportAllowance;

  /// Which income tax slab table applies (see tax_slabs.dart).
  final FilingStatus filingStatus;
  final EmploymentStatus status;

  /// Where salary is paid. Empty until HR fills them in.
  final String bankName;
  final String accountNumber;

  const EmployeeRecord({
    required this.id,
    required this.name,
    required this.jobTitle,
    required this.department,
    required this.manager,
    required this.joiningDate,
    required this.employmentType,
    required this.workLocation,
    required this.email,
    required this.phone,
    required this.basicSalary,
    required this.dearnessAllowance,
    required this.transportAllowance,
    required this.filingStatus,
    this.status = EmploymentStatus.active,
    this.bankName = '',
    this.accountNumber = '',
  });

  bool get isActive => status == EmploymentStatus.active;

  /// The shape the PDF letters and certificates take.
  EmployeeProfile toProfile() => EmployeeProfile(
    name: name,
    employeeId: id,
    jobTitle: jobTitle,
    department: department,
    manager: manager,
    joiningDate: joiningDate,
    employmentType: employmentType,
    workLocation: workLocation,
    email: email,
    basicSalary: basicSalary,
    dearnessAllowance: dearnessAllowance,
    transportAllowance: transportAllowance,
  );
  double get allowances => dearnessAllowance + transportAllowance;
  double get grossMonthly => basicSalary + allowances;

  /// "Suresh Karki" -> "SK"
  String get initials => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .take(2)
      .map((w) => w[0].toUpperCase())
      .join();

  EmployeeRecord copyWith({
    String? name,
    String? jobTitle,
    String? department,
    String? manager,
    DateTime? joiningDate,
    String? employmentType,
    String? workLocation,
    String? email,
    String? phone,
    double? basicSalary,
    double? dearnessAllowance,
    double? transportAllowance,
    FilingStatus? filingStatus,
    EmploymentStatus? status,
    String? bankName,
    String? accountNumber,
  }) {
    return EmployeeRecord(
      id: id,
      name: name ?? this.name,
      jobTitle: jobTitle ?? this.jobTitle,
      department: department ?? this.department,
      manager: manager ?? this.manager,
      joiningDate: joiningDate ?? this.joiningDate,
      employmentType: employmentType ?? this.employmentType,
      workLocation: workLocation ?? this.workLocation,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      basicSalary: basicSalary ?? this.basicSalary,
      dearnessAllowance: dearnessAllowance ?? this.dearnessAllowance,
      transportAllowance: transportAllowance ?? this.transportAllowance,
      filingStatus: filingStatus ?? this.filingStatus,
      status: status ?? this.status,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
    );
  }
}

class EmployeeRecordsState extends ChangeNotifier {
  final List<EmployeeRecord> _records = _seed();

  // Rebuilt only when records change, so the same Employee objects are
  // handed out between changes (screens compare them by identity).
  List<Employee> _directory = const [];

  EmployeeRecordsState() {
    _rebuildDirectory();
  }

  // The first eight come from the demo directory, so names, phones and
  // emails match what the rest of the app already shows. Bishwas Sigdel is
  // the signed-in demo employee: his figures match current_employee.dart.
  static List<EmployeeRecord> _seed() {
    const moreFields =
        <
          ({
            String id,
            int year,
            int month,
            int day,
            String type,
            String location,
            double basic,
            double da,
            double transport,
            FilingStatus filing,
          })
        >[
          (
            id: 'MB-21003',
            year: 2021,
            month: 3,
            day: 1,
            type: 'Full-Time',
            location: 'Kathmandu Head Office',
            basic: 95000,
            da: 9500,
            transport: 5000,
            filing: FilingStatus.married,
          ),
          (
            id: 'MB-22015',
            year: 2022,
            month: 9,
            day: 5,
            type: 'Full-Time',
            location: 'Kathmandu Head Office',
            basic: 62000,
            da: 6200,
            transport: 4000,
            filing: FilingStatus.single,
          ),
          (
            id: 'MB-24071',
            year: 2024,
            month: 1,
            day: 12,
            type: 'Full-Time',
            location: 'Kathmandu Head Office',
            basic: 45000,
            da: 4500,
            transport: 3000,
            filing: FilingStatus.single,
          ),
          (
            id: 'MB-23044',
            year: 2023,
            month: 4,
            day: 17,
            type: 'Full-Time',
            location: 'Lalitpur Branch',
            basic: 55000,
            da: 5500,
            transport: 3500,
            filing: FilingStatus.single,
          ),
          (
            id: 'MB-22021',
            year: 2022,
            month: 11,
            day: 21,
            type: 'Full-Time',
            location: 'Pokhara Branch',
            basic: 70000,
            da: 7000,
            transport: 4500,
            filing: FilingStatus.married,
          ),
          (
            id: 'MB-23088',
            year: 2023,
            month: 8,
            day: 7,
            type: 'Full-Time',
            location: 'Kathmandu Head Office',
            basic: 65000,
            da: 6500,
            transport: 4000,
            filing: FilingStatus.single,
          ),
          (
            id: 'MB-24012',
            year: 2024,
            month: 2,
            day: 26,
            type: 'Contract',
            location: 'Kathmandu Head Office',
            basic: 52000,
            da: 5200,
            transport: 3500,
            filing: FilingStatus.single,
          ),
          (
            id: 'MB-23102',
            year: 2023,
            month: 10,
            day: 2,
            type: 'Full-Time',
            location: 'Kathmandu Head Office',
            basic: 58000,
            da: 5800,
            transport: 3500,
            filing: FilingStatus.married,
          ),
        ];

    // Demo bank details, one per seeded employee.
    const banks = [
      ('Nabil Bank', '0010100123456'),
      ('Global IME Bank', '0020200234567'),
      ('NIC Asia Bank', '0030300345678'),
      ('Nepal Investment Mega Bank', '0040400456789'),
      ('Nabil Bank', '0050500567890'),
      ('Global IME Bank', '0060600678901'),
      ('NIC Asia Bank', '0070700789012'),
      ('Nepal Investment Mega Bank', '0080800890123'),
    ];

    final records = <EmployeeRecord>[];
    for (var i = 0; i < demoEmployees.length; i++) {
      final e = demoEmployees[i];
      final m = moreFields[i];
      records.add(
        EmployeeRecord(
          id: m.id,
          name: e.name,
          jobTitle: e.jobTitle,
          department: e.department,
          // The HR Manager reports to nobody in this demo company.
          manager: e.name == 'Suresh Karki' ? '' : 'Suresh Karki',
          joiningDate: DateTime(m.year, m.month, m.day),
          employmentType: m.type,
          workLocation: m.location,
          email: e.email,
          phone: e.phone,
          basicSalary: m.basic,
          dearnessAllowance: m.da,
          transportAllowance: m.transport,
          filingStatus: m.filing,
          bankName: banks[i].$1,
          accountNumber: banks[i].$2,
        ),
      );
    }

    // One former employee, so the Inactive filter has something to show.
    records.add(
      EmployeeRecord(
        id: 'MB-22030',
        name: 'Dipesh Pandey',
        jobTitle: 'Customer Support Officer',
        department: 'Operations',
        manager: 'Sita Gurung',
        joiningDate: DateTime(2022, 6, 14),
        employmentType: 'Full-Time',
        workLocation: 'Kathmandu Head Office',
        email: 'dipesh.pandey@karmahr.com',
        phone: '+977 9845566778',
        basicSalary: 38000,
        dearnessAllowance: 3800,
        transportAllowance: 2500,
        filingStatus: FilingStatus.single,
        status: EmploymentStatus.inactive,
        bankName: 'Global IME Bank',
        accountNumber: '0090900901234',
      ),
    );
    return records;
  }

  List<EmployeeRecord> get records => List.unmodifiable(_records);
  List<EmployeeRecord> get active => _records.where((r) => r.isActive).toList();

  /// Active employees in the shape the Directory, Kudos and search use.
  List<Employee> get directory => _directory;

  /// Every department that has a record, A to Z.
  List<String> get departments =>
      ({for (final r in _records) r.department}.toList()..sort());

  EmployeeRecord? byId(String id) {
    for (final r in _records) {
      if (r.id == id) return r;
    }
    return null;
  }

  /// The next free staff ID: one more than the highest number in use.
  String nextId() {
    var highest = 0;
    for (final r in _records) {
      final n = int.tryParse(r.id.split('-').last) ?? 0;
      if (n > highest) highest = n;
    }
    return 'MB-${highest + 1}';
  }

  /// Every record as CSV (a header, then one row each), for a spreadsheet.
  String toCsv() {
    String cell(String v) =>
        v.contains(',') || v.contains('"') ? '"${v.replaceAll('"', '""')}"' : v;
    String two(int n) => n.toString().padLeft(2, '0');
    String date(DateTime d) => '${d.year}-${two(d.month)}-${two(d.day)}';

    return [
      'Staff ID,Name,Job title,Department,Manager,Joined,Type,Location,Email,Phone,Status',
      for (final r in _records)
        [
          r.id,
          r.name,
          r.jobTitle,
          r.department,
          r.manager,
          date(r.joiningDate),
          r.employmentType,
          r.workLocation,
          r.email,
          r.phone,
          r.isActive ? 'Active' : 'Inactive',
        ].map(cell).join(','),
    ].join('\n');
  }

  /// Adds everyone in [csv]: one person per line, columns Name, Job title,
  /// Department, Email, Phone, Basic salary, Dearness allowance, Transport
  /// allowance. Commas or tabs (a paste from a spreadsheet) both work, and a
  /// first line starting with "Name" is taken as a header and skipped.
  /// A bad row is skipped and reported; the good ones still go in.
  CsvImportResult importCsv(String csv, {DateTime? today}) {
    final joined = today ?? DateTime.now();
    final skipped = <({int line, ImportProblem problem})>[];
    var added = 0;
    var first = true;

    final lines = csv.split(RegExp(r'\r?\n'));
    for (var i = 0; i < lines.length; i++) {
      final raw = lines[i];
      if (raw.trim().isEmpty) continue;
      final cells = _splitCsvLine(raw);
      if (first) {
        first = false;
        if (cells.first.toLowerCase() == 'name') continue; // a header
      }

      if (cells.length < 8) {
        skipped.add((line: i + 1, problem: ImportProblem.columns));
        continue;
      }
      final basic = parseMoney(cells[5]);
      final dearness = parseMoney(cells[6]);
      final transport = parseMoney(cells[7]);
      final problem = firstProblem(
        name: cells[0],
        jobTitle: cells[1],
        department: cells[2],
        email: cells[3],
        phone: cells[4],
        basicSalary: basic,
      );
      if (problem != null || dearness == null || transport == null) {
        skipped.add((
          line: i + 1,
          problem: switch (problem) {
            EmployeeProblem.name => ImportProblem.name,
            EmployeeProblem.job => ImportProblem.job,
            EmployeeProblem.email => ImportProblem.email,
            EmployeeProblem.phone => ImportProblem.phone,
            _ => ImportProblem.salary,
          },
        ));
        continue;
      }

      _records.add(
        EmployeeRecord(
          id: nextId(),
          name: cells[0],
          jobTitle: cells[1],
          department: cells[2],
          manager: '',
          joiningDate: DateTime(joined.year, joined.month, joined.day),
          employmentType: employmentTypes.first,
          workLocation: 'Kathmandu Head Office',
          email: cells[3],
          phone: cells[4],
          basicSalary: basic!,
          dearnessAllowance: dearness,
          transportAllowance: transport,
          filingStatus: FilingStatus.single,
        ),
      );
      added++;
    }

    if (added > 0) _changed();
    return CsvImportResult(added, skipped);
  }

  /// One CSV (or tab-separated) line to trimmed cells; double quotes keep a
  /// comma inside a cell.
  static List<String> _splitCsvLine(String line) {
    if (line.contains('\t')) {
      return line.split('\t').map((c) => c.trim()).toList();
    }
    final cells = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;
    for (var i = 0; i < line.length; i++) {
      final c = line[i];
      if (c == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (c == ',' && !inQuotes) {
        cells.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(c);
      }
    }
    cells.add(buffer.toString().trim());
    return cells;
  }

  void add(EmployeeRecord record) {
    _records.add(record);
    _changed();
  }

  void update(EmployeeRecord record) {
    final i = _records.indexWhere((r) => r.id == record.id);
    if (i < 0) return;
    _records[i] = record;
    _changed();
  }

  void setStatus(String id, EmploymentStatus status) {
    final record = byId(id);
    if (record == null || record.status == status) return;
    update(record.copyWith(status: status));
  }

  void _changed() {
    _rebuildDirectory();
    notifyListeners();
  }

  void _rebuildDirectory() {
    _directory = [
      for (final r in _records)
        if (r.isActive)
          Employee(
            name: r.name,
            initials: r.initials,
            jobTitle: r.jobTitle,
            department: r.department,
            phone: r.phone,
            email: r.email,
          ),
    ];
  }
}

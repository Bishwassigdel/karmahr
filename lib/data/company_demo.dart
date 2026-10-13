// A made-up large company for the Executive portal: about 290 people in 5
// branches and 8 departments, with 12 months of history.
//
// It exists so the Executive screens (charts, comparisons, drill-down) have
// something realistic to show; the real HR data has 9 people. Everything is
// generated from a fixed seed, so it is the same on every run and on every
// platform. DEMO DATA: with a backend, these same shapes come from the
// server and none of the screens change.

/// A branch office.
class Branch {
  final String id;
  final String name;

  const Branch(this.id, this.name);
}

/// A department.
class Dept {
  final String id;
  final String name;

  const Dept(this.id, this.name);
}

class DemoPerson {
  final String id;
  final String name;
  final String deptId;
  final String branchId;
  final String jobTitle;
  final DateTime joinedOn;

  /// Share of working days attended over the last 30, 0 to 100.
  final int attendance;

  /// How far along this quarter's goals are, 0 to 100.
  final int goals;
  final bool reviewDone;
  final bool trainingDone;

  /// Leave days still available.
  final double leaveBalance;

  /// Monthly gross pay, NPR. Sensitive: screens hide it until asked.
  final double monthlyGross;

  const DemoPerson({
    required this.id,
    required this.name,
    required this.deptId,
    required this.branchId,
    required this.jobTitle,
    required this.joinedOn,
    required this.attendance,
    required this.goals,
    required this.reviewDone,
    required this.trainingDone,
    required this.leaveBalance,
    required this.monthlyGross,
  });

  /// Whole months with the company.
  int tenureMonths(DateTime today) {
    var months =
        (today.year - joinedOn.year) * 12 + today.month - joinedOn.month;
    if (today.day < joinedOn.day) months--;
    return months < 0 ? 0 : months;
  }
}

/// Someone who left in the last 12 months. Kept so past months' headcount
/// and payroll can be worked out exactly.
class DemoLeaver {
  final String deptId;
  final String branchId;
  final DateTime joinedOn;
  final DateTime leftOn;
  final double monthlyGross;

  const DemoLeaver({
    required this.deptId,
    required this.branchId,
    required this.joinedOn,
    required this.leftOn,
    required this.monthlyGross,
  });
}

enum ProgressStatus { onTrack, watch, behind }

/// How a department (or a branch's slice of one) is doing.
///
/// score = 35% goals + 25% reviews + 20% training + 20% attendance, each
/// 0 to 100. 75 and above is on track, 60 to 74 needs watching, below 60 is
/// behind.
class Progress {
  final int headcount;
  final int plan;
  final int goals;
  final int reviews;
  final int training;
  final int attendance;

  const Progress({
    required this.headcount,
    required this.plan,
    required this.goals,
    required this.reviews,
    required this.training,
    required this.attendance,
  });

  static const goalsWeight = 0.35;
  static const reviewsWeight = 0.25;
  static const trainingWeight = 0.20;
  static const attendanceWeight = 0.20;

  int get score =>
      (goals * goalsWeight +
              reviews * reviewsWeight +
              training * trainingWeight +
              attendance * attendanceWeight)
          .round();

  ProgressStatus get status => score >= 75
      ? ProgressStatus.onTrack
      : score >= 60
      ? ProgressStatus.watch
      : ProgressStatus.behind;

  /// Positive when there are open positions, negative when over plan.
  int get gap => plan - headcount;
}

class CompanyDemo {
  final DateTime today;
  final List<Branch> branches;
  final List<Dept> depts;
  final List<DemoPerson> people;
  final List<DemoLeaver> leavers;

  /// Planned headcount for each department in each branch.
  final Map<String, int> _plan;

  const CompanyDemo._(
    this.today,
    this.branches,
    this.depts,
    this.people,
    this.leavers,
    this._plan,
  );

  static String _planKey(String deptId, String branchId) => '$deptId|$branchId';

  Branch branchById(String id) => branches.firstWhere((b) => b.id == id);
  Dept deptById(String id) => depts.firstWhere((d) => d.id == id);

  /// People in a department and/or branch (all of them when both are null).
  List<DemoPerson> peopleIn({String? deptId, String? branchId}) => people
      .where(
        (p) =>
            (deptId == null || p.deptId == deptId) &&
            (branchId == null || p.branchId == branchId),
      )
      .toList();

  int planFor({String? deptId, String? branchId}) {
    var total = 0;
    for (final d in depts) {
      if (deptId != null && d.id != deptId) continue;
      for (final b in branches) {
        if (branchId != null && b.id != branchId) continue;
        total += _plan[_planKey(d.id, b.id)] ?? 0;
      }
    }
    return total;
  }

  Progress progress({String? deptId, String? branchId}) {
    final group = peopleIn(deptId: deptId, branchId: branchId);
    int pct(num sum) => group.isEmpty ? 0 : (sum * 100 / group.length).round();
    int avg(int Function(DemoPerson) f) => group.isEmpty
        ? 0
        : (group.fold<int>(0, (s, p) => s + f(p)) / group.length).round();

    return Progress(
      headcount: group.length,
      plan: planFor(deptId: deptId, branchId: branchId),
      goals: avg((p) => p.goals),
      reviews: pct(group.where((p) => p.reviewDone).length),
      training: pct(group.where((p) => p.trainingDone).length),
      attendance: avg((p) => p.attendance),
    );
  }

  /// The last day of the month that is [monthsAgo] months before this one
  /// (0 = this month, which ends today for the purpose of the numbers).
  DateTime _monthEnd(int monthsAgo) {
    if (monthsAgo == 0) return today;
    return DateTime(today.year, today.month - monthsAgo + 1, 0);
  }

  /// "Jan", "Feb" ... for the month [monthsAgo] before this one.
  String monthLabel(int monthsAgo) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final d = DateTime(today.year, today.month - monthsAgo, 1);
    return names[d.month - 1];
  }

  bool _matches(String d, String b, String? deptId, String? branchId) =>
      (deptId == null || d == deptId) && (branchId == null || b == branchId);

  /// People employed at the end of the month [monthsAgo] months back.
  int headcountAt(int monthsAgo, {String? deptId, String? branchId}) {
    final end = _monthEnd(monthsAgo);
    var n = 0;
    for (final p in people) {
      if (_matches(p.deptId, p.branchId, deptId, branchId) &&
          !p.joinedOn.isAfter(end)) {
        n++;
      }
    }
    for (final l in leavers) {
      if (_matches(l.deptId, l.branchId, deptId, branchId) &&
          !l.joinedOn.isAfter(end) &&
          l.leftOn.isAfter(end)) {
        n++;
      }
    }
    return n;
  }

  /// Gross payroll for the month [monthsAgo] months back, NPR.
  double payrollAt(int monthsAgo, {String? deptId, String? branchId}) {
    final end = _monthEnd(monthsAgo);
    var total = 0.0;
    for (final p in people) {
      if (_matches(p.deptId, p.branchId, deptId, branchId) &&
          !p.joinedOn.isAfter(end)) {
        total += p.monthlyGross;
      }
    }
    for (final l in leavers) {
      if (_matches(l.deptId, l.branchId, deptId, branchId) &&
          !l.joinedOn.isAfter(end) &&
          l.leftOn.isAfter(end)) {
        total += l.monthlyGross;
      }
    }
    return total;
  }

  /// Oldest first, [months] points ending with this month.
  List<int> headcountSeries({
    int months = 12,
    String? deptId,
    String? branchId,
  }) => [
    for (var m = months - 1; m >= 0; m--)
      headcountAt(m, deptId: deptId, branchId: branchId),
  ];

  List<double> payrollSeries({
    int months = 12,
    String? deptId,
    String? branchId,
  }) => [
    for (var m = months - 1; m >= 0; m--)
      payrollAt(m, deptId: deptId, branchId: branchId),
  ];

  /// People who joined in the last [days] days.
  int joinedLast(int days, {String? deptId, String? branchId}) {
    final from = today.subtract(Duration(days: days));
    return people
        .where(
          (p) =>
              _matches(p.deptId, p.branchId, deptId, branchId) &&
              p.joinedOn.isAfter(from),
        )
        .length;
  }

  /// People who left in the last [days] days.
  int leftLast(int days, {String? deptId, String? branchId}) {
    final from = today.subtract(Duration(days: days));
    return leavers
        .where(
          (l) =>
              _matches(l.deptId, l.branchId, deptId, branchId) &&
              l.leftOn.isAfter(from),
        )
        .length;
  }

  /// Leavers over the last 12 months as a share of average headcount, in
  /// percent.
  double attritionPercent({String? deptId, String? branchId}) {
    final left = leftLast(365, deptId: deptId, branchId: branchId);
    final avg =
        (headcountAt(12, deptId: deptId, branchId: branchId) +
            headcountAt(0, deptId: deptId, branchId: branchId)) /
        2;
    return avg == 0 ? 0 : left * 100 / avg;
  }

  // ----------------------------------------------------------------------
  // Generation
  // ----------------------------------------------------------------------

  static CompanyDemo generate({DateTime? today, int seed = 7}) {
    final now = today ?? DateTime.now();
    final day = DateTime(now.year, now.month, now.day);
    final rng = _Rng(seed);

    const branches = [
      Branch('b-ktm', 'Kathmandu'),
      Branch('b-ltp', 'Lalitpur'),
      Branch('b-pkr', 'Pokhara'),
      Branch('b-brt', 'Biratnagar'),
      Branch('b-btl', 'Butwal'),
    ];
    // Share of each department's people in each branch, in percent.
    const branchShare = [45, 15, 15, 13, 12];

    // id, name, people, health (0 to 1: how well it is doing), base pay,
    // job titles.
    const specs = <(String, String, int, double, double, List<String>)>[
      (
        'd-ops',
        'Operations',
        70,
        0.82,
        42000,
        ['Operations Executive', 'Supervisor', 'Logistics Officer'],
      ),
      (
        'd-sales',
        'Sales',
        55,
        0.74,
        48000,
        ['Sales Executive', 'Account Manager', 'Regional Lead'],
      ),
      (
        'd-support',
        'Customer Support',
        50,
        0.45,
        36000,
        ['Support Agent', 'Senior Agent', 'Team Lead'],
      ),
      (
        'd-it',
        'Information Technology',
        40,
        0.88,
        78000,
        ['Software Engineer', 'QA Engineer', 'DevOps Engineer'],
      ),
      (
        'd-fin',
        'Finance',
        25,
        0.90,
        65000,
        ['Accountant', 'Finance Officer', 'Auditor'],
      ),
      (
        'd-mkt',
        'Marketing',
        25,
        0.68,
        55000,
        ['Marketing Executive', 'Content Specialist', 'Designer'],
      ),
      (
        'd-hr',
        'Human Resources',
        15,
        0.85,
        55000,
        ['HR Officer', 'Recruiter', 'HR Associate'],
      ),
      (
        'd-legal',
        'Legal',
        10,
        0.80,
        85000,
        ['Legal Officer', 'Compliance Officer'],
      ),
    ];

    const firstNames = [
      'Aarav',
      'Anita',
      'Bikash',
      'Binita',
      'Deepak',
      'Dipika',
      'Gita',
      'Hari',
      'Isha',
      'Kiran',
      'Kamala',
      'Laxmi',
      'Manish',
      'Maya',
      'Nabin',
      'Nisha',
      'Prakash',
      'Pooja',
      'Rajan',
      'Rita',
      'Roshan',
      'Sabina',
      'Sagar',
      'Sita',
      'Sunil',
      'Sujata',
      'Tara',
      'Umesh',
      'Yogesh',
      'Rashmi',
    ];
    const lastNames = [
      'Adhikari',
      'Bhandari',
      'Basnet',
      'Chaudhary',
      'Gurung',
      'Karki',
      'Khadka',
      'Lama',
      'Magar',
      'Neupane',
      'Pandey',
      'Poudel',
      'Rai',
      'Sharma',
      'Shrestha',
      'Sherpa',
      'Tamang',
      'Thapa',
      'Thakuri',
      'Yadav',
    ];

    int clamp(int v, int lo, int hi) => v < lo ? lo : (v > hi ? hi : v);

    final depts = [for (final s in specs) Dept(s.$1, s.$2)];
    final people = <DemoPerson>[];
    final leavers = <DemoLeaver>[];
    final plan = <String, int>{};
    final cell = <String, int>{}; // people per department and branch
    var serial = 1000;

    String pickBranch() {
      var roll = rng.next(100);
      for (var i = 0; i < branches.length; i++) {
        roll -= branchShare[i];
        if (roll < 0) return branches[i].id;
      }
      return branches.first.id;
    }

    for (final (deptId, _, size, health, pay, jobs) in specs) {
      for (var i = 0; i < size; i++) {
        final branchId = pickBranch();
        cell.update('$deptId|$branchId', (n) => n + 1, ifAbsent: () => 1);
        final tenureDays = 20 + rng.next(2900); // up to about 8 years
        final grade = 0.8 + (rng.next(60) / 100) + (tenureDays / 2900) * 0.3;
        serial++;
        people.add(
          DemoPerson(
            id: 'E$serial',
            name:
                '${firstNames[rng.next(firstNames.length)]} '
                '${lastNames[rng.next(lastNames.length)]}',
            deptId: deptId,
            branchId: branchId,
            jobTitle: jobs[rng.next(jobs.length)],
            joinedOn: day.subtract(Duration(days: tenureDays)),
            attendance: clamp(
              (74 + health * 22 + rng.next(13) - 6).round(),
              40,
              100,
            ),
            goals: clamp((health * 88 + rng.next(41) - 20).round(), 0, 100),
            reviewDone: rng.next(100) < health * 92,
            trainingDone: rng.next(100) < 30 + health * 55,
            leaveBalance: rng.next(19) + (rng.next(2) == 0 ? 0 : 0.5),
            monthlyGross: (pay * grade / 500).round() * 500.0,
          ),
        );
      }

      // People who left in the last 12 months: more where things are worse.
      final leaving = (size * (0.05 + (1 - health) * 0.16)).round();
      for (var i = 0; i < leaving; i++) {
        final branchId = pickBranch();
        cell.update('$deptId|$branchId', (n) => n, ifAbsent: () => 0);
        final leftDaysAgo = 5 + rng.next(355);
        final tenure = 120 + rng.next(2000);
        leavers.add(
          DemoLeaver(
            deptId: deptId,
            branchId: branchId,
            joinedOn: day.subtract(Duration(days: leftDaysAgo + tenure)),
            leftOn: day.subtract(Duration(days: leftDaysAgo)),
            monthlyGross:
                (pay * (0.9 + rng.next(40) / 100) / 500).round() * 500.0,
          ),
        );
      }

      // Plan: today's people plus the open positions. The weaker the
      // department, the more it is short of its plan.
      final open = ((1 - health) * size * 0.18).round();
      var left = open;
      for (final b in branches) {
        final have = cell['$deptId|${b.id}'] ?? 0;
        final extra = left > 0 && rng.next(3) == 0 ? 1 : 0;
        left -= extra;
        plan['$deptId|${b.id}'] = have + extra;
      }
      if (left > 0) {
        // Put what is still unassigned in the biggest branch.
        plan['$deptId|b-ktm'] = (plan['$deptId|b-ktm'] ?? 0) + left;
      }
    }

    return CompanyDemo._(day, branches, depts, people, leavers, plan);
  }
}

/// A tiny seeded generator. It stays within 32 bits so it gives the same
/// numbers on the phone, the web and in tests (a 64-bit multiply would not
/// on the web).
class _Rng {
  int _s;

  _Rng(int seed) : _s = (seed * 2654435761) & 0xFFFFFFFF | 1;

  int next(int max) {
    _s ^= (_s << 13) & 0xFFFFFFFF;
    _s ^= _s >> 17;
    _s ^= (_s << 5) & 0xFFFFFFFF;
    _s &= 0xFFFFFFFF;
    return _s % max;
  }
}

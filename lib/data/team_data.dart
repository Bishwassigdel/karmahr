// Demo data about the employee's coworkers and company events: who's on
// leave, birthdays/work anniversaries, and upcoming company events.
//
// Dates are generated relative to today (same approach as LeaveState's
// seed) so the demo always has someone out today, a celebration this
// month, and events coming up — instead of going stale in a week. Swap
// these functions for real API calls later; screens don't change.

class TeamLeave {
  final String name;
  final String initials;
  final String leaveType;
  final DateTime start;
  final DateTime end;

  const TeamLeave({
    required this.name,
    required this.initials,
    required this.leaveType,
    required this.start,
    required this.end,
  });

  bool coversDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return !d.isBefore(start) && !d.isAfter(end);
  }

  /// First day back at work — the day after leave ends (skipping
  /// Saturday, Nepal's weekly holiday).
  DateTime get backOn {
    final next = DateTime(end.year, end.month, end.day + 1);
    return next.weekday == DateTime.saturday
        ? DateTime(next.year, next.month, next.day + 1)
        : next;
  }
}

DateTime _today() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

DateTime _plus(int days) {
  final t = _today();
  return DateTime(t.year, t.month, t.day + days);
}

List<TeamLeave> demoTeamLeave() => [
  TeamLeave(
    name: 'Anita Shrestha',
    initials: 'AS',
    leaveType: 'Home Leave',
    start: _plus(-1),
    end: _plus(2),
  ),
  TeamLeave(
    name: 'Ramesh Thapa',
    initials: 'RT',
    leaveType: 'Sick Leave',
    start: _plus(0),
    end: _plus(0),
  ),
  TeamLeave(
    name: 'Manisha Rai',
    initials: 'MR',
    leaveType: 'Home Leave',
    start: _plus(3),
    end: _plus(6),
  ),
  TeamLeave(
    name: 'Prakash Adhikari',
    initials: 'PA',
    leaveType: 'Substitute Leave',
    start: _plus(5),
    end: _plus(5),
  ),
];

enum CelebrationKind { birthday, workAnniversary }

class Celebration {
  final String name;
  final String initials;
  final CelebrationKind kind;
  final DateTime date;

  /// Years completed, for work anniversaries.
  final int? years;

  const Celebration({
    required this.name,
    required this.initials,
    required this.kind,
    required this.date,
    this.years,
  });
}

List<Celebration> demoCelebrations() => [
  Celebration(
    name: 'Sita Gurung',
    initials: 'SG',
    kind: CelebrationKind.birthday,
    date: _plus(0),
  ),
  Celebration(
    name: 'Bikash Lama',
    initials: 'BL',
    kind: CelebrationKind.birthday,
    date: _plus(4),
  ),
  Celebration(
    name: 'Suresh Karki',
    initials: 'SK',
    kind: CelebrationKind.workAnniversary,
    date: _plus(9),
    years: 5,
  ),
  Celebration(
    name: 'Anita Shrestha',
    initials: 'AS',
    kind: CelebrationKind.workAnniversary,
    date: _plus(17),
    years: 2,
  ),
];

class CompanyEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startsAt;
  final String venue;

  /// Coworkers already going, not counting this user — demo baseline.
  final int othersGoing;

  const CompanyEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startsAt,
    required this.venue,
    required this.othersGoing,
  });
}

List<CompanyEvent> demoCompanyEvents() {
  DateTime at(int days, int hour, [int minute = 0]) {
    final d = _plus(days);
    return DateTime(d.year, d.month, d.day, hour, minute);
  }

  return [
    CompanyEvent(
      id: 'dashain-lunch',
      title: 'Dashain Celebration Lunch',
      description: 'Tika, sel roti, and lunch together before the break.',
      startsAt: at(2, 12, 30),
      venue: 'Head Office Rooftop',
      othersGoing: 34,
    ),
    CompanyEvent(
      id: 'futsal-friday',
      title: 'Futsal Friday',
      description: 'Inter-department futsal. All skill levels welcome.',
      startsAt: at(8, 17, 30),
      venue: 'Dhapasi Futsal Arena',
      othersGoing: 18,
    ),
    CompanyEvent(
      id: 'town-hall',
      title: 'Quarterly Town Hall',
      description: 'Q1 results, plans for Q2, and open Q&A with leadership.',
      startsAt: at(12, 15),
      venue: 'Main Conference Hall + online',
      othersGoing: 61,
    ),
    CompanyEvent(
      id: 'blood-drive',
      title: 'Blood Donation Drive',
      description: 'With the Nepal Red Cross Society. Walk-ins welcome.',
      startsAt: at(20, 10),
      venue: 'Ground Floor Lobby',
      othersGoing: 22,
    ),
  ];
}

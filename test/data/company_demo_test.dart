import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_flutter_app/data/company_demo.dart';

void main() {
  // A fixed "today" so every number below is stable.
  final today = DateTime(2026, 10, 5);
  final c = CompanyDemo.generate(today: today);

  String fingerprint(CompanyDemo d) => [
    for (final p in d.people)
      '${p.id}|${p.name}|${p.attendance}|${p.monthlyGross}',
  ].join(';');

  group('the generated company', () {
    test('is the same every time, so screens and tests can rely on it', () {
      final again = CompanyDemo.generate(today: today);
      expect(fingerprint(again), fingerprint(c));
      expect(again.leavers.length, c.leavers.length);
    });

    test('a different seed gives a different company', () {
      final other = CompanyDemo.generate(today: today, seed: 99);
      expect(fingerprint(other), isNot(fingerprint(c)));
    });

    test('has 5 branches, 8 departments and 290 people', () {
      expect(c.branches.length, 5);
      expect(c.depts.length, 8);
      expect(c.people.length, 290);
    });

    test('each department has the size it was given', () {
      int n(String id) => c.peopleIn(deptId: id).length;
      expect(n('d-ops'), 70);
      expect(n('d-sales'), 55);
      expect(n('d-support'), 50);
      expect(n('d-it'), 40);
      expect(n('d-legal'), 10);
    });

    test('everyone has a unique ID and a real branch and department', () {
      expect({for (final p in c.people) p.id}.length, c.people.length);
      final branchIds = {for (final b in c.branches) b.id};
      final deptIds = {for (final d in c.depts) d.id};
      for (final p in c.people) {
        expect(branchIds, contains(p.branchId));
        expect(deptIds, contains(p.deptId));
        expect(p.name, isNotEmpty);
      }
    });

    test('every branch has people, and Kathmandu is the biggest', () {
      final sizes = {
        for (final b in c.branches) b.id: c.peopleIn(branchId: b.id).length,
      };
      expect(sizes.values.every((n) => n > 0), isTrue);
      final biggest = sizes.values.reduce((a, b) => a > b ? a : b);
      expect(sizes['b-ktm'], biggest);
    });

    test('every figure is in its valid range', () {
      for (final p in c.people) {
        expect(p.attendance, inInclusiveRange(40, 100));
        expect(p.goals, inInclusiveRange(0, 100));
        expect(p.leaveBalance, inInclusiveRange(0, 19));
        expect(p.monthlyGross, greaterThan(20000));
        expect(p.joinedOn.isAfter(today), isFalse);
        expect(p.tenureMonths(today), greaterThanOrEqualTo(0));
      }
    });

    test('pay is rounded to the nearest Rs. 500', () {
      for (final p in c.people) {
        expect(p.monthlyGross % 500, 0);
      }
    });
  });

  group('progress', () {
    test('the score is the weighted blend, and the weights add to 1', () {
      expect(
        Progress.goalsWeight +
            Progress.reviewsWeight +
            Progress.trainingWeight +
            Progress.attendanceWeight,
        closeTo(1.0, 1e-9),
      );
      const p = Progress(
        headcount: 10,
        plan: 10,
        goals: 80,
        reviews: 60,
        training: 50,
        attendance: 90,
      );
      // 28 + 15 + 10 + 18
      expect(p.score, 71);
    });

    test('status thresholds: 75 on track, 60 watch, below that behind', () {
      Progress at(int s) => Progress(
        headcount: 1,
        plan: 1,
        goals: s,
        reviews: s,
        training: s,
        attendance: s,
      );
      expect(at(75).status, ProgressStatus.onTrack);
      expect(at(74).status, ProgressStatus.watch);
      expect(at(60).status, ProgressStatus.watch);
      expect(at(59).status, ProgressStatus.behind);
    });

    test('gap is plan minus headcount', () {
      const p = Progress(
        headcount: 47,
        plan: 50,
        goals: 0,
        reviews: 0,
        training: 0,
        attendance: 0,
      );
      expect(p.gap, 3);
    });

    test('the demo has strong, middling and struggling departments', () {
      final it = c.progress(deptId: 'd-it');
      final support = c.progress(deptId: 'd-support');
      expect(it.status, ProgressStatus.onTrack);
      expect(support.status, ProgressStatus.behind);
      expect(it.score, greaterThan(support.score));
      final statuses = {
        for (final d in c.depts) c.progress(deptId: d.id).status,
      };
      expect(statuses.length, greaterThanOrEqualTo(2));
    });

    test('headcount of branches adds up to the department', () {
      for (final d in c.depts) {
        final byBranch = c.branches.fold<int>(
          0,
          (sum, b) => sum + c.progress(deptId: d.id, branchId: b.id).headcount,
        );
        expect(byBranch, c.progress(deptId: d.id).headcount, reason: d.name);
      }
    });

    test('plans add up: branches to department, departments to company', () {
      for (final d in c.depts) {
        final byBranch = c.branches.fold<int>(
          0,
          (sum, b) => sum + c.planFor(deptId: d.id, branchId: b.id),
        );
        expect(byBranch, c.planFor(deptId: d.id), reason: d.name);
      }
      final byDept = c.depts.fold<int>(
        0,
        (s, d) => s + c.planFor(deptId: d.id),
      );
      expect(byDept, c.planFor());
    });

    test('the plan is never below who is already there', () {
      for (final d in c.depts) {
        for (final b in c.branches) {
          final p = c.progress(deptId: d.id, branchId: b.id);
          expect(p.plan, greaterThanOrEqualTo(p.headcount));
        }
      }
    });

    test('weaker departments are further short of their plan', () {
      final support = c.progress(deptId: 'd-support').gap;
      final finance = c.progress(deptId: 'd-fin').gap;
      expect(support, greaterThan(finance));
    });

    test('an empty slice scores zero instead of failing', () {
      final none = c.progress(deptId: 'nope');
      expect(none.headcount, 0);
      expect(none.score, 0);
      expect(none.status, ProgressStatus.behind);
    });

    test('company progress sits between the best and worst department', () {
      final scores = [for (final d in c.depts) c.progress(deptId: d.id).score];
      final all = c.progress().score;
      expect(
        all,
        greaterThanOrEqualTo(scores.reduce((a, b) => a < b ? a : b)),
      );
      expect(all, lessThanOrEqualTo(scores.reduce((a, b) => a > b ? a : b)));
    });
  });

  group('history', () {
    test('this month matches the people on the books today', () {
      expect(c.headcountAt(0), c.people.length);
      for (final d in c.depts) {
        expect(
          c.headcountAt(0, deptId: d.id),
          c.peopleIn(deptId: d.id).length,
        );
      }
    });

    test('the series has one point per month and ends with today', () {
      final s = c.headcountSeries();
      expect(s.length, 12);
      expect(s.last, c.people.length);
    });

    test('headcount rose over the year, as people joined faster than left', () {
      final s = c.headcountSeries();
      expect(s.last, greaterThan(s.first));
    });

    test('departments add up to the company, month by month', () {
      for (var m = 0; m < 12; m++) {
        final sum = c.depts.fold<int>(
          0,
          (s, d) => s + c.headcountAt(m, deptId: d.id),
        );
        expect(sum, c.headcountAt(m), reason: '$m months ago');
      }
    });

    test('branches add up to the company too', () {
      final sum = c.branches.fold<int>(
        0,
        (s, b) => s + c.headcountAt(6, branchId: b.id),
      );
      expect(sum, c.headcountAt(6));
    });

    test("payroll this month is the sum of everyone's pay", () {
      final total = c.people.fold<double>(0, (s, p) => s + p.monthlyGross);
      expect(c.payrollAt(0), closeTo(total, 0.01));
    });

    test('payroll follows headcount: a later month costs more', () {
      final heads = c.headcountSeries();
      final pay = c.payrollSeries();
      expect(pay.length, 12);
      expect(pay.last, greaterThan(pay.first));
      expect(heads.last, greaterThan(heads.first));
    });

    test('month labels count back from this month', () {
      expect(c.monthLabel(0), 'Oct');
      expect(c.monthLabel(1), 'Sep');
      expect(c.monthLabel(9), 'Jan');
      expect(c.monthLabel(10), 'Dec'); // crosses the year end
    });

    test('joiners and leavers over a period are counted from the dates', () {
      final joined = c.joinedLast(30);
      final manual = c.people
          .where(
            (p) => p.joinedOn.isAfter(today.subtract(const Duration(days: 30))),
          )
          .length;
      expect(joined, manual);
      expect(c.joinedLast(365), greaterThanOrEqualTo(joined));
      expect(c.leftLast(365), c.leavers.length);
    });

    test('attrition is a sane percentage, higher where things are worse', () {
      final all = c.attritionPercent();
      expect(all, inInclusiveRange(2, 40));
      expect(
        c.attritionPercent(deptId: 'd-support'),
        greaterThan(c.attritionPercent(deptId: 'd-fin')),
      );
    });

    test('someone who left is in the past, and joined before leaving', () {
      for (final l in c.leavers) {
        expect(l.leftOn.isBefore(today), isTrue);
        expect(l.joinedOn.isBefore(l.leftOn), isTrue);
        expect(today.difference(l.leftOn).inDays, lessThanOrEqualTo(365));
      }
    });
  });

  group('DemoPerson.tenureMonths', () {
    DemoPerson at(DateTime joined) => DemoPerson(
      id: 'x',
      name: 'x',
      deptId: 'd',
      branchId: 'b',
      jobTitle: 'j',
      joinedOn: joined,
      attendance: 90,
      goals: 50,
      reviewDone: false,
      trainingDone: false,
      leaveBalance: 0,
      monthlyGross: 1,
    );

    test('counts whole months, not rounding up', () {
      expect(at(DateTime(2026, 7, 5)).tenureMonths(DateTime(2026, 10, 5)), 3);
      expect(at(DateTime(2026, 7, 6)).tenureMonths(DateTime(2026, 10, 5)), 2);
    });

    test('crosses year ends', () {
      expect(
        at(DateTime(2024, 11, 20)).tenureMonths(DateTime(2026, 10, 5)),
        22,
      );
    });

    test('is never negative for someone who joins today', () {
      expect(at(DateTime(2026, 10, 5)).tenureMonths(DateTime(2026, 10, 5)), 0);
    });
  });
}

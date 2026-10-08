import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_flutter_app/state/audit_log_state.dart';
import 'package:my_first_flutter_app/state/checklist_state.dart';
import 'package:my_first_flutter_app/state/hiring_state.dart';
import 'package:my_first_flutter_app/state/reviews_state.dart';

void main() {
  group('ReviewsState', () {
    test('starts with two cycles, newest first', () {
      final r = ReviewsState();
      expect(r.cycles.length, 2);
      expect(r.cycles.first.createdAt.isAfter(r.cycles.last.createdAt), isTrue);
    });

    test('progress counts completed reviews', () {
      final c = ReviewsState().byId('c2')!;
      expect(c.total, 8);
      expect(c.completed, 3);
      expect(c.progress, closeTo(3 / 8, 1e-9));
    });

    test('start puts everyone at the first step', () {
      final r = ReviewsState();
      final c = r.start('Q2 review', ['a', 'b'], now: DateTime(2026, 10, 5))!;
      expect(c.total, 2);
      expect(c.stages.values.every((s) => s == ReviewStage.notStarted), isTrue);
      expect(r.cycles.first.id, c.id);
    });

    test('a cycle needs a name and at least one person', () {
      final r = ReviewsState();
      var n = 0;
      r.addListener(() => n++);
      expect(r.start('  ', ['a']), isNull);
      expect(r.start('Q2', const []), isNull);
      expect(r.cycles.length, 2);
      expect(n, 0);
    });

    test('advance moves one person one step, then stops at completed', () {
      final r = ReviewsState();
      final c = r.start('Q2', ['a', 'b'])!;
      for (final expected in [
        ReviewStage.selfDone,
        ReviewStage.managerDone,
        ReviewStage.completed,
        ReviewStage.completed,
      ]) {
        r.advance(c.id, 'a');
        expect(r.byId(c.id)!.stages['a'], expected);
      }
      expect(r.byId(c.id)!.stages['b'], ReviewStage.notStarted);
      expect(r.byId(c.id)!.completed, 1);
    });

    test('advancing an unknown person or cycle does nothing', () {
      final r = ReviewsState();
      var n = 0;
      r.addListener(() => n++);
      r.advance('nope', 'a');
      r.advance('c2', 'nobody');
      expect(n, 0);
    });
  });

  group('HiringState', () {
    test('open jobs come before closed ones', () {
      final jobs = HiringState().jobs;
      expect(jobs.last.isOpen, isFalse);
      expect(jobs.first.isOpen, isTrue);
    });

    test('activeCount excludes hired and rejected', () {
      final h = HiringState();
      expect(h.applicantsFor('j3').length, 1);
      expect(h.activeCount('j3'), 0); // the one applicant was hired
      expect(h.activeCount('j1'), 2);
    });

    test('a job needs a title, department and an opening', () {
      final h = HiringState();
      expect(h.addJob('', 'Finance', 1), isNull);
      expect(h.addJob('Cook', ' ', 1), isNull);
      expect(h.addJob('Cook', 'Ops', 0), isNull);
      final job = h.addJob('  Cook  ', 'Ops', 2)!;
      expect(job.title, 'Cook');
      expect(job.isOpen, isTrue);
      expect(h.jobs.length, 4);
    });

    test('setOpen closes and reopens, and ignores a no-op', () {
      final h = HiringState();
      var n = 0;
      h.addListener(() => n++);
      h.setOpen('j1', false);
      expect(h.jobById('j1')!.isOpen, isFalse);
      h.setOpen('j1', false);
      expect(n, 1);
    });

    test('an applicant needs a name and a real job', () {
      final h = HiringState();
      expect(h.addApplicant('j1', ' ', 'a@b.com'), isNull);
      expect(h.addApplicant('nope', 'Ram', ''), isNull);
      final a = h.addApplicant('j1', ' Ram ', ' ram@x.com ')!;
      expect(a.name, 'Ram');
      expect(a.email, 'ram@x.com');
      expect(a.stage, ApplicantStage.applied);
    });

    test('advance goes applied > screening > interview > offer > hired', () {
      final h = HiringState();
      final a = h.addApplicant('j1', 'Ram', '')!;
      final seen = <ApplicantStage>[];
      for (var i = 0; i < 6; i++) {
        h.advance(a.id);
        seen.add(h.applicantsFor('j1').firstWhere((x) => x.id == a.id).stage);
      }
      expect(seen, [
        ApplicantStage.screening,
        ApplicantStage.interview,
        ApplicantStage.offer,
        ApplicantStage.hired,
        ApplicantStage.hired, // the end of the line
        ApplicantStage.hired,
      ]);
    });

    test(
      'reject ends consideration, and a rejected applicant cannot advance',
      () {
        final h = HiringState();
        h.reject('a2');
        expect(
          h.applicantsFor('j1').firstWhere((a) => a.id == 'a2').stage,
          ApplicantStage.rejected,
        );
        h.advance('a2');
        expect(
          h.applicantsFor('j1').firstWhere((a) => a.id == 'a2').stage,
          ApplicantStage.rejected,
        );
        expect(h.activeCount('j1'), 1);
      },
    );

    test('a hired applicant cannot be rejected afterwards', () {
      final h = HiringState();
      h.reject('a5'); // Pooja, already hired
      expect(h.applicantsFor('j3').single.stage, ApplicantStage.hired);
    });
  });

  group('ChecklistState', () {
    test('seed has partial progress for a joiner and a leaver', () {
      final c = ChecklistState();
      expect(c.doneCount('MB-24012', onboardingItems), 2);
      expect(c.doneCount('MB-22030', offboardingItems), 2);
      expect(c.doneCount('MB-24071', onboardingItems), 0);
    });

    test('toggle ticks and unticks, and notifies each time', () {
      final c = ChecklistState();
      var n = 0;
      c.addListener(() => n++);
      c.toggle('MB-24071', ChecklistItem.createAccounts);
      expect(c.isDone('MB-24071', ChecklistItem.createAccounts), isTrue);
      c.toggle('MB-24071', ChecklistItem.createAccounts);
      expect(c.isDone('MB-24071', ChecklistItem.createAccounts), isFalse);
      expect(n, 2);
    });

    test('people are independent', () {
      final c = ChecklistState();
      c.toggle('A', ChecklistItem.exitInterview);
      expect(c.isDone('B', ChecklistItem.exitInterview), isFalse);
    });

    test('joining and leaving steps do not overlap', () {
      expect(
        onboardingItems.toSet().intersection(offboardingItems.toSet()),
        isEmpty,
      );
      expect(
        onboardingItems.length + offboardingItems.length,
        ChecklistItem.values.length,
      );
    });
  });

  group('AuditLogState.toCsv', () {
    test('a header, then one row per entry, newest first', () {
      final log = AuditLogState();
      log.log(
        AuditAction.employeeAdded,
        'Nima',
        actor: 'Asha',
        now: DateTime(2026, 10, 5, 9, 5),
      );
      log.log(
        AuditAction.payrollRun,
        'Ashwin 2083',
        actor: 'Asha',
        now: DateTime(2026, 10, 5, 14, 30),
      );
      final lines = log.toCsv().split('\n');
      expect(lines.first, 'When,Actor,Action,Detail');
      expect(lines[1], '2026-10-05 14:30,Asha,payrollRun,Ashwin 2083');
      expect(lines[2], '2026-10-05 09:05,Asha,employeeAdded,Nima');
    });

    test('commas and quotes in a detail are escaped', () {
      final log = AuditLogState();
      log.log(
        AuditAction.noticePublished,
        'Hello, "all"',
        actor: 'A',
        now: DateTime(2026, 1, 1),
      );
      expect(log.toCsv(), contains('"Hello, ""all"""'));
    });

    test('an empty log is just the header', () {
      expect(AuditLogState().toCsv(), 'When,Actor,Action,Detail');
    });
  });
}

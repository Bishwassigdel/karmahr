import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_flutter_app/data/company_demo.dart';
import 'package:my_first_flutter_app/domain/owner_insights.dart';

void main() {
  final c = CompanyDemo.generate(today: DateTime(2026, 10, 5));

  group('largeEnoughToShow', () {
    test('needs at least $minGroupForStats people', () {
      expect(largeEnoughToShow(0), isFalse);
      expect(largeEnoughToShow(minGroupForStats - 1), isFalse);
      expect(largeEnoughToShow(minGroupForStats), isTrue);
      expect(largeEnoughToShow(300), isTrue);
    });
  });

  group('companyAttention', () {
    test('flags the struggling department first', () {
      final items = companyAttention(c);
      expect(items, isNotEmpty);
      expect(items.first.kind, AttentionKind.deptBehind);
      expect(items.first.id, 'd-support');
      expect(items.first.value, lessThan(60));
    });

    test('is ordered by seriousness: behind, attrition, short, attendance', () {
      final order = {
        AttentionKind.deptBehind: 0,
        AttentionKind.deptAttrition: 1,
        AttentionKind.deptShort: 2,
        AttentionKind.branchAttendance: 3,
      };
      final ranks = [for (final i in companyAttention(c)) order[i.kind]!];
      expect(ranks, [...ranks]..sort());
    });

    test('within a kind, the worst comes first', () {
      final items = companyAttention(c);
      final behind = items.where((i) => i.kind == AttentionKind.deptBehind);
      final scores = [for (final i in behind) i.value];
      expect(scores, [...scores]..sort());
      final attr = items.where((i) => i.kind == AttentionKind.deptAttrition);
      final percents = [for (final i in attr) i.value];
      expect(percents, [...percents]..sort((a, b) => b.compareTo(a)));
    });

    test('every item points at a real department or branch', () {
      final ids = {
        for (final d in c.depts) d.id,
        for (final b in c.branches) b.id,
      };
      for (final i in companyAttention(c)) {
        expect(ids, contains(i.id));
        expect(i.name, isNotEmpty);
      }
    });

    test('a healthy department is not flagged as behind', () {
      final flagged = {
        for (final i in companyAttention(c))
          if (i.kind == AttentionKind.deptBehind) i.id,
      };
      expect(flagged, isNot(contains('d-it')));
      expect(flagged, isNot(contains('d-fin')));
    });

    test('every flagged value really crosses its threshold', () {
      for (final i in companyAttention(c)) {
        switch (i.kind) {
          case AttentionKind.deptBehind:
            expect(i.value, lessThan(60));
          case AttentionKind.deptAttrition:
            expect(i.value, greaterThanOrEqualTo(attritionAlertPercent));
          case AttentionKind.deptShort:
            expect(i.value, greaterThanOrEqualTo(shortAlertPeople));
          case AttentionKind.branchAttendance:
            expect(i.value, lessThan(branchAttendanceAlert));
        }
      }
    });
  });

  group('compactRupees', () {
    test('small amounts are written in full with commas', () {
      expect(compactRupees(0), 'Rs. 0');
      expect(compactRupees(950), 'Rs. 950');
      expect(compactRupees(38000), 'Rs. 38,000');
      expect(compactRupees(99999), 'Rs. 99,999');
    });

    test('a lakh and up is shown in lakh with one decimal at most', () {
      expect(compactRupees(100000), 'Rs. 1 lakh');
      expect(compactRupees(1250000), 'Rs. 12.5 lakh');
      expect(compactRupees(9990000), 'Rs. 99.9 lakh');
    });

    test('a crore and up is shown in crore with two decimals at most', () {
      expect(compactRupees(10000000), 'Rs. 1 crore');
      expect(compactRupees(15230000), 'Rs. 1.52 crore');
      expect(compactRupees(250000000), 'Rs. 25 crore');
    });

    test('the words can be translated', () {
      expect(compactRupees(2500000, lakh: 'लाख', crore: 'करोड'), 'Rs. 25 लाख');
      expect(compactRupees(20000000, crore: 'करोड'), 'Rs. 2 करोड');
    });

    test('negative amounts keep their sign', () {
      expect(compactRupees(-1250000), '-Rs. 12.5 lakh');
      expect(compactRupees(-500), '-Rs. 500');
    });

    test('the demo company payroll reads sensibly', () {
      final text = compactRupees(c.payrollAt(0));
      expect(text, contains('crore'));
    });
  });

  group('percentChange', () {
    test('is the rounded change against before', () {
      expect(percentChange(110, 100), 10);
      expect(percentChange(90, 100), -10);
      expect(percentChange(100, 100), 0);
      expect(percentChange(101.4, 100), 1);
    });

    test('is null when there is nothing to compare against', () {
      expect(percentChange(50, 0), isNull);
    });
  });
}

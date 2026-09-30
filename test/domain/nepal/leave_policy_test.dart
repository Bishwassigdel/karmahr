import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_flutter_app/domain/nepal/leave_policy.dart';

void main() {
  group('leavePolicies table', () {
    test('has an entry for every leave type offered in the apply-leave form', () {
      // Kept in sync manually with leave_screen.dart's _leaveTypes list —
      // if this fails after adding a new leave type there, add a matching
      // LeavePolicy entry here too.
      const typesOfferedInUi = [
        'Home Leave',
        'Sick Leave',
        'Maternity Leave',
        'Maternity Care Leave',
        'Mourning Leave',
        'Substitute Leave',
        'Unpaid Leave',
      ];
      for (final type in typesOfferedInUi) {
        expect(
          leavePolicies.containsKey(type),
          isTrue,
          reason: '$type is offered in the UI but has no LeavePolicy',
        );
      }
    });

    test('every policy sets exactly one of annualGrant/accrualPerWorkedDays', () {
      // Enforced by an assert in the constructor already; this just
      // confirms none of the const entries silently violate it.
      for (final policy in leavePolicies.values) {
        final hasGrant = policy.annualGrant != null;
        final hasAccrual = policy.accrualPerWorkedDays != null;
        expect(hasGrant != hasAccrual, isTrue, reason: policy.type);
      }
    });
  });

  group('isAccrualBased', () {
    test('Home Leave accrues rather than being flat-granted', () {
      expect(leavePolicies['Home Leave']!.isAccrualBased, isTrue);
    });

    test('Sick Leave is a flat annual grant, not accrual-based', () {
      expect(leavePolicies['Sick Leave']!.isAccrualBased, isFalse);
    });
  });

  group('policyFor', () {
    test('returns the matching policy for a known type', () {
      expect(policyFor('Sick Leave')?.type, 'Sick Leave');
    });

    test('returns null for an unknown type', () {
      expect(policyFor('Sabbatical'), isNull);
    });
  });

  group('domain rules worth protecting', () {
    test('Unpaid Leave is not paid', () {
      expect(leavePolicies['Unpaid Leave']!.paid, isFalse);
    });

    test('Maternity Leave is not available during probation', () {
      expect(leavePolicies['Maternity Leave']!.allowedDuringProbation, isFalse);
    });

    test('Sick Leave requires a document beyond its threshold', () {
      final sick = leavePolicies['Sick Leave']!;
      expect(sick.requiresDocument, isTrue);
      expect(sick.documentThresholdDays, greaterThan(0));
    });
  });
}

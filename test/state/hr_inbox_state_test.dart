import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_flutter_app/state/company_holidays_state.dart';
import 'package:my_first_flutter_app/state/hr_inbox_state.dart';

void main() {
  group('HrInboxState', () {
    test('starts with pending and already-decided requests', () {
      final inbox = HrInboxState();
      expect(inbox.pendingCount, 7);
      expect(inbox.decided.length, 2);
      expect(inbox.items.length, 9);
    });

    test('pending are listed oldest first', () {
      final pending = HrInboxState().pending;
      for (var i = 1; i < pending.length; i++) {
        expect(
          pending[i - 1].submittedAt.isAfter(pending[i].submittedAt),
          isFalse,
        );
      }
    });

    test('approving moves a request to decided and notifies', () {
      final inbox = HrInboxState();
      var notified = 0;
      inbox.addListener(() => notified++);

      inbox.decide('r1', InboxStatus.approved);

      expect(inbox.pendingCount, 6);
      expect(
        inbox.decided.firstWhere((i) => i.id == 'r1').status,
        InboxStatus.approved,
      );
      expect(notified, 1);
    });

    test('a decision is final: deciding again changes nothing', () {
      final inbox = HrInboxState();
      inbox.decide('r1', InboxStatus.approved);
      var notified = 0;
      inbox.addListener(() => notified++);

      inbox.decide('r1', InboxStatus.rejected);

      expect(
        inbox.items.firstWhere((i) => i.id == 'r1').status,
        InboxStatus.approved,
      );
      expect(notified, 0);
    });

    test('asking for "pending" or an unknown id does nothing', () {
      final inbox = HrInboxState();
      inbox.decide('r2', InboxStatus.pending);
      inbox.decide('nope', InboxStatus.approved);
      expect(inbox.pendingCount, 7);
    });

    test('rejecting works the same way', () {
      final inbox = HrInboxState()..decide('r4', InboxStatus.rejected);
      expect(
        inbox.items.firstWhere((i) => i.id == 'r4').status,
        InboxStatus.rejected,
      );
      expect(inbox.pendingCount, 6);
    });
  });

  group('CompanyHolidaysState', () {
    test('starts with two upcoming holidays, soonest first', () {
      final holidays = CompanyHolidaysState().holidays;
      expect(holidays.length, 2);
      expect(holidays.first.date.isBefore(holidays.last.date), isTrue);
    });

    test('add keeps the list sorted and trims the name', () {
      final state = CompanyHolidaysState();
      final soon = DateTime.now().add(const Duration(days: 3));
      state.add('  Team Day  ', soon);

      expect(state.holidays.first.title, 'Team Day');
      expect(state.holidays.length, 3);
    });

    test('an empty name is ignored', () {
      final state = CompanyHolidaysState();
      var notified = 0;
      state.addListener(() => notified++);
      state.add('   ', DateTime.now());
      expect(state.holidays.length, 2);
      expect(notified, 0);
    });

    test('the stored date has no time of day', () {
      final state = CompanyHolidaysState();
      state.add('Late', DateTime(2027, 5, 5, 23, 59));
      final added = state.holidays.firstWhere((h) => h.title == 'Late');
      expect([added.date.hour, added.date.minute], [0, 0]);
    });

    test('remove deletes by id', () {
      final state = CompanyHolidaysState();
      final id = state.holidays.first.id;
      state.remove(id);
      expect(state.holidays.length, 1);
      expect(state.holidays.any((h) => h.id == id), isFalse);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_flutter_app/state/employee_documents_state.dart';

void main() {
  final today = DateTime(2026, 10, 5);

  group('EmployeeDocument.daysLeft', () {
    EmployeeDocument doc(DateTime? expires) => EmployeeDocument(
      id: 'x',
      employeeId: 'E',
      type: DocType.contract,
      title: 't',
      expiresOn: expires,
    );

    test('null when it never expires', () {
      expect(doc(null).daysLeft(today), isNull);
    });

    test('counts whole calendar days, ignoring the time of day', () {
      expect(doc(DateTime(2026, 10, 15)).daysLeft(today), 10);
      expect(doc(DateTime(2026, 10, 5, 23, 59)).daysLeft(today), 0);
      expect(
        doc(DateTime(2026, 10, 15)).daysLeft(DateTime(2026, 10, 5, 23, 59)),
        10,
      );
    });

    test('negative once expired', () {
      expect(doc(DateTime(2026, 10, 1)).daysLeft(today), -4);
    });

    test('is not thrown off by a daylight-saving change in between', () {
      // Across 8 Nov 2026 (US clocks go back): still exactly 10 days.
      expect(doc(DateTime(2026, 11, 10)).daysLeft(DateTime(2026, 10, 31)), 10);
    });
  });

  group('EmployeeDocumentsState', () {
    test('seed has documents for several people', () {
      final s = EmployeeDocumentsState();
      expect(s.all.length, 7);
      expect(s.forEmployee('MB-24071').single.type, DocType.citizenship);
    });

    test('expiringSoon includes expired and the next 30 days, in order', () {
      final s = EmployeeDocumentsState();
      final soon = s.expiringSoon();

      // expired (-5), 12 days, 20 days; the 200-day certificate and the
      // ones with no expiry are left out.
      expect(soon.map((d) => d.id), ['d4', 'd3', 'd2']);
    });

    test('exactly 30 days away still counts, 31 does not', () {
      final s = EmployeeDocumentsState();
      s.add(
        employeeId: 'E',
        type: DocType.other,
        title: 'edge 30',
        expiresOn: DateTime(2026, 11, 4),
      );
      s.add(
        employeeId: 'E',
        type: DocType.other,
        title: 'edge 31',
        expiresOn: DateTime(2026, 11, 5),
      );
      final titles = s.expiringSoon(now: today).map((d) => d.title);
      expect(titles, contains('edge 30'));
      expect(titles, isNot(contains('edge 31')));
    });

    test('add trims the title and strips the time from the date', () {
      final s = EmployeeDocumentsState();
      final ok = s.add(
        employeeId: 'MB-24071',
        type: DocType.pan,
        title: '  PAN card  ',
        expiresOn: DateTime(2030, 1, 1, 17, 30),
      );
      expect(ok, isTrue);
      final added = s.forEmployee('MB-24071').last;
      expect(added.title, 'PAN card');
      expect([added.expiresOn!.hour, added.expiresOn!.minute], [0, 0]);
    });

    test('a blank title is refused and nothing changes', () {
      final s = EmployeeDocumentsState();
      var n = 0;
      s.addListener(() => n++);
      expect(
        s.add(employeeId: 'E', type: DocType.other, title: '   '),
        isFalse,
      );
      expect(s.all.length, 7);
      expect(n, 0);
    });

    test('remove deletes by id, and an unknown id does not notify', () {
      final s = EmployeeDocumentsState();
      var n = 0;
      s.addListener(() => n++);
      s.remove('d1');
      expect(s.all.any((d) => d.id == 'd1'), isFalse);
      s.remove('nope');
      expect(n, 1);
    });
  });
}

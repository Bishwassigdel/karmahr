import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_flutter_app/domain/pdf_documents.dart';
import 'package:my_first_flutter_app/state/employee_records_state.dart';

// The pdf package writes text word by word, so look for each word alone.
String _text(List<int> bytes) => latin1.decode(bytes);
Matcher _prints(String phrase) =>
    allOf([for (final w in phrase.split(' ')) contains('[($w)]TJ')]);

void main() {
  final record = EmployeeRecordsState().byId('MB-24071')!;
  final profile = record.toProfile();

  test('the appointment letter names the person, post and pay', () async {
    final bytes = await buildAppointmentLetterPdf(
      employee: profile,
      issuedOn: DateTime(2026, 10, 5),
      compress: false,
    );
    final text = _text(bytes);

    expect(text, startsWith('%PDF'));
    expect(text, _prints('APPOINTMENT LETTER'));
    expect(text, _prints('Dear Bishwas Sigdel,'));
    expect(text, _prints('HR Associate'));
    expect(text, _prints('Human Resources'));
    expect(text, _prints('Rs. 45,000')); // basic
    expect(text, _prints('Rs. 52,500')); // gross
    expect(text, _prints('report to Suresh Karki.')); // reports to
    expect(text, _prints('KHR/AL/MB-24071/20261005'));
  });

  test(
    'the appointment letter omits "report to" for someone with no manager',
    () async {
      final boss = EmployeeRecordsState().byId('MB-21003')!.toProfile();
      final text = _text(
        await buildAppointmentLetterPdf(employee: boss, compress: false),
      );
      expect(text.contains('[(report)]TJ'), isFalse);
    },
  );

  test('the experience letter states the dates worked', () async {
    final bytes = await buildExperienceLetterPdf(
      employee: profile,
      lastWorkingDay: DateTime(2026, 9, 30),
      issuedOn: DateTime(2026, 10, 5),
      compress: false,
    );
    final text = _text(bytes);

    expect(text, _prints('EXPERIENCE LETTER'));
    expect(text, _prints('January 12, 2024')); // joined
    expect(text, _prints('September 30, 2026')); // last day
    expect(text, _prints('KHR/EL/MB-24071/20261005'));
  });

  test('every letter is marked as an unsigned draft', () async {
    final text = _text(
      await buildExperienceLetterPdf(
        employee: profile,
        lastWorkingDay: DateTime(2026, 9, 30),
        compress: false,
      ),
    );
    expect(text, _prints('DRAFT - UNSIGNED'));
  });

  test(
    'the salary certificate works for any employee, not just the demo one',
    () async {
      final other = EmployeeRecordsState().byId('MB-22015')!.toProfile();
      final text = _text(
        await buildSalaryCertificatePdf(employee: other, compress: false),
      );
      expect(text, _prints('Anita Shrestha'));
      // The ID is followed by a closing bracket, which PDF text escapes.
      expect(text, contains('MB-22015'));
    },
  );
}

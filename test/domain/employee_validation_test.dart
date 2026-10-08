import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_flutter_app/domain/employee_validation.dart';

void main() {
  group('isValidEmail', () {
    test('accepts ordinary addresses', () {
      expect(isValidEmail('nima@karmahr.com'), isTrue);
      expect(isValidEmail('  nima.s@mail.co.np '), isTrue);
    });
    test('rejects the rest', () {
      for (final bad in [
        '',
        'nima',
        'nima@',
        '@karmahr.com',
        'a b@c.com',
        'a@b',
      ]) {
        expect(isValidEmail(bad), isFalse, reason: bad);
      }
    });
  });

  group('isValidNepaliMobile', () {
    test(
      'accepts 96/97/98 numbers, with or without +977, spaces or dashes',
      () {
        for (final ok in [
          '9841234567',
          '9741234567',
          '9641234567',
          '+9779841234567',
          '+977 984-123 4567',
          '984 123 4567',
        ]) {
          expect(isValidNepaliMobile(ok), isTrue, reason: ok);
        }
      },
    );
    test('rejects wrong prefixes, lengths and letters', () {
      for (final bad in [
        '9541234567',
        '984123456',
        '98412345678',
        'abc',
        '',
        '+9779541234567',
      ]) {
        expect(isValidNepaliMobile(bad), isFalse, reason: bad);
      }
    });
  });

  group('parseMoney', () {
    test('reads plain, comma and decimal amounts', () {
      expect(parseMoney('45000'), 45000);
      expect(parseMoney(' 45,000 '), 45000);
      expect(parseMoney('45000.50'), 45000.5);
    });
    test('blank is zero (an allowance can be left empty)', () {
      expect(parseMoney(''), 0);
      expect(parseMoney('   '), 0);
    });
    test('text and negatives are rejected', () {
      expect(parseMoney('abc'), isNull);
      expect(parseMoney('-5'), isNull);
      expect(parseMoney('1.2.3'), isNull);
    });
  });

  group('firstProblem', () {
    String? run({
      String name = 'Nima',
      String job = 'Designer',
      String dept = 'Product',
      String email = 'n@k.com',
      String phone = '9841234567',
      double? basic = 50000,
    }) => firstProblem(
      name: name,
      jobTitle: job,
      department: dept,
      email: email,
      phone: phone,
      basicSalary: basic,
    )?.name;

    test('good details have no problem', () => expect(run(), isNull));
    test('reports the first problem in a fixed order', () {
      expect(run(name: ' '), 'name');
      expect(run(name: '', email: 'bad', basic: 0), 'name');
      expect(run(job: ''), 'job');
      expect(run(dept: ' '), 'job');
      expect(run(email: 'bad'), 'email');
      expect(run(phone: '123'), 'phone');
      expect(run(basic: 0), 'salary');
      expect(run(basic: null), 'salary');
    });
  });
}

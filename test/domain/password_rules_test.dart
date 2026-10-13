import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_flutter_app/domain/password_rules.dart';

void main() {
  test('a good password passes', () {
    expect(passwordProblem('longenough1', 'longenough1'), isNull);
  });

  test('exactly the minimum length passes, one less does not', () {
    expect(passwordProblem('a' * 8, 'a' * 8), isNull);
    expect(passwordProblem('a' * 7, 'a' * 7), PasswordProblem.tooShort);
  });

  test('too short is reported before a mismatch', () {
    expect(passwordProblem('abc', 'xyz'), PasswordProblem.tooShort);
  });

  test('two different passwords are a mismatch', () {
    expect(
      passwordProblem('longenough1', 'longenough2'),
      PasswordProblem.mismatch,
    );
  });

  test('the new password may not equal the old one', () {
    expect(
      passwordProblem('samepass123', 'samepass123', old: 'samepass123'),
      PasswordProblem.sameAsOld,
    );
    expect(
      passwordProblem('newpass1234', 'newpass1234', old: 'samepass123'),
      isNull,
    );
  });
}

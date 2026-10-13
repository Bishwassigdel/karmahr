import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_flutter_app/data/current_employee.dart';
import 'package:my_first_flutter_app/state/auth_repository.dart';
import 'package:my_first_flutter_app/state/auth_state.dart';

void main() {
  // The signed-in person is app-wide state; every test starts as the demo.
  setUp(resetCurrentEmployee);
  tearDown(resetCurrentEmployee);

  group('roleForKey: the database role decides the portal', () {
    test('each built-in role opens the right portal', () {
      expect(roleForKey('employee'), UserRole.employee);
      expect(roleForKey('hr'), UserRole.hr);
      expect(roleForKey('executive'), UserRole.owner);
    });

    test('Company Admin opens the HR portal', () {
      expect(roleForKey('company_admin'), UserRole.hr);
    });

    test('an unknown or misspelt role opens nothing', () {
      expect(roleForKey('ceo'), isNull);
      expect(roleForKey('HR'), isNull); // keys are exact, lower case
      expect(roleForKey(''), isNull);
      expect(roleForKey('admin'), isNull);
    });
  });

  group('AuthState with a real login', () {
    const user = AppUser(
      role: UserRole.hr,
      name: 'Hari HR',
      companyId: 'c1',
      employeeId: 'e1',
    );

    test('signInAs sets the role and remembers who signed in', () {
      final auth = AuthState()..signInAs(user);
      expect(auth.role, UserRole.hr);
      expect(auth.isSignedIn, isTrue);
      expect(auth.user?.name, 'Hari HR');
      expect(auth.user?.companyId, 'c1');
    });

    test('signOut forgets the person as well as the role', () {
      final auth = AuthState()..signInAs(user);
      auth.signOut();
      expect(auth.role, isNull);
      expect(auth.user, isNull);
      expect(auth.isSignedIn, isFalse);
    });

    test('the demo sign-in has a role but no user', () {
      final auth = AuthState()..signIn(UserRole.employee);
      expect(auth.role, UserRole.employee);
      expect(auth.user, isNull);
    });

    test('signing in as someone else replaces the earlier person', () {
      final auth = AuthState()..signInAs(user);
      auth.signInAs(
        const AppUser(role: UserRole.owner, name: 'Eka Exec', companyId: 'c1'),
      );
      expect(auth.role, UserRole.owner);
      expect(auth.user?.name, 'Eka Exec');
    });
  });

  group('whose screens these are (currentEmployee)', () {
    final sita = EmployeeProfile(
      name: 'Sita Employee',
      employeeId: 'KD-2',
      jobTitle: 'Support Agent',
      department: 'Support',
      manager: 'Hari HR',
      joiningDate: DateTime(2025, 3, 1),
      employmentType: 'Full-Time',
      workLocation: 'Kathmandu',
      email: 'sita@karma.com',
      basicSalary: 30000,
      dearnessAllowance: 2000,
      transportAllowance: 1000,
    );

    test('before anyone signs in, it is the demo person', () {
      expect(currentEmployee.name, demoEmployee.name);
    });

    test('a real sign-in makes the screens show that person\'s own record', () {
      AuthState().signInAs(
        AppUser(
          role: UserRole.employee,
          name: 'Sita Employee',
          companyId: 'c1',
          employeeId: 'e2',
          profile: sita,
        ),
      );
      expect(currentEmployee.name, 'Sita Employee');
      expect(currentEmployee.employeeId, 'KD-2');
      expect(currentEmployee.basicSalary, 30000);
      expect(currentEmployee.grossMonthly, 33000);
    });

    test('someone with no employee record shows only their name', () {
      AuthState().signInAs(
        const AppUser(role: UserRole.hr, name: 'Adi Admin', companyId: 'c1'),
      );
      expect(currentEmployee.name, 'Adi Admin');
      // Nothing of the demo person leaks through.
      expect(currentEmployee.employeeId, isEmpty);
      expect(currentEmployee.email, isEmpty);
      expect(currentEmployee.basicSalary, 0);
      expect(currentEmployee.name, isNot(demoEmployee.name));
    });

    test('logging out goes back to the demo person', () {
      final auth = AuthState()
        ..signInAs(
          AppUser(
            role: UserRole.employee,
            name: 'Sita Employee',
            companyId: 'c1',
            profile: sita,
          ),
        );
      auth.signOut();
      expect(currentEmployee.name, demoEmployee.name);
    });

    test('signing in as someone else replaces the earlier person', () {
      final auth = AuthState()
        ..signInAs(
          AppUser(
            role: UserRole.employee,
            name: 'Sita Employee',
            companyId: 'c1',
            profile: sita,
          ),
        );
      auth.signInAs(
        const AppUser(role: UserRole.owner, name: 'Eka Exec', companyId: 'c1'),
      );
      expect(currentEmployee.name, 'Eka Exec');
    });

    test('the demo sign-in always shows the demo person', () {
      final auth = AuthState()
        ..signInAs(
          AppUser(
            role: UserRole.employee,
            name: 'Sita Employee',
            companyId: 'c1',
            profile: sita,
          ),
        );
      auth.signIn(UserRole.employee);
      expect(currentEmployee.name, demoEmployee.name);
    });
  });

  test('the demo repository has no backend and no saved session', () async {
    final repo = DemoAuthRepository();
    expect(repo.usesBackend, isFalse);
    expect(await repo.restoreSession(), isNull);
    await repo.signOut(); // must not throw
    expect(() => repo.signIn('a@b.com', 'x'), throwsA(isA<AuthFailure>()));
  });
}

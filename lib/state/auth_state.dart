import 'package:flutter/foundation.dart';

import '../data/current_employee.dart';
import 'auth_repository.dart' show AppUser;

/// Who is signed in, which decides the portal they see:
///   - employee: the employee app
///   - manager: the employee app plus a Team tab
///   - hr: the HR portal
enum UserRole { employee, manager, hr, owner }

/// The roles the demo login offers. The Manager role is postponed (HR
/// approves everything for now), so it is not offered, though the app still
/// knows how to show it.
const demoLoginRoles = [UserRole.employee, UserRole.hr, UserRole.owner];

class AuthState extends ChangeNotifier {
  // login screen's demo picker sets it.
  UserRole? _role;
  UserRole? get role => _role;
  bool get isSignedIn => _role != null;

  // Who signed in, when it was a real login (null for the demo picker).
  AppUser? _user;
  AppUser? get user => _user;

  /// Demo sign-in: just picks a role.
  void signIn(UserRole role) {
    _role = role;
    _user = null;
    resetCurrentEmployee(); // the demo person
    notifyListeners();
  }

  /// Real sign-in: the role comes from the person's profile.
  void signInAs(AppUser user) {
    _role = user.role;
    _user = user;
    // The employee screens show this person's own record, never the demo
    // person's (a Company Admin may have no record: just their name).
    setCurrentEmployee(user.profile ?? EmployeeProfile.nameOnly(user.name));
    notifyListeners();
  }

  void signOut() {
    if (_role == null) return;
    _role = null;
    _user = null;
    resetCurrentEmployee();
    notifyListeners();
  }
}

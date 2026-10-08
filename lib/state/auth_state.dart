import 'package:flutter/foundation.dart';

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

  void signIn(UserRole role) {
    _role = role;
    notifyListeners();
  }

  void signOut() {
    if (_role == null) return;
    _role = null;
    notifyListeners();
  }
}

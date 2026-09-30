import 'package:flutter/foundation.dart';

/// Who is signed in, which decides the portal they see:
///   - employee: the employee app
///   - manager: the employee app plus a Team tab
///   - hr: the HR portal
enum UserRole { employee, manager, hr }

class AuthState extends ChangeNotifier {
  // TODO(backend): the role comes from the login response. Until then the
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

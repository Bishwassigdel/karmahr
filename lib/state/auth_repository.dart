// Everything the app needs from "the login system", behind one interface.
//
// Two implementations:
//  - SupabaseAuthRepository: real email + password login (used when the app
//    was started with keys, see config/env.dart)
//  - DemoAuthRepository: no backend; the login screen keeps its demo role
//    picker (used by tests, CI and anyone running without a .env)
//
// Screens only talk to [AuthRepository], so tests can swap in a fake.

import '../data/current_employee.dart' show EmployeeProfile;
import 'auth_state.dart';

/// A signed-in person, as the app needs to know them.
class AppUser {
  final UserRole role;
  final String name;
  final String companyId;

  /// Their employee record, if they have one (a Company Admin may not).
  final String? employeeId;

  /// Their own employee record (job, pay...), when they have one and it
  /// could be loaded. The employee screens show this person's details.
  final EmployeeProfile? profile;

  const AppUser({
    required this.role,
    required this.name,
    required this.companyId,
    this.employeeId,
    this.profile,
  });
}

/// Turns the role key stored in the database (roles.key) into the portal
/// the person should see. Returns null for a key we don't know, so a typo
/// in the database can never open a portal by accident.
///
/// Company Admin opens the HR portal for now (same powers plus settings).
UserRole? roleForKey(String key) => switch (key) {
  'employee' => UserRole.employee,
  'hr' || 'company_admin' => UserRole.hr,
  'executive' => UserRole.owner,
  _ => null,
};

/// Why a sign-in failed, so the screen can say something useful.
enum AuthFailureReason {
  /// Wrong email or password.
  wrongCredentials,

  /// The login is valid but has no profile (no company or role yet).
  noProfile,

  /// The login is valid but HR has deactivated this person's account.
  deactivated,

  /// The emailed code is wrong or has expired.
  invalidCode,

  /// The server refused the new password as too weak.
  weakPassword,

  /// Couldn't reach the server, or something unexpected went wrong.
  network,
}

class AuthFailure implements Exception {
  final AuthFailureReason reason;

  const AuthFailure(this.reason);

  @override
  String toString() => 'AuthFailure($reason)';
}

abstract class AuthRepository {
  /// True when logins are real (a backend is connected). False means the
  /// login screen shows its demo role picker instead.
  bool get usesBackend;

  /// Signs in and returns who the person is. Throws [AuthFailure].
  Future<AppUser> signIn(String email, String password);

  /// If a saved session exists (the person stayed signed in), who it is;
  /// otherwise null.
  Future<AppUser?> restoreSession();

  /// Ends the session. Never throws.
  Future<void> signOut();

  /// First visit of an invited employee: makes the login and emails a
  /// 6-digit code to [email]. Throws [AuthFailure].
  Future<void> startSignUp(String email, String password);

  /// Checks the emailed [code], then signs the person in. If HR never
  /// invited this email there is no profile: [AuthFailureReason.noProfile].
  Future<AppUser> finishSignUp(String email, String code);

  /// Emails a 6-digit reset code to [email]. Says nothing about whether
  /// the address has an account.
  Future<void> sendPasswordReset(String email);

  /// Checks the emailed [code] and sets [newPassword]. The person then
  /// signs in with it.
  Future<void> resetPassword(String email, String code, String newPassword);

  /// A signed-in person changes their password; [current] must be right.
  Future<void> changePassword(String current, String next);
}

/// Used when there is no backend: nobody can really sign in.
class DemoAuthRepository implements AuthRepository {
  @override
  bool get usesBackend => false;

  @override
  Future<AppUser> signIn(String email, String password) =>
      Future.error(const AuthFailure(AuthFailureReason.network));

  @override
  Future<AppUser?> restoreSession() async => null;

  @override
  Future<void> signOut() async {}

  static Future<T> _unavailable<T>() =>
      Future.error(const AuthFailure(AuthFailureReason.network));

  @override
  Future<void> startSignUp(String email, String password) => _unavailable();

  @override
  Future<AppUser> finishSignUp(String email, String code) => _unavailable();

  @override
  Future<void> sendPasswordReset(String email) => _unavailable();

  @override
  Future<void> resetPassword(String email, String code, String newPassword) =>
      _unavailable();

  @override
  Future<void> changePassword(String current, String next) => _unavailable();
}

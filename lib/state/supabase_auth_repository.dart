// Real login with Supabase. See auth_repository.dart for the interface.
//
// What happens on sign-in:
//  1. Supabase checks the email and password and keeps the session on the
//     device, which is what makes "stay signed in" work.
//  2. We read the person's own row from `profiles` (the database's
//     Row Level Security only lets them read their own) together with the
//     role key from `roles`.
//  3. The role key decides the portal (roleForKey).

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:supabase_flutter/supabase_flutter.dart'
    show
        AuthApiException,
        AuthException,
        OtpType,
        UserAttributes,
        PostgrestException,
        Supabase,
        SupabaseClient;

import '../data/current_employee.dart' show EmployeeProfile;
import 'auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository([this._injected]);

  // The person sees a short message; the real reason goes to the debug
  // console, so a failure can be diagnosed instead of guessed at.
  static void _log(String what, Object error) =>
      debugPrint('KarmaHR login: $what -> $error');

  final SupabaseClient? _injected;

  // Looked up when first used, not when this object is made: the provider
  // is created before we can be sure Supabase has started.
  SupabaseClient get _client => _injected ?? Supabase.instance.client;

  @override
  bool get usesBackend => true;

  @override
  Future<AppUser> signIn(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } on AuthApiException catch (e) {
      // 400 = "Invalid login credentials". Anything else (rate limit,
      // server error) isn't the person's fault.
      _log('sign-in refused (${e.statusCode} ${e.code})', e.message);
      throw AuthFailure(
        e.statusCode == '400'
            ? AuthFailureReason.wrongCredentials
            : AuthFailureReason.network,
      );
    } catch (e) {
      _log('sign-in failed', e);
      throw const AuthFailure(AuthFailureReason.network);
    }

    // A deactivated person's password still works, so ask the database
    // whether the account is switched off before letting them in. (The
    // database also refuses them any data; this gives a clear message.)
    try {
      if (!await _isActive()) {
        _log('account is deactivated', _client.auth.currentUser?.id ?? '?');
        await signOut();
        throw const AuthFailure(AuthFailureReason.deactivated);
      }
    } on AuthFailure {
      rethrow;
    } catch (e) {
      _log('could not check the account status', e);
      await signOut();
      throw const AuthFailure(AuthFailureReason.network);
    }

    final AppUser? user;
    try {
      user = await _loadProfile();
    } catch (e) {
      _log('could not read the profile', e);
      await signOut();
      throw const AuthFailure(AuthFailureReason.network);
    }
    if (user == null) {
      // A valid login with no profile must not stay signed in.
      _log(
        'signed in, but no usable profile',
        'user ${_client.auth.currentUser?.id}',
      );
      await signOut();
      throw const AuthFailure(AuthFailureReason.noProfile);
    }
    return user;
  }

  @override
  Future<AppUser?> restoreSession() async {
    if (_client.auth.currentSession == null) return null;
    try {
      if (!await _isActive()) {
        // Deactivated since they last opened the app.
        await signOut();
        return null;
      }
      return await _loadProfile();
    } catch (_) {
      // Offline, or the profile was removed: show the login screen.
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException {
      // The device session is already cleared; the server call failing
      // (offline) must not stop a logout.
    }
  }

  // ---- Activate an invited account, and passwords -------------------------
  //
  // Codes, not links: the emails carry a 6-digit code ({{ .Token }} in the
  // Supabase email templates) that the person types into the app, so no
  // deep links or web page are needed.

  @override
  Future<void> startSignUp(String email, String password) async {
    try {
      await _client.auth.signUp(email: email.trim(), password: password);
    } on AuthApiException catch (e) {
      _log('sign-up refused (${e.statusCode} ${e.code})', e.message);
      throw AuthFailure(_reasonFor(e));
    } catch (e) {
      _log('sign-up failed', e);
      throw const AuthFailure(AuthFailureReason.network);
    }
  }

  @override
  Future<AppUser> finishSignUp(String email, String code) async {
    try {
      await _client.auth.verifyOTP(
        email: email.trim(),
        token: code.trim(),
        type: OtpType.signup,
      );
    } on AuthApiException catch (e) {
      _log('code refused (${e.statusCode} ${e.code})', e.message);
      throw const AuthFailure(AuthFailureReason.invalidCode);
    } catch (e) {
      _log('code check failed', e);
      throw const AuthFailure(AuthFailureReason.network);
    }
    // Confirming the email is what makes the database link the invite.
    final AppUser? user;
    try {
      user = await _loadProfile();
    } catch (e) {
      _log('could not read the profile', e);
      await signOut();
      throw const AuthFailure(AuthFailureReason.network);
    }
    if (user == null) {
      await signOut();
      throw const AuthFailure(AuthFailureReason.noProfile);
    }
    return user;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
    } catch (e) {
      _log('reset email failed', e);
      throw const AuthFailure(AuthFailureReason.network);
    }
  }

  @override
  Future<void> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      await _client.auth.verifyOTP(
        email: email.trim(),
        token: code.trim(),
        type: OtpType.recovery,
      );
    } on AuthApiException catch (e) {
      _log('reset code refused (${e.statusCode} ${e.code})', e.message);
      throw const AuthFailure(AuthFailureReason.invalidCode);
    } catch (e) {
      _log('reset code check failed', e);
      throw const AuthFailure(AuthFailureReason.network);
    }
    // The code signed them in just long enough to set the password.
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthApiException catch (e) {
      _log('new password refused (${e.statusCode} ${e.code})', e.message);
      await signOut();
      throw AuthFailure(_reasonFor(e));
    } catch (e) {
      _log('new password failed', e);
      await signOut();
      throw const AuthFailure(AuthFailureReason.network);
    }
    await signOut();
  }

  @override
  Future<void> changePassword(String current, String next) async {
    final email = _client.auth.currentUser?.email;
    if (email == null) throw const AuthFailure(AuthFailureReason.network);
    // Asking for the current password stops someone who picks up an
    // unlocked phone from changing it.
    try {
      await _client.auth.signInWithPassword(email: email, password: current);
    } on AuthApiException catch (e) {
      _log('current password refused (${e.statusCode} ${e.code})', e.message);
      throw AuthFailure(
        e.statusCode == '400'
            ? AuthFailureReason.wrongCredentials
            : AuthFailureReason.network,
      );
    } catch (e) {
      _log('current password check failed', e);
      throw const AuthFailure(AuthFailureReason.network);
    }
    try {
      await _client.auth.updateUser(UserAttributes(password: next));
    } on AuthApiException catch (e) {
      _log('new password refused (${e.statusCode} ${e.code})', e.message);
      throw AuthFailure(_reasonFor(e));
    } catch (e) {
      _log('new password failed', e);
      throw const AuthFailure(AuthFailureReason.network);
    }
  }

  AuthFailureReason _reasonFor(AuthApiException e) => e.code == 'weak_password'
      ? AuthFailureReason.weakPassword
      : AuthFailureReason.network;

  /// False when HR has deactivated the signed-in person.
  Future<bool> _isActive() async =>
      await _client.rpc('account_is_active') as bool;

  /// The signed-in person's profile, or null if they have none or their
  /// role isn't one we know.
  Future<AppUser?> _loadProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final Map<String, dynamic>? row;
    try {
      row = await _client
          .from('profiles')
          .select('full_name, company_id, employee_id, roles(key)')
          .eq('id', userId)
          .maybeSingle();
    } on PostgrestException catch (e) {
      _log('profile query refused', '${e.code} ${e.message}');
      return null;
    }
    if (row == null) {
      _log('no profile row for this login', userId);
      return null;
    }

    final roles = row['roles'];
    final key = roles is Map ? roles['key'] as String? : null;
    final role = key == null ? null : roleForKey(key);
    if (role == null) {
      _log('unknown role', key ?? 'none');
      return null;
    }
    _log('signed in as', '$key (company ${row['company_id']})');

    final employeeId = row['employee_id'] as String?;
    return AppUser(
      role: role,
      name: (row['full_name'] as String?) ?? '',
      companyId: row['company_id'] as String,
      employeeId: employeeId,
      profile: employeeId == null ? null : await _loadEmployee(employeeId),
    );
  }

  /// The person's own employee record: Row Level Security lets everyone
  /// read their own. A failure here must not stop the login, so it returns
  /// null and the app falls back to just their name.
  Future<EmployeeProfile?> _loadEmployee(String employeeId) async {
    try {
      final row = await _client
          .from('employees')
          .select(
            'name, staff_id, job_title, department_id, manager_id, '
            'joining_date, employment_type, work_location, email, '
            'basic_salary, dearness_allowance, transport_allowance',
          )
          .eq('id', employeeId)
          .maybeSingle();
      if (row == null) return null;

      // Department names are readable by the whole company.
      var department = '';
      final departmentId = row['department_id'];
      if (departmentId != null) {
        final d = await _client
            .from('departments')
            .select('name')
            .eq('id', departmentId)
            .maybeSingle();
        department = (d?['name'] as String?) ?? '';
      }

      // The manager's name comes from the colleague directory, which
      // everyone may read (it never includes pay or bank details).
      var manager = '';
      final managerId = row['manager_id'];
      if (managerId != null) {
        final directory = await _client.rpc('company_directory') as List;
        for (final person in directory) {
          if (person['id'] == managerId) manager = person['name'] as String;
        }
      }

      // Numbers normally arrive as numbers; accept text too, never guess pay.
      double money(Object? v) => switch (v) {
        num() => v.toDouble(),
        String() => double.tryParse(v) ?? 0,
        _ => 0,
      };
      return EmployeeProfile(
        name: row['name'] as String,
        employeeId: row['staff_id'] as String,
        jobTitle: row['job_title'] as String,
        department: department,
        manager: manager,
        joiningDate: DateTime.parse(row['joining_date'] as String),
        employmentType: row['employment_type'] as String,
        workLocation: (row['work_location'] as String?) ?? '',
        email: (row['email'] as String?) ?? '',
        basicSalary: money(row['basic_salary']),
        dearnessAllowance: money(row['dearness_allowance']),
        transportAllowance: money(row['transport_allowance']),
      );
    } catch (e) {
      _log('could not load the employee record', e);
      return null;
    }
  }
}

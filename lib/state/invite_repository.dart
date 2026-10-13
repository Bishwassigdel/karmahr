// Inviting employees to sign in. HR picks an employee and an email; the
// employee then activates their own account from the login screen (see
// supabase/migrations/20261012010000_invites.sql for how the database
// links the two).
//
// Two implementations: SupabaseInviteRepository (real) and
// DemoInviteRepository (no backend: HR screens hide the invite section).

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:supabase_flutter/supabase_flutter.dart'
    show PostgrestException, Supabase, SupabaseClient;

import 'employee_repository.dart' show SaveFailure, SaveProblem;
import 'supabase_company.dart';

/// Where an employee stands on signing in.
enum AccountStatus {
  /// No login and no open invite.
  none,

  /// HR invited this email; the employee hasn't activated yet.
  invited,

  /// The employee has a login.
  active,
}

/// What HR sees for one employee: the status and, when invited, the email.
class AccountInfo {
  final AccountStatus status;
  final String email;

  const AccountInfo(this.status, [this.email = '']);
}

abstract class InviteRepository {
  bool get usesBackend;

  /// Where [staffId] stands. Throws [SaveFailure] if it can't be read.
  Future<AccountInfo> statusOf(String staffId);

  /// Invites [staffId] at [email], replacing any open invite.
  /// Throws [SaveFailure].
  Future<void> invite(String staffId, String email);

  /// Withdraws the open invite, if any. Throws [SaveFailure].
  Future<void> cancel(String staffId);
}

class DemoInviteRepository implements InviteRepository {
  @override
  bool get usesBackend => false;

  @override
  Future<AccountInfo> statusOf(String staffId) async =>
      const AccountInfo(AccountStatus.none);

  @override
  Future<void> invite(String staffId, String email) async {}

  @override
  Future<void> cancel(String staffId) async {}
}

class SupabaseInviteRepository implements InviteRepository {
  SupabaseInviteRepository([this._injected]);

  final SupabaseClient? _injected;

  SupabaseClient get _client => _injected ?? Supabase.instance.client;

  static void _log(String what, Object error) =>
      debugPrint('KarmaHR invites: $what -> $error');

  @override
  bool get usesBackend => true;

  @override
  Future<AccountInfo> statusOf(String staffId) => _guard('status', () async {
    final id = await _uuidOf(staffId);
    // HR may read the company's profiles (Day 5), so a profile that points
    // at this employee means they already have a login.
    final profile = await _client
        .from('profiles')
        .select('id')
        .eq('employee_id', id)
        .limit(1);
    if (profile.isNotEmpty) return const AccountInfo(AccountStatus.active);

    final open = await _client
        .from('invites')
        .select('email')
        .eq('employee_id', id)
        .filter('accepted_at', 'is', null)
        .limit(1);
    if (open.isEmpty) return const AccountInfo(AccountStatus.none);
    return AccountInfo(AccountStatus.invited, open.first['email'] as String);
  });

  @override
  Future<void> invite(String staffId, String email) =>
      _guard('invite', () async {
        final id = await _uuidOf(staffId);
        // One open invite per employee: clear the old one, then add the new.
        await _client
            .from('invites')
            .delete()
            .eq('employee_id', id)
            .filter('accepted_at', 'is', null);
        await _client.from('invites').insert({
          'company_id': await companyIdOf(_client),
          'employee_id': id,
          'email': email.trim().toLowerCase(),
        });
      });

  @override
  Future<void> cancel(String staffId) => _guard('cancel', () async {
    await _client
        .from('invites')
        .delete()
        .eq('employee_id', await _uuidOf(staffId))
        .filter('accepted_at', 'is', null);
  });

  Future<String> _uuidOf(String staffId) async {
    final rows = await _client.rpc('company_directory') as List;
    for (final person in rows) {
      if (person['staff_id'] == staffId) return person['id'] as String;
    }
    throw const SaveFailure(SaveProblem.notAllowed);
  }

  Future<T> _guard<T>(String doing, Future<T> Function() work) async {
    try {
      return await work();
    } on SaveFailure {
      rethrow;
    } on PostgrestException catch (e) {
      _log(doing, '${e.code} ${e.message}');
      throw failureFrom(e);
    } catch (e) {
      _log(doing, e);
      throw const SaveFailure(SaveProblem.network);
    }
  }
}

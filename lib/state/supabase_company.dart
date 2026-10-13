// Small helpers the Supabase repositories share.

import 'package:supabase_flutter/supabase_flutter.dart'
    show PostgrestException, SupabaseClient;

import 'employee_repository.dart' show SaveFailure, SaveProblem;

// The signed-in person's company, looked up once per login.
String? _companyId;
String? _companyFor;

/// The company of whoever is signed in on [client]. Every row we add must
/// carry it (the database checks it matches, so a wrong one is refused).
Future<String> companyIdOf(SupabaseClient client) async {
  final userId = client.auth.currentUser?.id;
  if (userId == null) throw const SaveFailure(SaveProblem.notAllowed);
  if (_companyFor != userId) {
    final row = await client
        .from('profiles')
        .select('company_id')
        .eq('id', userId)
        .single();
    _companyId = row['company_id'] as String;
    _companyFor = userId;
  }
  return _companyId!;
}

/// The id of the row in [table] (departments or branches) with this name,
/// ignoring capitals; made first if it doesn't exist. Null for a blank name.
Future<String?> findOrMakeNamed(
  SupabaseClient client,
  String table,
  String name,
) async {
  final wanted = name.trim();
  if (wanted.isEmpty) return null;

  Future<String?> find() async {
    // ilike is a pattern match: escape the characters that mean "any".
    final pattern = wanted
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
    final rows = await client
        .from(table)
        .select('id')
        .ilike('name', pattern)
        .limit(1);
    return rows.isEmpty ? null : rows.first['id'] as String;
  }

  final existing = await find();
  if (existing != null) return existing;
  try {
    final made = await client
        .from(table)
        .insert({'company_id': await companyIdOf(client), 'name': wanted})
        .select('id')
        .single();
    return made['id'] as String;
  } on PostgrestException catch (e) {
    // Someone made the same one a moment ago.
    if (e.code == '23505') return find();
    rethrow;
  }
}

/// A database error as the reason the app shows.
SaveFailure failureFrom(PostgrestException e) {
  switch (e.code) {
    case '23505': // a unique rule: something with that name, ID or email
      final text = '${e.message} ${e.details}';
      if (text.contains('email')) {
        return const SaveFailure(SaveProblem.duplicateEmail);
      }
      if (text.contains('staff_id')) {
        return const SaveFailure(SaveProblem.duplicateStaffId);
      }
      if (text.contains('name')) {
        return const SaveFailure(SaveProblem.duplicateName);
      }
      return const SaveFailure(SaveProblem.conflict);
    case '23503': // a link to something that is gone or not allowed
      return const SaveFailure(SaveProblem.conflict);
    case '42501': // Row Level Security said no
      return const SaveFailure(SaveProblem.notAllowed);
    default:
      return const SaveFailure(SaveProblem.network);
  }
}

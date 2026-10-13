// What makes a new password acceptable before it is sent to the server.
// Pure Dart, so the rules can be tested without any screen.

/// A password shorter than this is refused. (The server has its own,
/// weaker minimum; this is the one people see first.)
const minPasswordLength = 8;

enum PasswordProblem { tooShort, mismatch, sameAsOld }

/// Null when [password] is fine, otherwise the first thing wrong with it.
/// [old] is the current password, when changing one.
PasswordProblem? passwordProblem(
  String password,
  String confirm, {
  String? old,
}) {
  if (password.length < minPasswordLength) return PasswordProblem.tooShort;
  if (password != confirm) return PasswordProblem.mismatch;
  if (old != null && password == old) return PasswordProblem.sameAsOld;
  return null;
}

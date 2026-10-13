import 'package:flutter/widgets.dart';

import '../domain/password_rules.dart';
import '../state/auth_repository.dart' show AuthFailureReason;
import '../state/auth_state.dart';
import '../state/employee_repository.dart' show SaveProblem;
import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  /// This screen's translated strings: `context.l10n.signIn`.
  ///
  /// Falls back to English when no localization delegate is above this
  /// context (a bare CupertinoApp in a widget test), so a screen never
  /// crashes just because translations weren't wired in.
  AppLocalizations get l10n =>
      AppLocalizations.of(this) ?? lookupAppLocalizations(const Locale('en'));
}

extension SaveProblemLabel on SaveProblem {
  String label(AppLocalizations l10n) => switch (this) {
    SaveProblem.duplicateStaffId => l10n.hrErrDuplicateStaffId,
    SaveProblem.duplicateEmail => l10n.hrErrDuplicateEmail,
    SaveProblem.duplicateName => l10n.hrErrDuplicateName,
    SaveProblem.conflict => l10n.hrErrConflict,
    SaveProblem.notAllowed => l10n.hrErrNotAllowed,
    SaveProblem.network => l10n.hrErrSaveNetwork,
  };
}

extension UserRoleLabel on UserRole {
  String label(AppLocalizations l10n) => switch (this) {
    UserRole.employee => l10n.roleEmployee,
    UserRole.manager => l10n.roleManager,
    UserRole.hr => l10n.roleHr,
    UserRole.owner => l10n.roleOwner,
  };
}

extension AuthFailureLabel on AuthFailureReason {
  /// The message for a failed sign-up, activation or password change.
  /// ([AuthFailureReason.wrongCredentials] here is "current password wrong".)
  String accountLabel(AppLocalizations l10n) => switch (this) {
    AuthFailureReason.wrongCredentials => l10n.authErrCurrent,
    AuthFailureReason.noProfile => l10n.loginErrNoProfile,
    AuthFailureReason.deactivated => l10n.loginErrDeactivated,
    AuthFailureReason.invalidCode => l10n.authErrCode,
    AuthFailureReason.weakPassword => l10n.authErrWeak,
    AuthFailureReason.network => l10n.loginErrNetwork,
  };
}

extension PasswordProblemLabel on PasswordProblem {
  String label(AppLocalizations l10n) => switch (this) {
    PasswordProblem.tooShort => l10n.pwErrShort,
    PasswordProblem.mismatch => l10n.pwErrMismatch,
    PasswordProblem.sameAsOld => l10n.pwErrSame,
  };
}

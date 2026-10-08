import 'package:flutter/widgets.dart';

import '../state/auth_state.dart';
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

extension UserRoleLabel on UserRole {
  String label(AppLocalizations l10n) => switch (this) {
    UserRole.employee => l10n.roleEmployee,
    UserRole.manager => l10n.roleManager,
    UserRole.hr => l10n.roleHr,
    UserRole.owner => l10n.roleOwner,
  };
}

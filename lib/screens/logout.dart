import 'package:flutter/cupertino.dart';

import '../l10n/l10n.dart';
import '../state/session.dart';
import 'app_lock_gate.dart';
import 'welcome_screen.dart';

/// Asks, then logs out. Shared by every portal, so each one wipes the
/// session and re-locks the same way.
void confirmLogout(BuildContext context) {
  final l10n = context.l10n;
  showCupertinoDialog<void>(
    context: context,
    builder: (dialogContext) => CupertinoAlertDialog(
      title: Text(l10n.logOut),
      content: Text(l10n.logOutConfirm),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(l10n.cancel),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () {
            // Wipe every piece of this user's data and re-lock BEFORE
            // navigating away. Providers live above the navigator, so
            // they survive pushAndRemoveUntil — see session.dart.
            resetSession(dialogContext);

            // AppLockGate, not a bare WelcomeScreen: pushAndRemoveUntil
            // replaces the ENTIRE stack, so re-entering any other way
            // would bypass the re-lock above.
            Navigator.of(dialogContext, rootNavigator: true).pushAndRemoveUntil(
              CupertinoPageRoute(
                builder: (_) => const AppLockGate(child: WelcomeScreen()),
              ),
              (route) => false,
            );
          },
          child: Text(l10n.logOut),
        ),
      ],
    ),
  );
}

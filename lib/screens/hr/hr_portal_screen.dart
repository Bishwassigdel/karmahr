import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../state/auth_state.dart';
import '../apps/widgets/coming_soon_view.dart';
import '../logout.dart';
import '../settings_screen.dart';

/// Home of the HR/Admin portal. Employee records, payroll, policies and
/// reports are built here next, with a wide (web/tablet) layout.
class HrPortalScreen extends StatelessWidget {
  const HrPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final role = context.watch<AuthState>().role ?? UserRole.hr;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(l10n.hrPortalTitle),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.push(
            context,
            CupertinoPageRoute(builder: (_) => const SettingsScreen()),
          ),
          child: const Icon(CupertinoIcons.settings),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => confirmLogout(context),
          child: Text(l10n.logOut),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                l10n.signedInAs(role.label(l10n)),
                style: TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.systemGrey.resolveFrom(context),
                ),
              ),
            ),
            Expanded(
              child: ComingSoonView(
                icon: CupertinoIcons.building_2_fill,
                title: l10n.hrComingTitle,
                body: l10n.hrComingBody,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

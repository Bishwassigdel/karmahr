import 'package:flutter/cupertino.dart';

import '../../l10n/l10n.dart';
import '../../state/auth_state.dart';
import '../apps/widgets/portal_sidebar.dart';
import '../hr/hr_section_view.dart' show HrSignedInLine;
import '../logout.dart';
import '../notifications_screen.dart';
import '../settings_screen.dart';
import 'owner_nav_scope.dart';
import 'owner_phone_shell.dart';
import 'owner_section.dart';
import 'owner_section_view.dart';

/// Home of the CEO portal. Wide screens get a sidebar listing every
/// section; phones get a bottom tab bar (see OwnerPhoneShell).
class OwnerPortalScreen extends StatefulWidget {
  const OwnerPortalScreen({super.key});

  @override
  State<OwnerPortalScreen> createState() => _OwnerPortalScreenState();
}

class _OwnerPortalScreenState extends State<OwnerPortalScreen> {
  static const double _wideBreakpoint = 900;

  // Only used by the wide layout; the phone shell keeps its own tab state.
  OwnerSection _section = OwnerSection.overview;

  void _openSettings() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;
    if (!isWide) return const OwnerPhoneShell();

    final l10n = context.l10n;
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Row(
          children: [
            PortalSidebar(
              items: [
                for (final s in OwnerSection.values)
                  PortalSidebarItem(s.icon, s.label(l10n)),
              ],
              selected: OwnerSection.values.indexOf(_section),
              onSelect: (i) =>
                  setState(() => _section = OwnerSection.values[i]),
              onSettings: _openSettings,
              onLogout: () => confirmLogout(context),
            ),
            Container(
              width: 1,
              color: CupertinoColors.separator.resolveFrom(context),
            ),
            Expanded(
              child: OwnerNavScope(
                onOpen: (_, section) => setState(() => _section = section),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        SizedBox(width: 56),
                        Expanded(
                          child: Center(
                            child: HrSignedInLine(fallback: UserRole.owner),
                          ),
                        ),
                        SizedBox(
                          width: 56,
                          child: Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: NotificationBell(),
                          ),
                        ),
                      ],
                    ),
                    Expanded(child: OwnerSectionView(section: _section)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

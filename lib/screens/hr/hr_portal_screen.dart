import 'package:flutter/cupertino.dart';

import '../../l10n/l10n.dart';
import '../logout.dart';
import '../apps/widgets/portal_sidebar.dart';
import '../notifications_screen.dart';
import '../settings_screen.dart';
import 'hr_nav_scope.dart';
import 'hr_phone_shell.dart';
import 'hr_section.dart';
import 'hr_section_view.dart';

/// Home of the HR/Admin portal.
///
/// Wide screens (web, tablet, desktop) get a permanent sidebar listing all
/// six sections. Phones get a bottom tab bar instead (see HrPhoneShell).
class HrPortalScreen extends StatefulWidget {
  const HrPortalScreen({super.key});

  @override
  State<HrPortalScreen> createState() => _HrPortalScreenState();
}

class _HrPortalScreenState extends State<HrPortalScreen> {
  static const double _wideBreakpoint = 900;

  // Only used by the wide layout; the phone shell keeps its own tab state.
  HrSection _section = HrSection.overview;

  void _select(HrSection section) => setState(() => _section = section);

  void _openSettings() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;
    if (!isWide) return const HrPhoneShell();

    return CupertinoPageScaffold(
      child: SafeArea(
        child: Row(
          children: [
            PortalSidebar(
              items: [
                for (final s in HrSection.values)
                  PortalSidebarItem(s.icon, s.label(context.l10n)),
              ],
              selected: HrSection.values.indexOf(_section),
              onSelect: (i) => _select(HrSection.values[i]),
              onSettings: _openSettings,
              onLogout: () => confirmLogout(context),
            ),
            Container(
              width: 1,
              color: CupertinoColors.separator.resolveFrom(context),
            ),
            Expanded(
              child: HrNavScope(
                onOpen: (_, section) => setState(() => _section = section),
                child: Column(
                  children: [
                    // Same bell as the employee Home, top right.
                    const Row(
                      children: [
                        SizedBox(width: 56),
                        Expanded(child: Center(child: HrSignedInLine())),
                        SizedBox(
                          width: 56,
                          child: Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: NotificationBell(),
                          ),
                        ),
                      ],
                    ),
                    Expanded(child: HrSectionView(section: _section)),
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

import 'package:flutter/cupertino.dart';

import '../../l10n/l10n.dart';
import '../logout.dart';
import '../settings_screen.dart';
import 'hr_phone_shell.dart';
import 'hr_section.dart';

/// The "More" tab: the sections without a tab of their own, plus Settings
/// and Log Out.
class HrMoreScreen extends StatelessWidget {
  const HrMoreScreen({super.key});

  // Sections that live here instead of in the tab bar.
  static const _sections = [
    HrSection.attendance,
    HrSection.reviews,
    HrSection.hiring,
    HrSection.notices,
    HrSection.reports,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(l10n.hrTabMore)),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 20),
            CupertinoListSection.insetGrouped(
              children: [
                for (final section in _sections)
                  CupertinoListTile(
                    leading: Icon(section.icon),
                    title: Text(section.label(l10n)),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => HrSectionPage(section: section),
                      ),
                    ),
                  ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.settings),
                  title: Text(l10n.settingsTitle),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                ),
                CupertinoListTile(
                  leading: const Icon(
                    CupertinoIcons.square_arrow_right,
                    color: CupertinoColors.destructiveRed,
                  ),
                  title: Text(
                    l10n.logOut,
                    style: const TextStyle(
                      color: CupertinoColors.destructiveRed,
                    ),
                  ),
                  onTap: () => confirmLogout(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

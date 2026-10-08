import 'package:flutter/cupertino.dart';

import '../data/current_employee.dart';
import '../l10n/l10n.dart';
import 'apps/widgets/ui_kit.dart';
import 'apps_screen.dart';
import 'logout.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

/// The employee app's "More" tab: your profile, every app (feature
/// module), Settings, and Log Out.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  // "Suresh Karki" -> "SK"
  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.take(2).map((p) => p.isEmpty ? '' : p[0].toUpperCase()).join();
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, CupertinoPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final employee = currentEmployee;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(l10n.tabMore)),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 20),
            CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile(
                  leading: InitialsAvatar(
                    initials: _initials(employee.name),
                    size: 40,
                  ),
                  leadingSize: 40,
                  title: Text(
                    employee.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${l10n.moreProfile} · ${employee.employeeId}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => _open(context, const ProfileScreen()),
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.square_grid_2x2),
                  title: Text(l10n.moreApps),
                  subtitle: Text(
                    l10n.moreAppsSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => _open(context, const AppsScreen()),
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.settings),
                  title: Text(l10n.settingsTitle),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => _open(context, const SettingsScreen()),
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

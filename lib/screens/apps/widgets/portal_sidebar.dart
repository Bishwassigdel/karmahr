import 'package:flutter/cupertino.dart';

import '../../../l10n/l10n.dart';
import '../../../theme/app_colors.dart';
import 'karma_logo.dart';

/// One entry in a [PortalSidebar].
class PortalSidebarItem {
  final IconData icon;
  final String label;

  const PortalSidebarItem(this.icon, this.label);
}

/// The permanent left sidebar of a portal on a wide screen: the logo, one
/// entry per section, then Settings and Log Out at the bottom. Shared by
/// the HR and CEO portals.
class PortalSidebar extends StatelessWidget {
  final List<PortalSidebarItem> items;
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  const PortalSidebar({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelect,
    required this.onSettings,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      width: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Row(
              children: [
                const KarmaLogo(size: 44),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'KarmaHR',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.karmaRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (var i = 0; i < items.length; i++)
                  _SidebarButton(
                    icon: items[i].icon,
                    label: items[i].label,
                    selected: i == selected,
                    onTap: () => onSelect(i),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Column(
              children: [
                _SidebarButton(
                  icon: CupertinoIcons.settings,
                  label: l10n.settingsTitle,
                  selected: false,
                  onTap: onSettings,
                ),
                _SidebarButton(
                  icon: CupertinoIcons.square_arrow_right,
                  label: l10n.logOut,
                  selected: false,
                  onTap: onLogout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.karmaRed
        : AppColors.textPrimary.resolveFrom(context);
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.karmaRed.withValues(alpha: 0.1)
              : const Color(0x00000000),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';

import '../../l10n/l10n.dart';
import '../../state/auth_state.dart';
import '../../theme/app_colors.dart';
import '../apps/widgets/karma_logo.dart';
import '../hr/hr_section_view.dart' show HrSignedInLine;
import '../logout.dart';
import '../notifications_screen.dart';
import '../settings_screen.dart';
import 'owner_nav_scope.dart';
import 'owner_section.dart';
import 'owner_section_view.dart';

/// The Executive portal on a phone: Overview, Departments, People, Money, and a
/// More tab with Activity, Settings and Log Out.
class OwnerPhoneShell extends StatefulWidget {
  const OwnerPhoneShell({super.key});

  @override
  State<OwnerPhoneShell> createState() => _OwnerPhoneShellState();
}

class _OwnerPhoneShellState extends State<OwnerPhoneShell> {
  /// The sections with their own tab, in order; More is the fifth.
  static const _tabSections = [
    OwnerSection.overview,
    OwnerSection.departments,
    OwnerSection.people,
    OwnerSection.money,
  ];

  final _controller = CupertinoTabController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _open(BuildContext context, OwnerSection section) {
    final tab = _tabSections.indexOf(section);
    if (tab >= 0) {
      _controller.index = tab;
    } else {
      Navigator.push(
        context,
        CupertinoPageRoute(builder: (_) => OwnerSectionPage(section: section)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CupertinoTabScaffold(
      controller: _controller,
      tabBar: CupertinoTabBar(
        activeColor: AppColors.karmaRed,
        inactiveColor: CupertinoColors.systemGrey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.chart_pie),
            label: l10n.ownerSecOverview,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.building_2_fill),
            label: l10n.ownerSecDepartments,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.person_2),
            label: l10n.ownerSecPeople,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.money_dollar_circle),
            label: l10n.ownerSecMoney,
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.ellipsis),
            label: l10n.hrTabMore,
          ),
        ],
      ),
      tabBuilder: (context, index) {
        if (index == _tabSections.length) {
          return CupertinoTabView(
            builder: (_) =>
                OwnerNavScope(onOpen: _open, child: const _OwnerMore()),
          );
        }
        return CupertinoTabView(
          builder: (_) => OwnerNavScope(
            onOpen: _open,
            child: OwnerSectionPage(
              section: _tabSections[index],
              isHome: index == 0,
            ),
          ),
        );
      },
    );
  }
}

/// One Executive section as a phone page. The home page carries the logo, the
/// KarmaHR name and the bell, like the other portals' Home.
class OwnerSectionPage extends StatelessWidget {
  final OwnerSection section;
  final bool isHome;

  const OwnerSectionPage({
    super.key,
    required this.section,
    this.isHome = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: isHome ? const KarmaLogo() : null,
        middle: Text(isHome ? 'KarmaHR' : section.label(l10n)),
        trailing: isHome ? const NotificationBell() : null,
      ),
      child: SafeArea(
        child: Column(
          children: [
            if (isHome) const HrSignedInLine(fallback: UserRole.owner),
            Expanded(child: OwnerSectionView(section: section)),
          ],
        ),
      ),
    );
  }
}

class _OwnerMore extends StatelessWidget {
  const _OwnerMore();

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
                CupertinoListTile(
                  leading: Icon(OwnerSection.activity.icon),
                  title: Text(OwnerSection.activity.label(l10n)),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => const OwnerSectionPage(
                        section: OwnerSection.activity,
                      ),
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

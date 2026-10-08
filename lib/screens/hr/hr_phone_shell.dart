import 'package:flutter/cupertino.dart';

import '../../l10n/l10n.dart';
import '../../theme/app_colors.dart';
import '../apps/widgets/karma_logo.dart';
import '../notifications_screen.dart';
import 'hr_more_screen.dart';
import 'hr_nav_scope.dart';
import 'hr_section.dart';
import 'hr_section_view.dart';

/// The HR portal on a phone: a bottom tab bar, like the employee app.
///
/// Four sections get a tab; Notices and Reports live under More, because
/// iOS tab bars work best with five tabs at most.
class HrPhoneShell extends StatefulWidget {
  const HrPhoneShell({super.key});

  @override
  State<HrPhoneShell> createState() => _HrPhoneShellState();
}

class _HrPhoneShellState extends State<HrPhoneShell> {
  /// The sections that have their own tab, in tab order. "More" is the
  /// fifth tab, after these.
  static const _tabSections = [
    HrSection.overview,
    HrSection.employees,
    HrSection.leave,
    HrSection.payroll,
  ];

  final _controller = CupertinoTabController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// A section with its own tab switches to it; one under More opens as a
  /// page on top of the current tab.
  void _open(BuildContext context, HrSection section) {
    final tab = _tabSections.indexOf(section);
    if (tab >= 0) {
      _controller.index = tab;
    } else {
      Navigator.push(
        context,
        CupertinoPageRoute(builder: (_) => HrSectionPage(section: section)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final items = [
      BottomNavigationBarItem(
        icon: const Icon(CupertinoIcons.home),
        label: l10n.tabHome,
      ),
      BottomNavigationBarItem(
        icon: const Icon(CupertinoIcons.person_2),
        label: l10n.hrSectionEmployees,
      ),
      BottomNavigationBarItem(
        icon: const Icon(CupertinoIcons.calendar),
        label: l10n.tabLeave,
      ),
      BottomNavigationBarItem(
        icon: const Icon(CupertinoIcons.money_dollar_circle),
        label: l10n.hrSectionPayroll,
      ),
      BottomNavigationBarItem(
        icon: const Icon(CupertinoIcons.ellipsis),
        label: l10n.hrTabMore,
      ),
    ];

    return CupertinoTabScaffold(
      controller: _controller,
      tabBar: CupertinoTabBar(
        activeColor: AppColors.karmaRed,
        inactiveColor: CupertinoColors.systemGrey,
        items: items,
      ),
      tabBuilder: (context, index) {
        if (index == _tabSections.length) {
          return CupertinoTabView(
            builder: (_) =>
                HrNavScope(onOpen: _open, child: const HrMoreScreen()),
          );
        }
        return CupertinoTabView(
          builder: (_) => HrNavScope(
            onOpen: _open,
            child: HrSectionPage(
              section: _tabSections[index],
              // Home gets the KarmaHR title, the bell and "signed in as".
              isHome: index == 0,
            ),
          ),
        );
      },
    );
  }
}

/// One HR section as a full phone page: navigation bar + the section body.
///
/// [isHome] makes it the HR home page, laid out like the employee Home:
/// "KarmaHR" as the title and the notification bell on the right.
class HrSectionPage extends StatelessWidget {
  final HrSection section;
  final bool isHome;

  const HrSectionPage({super.key, required this.section, this.isHome = false});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: isHome ? const KarmaLogo() : null,
        // The brand name is the same in every language.
        middle: Text(isHome ? 'KarmaHR' : section.label(l10n)),
        trailing: isHome ? const NotificationBell() : null,
      ),
      child: SafeArea(
        child: Column(
          children: [
            if (isHome) const HrSignedInLine(),
            Expanded(child: HrSectionView(section: section)),
          ],
        ),
      ),
    );
  }
}

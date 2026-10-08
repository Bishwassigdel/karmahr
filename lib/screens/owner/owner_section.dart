import 'package:flutter/cupertino.dart';

import '../../l10n/l10n.dart';

/// The sections of the CEO portal, in sidebar order. On a phone the first
/// four are tabs and Activity lives under More.
enum OwnerSection {
  overview(CupertinoIcons.chart_pie),
  departments(CupertinoIcons.building_2_fill),
  people(CupertinoIcons.person_2),
  money(CupertinoIcons.money_dollar_circle),
  activity(CupertinoIcons.time);

  const OwnerSection(this.icon);

  final IconData icon;

  String label(AppLocalizations l10n) => switch (this) {
    OwnerSection.overview => l10n.ownerSecOverview,
    OwnerSection.departments => l10n.ownerSecDepartments,
    OwnerSection.people => l10n.ownerSecPeople,
    OwnerSection.money => l10n.ownerSecMoney,
    OwnerSection.activity => l10n.ownerSecActivity,
  };
}

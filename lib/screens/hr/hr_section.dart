import 'package:flutter/cupertino.dart';

import '../../l10n/l10n.dart';

/// The sections of the HR portal, in the order they appear in the sidebar
/// (wide screens) and the menu (phones). Adding a section = one new value
/// here + one case in HrPortalScreen._contentFor.
enum HrSection {
  overview(CupertinoIcons.chart_pie),
  employees(CupertinoIcons.person_2),
  teams(CupertinoIcons.person_3),
  leave(CupertinoIcons.calendar),
  payroll(CupertinoIcons.money_dollar_circle),
  attendance(CupertinoIcons.clock),
  reviews(CupertinoIcons.star),
  hiring(CupertinoIcons.person_badge_plus),
  notices(CupertinoIcons.bell),
  reports(CupertinoIcons.doc_chart);

  const HrSection(this.icon);

  final IconData icon;

  String label(AppLocalizations l10n) => switch (this) {
    HrSection.overview => l10n.hrSectionOverview,
    HrSection.employees => l10n.hrSectionEmployees,
    HrSection.teams => l10n.hrSectionTeams,
    HrSection.leave => l10n.hrSectionLeave,
    HrSection.payroll => l10n.hrSectionPayroll,
    HrSection.attendance => l10n.hrSectionAttendance,
    HrSection.reviews => l10n.hrSectionReviews,
    HrSection.hiring => l10n.hrSectionHiring,
    HrSection.notices => l10n.hrSectionNotices,
    HrSection.reports => l10n.hrSectionReports,
  };
}

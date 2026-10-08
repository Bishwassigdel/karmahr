import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../state/auth_state.dart';
import 'hr_attendance_screen.dart';
import 'hr_employees_screen.dart';
import 'hr_hiring_screen.dart';
import 'hr_leave_screen.dart';
import 'hr_notices_screen.dart';
import 'hr_overview_screen.dart';
import 'hr_payroll_screen.dart';
import 'hr_reports_screen.dart';
import 'hr_reviews_screen.dart';
import 'hr_section.dart';
import 'hr_teams_screen.dart';

/// The body of one HR section. Shared by the wide layout (sidebar) and the
/// phone layout (tab bar / More), so a section is built in exactly one
/// place. Each later step replaces one placeholder case here.
class HrSectionView extends StatelessWidget {
  final HrSection section;

  const HrSectionView({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    // Every section has its screen; adding a value to HrSection makes this
    // switch fail to compile until its screen is added here.
    return switch (section) {
      HrSection.overview => const HrOverviewScreen(),
      HrSection.employees => const HrEmployeesScreen(),
      HrSection.teams => const HrTeamsScreen(),
      HrSection.leave => const HrLeaveScreen(),
      HrSection.payroll => const HrPayrollScreen(),
      HrSection.attendance => const HrAttendanceScreen(),
      HrSection.reviews => const HrReviewsScreen(),
      HrSection.hiring => const HrHiringScreen(),
      HrSection.notices => const HrNoticesScreen(),
      HrSection.reports => const HrReportsScreen(),
    };
  }
}

/// "Signed in as HR" in small grey text.
class HrSignedInLine extends StatelessWidget {
  /// Shown when nobody is signed in (a screen on its own, as in tests).
  final UserRole fallback;

  const HrSignedInLine({super.key, this.fallback = UserRole.hr});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final role = context.watch<AuthState>().role ?? fallback;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        l10n.signedInAs(role.label(l10n)),
        style: TextStyle(
          fontSize: 13,
          color: CupertinoColors.systemGrey.resolveFrom(context),
        ),
      ),
    );
  }
}

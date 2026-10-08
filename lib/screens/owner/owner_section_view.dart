import 'package:flutter/cupertino.dart';

import 'owner_activity_screen.dart';
import 'owner_departments_screen.dart';
import 'owner_money_screen.dart';
import 'owner_overview_screen.dart';
import 'owner_people_screen.dart';
import 'owner_section.dart';

/// The body of one CEO section, shared by the sidebar and phone layouts.
/// The switch has no default: adding a section stops the build until its
/// screen is wired in here.
class OwnerSectionView extends StatelessWidget {
  final OwnerSection section;

  const OwnerSectionView({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return switch (section) {
      OwnerSection.overview => const OwnerOverviewScreen(),
      OwnerSection.departments => const OwnerDepartmentsScreen(),
      OwnerSection.people => const OwnerPeopleScreen(),
      OwnerSection.money => const OwnerMoneyScreen(),
      OwnerSection.activity => const OwnerActivityScreen(),
    };
  }
}

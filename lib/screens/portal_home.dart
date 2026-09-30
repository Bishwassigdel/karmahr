import 'package:flutter/cupertino.dart';

import '../state/auth_state.dart';
import 'hr/hr_portal_screen.dart';
import 'main_nav_screen.dart';

/// The first screen after sign-in for [role]. Managers get the employee
/// app (they still take leave and check in) with a Team tab added.
Widget portalHomeFor(UserRole role) => switch (role) {
  UserRole.employee || UserRole.manager => const MainNavScreen(),
  UserRole.hr => const HrPortalScreen(),
};

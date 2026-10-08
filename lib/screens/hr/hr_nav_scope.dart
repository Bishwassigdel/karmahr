import 'package:flutter/cupertino.dart';

import 'hr_section.dart';

/// Lets a section ask the portal to open another section ("3 requests to
/// review" on Home opens Leave & Holidays). The portal decides what that
/// means: the sidebar layout switches section, the phone layout switches
/// tab or pushes a page.
class HrNavScope extends InheritedWidget {
  final void Function(BuildContext context, HrSection section) onOpen;

  const HrNavScope({super.key, required this.onOpen, required super.child});

  /// Does nothing when there is no portal around (a screen shown on its
  /// own, as in tests).
  static void openSection(BuildContext context, HrSection section) {
    context.getInheritedWidgetOfExactType<HrNavScope>()?.onOpen(
      context,
      section,
    );
  }

  @override
  bool updateShouldNotify(HrNavScope oldWidget) => false;
}

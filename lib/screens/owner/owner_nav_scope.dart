import 'package:flutter/cupertino.dart';

import 'owner_section.dart';

/// Lets an Executive screen ask the portal to open another section. The sidebar
/// layout switches section; the phone layout switches tab or pushes a page.
class OwnerNavScope extends InheritedWidget {
  final void Function(BuildContext context, OwnerSection section) onOpen;

  const OwnerNavScope({super.key, required this.onOpen, required super.child});

  /// Does nothing when there is no portal around (a screen shown alone).
  static void openSection(BuildContext context, OwnerSection section) {
    context.getInheritedWidgetOfExactType<OwnerNavScope>()?.onOpen(
      context,
      section,
    );
  }

  @override
  bool updateShouldNotify(OwnerNavScope oldWidget) => false;
}

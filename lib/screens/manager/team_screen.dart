import 'package:flutter/cupertino.dart';

import '../../l10n/l10n.dart';
import '../apps/widgets/coming_soon_view.dart';

/// The manager's Team tab. Approvals, team attendance and team reports
/// are built here next.
class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(l10n.teamTitle)),
      child: SafeArea(
        child: ComingSoonView(
          icon: CupertinoIcons.person_3_fill,
          title: l10n.teamComingTitle,
          body: l10n.teamComingBody,
        ),
      ),
    );
  }
}

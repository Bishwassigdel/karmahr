import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../state/audit_log_state.dart';
import '../../state/hr_inbox_state.dart';
import '../apps/widgets/ui_kit.dart';
import '../hr/hr_reports_screen.dart' show auditActionLabel;
import '../notifications_screen.dart' show relativeTime;

/// CEO > Activity: what is waiting on a decision, longest first, and what
/// has been changed lately. Both come from the HR portal's live data.
class OwnerActivityScreen extends StatelessWidget {
  const OwnerActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);
    final waiting = context.watch<HrInboxState>().pending;
    final log = context.watch<AuditLogState>().entries;
    final now = DateTime.now(); // after the data, so ages never run early

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SectionCard(
              title: l10n.ownerWaiting,
              child: waiting.isEmpty
                  ? Text(
                      l10n.ownerNoWaiting,
                      style: TextStyle(fontSize: 13, color: subtle),
                    )
                  : Column(
                      children: [
                        // Oldest first: the ones left longest.
                        for (final i in waiting)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        i.employeeName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        i.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: subtle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.ownerWaitingDays(
                                    now.difference(i.submittedAt).inDays,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 14),
            SectionCard(
              title: l10n.hrReportsActivity,
              child: log.isEmpty
                  ? Text(
                      l10n.hrNoActivity,
                      style: TextStyle(fontSize: 13, color: subtle),
                    )
                  : Column(
                      children: [
                        for (final e in log.take(20))
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        auditActionLabel(l10n, e.action),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        l10n.hrAuditLine(e.actor, e.detail),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: subtle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  relativeTime(e.when),
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: subtle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

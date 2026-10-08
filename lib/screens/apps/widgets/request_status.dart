import 'package:flutter/cupertino.dart';

import '../../../l10n/l10n.dart';
import 'status_badge.dart';

/// Where any request stands, whatever its type (leave, expense, overtime,
/// HR). Each state class has its own status enum; screens that list
/// several types map them onto this.
enum RequestOutcome { pending, approved, rejected, paid }

extension RequestOutcomeX on RequestOutcome {
  bool get isOpen => this == RequestOutcome.pending;

  String label(AppLocalizations l10n) => switch (this) {
    RequestOutcome.pending => l10n.statusPending,
    RequestOutcome.approved => l10n.statusApproved,
    RequestOutcome.rejected => l10n.statusRejected,
    RequestOutcome.paid => l10n.statusPaid,
  };

  Color get color => switch (this) {
    RequestOutcome.pending => CupertinoColors.systemOrange,
    RequestOutcome.approved => CupertinoColors.activeGreen,
    RequestOutcome.rejected => CupertinoColors.destructiveRed,
    RequestOutcome.paid => CupertinoColors.systemBlue,
  };
}

/// A colored pill for [outcome], translated.
class OutcomeBadge extends StatelessWidget {
  final RequestOutcome outcome;

  const OutcomeBadge(this.outcome, {super.key});

  @override
  Widget build(BuildContext context) {
    return StatusBadge(
      label: outcome.label(context.l10n),
      color: outcome.color,
    );
  }
}

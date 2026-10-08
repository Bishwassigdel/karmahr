import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../state/audit_log_state.dart';
import '../../state/hr_inbox_state.dart';
import '../../theme/app_colors.dart';
import '../apps/widgets/request_status.dart';
import '../apps/widgets/ui_kit.dart';
import '../notifications_screen.dart' show relativeTime;

/// HR > Leave & Holidays > Approvals: one inbox for every kind of request.
class HrApprovalsView extends StatefulWidget {
  const HrApprovalsView({super.key});

  @override
  State<HrApprovalsView> createState() => _HrApprovalsViewState();
}

class _HrApprovalsViewState extends State<HrApprovalsView> {
  /// null = every kind.
  InboxKind? _kind;

  String _kindLabel(AppLocalizations l10n, InboxKind kind) => switch (kind) {
    InboxKind.leave => l10n.requestTypeLeave,
    InboxKind.expense => l10n.requestTypeExpense,
    InboxKind.overtime => l10n.requestTypeOvertime,
    InboxKind.hrRequest => l10n.requestTypeHr,
  };

  IconData _kindIcon(InboxKind kind) => switch (kind) {
    InboxKind.leave => CupertinoIcons.airplane,
    InboxKind.expense => CupertinoIcons.doc_on_clipboard,
    InboxKind.overtime => CupertinoIcons.timer,
    InboxKind.hrRequest => CupertinoIcons.person_crop_circle_badge_checkmark,
  };

  Future<void> _reject(InboxItem item) async {
    final l10n = context.l10n;
    final ok = await confirm(
      context,
      title: l10n.hrRejectTitle,
      message: l10n.hrRejectMessage(item.employeeName),
      confirmLabel: l10n.hrReject,
      destructive: true,
    );
    if (!ok || !mounted) return;
    context.read<HrInboxState>().decide(item.id, InboxStatus.rejected);
    logAudit(
      context,
      AuditAction.requestRejected,
      '${item.employeeName}: ${item.title}',
    );
  }

  void _approve(InboxItem item) {
    context.read<HrInboxState>().decide(item.id, InboxStatus.approved);
    logAudit(
      context,
      AuditAction.requestApproved,
      '${item.employeeName}: ${item.title}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);
    final inbox = context.watch<HrInboxState>();

    bool shown(InboxItem i) => _kind == null || i.kind == _kind;
    final pending = inbox.pending.where(shown).toList();
    final decided = inbox.decided.where(shown).toList();

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Text(
              l10n.hrWaitingForYou(inbox.pendingCount),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterChip(
                  label: l10n.filterAll,
                  selected: _kind == null,
                  onTap: () => setState(() => _kind = null),
                ),
                for (final kind in InboxKind.values)
                  _FilterChip(
                    label: _kindLabel(l10n, kind),
                    selected: _kind == kind,
                    onTap: () => setState(() => _kind = kind),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (pending.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Text(
                  l10n.noRequests,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: subtle),
                ),
              ),
            for (final item in pending)
              _RequestCard(
                item: item,
                kindLabel: _kindLabel(l10n, item.kind),
                kindIcon: _kindIcon(item.kind),
                onApprove: () => _approve(item),
                onReject: () => _reject(item),
              ),
            if (decided.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                child: Text(
                  l10n.hrDecided.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: subtle,
                  ),
                ),
              ),
              for (final item in decided)
                _RequestCard(
                  item: item,
                  kindLabel: _kindLabel(l10n, item.kind),
                  kindIcon: _kindIcon(item.kind),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.karmaRed
              : CupertinoColors.systemGrey5.resolveFrom(context),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected
                ? CupertinoColors.white
                : AppColors.textPrimary.resolveFrom(context),
          ),
        ),
      ),
    );
  }
}

/// One request. Pending ones carry Approve and Reject; decided ones carry
/// their outcome instead.
class _RequestCard extends StatelessWidget {
  final InboxItem item;
  final String kindLabel;
  final IconData kindIcon;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const _RequestCard({
    required this.item,
    required this.kindLabel,
    required this.kindIcon,
    this.onApprove,
    this.onReject,
  });

  RequestOutcome get _outcome => switch (item.status) {
    InboxStatus.pending => RequestOutcome.pending,
    InboxStatus.approved => RequestOutcome.approved,
    InboxStatus.rejected => RequestOutcome.rejected,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary.resolveFrom(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InitialsAvatar(initials: item.initials, size: 38),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.employeeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        Icon(kindIcon, size: 13, color: subtle),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '$kindLabel · ${relativeTime(item.submittedAt)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: subtle),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!item.isPending) ...[
                const SizedBox(width: 8),
                Flexible(
                  flex: 0,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: OutcomeBadge(_outcome),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            item.detail,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: subtle),
          ),
          if (item.isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    minimumSize: Size.zero,
                    color: CupertinoColors.systemGrey5.resolveFrom(context),
                    onPressed: onReject,
                    child: Text(
                      l10n.hrReject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.destructiveRed,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    minimumSize: Size.zero,
                    color: AppColors.karmaRed,
                    onPressed: onApprove,
                    child: Text(
                      l10n.hrApprove,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

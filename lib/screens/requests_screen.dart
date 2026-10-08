// REQUESTS — one list of everything you've asked for: time off, expense
// claims, overtime and HR requests, each with its status. Replaces hunting
// through My Requests, Expense Claims and Shifts & Overtime separately.
// "+" asks what kind of request, then opens that form.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../data/current_employee.dart';
import '../l10n/l10n.dart';
import '../state/expense_state.dart';
import '../state/hr_request_state.dart';
import '../state/leave_state.dart';
import '../state/overtime_state.dart';
import 'apps/widgets/request_status.dart';
import 'apps/widgets/ui_kit.dart';
import 'expense_claims_screen.dart';
import 'leave_screen.dart';
import 'request_screen.dart';
import 'shifts_overtime_screen.dart';

enum _Filter { all, open, closed }

/// One row in the combined list, whatever kind of request it came from.
class _Item {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final RequestOutcome outcome;

  /// For ordering, newest first. HR requests carry no date (null).
  final DateTime? date;

  const _Item({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.outcome,
    this.date,
  });
}

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  _Filter _filter = _Filter.all;

  List<_Item> _items(BuildContext context) {
    final l10n = context.l10n;
    final items = <_Item>[
      for (final r in context.watch<LeaveState>().requests)
        _Item(
          icon: CupertinoIcons.airplane,
          color: CupertinoColors.systemTeal,
          title: r.leaveType,
          subtitle:
              '${l10n.requestTypeLeave} · ${shortDate(r.startDate)}'
              '${r.endDate == r.startDate ? '' : ' – ${shortDate(r.endDate)}'}',
          outcome: switch (r.status) {
            LeaveRequestStatus.pending => RequestOutcome.pending,
            LeaveRequestStatus.approved => RequestOutcome.approved,
            LeaveRequestStatus.rejected => RequestOutcome.rejected,
          },
          date: r.startDate,
        ),
      for (final c in context.watch<ExpenseState>().claims)
        _Item(
          icon: expenseCategoryIcon(c.category),
          color: CupertinoColors.systemGreen,
          title: expenseCategoryLabel(c.category),
          subtitle:
              '${l10n.requestTypeExpense} · ${formatRupees(c.amount)} · '
              '${shortDate(c.spentOn)}',
          outcome: switch (c.status) {
            ExpenseStatus.pending => RequestOutcome.pending,
            ExpenseStatus.approved => RequestOutcome.approved,
            ExpenseStatus.rejected => RequestOutcome.rejected,
            ExpenseStatus.paid => RequestOutcome.paid,
          },
          date: c.submittedAt,
        ),
      for (final o in context.watch<OvertimeState>().requests)
        _Item(
          icon: CupertinoIcons.timer,
          color: CupertinoColors.systemIndigo,
          title: '${l10n.requestTypeOvertime} · ${o.hours}h',
          subtitle: shortDate(o.date),
          outcome: switch (o.status) {
            OvertimeStatus.pending => RequestOutcome.pending,
            OvertimeStatus.approved => RequestOutcome.approved,
            OvertimeStatus.rejected => RequestOutcome.rejected,
          },
          date: o.date,
        ),
      for (final h in context.watch<HrRequestState>().requests)
        _Item(
          icon: hrCategoryIcon(h.category),
          color: CupertinoColors.systemOrange,
          title: hrCategoryLabel(h.category),
          subtitle: h.issueDate == null
              ? l10n.requestTypeHr
              : '${l10n.requestTypeHr} · ${shortDate(h.issueDate!)}',
          outcome: switch (h.status) {
            RequestStatus.pending => RequestOutcome.pending,
            RequestStatus.approved => RequestOutcome.approved,
            RequestStatus.rejected => RequestOutcome.rejected,
          },
          date: h.issueDate,
        ),
    ];

    // Open first (they need attention), then newest first; undated last.
    items.sort((a, b) {
      if (a.outcome.isOpen != b.outcome.isOpen) {
        return a.outcome.isOpen ? -1 : 1;
      }
      if (a.date == null || b.date == null) {
        return (a.date == null ? 1 : 0) - (b.date == null ? 1 : 0);
      }
      return b.date!.compareTo(a.date!);
    });

    return switch (_filter) {
      _Filter.all => items,
      _Filter.open => items.where((i) => i.outcome.isOpen).toList(),
      _Filter.closed => items.where((i) => !i.outcome.isOpen).toList(),
    };
  }

  Future<void> _newRequest() async {
    final l10n = context.l10n;
    final screen = await showCupertinoModalPopup<Widget>(
      context: context,
      builder: (sheet) => CupertinoActionSheet(
        title: Text(l10n.newRequest),
        actions: [
          for (final (label, target) in <(String, Widget)>[
            (l10n.requestTypeLeave, const LeaveScreen()),
            (l10n.requestTypeExpense, const NewExpenseClaimScreen()),
            (l10n.requestTypeOvertime, const OvertimeRequestScreen()),
            (l10n.requestTypeHr, const HrRequestScreen()),
          ])
            CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(sheet, target),
              child: Text(label),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(sheet),
          child: Text(l10n.cancel),
        ),
      ),
    );
    if (screen == null || !mounted) return;
    Navigator.push(context, CupertinoPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = _items(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(l10n.tabRequests),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _newRequest,
          child: Icon(CupertinoIcons.add, semanticLabel: l10n.newRequest),
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<_Filter>(
                  groupValue: _filter,
                  onValueChanged: (f) {
                    if (f != null) setState(() => _filter = f);
                  },
                  children: {
                    _Filter.all: Text(l10n.filterAll),
                    _Filter.open: Text(l10n.filterOpen),
                    _Filter.closed: Text(l10n.filterClosed),
                  },
                ),
              ),
            ),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  l10n.noRequests,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CupertinoColors.systemGrey.resolveFrom(context),
                  ),
                ),
              )
            else
              CupertinoListSection.insetGrouped(
                children: [
                  for (final i in items)
                    CupertinoListTile(
                      leading: Icon(i.icon, color: i.color),
                      title: Text(
                        i.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        i.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      additionalInfo: TileInfoBox(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: OutcomeBadge(i.outcome),
                        ),
                      ),
                    ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: _newRequest,
                  child: Text(l10n.newRequest),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

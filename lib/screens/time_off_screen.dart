// TIME OFF — the one place for leave: what you have left, a big Request
// button, planning and the holiday calendar, and your requests so far.
// Pulls together the Apply Leave form, Leave & Balances, Leave Planner and
// the Holiday Calendar, which each used to be a separate stop.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../state/leave_balance_state.dart';
import '../state/leave_state.dart';
import '../theme/app_colors.dart';
import 'apps/widgets/request_status.dart';
import 'apps/widgets/ui_kit.dart';
import 'holiday_calendar_screen.dart';
import 'leave_balances_screen.dart';
import 'leave_planner_screen.dart';
import 'leave_screen.dart';

class TimeOffScreen extends StatelessWidget {
  const TimeOffScreen({super.key});

  // The balances shown as cards; the rest are under "All balances".
  static const _featured = ['Home Leave', 'Sick Leave', 'Substitute Leave'];

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, CupertinoPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final requests = context.watch<LeaveState>().requests;
    final balances = context.read<LeaveBalanceState>().balancesFor(requests);
    final featured = [
      for (final type in _featured) ...balances.where((b) => b.type == type),
    ];
    final cards = featured.isEmpty ? balances.take(3).toList() : featured;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(l10n.tabTimeOff)),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            SizedBox(
              height: 112,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: cards.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, i) => _BalanceCard(
                  type: cards[i].type,
                  remaining: cards[i].remaining,
                  onTap: () => _open(context, const LeaveBalancesScreen()),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  onPressed: () => _open(context, const LeaveScreen()),
                  child: Text(l10n.requestTimeOff),
                ),
              ),
            ),
            CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.airplane),
                  title: Text(l10n.planTrip),
                  subtitle: Text(
                    l10n.planTripSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => _open(context, const LeavePlannerScreen()),
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.calendar),
                  title: Text(l10n.holidayCalendarLabel),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => _open(context, const HolidayCalendarScreen()),
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.chart_bar_square),
                  title: Text(l10n.allBalances),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => _open(context, const LeaveBalancesScreen()),
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: Text(l10n.myTimeOffRequests.toUpperCase()),
              children: [
                if (requests.isEmpty)
                  CupertinoListTile(title: Text(l10n.noTimeOffRequests))
                else
                  for (final r in requests)
                    CupertinoListTile(
                      title: Text(
                        r.leaveType,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        r.endDate == r.startDate
                            ? dayDate(r.startDate)
                            : '${shortDate(r.startDate)} – '
                                  '${shortDate(r.endDate)}',
                      ),
                      additionalInfo: TileInfoBox(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: OutcomeBadge(switch (r.status) {
                            LeaveRequestStatus.pending =>
                              RequestOutcome.pending,
                            LeaveRequestStatus.approved =>
                              RequestOutcome.approved,
                            LeaveRequestStatus.rejected =>
                              RequestOutcome.rejected,
                          }),
                        ),
                      ),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String type;
  final double remaining;
  final VoidCallback onTap;

  const _BalanceCard({
    required this.type,
    required this.remaining,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 7.5 → "7.5", 8.0 → "8"
    final days = remaining == remaining.roundToDouble()
        ? remaining.toStringAsFixed(0)
        : remaining.toStringAsFixed(1);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary.resolveFrom(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              type,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                days,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.karmaRed,
                ),
              ),
            ),
            Text(
              context.l10n.daysLeft(days),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey.resolveFrom(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

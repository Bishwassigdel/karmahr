// Leave Planner: pick a trip, see what it actually costs in leave days
// (Saturdays and public holidays are free), against your real Home Leave
// balance — plus "bridge" suggestions where 1–2 leave days next to a
// festival buy a much longer break.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../data/calendar_data.dart';
import '../domain/nepal/leave_planner.dart';
import '../state/leave_balance_state.dart';
import '../state/leave_state.dart';
import '../theme/app_colors.dart';
import 'apps/widgets/ui_kit.dart';
import 'leave_screen.dart';

String _days(num n) {
  final s = n == n.roundToDouble()
      ? n.toStringAsFixed(0)
      : n.toStringAsFixed(1);
  return n == 1 ? '$s day' : '$s days';
}

/// Upcoming bridge opportunities from the real holiday calendar.
List<BridgeSuggestion> upcomingBridges({int limit = 5}) => findBridges(
  from: dateOnly(DateTime.now()),
  holidayName: holidayNameOn,
).take(limit).toList();

class LeavePlannerScreen extends StatefulWidget {
  const LeavePlannerScreen({super.key});

  @override
  State<LeavePlannerScreen> createState() => _LeavePlannerScreenState();
}

class _LeavePlannerScreenState extends State<LeavePlannerScreen> {
  DateTime? _start;
  DateTime? _end;

  Future<void> _pickStart() async {
    final today = dateOnly(DateTime.now());
    final picked = await pickDate(
      context,
      initial: _start ?? today,
      minimum: today,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _start = picked;
      // Keep the range valid: an end before the new start is reset.
      if (_end != null && _end!.isBefore(picked)) _end = picked;
    });
  }

  Future<void> _pickEnd() async {
    final today = dateOnly(DateTime.now());
    final min = _start ?? today;
    final picked = await pickDate(context, initial: _end ?? min, minimum: min);
    if (picked == null || !mounted) return;
    setState(() => _end = picked);
  }

  void _useBridge(BridgeSuggestion b) {
    setState(() {
      _start = b.breakStart;
      _end = b.breakEnd;
    });
  }

  @override
  Widget build(BuildContext context) {
    final requests = context.watch<LeaveState>().requests;
    final homeLeave = context.read<LeaveBalanceState>().balanceFor(
      'Home Leave',
      requests,
    );
    final bridges = upcomingBridges();

    final estimate = (_start != null && _end != null)
        ? estimateLeave(start: _start!, end: _end!, holidayName: holidayNameOn)
        : null;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Leave Planner'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              header: const Text('YOUR TRIP'),
              children: [
                FormRow(
                  label: 'From',
                  value: _start == null ? 'Choose date' : dayDate(_start!),
                  placeholder: _start == null,
                  onTap: _pickStart,
                ),
                FormRow(
                  label: 'To',
                  value: _end == null ? 'Choose date' : dayDate(_end!),
                  placeholder: _end == null,
                  onTap: _pickEnd,
                ),
              ],
            ),
            if (estimate != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _EstimateCard(
                  estimate: estimate,
                  remaining: homeLeave?.remaining,
                  onApply: estimate.leaveDaysNeeded == 0
                      ? null
                      : () => Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => LeaveScreen(
                              initialStartDate: _start,
                              initialEndDate: _end,
                            ),
                          ),
                        ),
                ),
              ),
            CupertinoListSection.insetGrouped(
              header: const Text('LONG BREAKS AHEAD'),
              footer: const Text(
                'Tap a suggestion to plan it. Based on the holidays in your '
                'HR calendar.',
              ),
              children: bridges.isEmpty
                  ? const [
                      CupertinoListTile(
                        title: Text(
                          'No bridge opportunities in the next few months.',
                        ),
                      ),
                    ]
                  : [
                      for (final b in bridges)
                        BridgeSuggestionTile(
                          suggestion: b,
                          onTap: () => _useBridge(b),
                        ),
                    ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _EstimateCard extends StatelessWidget {
  final LeaveEstimate estimate;
  final double? remaining;
  final VoidCallback? onApply;

  const _EstimateCard({
    required this.estimate,
    required this.remaining,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);
    final needed = estimate.leaveDaysNeeded;
    final left = remaining == null ? null : remaining! - needed;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            needed == 0 ? 'No leave needed' : '${_days(needed)} of leave',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${_days(estimate.calendarDays)} away · '
            '${_days(estimate.weeklyOffDays)} Saturday · '
            '${_days(estimate.holidays.length)} public holiday',
            style: TextStyle(fontSize: 12.5, color: subtle),
          ),
          if (estimate.holidays.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final (date, name) in estimate.holidays)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.gift_fill,
                      size: 14,
                      color: CupertinoColors.systemGreen.resolveFrom(context),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '$name · ${shortDate(date)} (free)',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          if (left != null && needed > 0) ...[
            const SizedBox(height: 10),
            left >= 0
                ? NoteBanner(
                    icon: CupertinoIcons.checkmark_seal,
                    color: CupertinoColors.systemGreen,
                    text:
                        'You have ${_days(remaining!)} of Home Leave. After this '
                        "trip you'll have ${_days(left)} left.",
                  )
                : NoteBanner(
                    icon: CupertinoIcons.exclamationmark_triangle,
                    color: CupertinoColors.systemRed,
                    text:
                        'You have ${_days(remaining!)} of Home Leave — '
                        '${_days(-left)} short. The rest would be unpaid '
                        'unless another leave type applies.',
                  ),
          ],
          if (onApply != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                color: AppColors.karmaRed,
                borderRadius: BorderRadius.circular(12),
                onPressed: onApply,
                child: const Text(
                  'Apply for this leave',
                  style: TextStyle(color: CupertinoColors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// One bridge opportunity row — shared with the Events screen.
class BridgeSuggestionTile extends StatelessWidget {
  final BridgeSuggestion suggestion;
  final VoidCallback onTap;

  const BridgeSuggestionTile({
    super.key,
    required this.suggestion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final b = suggestion;
    final leaveLabel = b.leaveDays == 1
        ? 'Take ${dayDate(b.leaveStart)}'
        : 'Take ${shortDate(b.leaveStart)} – ${shortDate(b.leaveEnd)}';
    return CupertinoListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: CupertinoColors.systemGreen
              .resolveFrom(context)
              .withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          '${b.totalDaysOff}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: CupertinoColors.systemGreen.resolveFrom(context),
          ),
        ),
      ),
      leadingSize: 36,
      title: Text(
        '${b.totalDaysOff} days off for ${_days(b.leaveDays)} of leave',
      ),
      subtitle: Text(
        '$leaveLabel · ${b.holidayNames.join(', ')}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const CupertinoListTileChevron(),
      onTap: onTap,
    );
  }
}

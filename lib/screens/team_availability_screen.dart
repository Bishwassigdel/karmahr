// "Who's out?" — coworkers on leave today and later this week, so people
// stop messaging someone who's away. Also exports the compact strip the
// Dashboard shows.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../data/current_employee.dart';
import '../data/team_data.dart';
import '../state/leave_state.dart';
import 'apps/widgets/ui_kit.dart';

/// Coworker leave plus the current user's own APPROVED leave, so "who's
/// out today" is honest about you too.
List<TeamLeave> teamLeaveWithMe(List<LeaveRequest> myRequests) {
  final mine = myRequests
      .where((r) => r.status == LeaveRequestStatus.approved)
      .map(
        (r) => TeamLeave(
          name: '${currentEmployee.name} (you)',
          initials: 'BS',
          leaveType: r.leaveType,
          start: dateOnly(r.startDate),
          end: dateOnly(r.endDate),
        ),
      );
  return [...demoTeamLeave(), ...mine];
}

List<TeamLeave> outOn(DateTime day, List<TeamLeave> all) =>
    all.where((l) => l.coversDay(day)).toList();

List<TeamLeave> startingSoon(DateTime today, List<TeamLeave> all) {
  final horizon = DateTime(today.year, today.month, today.day + 7);
  return all
      .where((l) => l.start.isAfter(today) && !l.start.isAfter(horizon))
      .toList()
    ..sort((a, b) => a.start.compareTo(b.start));
}

class TeamAvailabilityScreen extends StatelessWidget {
  const TeamAvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = dateOnly(DateTime.now());
    final all = teamLeaveWithMe(context.watch<LeaveState>().requests);
    final outToday = outOn(today, all);
    final soon = startingSoon(today, all);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text("Who's Out")),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              header: Text('OUT TODAY · ${dayDate(today).toUpperCase()}'),
              children: outToday.isEmpty
                  ? const [
                      CupertinoListTile(title: Text("Everyone's in today.")),
                    ]
                  : [for (final l in outToday) _LeaveTile(leave: l)],
            ),
            CupertinoListSection.insetGrouped(
              header: const Text('LATER THIS WEEK'),
              children: soon.isEmpty
                  ? const [CupertinoListTile(title: Text('No leave planned.'))]
                  : [
                      for (final l in soon)
                        _LeaveTile(leave: l, upcoming: true),
                    ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaveTile extends StatelessWidget {
  final TeamLeave leave;
  final bool upcoming;

  const _LeaveTile({required this.leave, this.upcoming = false});

  @override
  Widget build(BuildContext context) {
    final range = leave.start == leave.end
        ? dayDate(leave.start)
        : '${shortDate(leave.start)} – ${shortDate(leave.end)}';
    return CupertinoListTile(
      leadingSize: 36,
      leading: InitialsAvatar(initials: leave.initials, size: 36),
      title: Text(leave.name),
      subtitle: Text('${leave.leaveType} · $range'),
      additionalInfo: TileInfo(
        upcoming
            ? 'From ${shortDate(leave.start)}'
            : 'Back ${shortDate(leave.backOn)}',
        style: const TextStyle(fontSize: 12.5),
      ),
    );
  }
}

/// Dashboard strip: stacked avatars + "3 out today". Taps through.
class WhosOutStrip extends StatelessWidget {
  const WhosOutStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final today = dateOnly(DateTime.now());
    final out = outOn(
      today,
      teamLeaveWithMe(context.watch<LeaveState>().requests),
    );
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);
    final visible = out.take(4).toList();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        CupertinoPageRoute(builder: (_) => const TeamAvailabilityScreen()),
      ),
      child: SectionCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            if (visible.isNotEmpty)
              SizedBox(
                // Overlapping avatars: each one 22px right of the last.
                width: 32.0 + (visible.length - 1) * 22,
                height: 32,
                child: Stack(
                  children: [
                    for (var i = 0; i < visible.length; i++)
                      Positioned(
                        left: i * 22.0,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: CupertinoColors.systemBackground
                                  .resolveFrom(context),
                              width: 2,
                            ),
                          ),
                          child: InitialsAvatar(
                            initials: visible[i].initials,
                            size: 28,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            if (visible.isNotEmpty) const SizedBox(width: 10),
            Expanded(
              child: Text(
                out.isEmpty
                    ? "Everyone's in today"
                    : out.length == 1
                    ? '${out.first.name.split(' ').first} is out today'
                    : '${out.length} people out today',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(CupertinoIcons.chevron_right, size: 16, color: subtle),
          ],
        ),
      ),
    );
  }
}

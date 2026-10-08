import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../data/attendance_demo.dart';
import '../../l10n/l10n.dart';
import '../../state/employee_records_state.dart';
import '../../theme/app_colors.dart';
import '../apps/widgets/status_badge.dart';
import '../apps/widgets/ui_kit.dart';

/// HR > Attendance: who came to work on a given day, for the whole company.
class HrAttendanceScreen extends StatefulWidget {
  const HrAttendanceScreen({super.key});

  @override
  State<HrAttendanceScreen> createState() => _HrAttendanceScreenState();
}

class _HrAttendanceScreenState extends State<HrAttendanceScreen> {
  // How many days before today is on screen: 0 = today.
  var _daysBack = 0;

  DateTime get _today => dateOnly(DateTime.now());
  DateTime get _day => _today.subtract(Duration(days: _daysBack));

  String _statusLabel(AppLocalizations l10n, DayStatus s) => switch (s) {
    DayStatus.present => l10n.hrAttPresent,
    DayStatus.late => l10n.hrAttLate,
    DayStatus.absent => l10n.hrAttAbsent,
    DayStatus.onLeave => l10n.hrAttOnLeave,
  };

  Color _statusColor(DayStatus s) => switch (s) {
    DayStatus.present => CupertinoColors.activeGreen,
    DayStatus.late => CupertinoColors.systemOrange,
    DayStatus.absent => CupertinoColors.destructiveRed,
    DayStatus.onLeave => CupertinoColors.systemBlue,
  };

  // Worst first: the people HR needs to look at come to the top.
  static int _severity(DayStatus s) => switch (s) {
    DayStatus.absent => 0,
    DayStatus.late => 1,
    DayStatus.onLeave => 2,
    DayStatus.present => 3,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);
    final staff = context.watch<EmployeeRecordsState>().records;
    final roster = rosterFor(_day, staff);
    final entries = roster == null
        ? <DayAttendance>[]
        : (List.of(roster)..sort((a, b) {
            final bySeverity = _severity(a.status) - _severity(b.status);
            return bySeverity != 0
                ? bySeverity
                : a.employee.name.compareTo(b.employee.name);
          }));

    int count(DayStatus s) => entries.where((e) => e.status == s).length;
    final cameToWork = count(DayStatus.present) + count(DayStatus.late);
    final rate = entries.isEmpty
        ? 0
        : (cameToWork * 100 / entries.length).round();

    Widget stat(String label, DayStatus s) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceSecondary.resolveFrom(context),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(
                '${count(s)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _statusColor(s),
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11.5, color: subtle),
              ),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  CupertinoButton(
                    onPressed: _daysBack >= attendanceHistoryDays
                        ? null
                        : () => setState(() => _daysBack++),
                    child: Icon(
                      CupertinoIcons.chevron_left,
                      semanticLabel: l10n.a11yPreviousDay,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _daysBack == 0
                          ? '${l10n.feedToday} · ${dayDate(_day)}'
                          : dayDate(_day),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    onPressed: _daysBack == 0
                        ? null
                        : () => setState(() => _daysBack--),
                    child: Icon(
                      CupertinoIcons.chevron_right,
                      semanticLabel: l10n.a11yNextDay,
                    ),
                  ),
                ],
              ),
            ),
            if (roster == null)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.hrAttWeeklyOff,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: subtle),
                ),
              )
            else if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.hrAttNoRecords,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: subtle),
                ),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(
                  children: [
                    stat(l10n.hrAttPresent, DayStatus.present),
                    const SizedBox(width: 8),
                    stat(l10n.hrAttLate, DayStatus.late),
                    const SizedBox(width: 8),
                    stat(l10n.hrAttAbsent, DayStatus.absent),
                    const SizedBox(width: 8),
                    stat(l10n.hrAttOnLeave, DayStatus.onLeave),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  l10n.hrAttRate(rate),
                  style: TextStyle(fontSize: 12.5, color: subtle),
                ),
              ),
              CupertinoListSection.insetGrouped(
                children: [
                  for (final e in entries)
                    CupertinoListTile(
                      leading: InitialsAvatar(
                        initials: e.employee.initials,
                        size: 34,
                      ),
                      leadingSize: 34,
                      title: Text(
                        e.employee.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        e.checkIn == null
                            ? e.employee.department
                            : '${e.employee.department} · '
                                  '${l10n.hrAttCheckedIn(clockTime(e.checkIn!))}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      additionalInfo: TileInfoBox(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: StatusBadge(
                            label: _statusLabel(l10n, e.status),
                            color: _statusColor(e.status),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../state/attendance_state.dart';
import '../../../theme/app_colors.dart';
import '../widgets/async_state_view.dart';
import '../widgets/stat_tile.dart';
import '../widgets/status_badge.dart';
import 'attendance_models.dart';

class AttendanceModuleScreen extends StatefulWidget {
  const AttendanceModuleScreen({super.key});

  @override
  State<AttendanceModuleScreen> createState() =>
      _AttendanceModuleScreenState();
}

class _AttendanceModuleScreenState extends State<AttendanceModuleScreen> {
  LoadState _loadState = LoadState.loading;
  List<AttendanceRecord> _history = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loadState = LoadState.loading);

    try {
      final records = await fetchMyAttendanceHistory();
      if (!mounted) return;
      setState(() {
        _history = records;
        _loadState = records.isEmpty ? LoadState.empty : LoadState.ready;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadState = LoadState.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Same shared instance the main Time tab watches — checking in
    // here updates there too, and vice versa.
    final attendance = context.watch<AttendanceState>();

    final surface = AppColors.surface.resolveFrom(context);
    final surfaceSecondary = AppColors.surfaceSecondary.resolveFrom(context);
    final border = AppColors.border.resolveFrom(context);
    final subtleTextColor = CupertinoColors.systemGrey.resolveFrom(context);

    // CupertinoDynamicColor values must be resolved against the
    // current context before use in a plain Container/Text —
    // otherwise they silently always render their light-mode value,
    // even in Dark Mode.
    final presentColor =
        attendanceStatusColor(AttendanceDayStatus.present).resolveFrom(context);
    final absentColor =
        attendanceStatusColor(AttendanceDayStatus.absent).resolveFrom(context);
    final lateColor =
        attendanceStatusColor(AttendanceDayStatus.late).resolveFrom(context);
    final halfDayColor =
        attendanceStatusColor(AttendanceDayStatus.halfDay).resolveFrom(context);

    final presentCount = _history
        .where((r) => r.status == AttendanceDayStatus.present)
        .length;
    final absentCount = _history
        .where((r) => r.status == AttendanceDayStatus.absent)
        .length;
    final lateCount =
        _history.where((r) => r.status == AttendanceDayStatus.late).length;
    final halfDayCount = _history
        .where((r) => r.status == AttendanceDayStatus.halfDay)
        .length;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Attendance')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // TODAY CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Status",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _TodayStat(
                        label: 'Check-In',
                        value: attendance.checkInTime ?? '--:--',
                        subtleTextColor: subtleTextColor,
                      ),
                      _TodayStat(
                        label: 'Check-Out',
                        value: attendance.checkOutTime ?? '--:--',
                        subtleTextColor: subtleTextColor,
                      ),
                      _TodayStat(
                        label: 'Status',
                        value: attendance.isCheckedOut
                            ? 'Done'
                            : attendance.isCheckedIn
                                ? 'Working'
                                : 'Not In',
                        subtleTextColor: subtleTextColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: AppColors.karmaRed,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: attendance.isCheckedOut
                          ? null
                          : () {
                              if (attendance.isCheckedIn) {
                                context.read<AttendanceState>().checkOut();
                              } else {
                                context.read<AttendanceState>().checkIn();
                              }
                            },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            attendance.isCheckedIn
                                ? CupertinoIcons.arrow_left_circle
                                : CupertinoIcons.arrow_right_circle,
                            size: 16,
                            color: CupertinoColors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            attendance.isCheckedOut
                                ? 'Checked Out'
                                : attendance.isCheckedIn
                                    ? 'Check Out'
                                    : 'Check In',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // THIS MONTH SUMMARY
            const Text(
              'This Month',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'Present',
                    count: presentCount,
                    color: presentColor,
                    background: surfaceSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatTile(
                    label: 'Absent',
                    count: absentCount,
                    color: absentColor,
                    background: surfaceSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'Late',
                    count: lateCount,
                    color: lateColor,
                    background: surfaceSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatTile(
                    label: 'Half-day',
                    count: halfDayCount,
                    color: halfDayColor,
                    background: surfaceSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // HISTORY
            const Text(
              'Attendance History',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            AsyncStateView(
              state: _loadState,
              emptyMessage: 'No attendance records yet.',
              errorMessage: "Couldn't load your attendance history.",
              onRetry: _load,
              child: Column(
                children: _history
                    .map(
                      (record) => _HistoryCard(
                        record: record,
                        surface: surface,
                        border: border,
                        subtleTextColor: subtleTextColor,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayStat extends StatelessWidget {
  final String label;
  final String value;
  final Color subtleTextColor;

  const _TodayStat({
    required this.label,
    required this.value,
    required this.subtleTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: subtleTextColor)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final AttendanceRecord record;
  final Color surface;
  final Color border;
  final Color subtleTextColor;

  const _HistoryCard({
    required this.record,
    required this.surface,
    required this.border,
    required this.subtleTextColor,
  });

  String _formatDate(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    // .resolveFrom(context) here too — same reason as the summary
    // tiles above, otherwise this stays stuck on its light-mode value
    // in Dark Mode.
    final color = attendanceStatusColor(record.status).resolveFrom(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(record.date),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                StatusBadge(
                  label: attendanceStatusLabel(record.status),
                  color: color,
                ),
              ],
            ),
          ),
          if (record.checkInTime != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${record.checkInTime} – ${record.checkOutTime}',
                  style: TextStyle(fontSize: 12.5, color: subtleTextColor),
                ),
                const SizedBox(height: 3),
                Text(
                  record.workingHours ?? '',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

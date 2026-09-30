// This week's schedule (Sun–Fri, Saturday off, public holidays marked)
// and overtime: requests, weekly total vs the limit, and a request form
// that estimates the pay as you type.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../data/calendar_data.dart';
import '../data/current_employee.dart';
import '../domain/nepal/overtime.dart';
import '../state/notification_state.dart';
import '../state/overtime_state.dart';
import '../theme/app_colors.dart';
import 'apps/widgets/progress_bar.dart';
import 'apps/widgets/ui_kit.dart';

// Demo office hours. With a backend these come from the roster.
const _shiftStart = (9, 30);
const _shiftEnd = (17, 30);

String _hhmm((int, int) t) => clockTime(DateTime(2000, 1, 1, t.$1, t.$2));

String _fmtHours(double h) =>
    '${h == h.roundToDouble() ? h.toStringAsFixed(0) : h.toStringAsFixed(1)}h';

class ShiftsOvertimeScreen extends StatelessWidget {
  const ShiftsOvertimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = dateOnly(DateTime.now());
    final weekStart = workWeekStart(today);
    final overtime = context.watch<OvertimeState>();
    final weekHours = overtime.hoursInWeekOf(today);
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Shifts & Overtime'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              header: const Text('THIS WEEK'),
              children: [
                for (var i = 0; i < 7; i++)
                  _dayTile(
                    context,
                    DateTime(
                      weekStart.year,
                      weekStart.month,
                      weekStart.day + i,
                    ),
                    today,
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SectionCard(
                title: 'Overtime this week',
                subtitle:
                    'Limit ${_fmtHours(overtimeMaxHoursPerWeek)} a week, '
                    '${_fmtHours(overtimeMaxHoursPerDay)} a day · paid at '
                    '${overtimeMultiplier}x',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_fmtHours(weekHours)} of ${_fmtHours(overtimeMaxHoursPerWeek)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ProgressBar(
                      progress: weekHours / overtimeMaxHoursPerWeek,
                      color: AppColors.karmaRed,
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: AppColors.karmaRed,
                        borderRadius: BorderRadius.circular(12),
                        onPressed: () => Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => const OvertimeRequestScreen(),
                          ),
                        ),
                        child: const Text(
                          'Request Overtime',
                          style: TextStyle(color: CupertinoColors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            CupertinoListSection.insetGrouped(
              header: const Text('OVERTIME REQUESTS'),
              children: overtime.requests.isEmpty
                  ? const [
                      CupertinoListTile(
                        title: Text('No overtime requested yet.'),
                      ),
                    ]
                  : [
                      for (final r in overtime.requests)
                        CupertinoListTile(
                          leading: const Icon(CupertinoIcons.clock_fill),
                          title: Text(
                            '${dayDate(r.date)} · ${_fmtHours(r.hours)}',
                          ),
                          subtitle: Text(
                            r.reason,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          additionalInfo: TileInfoBox(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  formatRupees(r.estimatedPay),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  switch (r.status) {
                                    OvertimeStatus.pending => 'Pending',
                                    OvertimeStatus.approved => 'Approved',
                                    OvertimeStatus.rejected => 'Rejected',
                                  },
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: subtle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: NoteBanner(
                icon: CupertinoIcons.info_circle,
                text:
                    'Overtime rate and limits are placeholders pending HR '
                    'review of the Labour Act and company bylaw.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayTile(BuildContext context, DateTime day, DateTime today) {
    final isToday = day == today;
    final holiday = holidayNameOn(day);
    final isSaturday = day.weekday == DateTime.saturday;
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);

    final String hours;
    final Color? color;
    if (isSaturday) {
      hours = 'Weekly holiday';
      color = subtle;
    } else if (holiday != null) {
      hours = holiday;
      color = CupertinoColors.systemGreen.resolveFrom(context);
    } else {
      hours = '${_hhmm(_shiftStart)} – ${_hhmm(_shiftEnd)}';
      color = null;
    }

    return CupertinoListTile(
      title: Text(
        dayDate(day),
        style: TextStyle(
          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      // Subtitle, not additionalInfo: a holiday name can be long, and the
      // subtitle truncates where additionalInfo would overflow.
      subtitle: Text(hours, style: TextStyle(color: color)),
      trailing: isToday
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.karmaRed,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Today',
                style: TextStyle(color: CupertinoColors.white, fontSize: 11),
              ),
            )
          : null,
    );
  }
}

class OvertimeRequestScreen extends StatefulWidget {
  const OvertimeRequestScreen({super.key});

  @override
  State<OvertimeRequestScreen> createState() => _OvertimeRequestScreenState();
}

class _OvertimeRequestScreenState extends State<OvertimeRequestScreen> {
  final _reason = TextEditingController();
  DateTime _date = dateOnly(DateTime.now());
  double _hours = 2;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit(List<String> warnings) async {
    if (warnings.isNotEmpty) {
      await showMessage(
        context,
        title: 'Over the Limit',
        message: '${warnings.join('\n\n')}\n\nReduce the hours to continue.',
      );
      return;
    }
    if (_reason.text.trim().isEmpty) {
      await showMessage(
        context,
        title: 'Almost there',
        message: 'Add a reason so your manager can approve it.',
      );
      return;
    }
    if (!mounted) return;
    context.read<OvertimeState>().submit(
      OvertimeRequest(
        date: _date,
        hours: _hours,
        reason: _reason.text.trim(),
        status: OvertimeStatus.pending,
      ),
    );
    notifyUser(
      context,
      kind: AppNotificationKind.hrRequest,
      title: 'Overtime request submitted',
      body: '${_fmtHours(_hours)} on ${dayDate(_date)} — pending approval.',
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final alreadyThisWeek = context.watch<OvertimeState>().hoursInWeekOf(_date);
    final warnings = overtimeWarnings(
      hoursThatDay: _hours,
      hoursThisWeek: alreadyThisWeek + _hours,
    );
    final pay = overtimePay(
      monthlyBasic: currentEmployee.basicSalary,
      hours: _hours,
    );
    final rate = hourlyBasicRate(currentEmployee.basicSalary);
    final today = dateOnly(DateTime.now());

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Request Overtime'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              children: [
                FormRow(
                  label: 'Date',
                  value: dayDate(_date),
                  onTap: () async {
                    final picked = await pickDate(
                      context,
                      initial: _date,
                      minimum: DateTime(
                        today.year,
                        today.month,
                        today.day - 14,
                      ),
                      maximum: today,
                    );
                    if (picked != null && mounted) setState(() => _date = picked);
                  },
                ),
                CupertinoListTile(
                  title: const Text('Hours'),
                  additionalInfo: Text(_fmtHours(_hours)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(32, 32),
                        onPressed: _hours <= 0.5
                            ? null
                            : () => setState(() => _hours -= 0.5),
                        child: const Icon(CupertinoIcons.minus_circle),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(32, 32),
                        onPressed: _hours >= 8
                            ? null
                            : () => setState(() => _hours += 0.5),
                        child: const Icon(CupertinoIcons.plus_circle),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estimated overtime pay',
                          style: TextStyle(fontSize: 12.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatRupees(pay),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_fmtHours(_hours)} × ${formatRupees(rate)}/hr × ${overtimeMultiplier}x',
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.systemGrey.resolveFrom(
                              context,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (final w in warnings) ...[
                    const SizedBox(height: 10),
                    NoteBanner(
                      icon: CupertinoIcons.exclamationmark_triangle,
                      color: CupertinoColors.systemRed,
                      text: w,
                    ),
                  ],
                  const SizedBox(height: 14),
                  CupertinoTextField(
                    controller: _reason,
                    placeholder: 'Reason, e.g. month-end payroll close',
                    maxLines: 3,
                    minLines: 2,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6.resolveFrom(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: AppColors.karmaRed,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: () => _submit(warnings),
                      child: const Text(
                        'Submit',
                        style: TextStyle(color: CupertinoColors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

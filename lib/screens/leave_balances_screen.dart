// 1. IMPORT FLUTTER CUPERTINO
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../domain/nepal/fiscal_year.dart';
import '../state/leave_balance_state.dart';
import '../state/leave_state.dart';
import '../state/notification_state.dart';
import '../theme/app_colors.dart';
import 'apps/widgets/progress_bar.dart';

// 2. LEAVE REQUEST STATUS
//
// LeaveRequestStatus, the label/color helpers, and LeaveRequest all
// moved to state/leave_state.dart, so this screen and
// leave_screen.dart share exactly the same definitions instead of
// each keeping a private copy.

// 4. LEAVE & BALANCES SCREEN
class LeaveBalancesScreen extends StatefulWidget {
  const LeaveBalancesScreen({super.key});

  @override
  State<LeaveBalancesScreen> createState() => _LeaveBalancesScreenState();
}

class _LeaveBalancesScreenState extends State<LeaveBalancesScreen> {
  // 5. LEAVE BALANCE
  //
  // No longer stored here as dummy fields — balances are now computed
  // in build() by LeaveBalanceState from the Nepali fiscal year + the
  // leave policy table (lib/domain/nepal/) + whatever's actually been
  // submitted in LeaveState. See _homeLeaveCards / _allBalancesSection
  // below.

  // 6. REASON CONTROLLER
  final _reasonController = TextEditingController();

  // 7. SELECTED LEAVE TYPE
  String _selectedLeaveType = 'Select Leave Type';
  final List<String> _leaveTypes = [
    'Home Leave',
    'Sick Leave',
    'Maternity Leave',
    'Maternity Care Leave',
    'Mourning Leave',
    'Substitute Leave',
    'Unpaid Leave',
    'Other',
  ];

  // 8. SELECTED DURATION TYPE
  String _selectedDurationType = 'Full Day';
  final List<String> _durationTypes = [
    'Full Day',
    'First Half Day',
    'Second Half Day',
    'Hours Leave',
  ];

  // 9. DATES / TIME / HOURS
  DateTime? _startDate;
  DateTime? _endDate;
  int _leaveHours = 1;
  DateTime? _leaveStartTime;

  // 10. LEAVE REQUEST HISTORY
  //
  // No longer a local list — this now lives in the shared LeaveState
  // (via Provider), same as leave_screen.dart, so both screens
  // always agree on what has been submitted and its current status.

  // 11. FORMAT DATE
  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // 12. FORMAT SHORT DATE — used in the history list.
  String _formatShortDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  // 13. FORMAT TIME
  String _formatTime(DateTime time) {
    int hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }
    return '$hour:$minute $period';
  }

  // 14. CALCULATE DURATION TEXT
  String get _duration {
    if (_selectedDurationType == 'First Half Day' ||
        _selectedDurationType == 'Second Half Day') {
      return '0.5 Day';
    }
    if (_selectedDurationType == 'Hours Leave') {
      return '$_leaveHours ${_leaveHours == 1 ? 'Hour' : 'Hours'}';
    }
    if (_startDate == null || _endDate == null) {
      return 'Select dates';
    }
    final days = _endDate!.difference(_startDate!).inDays + 1;
    return '$days ${days == 1 ? 'Day' : 'Days'}';
  }

  // 15. SELECT LEAVE TYPE
  void _selectLeaveType() {
    int selectedIndex = _leaveTypes.indexOf(_selectedLeaveType);
    if (selectedIndex == -1) selectedIndex = 0;

    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        // Only commit on Done — see leave_screen.dart for why.
        int pendingIndex = selectedIndex;

        return Container(
          height: 300,
          color: AppColors.surface.resolveFrom(context),
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: () {
                      setState(() {
                        _selectedLeaveType = _leaveTypes[pendingIndex];
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Done'),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(
                    initialItem: selectedIndex,
                  ),
                  onSelectedItemChanged: (index) => pendingIndex = index,
                  children: _leaveTypes
                      .map((type) => Center(child: Text(type)))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 16. SELECT DURATION TYPE
  void _selectDurationType() {
    int selectedIndex = _durationTypes.indexOf(_selectedDurationType);

    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          color: AppColors.surface.resolveFrom(context),
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(
                    initialItem: selectedIndex,
                  ),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedDurationType = _durationTypes[index];

                      // Clear values not needed for this duration type.
                      if (_selectedDurationType == 'Hours Leave') {
                        _endDate = null;
                      } else if (_selectedDurationType == 'First Half Day' ||
                          _selectedDurationType == 'Second Half Day') {
                        _endDate = _startDate;
                        _leaveStartTime = null;
                      } else {
                        _leaveStartTime = null;
                      }
                    });
                  },
                  children: _durationTypes
                      .map((type) => Center(child: Text(type)))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 17. SELECT START DATE (Full Day)
  void _selectStartDate() {
    final today = DateTime.now();
    final initialDate = _startDate ?? today;

    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        DateTime selectedDate = initialDate;
        return Container(
          height: 300,
          color: AppColors.surface.resolveFrom(context),
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: () {
                      setState(() {
                        _startDate = selectedDate;
                        if (_endDate != null &&
                            _endDate!.isBefore(selectedDate)) {
                          _endDate = null;
                        }
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Done'),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate,
                  minimumDate: today,
                  onDateTimeChanged: (date) => selectedDate = date,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 18. SELECT END DATE (Full Day)
  void _selectEndDate() {
    final today = DateTime.now();
    final initialDate = _endDate ?? _startDate ?? today;

    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        DateTime selectedDate = initialDate;
        return Container(
          height: 300,
          color: AppColors.surface.resolveFrom(context),
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: () {
                      setState(() => _endDate = selectedDate);
                      Navigator.pop(context);
                    },
                    child: const Text('Done'),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate,
                  minimumDate: _startDate ?? today,
                  onDateTimeChanged: (date) => selectedDate = date,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 19. SELECT HALF DAY DATE
  void _selectHalfDayDate() {
    final today = DateTime.now();
    final initialDate = _startDate ?? today;

    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        DateTime selectedDate = initialDate;
        return Container(
          height: 300,
          color: AppColors.surface.resolveFrom(context),
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: () {
                      setState(() {
                        _startDate = selectedDate;
                        _endDate = selectedDate;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Done'),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate,
                  minimumDate: today,
                  onDateTimeChanged: (date) => selectedDate = date,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 20. SELECT HOURS LEAVE DATE
  void _selectHoursLeaveDate() {
    final today = DateTime.now();
    final initialDate = _startDate ?? today;

    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        DateTime selectedDate = initialDate;
        return Container(
          height: 300,
          color: AppColors.surface.resolveFrom(context),
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: () {
                      setState(() {
                        _startDate = selectedDate;
                        _endDate = selectedDate;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Done'),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate,
                  minimumDate: today,
                  onDateTimeChanged: (date) => selectedDate = date,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 21. SELECT START TIME (Hours Leave)
  void _selectStartTime() {
    final now = DateTime.now();
    final initialTime =
        _leaveStartTime ??
        DateTime(now.year, now.month, now.day, now.hour, now.minute);

    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        DateTime selectedTime = initialTime;
        return Container(
          height: 300,
          color: AppColors.surface.resolveFrom(context),
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: () {
                      setState(() => _leaveStartTime = selectedTime);
                      Navigator.pop(context);
                    },
                    child: const Text('Done'),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: initialTime,
                  use24hFormat: false,
                  onDateTimeChanged: (time) => selectedTime = time,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 22. SELECT NUMBER OF HOURS
  void _selectLeaveHours() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          color: AppColors.surface.resolveFrom(context),
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(
                    initialItem: _leaveHours - 1,
                  ),
                  onSelectedItemChanged: (index) {
                    setState(() => _leaveHours = index + 1);
                  },
                  children: List.generate(8, (index) {
                    final hours = index + 1;
                    return Center(
                      child: Text('$hours ${hours == 1 ? 'Hour' : 'Hours'}'),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 23. SUBMIT LEAVE REQUEST
  void _submitLeaveRequest() {
    if (_selectedLeaveType == 'Select Leave Type') {
      _showMessage('Please select a leave type.');
      return;
    }

    if (_selectedDurationType == 'Full Day') {
      if (_startDate == null) {
        _showMessage('Please select a start date.');
        return;
      }
      if (_endDate == null) {
        _showMessage('Please select an end date.');
        return;
      }
    }

    if ((_selectedDurationType == 'First Half Day' ||
            _selectedDurationType == 'Second Half Day') &&
        _startDate == null) {
      _showMessage('Please select a date.');
      return;
    }

    if (_selectedDurationType == 'Hours Leave') {
      if (_startDate == null) {
        _showMessage('Please select a date.');
        return;
      }
      if (_leaveStartTime == null) {
        _showMessage('Please select a start time.');
        return;
      }
      if (_leaveHours <= 0) {
        _showMessage('Please select the number of hours.');
        return;
      }
    }

    if (_reasonController.text.trim().isEmpty) {
      _showMessage('Please enter a reason for leave.');
      return;
    }

    // Goes into the shared LeaveState (read, not watch — we're
    // calling a method, not rebuilding in response to a change) so
    // leave_screen.dart sees it too.
    context.read<LeaveState>().submitLeave(
      LeaveRequest(
        leaveType: _selectedLeaveType,
        durationType: _selectedDurationType,
        startDate: _startDate!,
        endDate: _endDate ?? _startDate!,
        leaveHours: _selectedDurationType == 'Hours Leave' ? _leaveHours : null,
        leaveStartTime: _selectedDurationType == 'Hours Leave'
            ? _leaveStartTime
            : null,
        reason: _reasonController.text.trim(),
        status: LeaveRequestStatus.pending,
      ),
    );
    notifyUser(
      context,
      kind: AppNotificationKind.leave,
      title: '$_selectedLeaveType request submitted',
      body: 'Your request is pending approval from your manager.',
    );

    // Reset the form — still local UI state, so setState is still
    // correct here; only the submitted request itself moved.
    setState(() {
      _selectedLeaveType = 'Select Leave Type';
      _selectedDurationType = 'Full Day';
      _startDate = null;
      _endDate = null;
      _leaveHours = 1;
      _leaveStartTime = null;
      _reasonController.clear();
    });

    _showMessage('Leave request submitted.');
  }

  // 24. SHOW MESSAGE
  void _showMessage(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // 25. BUILD METHOD
  @override
  Widget build(BuildContext context) {
    const karmaRed = AppColors.karmaRed;

    // CupertinoDynamicColor values must be resolved against the
    // current context before use in a plain Container — otherwise
    // they silently always render their light-mode value, even in
    // Dark Mode.
    final fieldBackground = CupertinoColors.systemGrey6.resolveFrom(context);
    final surfaceSecondary = AppColors.surfaceSecondary.resolveFrom(context);

    // context.watch so this screen rebuilds automatically when
    // LeaveState changes — including a submission made from
    // leave_screen.dart instead of here.
    final submittedRequests = context.watch<LeaveState>().requests;

    // LeaveBalanceState itself never changes (it holds no fields), so
    // context.read is enough — this screen already rebuilds whenever
    // submittedRequests changes above.
    final fiscalYear = NepaliFiscalYear.current();
    final balances = context.read<LeaveBalanceState>().balancesFor(
      submittedRequests,
      fiscalYear: fiscalYear,
    );
    // The top summary row focuses on Home Leave — the one type every
    // employee accrues continuously and is most likely to check day to
    // day. The full per-type breakdown lives in _allBalancesSection below.
    final homeLeave = balances.firstWhere((b) => b.type == 'Home Leave');

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Leave & Balances'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 26. LEAVE BALANCE CARDS — Home Leave, for the current
              // Nepali fiscal year (Shrawan–Ashad), computed live by
              // LeaveBalanceState rather than hardcoded.
              // Wrap, not Row: at large text sizes the fiscal-year label
              // moves to a second line instead of running off-screen.
              Wrap(
                spacing: 6,
                children: [
                  Text(
                    'Home Leave',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.secondaryLabel.resolveFrom(
                        context,
                      ),
                    ),
                  ),
                  Text(
                    '· FY ${fiscalYear.label}',
                    style: TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.systemGrey.resolveFrom(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _balanceCard(
                      'Total',
                      '${_formatDays(homeLeave.entitled)} Days',
                      karmaRed,
                      surfaceSecondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _balanceCard(
                      'Used',
                      '${_formatDays(homeLeave.used)} Days',
                      CupertinoColors.systemOrange.resolveFrom(context),
                      surfaceSecondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _balanceCard(
                      'Remaining',
                      '${_formatDays(homeLeave.remaining)} Days',
                      CupertinoColors.systemGreen.resolveFrom(context),
                      surfaceSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 26b. ALL LEAVE TYPES — the fuller breakdown Home Leave's
              // 3 cards above don't have room for: every policy-tracked
              // leave type, how much is left, and a warning if approved-
              // but-unused days will lapse at this fiscal year's Ashad-end.
              _allBalancesSection(balances, fiscalYear, surfaceSecondary),

              const SizedBox(height: 28),

              // 27. APPLY LEAVE
              const Text(
                'Apply Leave',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              const Text(
                'Leave Type',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _formField(
                background: fieldBackground,
                child: CupertinoListTile(
                  title: Text(_selectedLeaveType),
                  trailing: const Icon(CupertinoIcons.chevron_right, size: 18),
                  onTap: _selectLeaveType,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Leave Duration',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _formField(
                background: fieldBackground,
                child: CupertinoListTile(
                  title: Text(_selectedDurationType),
                  trailing: const Icon(CupertinoIcons.chevron_right, size: 18),
                  onTap: _selectDurationType,
                ),
              ),

              const SizedBox(height: 20),

              // FULL DAY FIELDS
              if (_selectedDurationType == 'Full Day') ...[
                const Text(
                  'Start Date',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _formField(
                  background: fieldBackground,
                  child: CupertinoListTile(
                    title: Text(
                      _startDate == null
                          ? 'Select Start Date'
                          : _formatDate(_startDate!),
                    ),
                    trailing: const Icon(CupertinoIcons.calendar, size: 20),
                    onTap: _selectStartDate,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'End Date',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _formField(
                  background: fieldBackground,
                  child: CupertinoListTile(
                    title: Text(
                      _endDate == null
                          ? 'Select End Date'
                          : _formatDate(_endDate!),
                    ),
                    trailing: const Icon(CupertinoIcons.calendar, size: 20),
                    onTap: _selectEndDate,
                  ),
                ),
              ],

              // HALF DAY FIELD
              if (_selectedDurationType == 'First Half Day' ||
                  _selectedDurationType == 'Second Half Day') ...[
                const Text(
                  'Date',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _formField(
                  background: fieldBackground,
                  child: CupertinoListTile(
                    title: Text(
                      _startDate == null
                          ? 'Select Date'
                          : _formatDate(_startDate!),
                    ),
                    trailing: const Icon(CupertinoIcons.calendar, size: 20),
                    onTap: _selectHalfDayDate,
                  ),
                ),
              ],

              // HOURS LEAVE FIELDS
              if (_selectedDurationType == 'Hours Leave') ...[
                const Text(
                  'Date',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _formField(
                  background: fieldBackground,
                  child: CupertinoListTile(
                    title: Text(
                      _startDate == null
                          ? 'Select Date'
                          : _formatDate(_startDate!),
                    ),
                    trailing: const Icon(CupertinoIcons.calendar, size: 20),
                    onTap: _selectHoursLeaveDate,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Start Time',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _formField(
                  background: fieldBackground,
                  child: CupertinoListTile(
                    title: Text(
                      _leaveStartTime == null
                          ? 'Select Start Time'
                          : _formatTime(_leaveStartTime!),
                    ),
                    trailing: const Icon(CupertinoIcons.time, size: 20),
                    onTap: _selectStartTime,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Hours',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _formField(
                  background: fieldBackground,
                  child: CupertinoListTile(
                    title: Text(
                      '$_leaveHours ${_leaveHours == 1 ? 'Hour' : 'Hours'}',
                    ),
                    trailing: const Icon(
                      CupertinoIcons.chevron_right,
                      size: 18,
                    ),
                    onTap: _selectLeaveHours,
                  ),
                ),
              ],

              const SizedBox(height: 20),

              const Text(
                'Duration',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _formField(
                background: fieldBackground,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(_duration, style: const TextStyle(fontSize: 14)),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Reason',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: _reasonController,
                placeholder: 'Briefly describe the reason for leave',
                maxLines: 4,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: fieldBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                style: const TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 28),

              // 28. SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: karmaRed,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: _submitLeaveRequest,
                  child: const Text(
                    'Submit Request',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 29. LEAVE REQUEST HISTORY
              const Text(
                'Leave Request History',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              if (submittedRequests.isEmpty)
                const Text(
                  'No requests yet',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: CupertinoColors.systemGrey,
                  ),
                )
              else
                ...submittedRequests.map(
                  (request) => _requestCard(request, fieldBackground),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 29b. FORMAT A DAY COUNT FOR DISPLAY
  //
  // Accrual-based balances (Home Leave) are fractional day-by-day —
  // showing "6.4 Days" reads oddly for a whole number, so this only
  // keeps the decimal when the value actually isn't a whole day.
  String _formatDays(double days) {
    if (days.isInfinite) return 'Unlimited';
    return days == days.roundToDouble()
        ? days.toStringAsFixed(0)
        : days.toStringAsFixed(1);
  }

  // 29c. ALL LEAVE TYPES SECTION
  //
  // One row per policy-tracked leave type, each with a progress bar and
  // a "days will lapse" warning where relevant. Built from LeaveBalance
  // objects that LeaveBalanceState computed in build() above — this
  // method only lays them out, it does no balance math itself.
  Widget _allBalancesSection(
    List<LeaveBalance> balances,
    NepaliFiscalYear fiscalYear,
    Color background,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'All Leave Balances',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Unused balance beyond the carry-forward limit lapses at '
            'Ashad-end (FY ${fiscalYear.label}).',
            style: TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey.resolveFrom(context),
            ),
          ),
          const SizedBox(height: 14),
          for (final balance in balances) ...[
            _leaveTypeRow(balance),
            if (balance != balances.last) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  Widget _leaveTypeRow(LeaveBalance balance) {
    final atRisk = balance.atRiskOfLapsing;
    final progress = balance.entitled.isInfinite || balance.entitled == 0
        ? 0.0
        : balance.used / balance.entitled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                balance.type,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '${_formatDays(balance.remaining)} / '
                '${_formatDays(balance.entitled)} left',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ProgressBar(
          progress: progress,
          color: balance.paid
              ? AppColors.karmaRed
              : CupertinoColors.systemGrey.resolveFrom(context),
        ),
        if (atRisk > 0) ...[
          const SizedBox(height: 4),
          Text(
            '${_formatDays(atRisk)} day(s) will lapse if unused before '
            'Ashad-end',
            style: TextStyle(
              fontSize: 11,
              color: CupertinoColors.systemOrange.resolveFrom(context),
            ),
          ),
        ],
      ],
    );
  }

  // 30. REUSABLE BALANCE CARD
  Widget _balanceCard(
    String label,
    String value,
    Color accent,
    Color background,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }

  // 31. REUSABLE FORM FIELD CONTAINER
  Widget _formField({required Widget child, required Color background}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  // 32. REQUEST CARD
  Widget _requestCard(LeaveRequest request, Color background) {
    final color = leaveStatusColor(request.status).resolveFrom(context);

    String dateText;
    if (request.durationType == 'Full Day') {
      dateText =
          '${_formatShortDate(request.startDate)} – '
          '${_formatShortDate(request.endDate)}';
    } else {
      dateText = _formatShortDate(request.startDate);
    }

    String durationText;
    if (request.durationType == 'Hours Leave') {
      durationText =
          '${request.leaveHours} '
          '${request.leaveHours == 1 ? 'Hour' : 'Hours'}';
    } else if (request.durationType == 'First Half Day' ||
        request.durationType == 'Second Half Day') {
      durationText = request.durationType;
    } else {
      final days = request.endDate.difference(request.startDate).inDays + 1;
      durationText = '$days ${days == 1 ? 'Day' : 'Days'}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  request.leaveType,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  leaveStatusLabel(request.status),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$dateText · $durationText',
            style: const TextStyle(
              fontSize: 12.5,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 6),
          Text(request.reason, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  // 33. DISPOSE CONTROLLER
  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
}

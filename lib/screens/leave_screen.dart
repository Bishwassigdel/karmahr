// 1. IMPORT FLUTTER CUPERTINO
// Imports Cupertino widgets so we can build an iOS-style UI.
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../state/leave_state.dart';
import '../state/notification_state.dart';
import '../theme/app_colors.dart';

// 2. LEAVE REQUEST MODEL
//
// LeaveRequest and LeaveRequestStatus now live in state/leave_state.dart
// instead of being defined here — this screen and
// leave_balances_screen.dart used to each keep their own separate
// copy, which meant a request submitted on one screen never showed
// up on the other. Both screens now share the same LeaveState.

// 3. LEAVE SCREEN
//
// This screen allows an employee to apply for leave.
class LeaveScreen extends StatefulWidget {
  // Optional pre-fill — the Leave Planner opens this form with the dates
  // it just calculated, so the employee doesn't re-enter them.
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const LeaveScreen({super.key, this.initialStartDate, this.initialEndDate});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

// 4. LEAVE SCREEN STATE
//
// Contains the changing data and logic for the Leave screen.
class _LeaveScreenState extends State<LeaveScreen> {
  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  // 5. REASON CONTROLLER
  //
  // Controller used to read the reason entered by the employee.
  final _reasonController = TextEditingController();

  // 6. SELECTED LEAVE TYPE
  //
  // Stores the selected type of leave.
  String _selectedLeaveType = 'Select Leave Type';

  // Available leave types.
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

  // 7. SELECTED DURATION TYPE
  //
  // Stores how the employee wants to take the leave.
  String _selectedDurationType = 'Full Day';

  // Available duration options.
  final List<String> _durationTypes = [
    'Full Day',
    'First Half Day',
    'Second Half Day',
    'Hours Leave',
  ];

  // 8. START DATE
  //
  // Stores the selected start date.
  DateTime? _startDate;

  // 9. END DATE
  //
  // Stores the selected end date.
  DateTime? _endDate;

  // 10. HOURS LEAVE
  //
  // Stores the number of hours requested.
  int _leaveHours = 1;

  // Stores the starting time for hours leave.
  DateTime? _leaveStartTime;

  // 11. SUBMITTED REQUESTS
  //
  // No longer a local list — leave requests now live in the shared
  // LeaveState (via Provider), so this screen and
  // leave_balances_screen.dart always show the exact same data.

  // 12. FORMAT DATE
  //
  // Converts DateTime into a readable date.
  //
  // Example:
  // 2026-09-15 → September 15, 2026
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

  // 13. FORMAT SHORT DATE
  //
  // Used in the leave request list.
  //
  // Example:
  // September 15 → Sep 15
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

  // 14. FORMAT TIME
  //
  // Converts DateTime into 12-hour time.
  //
  // Example:
  // 13:30 → 1:30 PM
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

  // 15. CALCULATE DURATION
  //
  // Calculates the leave duration based on the
  // selected duration type.
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

  // 16. SELECT LEAVE TYPE
  //
  // Opens a Cupertino picker for selecting the leave type.
  void _selectLeaveType() {
    int selectedIndex = _leaveTypes.indexOf(_selectedLeaveType);

    if (selectedIndex == -1) {
      selectedIndex = 0;
    }

    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        // Only commit on Done — starting this at selectedIndex is what
        // makes "open the picker and tap Done immediately" select the
        // item that was visibly centered, instead of selecting nothing.
        int pendingIndex = selectedIndex;

        return Container(
          height: 300,
          color: AppColors.surface.resolveFrom(context),
          child: Column(
            children: [
              // Picker header.
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

              // Leave type picker.
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(
                    initialItem: selectedIndex,
                  ),
                  onSelectedItemChanged: (index) => pendingIndex = index,
                  children: _leaveTypes.map((leaveType) {
                    return Center(child: Text(leaveType));
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 17. SELECT DURATION TYPE
  //
  // Opens a Cupertino picker for selecting
  // Full Day, First Half Day, Second Half Day,
  // or Hours Leave.
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
              // Picker header.
              SizedBox(
                height: 50,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Done'),
                  ),
                ),
              ),

              // Duration picker.
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(
                    initialItem: selectedIndex,
                  ),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedDurationType = _durationTypes[index];

                      // Clear values that are not needed
                      // for the selected duration type.
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
                  children: _durationTypes.map((durationType) {
                    return Center(child: Text(durationType));
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 18. SELECT START DATE
  //
  // Opens a Cupertino date picker for full-day leave.
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
              // Date picker header.
              SizedBox(
                height: 50,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: () {
                      setState(() {
                        _startDate = selectedDate;

                        // Clears the end date if it becomes
                        // earlier than the new start date.
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

              // Start date picker.
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate,
                  minimumDate: today,
                  onDateTimeChanged: (date) {
                    selectedDate = date;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 19. SELECT END DATE
  //
  // Opens a Cupertino date picker for full-day leave.
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
              // Date picker header.
              SizedBox(
                height: 50,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: () {
                      setState(() {
                        _endDate = selectedDate;
                      });

                      Navigator.pop(context);
                    },
                    child: const Text('Done'),
                  ),
                ),
              ),

              // End date picker.
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate,
                  minimumDate: _startDate ?? today,
                  onDateTimeChanged: (date) {
                    selectedDate = date;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 20. SELECT HALF DAY DATE
  //
  // Opens a Cupertino date picker for half-day leave.
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
              // Date picker header.
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

              // Half-day date picker.
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate,
                  minimumDate: today,
                  onDateTimeChanged: (date) {
                    selectedDate = date;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 21. SELECT HOURS LEAVE DATE
  //
  // Opens a Cupertino date picker for hours leave.
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
              // Date picker header.
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

              // Hours leave date picker.
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate,
                  minimumDate: today,
                  onDateTimeChanged: (date) {
                    selectedDate = date;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 22. SELECT START TIME
  //
  // Opens a Cupertino time picker for hours leave.
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
              // Time picker header.
              SizedBox(
                height: 50,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: () {
                      setState(() {
                        _leaveStartTime = selectedTime;
                      });

                      Navigator.pop(context);
                    },
                    child: const Text('Done'),
                  ),
                ),
              ),

              // Time picker.
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: initialTime,
                  use24hFormat: false,
                  onDateTimeChanged: (time) {
                    selectedTime = time;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 23. SELECT NUMBER OF HOURS
  //
  // Opens a Cupertino picker for selecting
  // how many hours of leave the employee wants.
  void _selectLeaveHours() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          color: AppColors.surface.resolveFrom(context),
          child: Column(
            children: [
              // Picker header.
              SizedBox(
                height: 50,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Done'),
                  ),
                ),
              ),

              // Hours picker.
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(
                    initialItem: _leaveHours - 1,
                  ),
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _leaveHours = index + 1;
                    });
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

  // 24. SUBMIT LEAVE REQUEST
  //
  // Validates the form when the employee taps
  // the Submit Request button.
  void _submitLeaveRequest() {
    // Checks whether a leave type was selected.
    if (_selectedLeaveType == 'Select Leave Type') {
      _showMessage('Please select a leave type.');
      return;
    }

    // Checks the date for full-day leave.
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

    // Checks the date for half-day leave.
    if (_selectedDurationType == 'First Half Day' ||
        _selectedDurationType == 'Second Half Day') {
      if (_startDate == null) {
        _showMessage('Please select a date.');
        return;
      }
    }

    // Checks the date for hours leave.
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

    // Checks whether the employee entered a reason.
    if (_reasonController.text.trim().isEmpty) {
      _showMessage('Please enter a reason for leave.');
      return;
    }

    // All checks passed. The request goes into the shared LeaveState
    // (read, not watch — we're only calling a method here, not
    // rebuilding this widget in response to a change) so
    // leave_balances_screen.dart sees it too.
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

    // Reset the form. This part is still local UI state (what's
    // currently typed into the form), so setState is still correct
    // here — only the submitted request itself moved to LeaveState.
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

  // 25. SHOW MESSAGE
  //
  // Displays a Cupertino alert dialog.
  void _showMessage(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // 26. BUILD METHOD
  //
  // Builds the Leave form UI.
  @override
  Widget build(BuildContext context) {
    const karmaRed = AppColors.karmaRed;

    // Resolves the dynamic Cupertino grey color
    // for the current light/dark mode.
    final fieldBackground = CupertinoColors.systemGrey6.resolveFrom(context);

    // context.watch (not .read) so this screen automatically rebuilds
    // whenever LeaveState changes — including when a request is
    // submitted from leave_balances_screen.dart instead of here.
    final submittedRequests = context.watch<LeaveState>().requests;

    return CupertinoPageScaffold(
      // Navigation bar.
      navigationBar: const CupertinoNavigationBar(middle: Text('Apply Leave')),

      // Page body.
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 27. LEAVE TYPE
              const Text(
                'Leave Type',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              // Leave type selection field.
              _formContainer(
                background: fieldBackground,
                child: CupertinoListTile(
                  title: Text(_selectedLeaveType),
                  trailing: const Icon(CupertinoIcons.chevron_right, size: 18),
                  onTap: _selectLeaveType,
                ),
              ),

              const SizedBox(height: 20),

              // 28. LEAVE DURATION TYPE
              const Text(
                'Leave Duration',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              // Duration type selection field.
              _formContainer(
                background: fieldBackground,
                child: CupertinoListTile(
                  title: Text(_selectedDurationType),
                  trailing: const Icon(CupertinoIcons.chevron_right, size: 18),
                  onTap: _selectDurationType,
                ),
              ),

              const SizedBox(height: 20),

              // 29. FULL DAY FIELDS
              //
              // Start Date and End Date are displayed
              // only when Full Day is selected.
              if (_selectedDurationType == 'Full Day') ...[
                const Text(
                  'Start Date',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 8),

                _formContainer(
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

                _formContainer(
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

              // 30. HALF DAY FIELDS
              //
              // One date is required for half-day leave.
              if (_selectedDurationType == 'First Half Day' ||
                  _selectedDurationType == 'Second Half Day') ...[
                const Text(
                  'Date',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 8),

                _formContainer(
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

              // 31. HOURS LEAVE FIELDS
              //
              // Date, start time, and hours are required
              // for an hours leave request.
              if (_selectedDurationType == 'Hours Leave') ...[
                const Text(
                  'Date',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 8),

                _formContainer(
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

                _formContainer(
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

                _formContainer(
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

              // 32. DURATION
              const Text(
                'Duration',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              // Displays the calculated leave duration.
              _formContainer(
                background: fieldBackground,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(_duration, style: const TextStyle(fontSize: 14)),
                ),
              ),

              const SizedBox(height: 20),

              // 33. REASON
              const Text(
                'Reason',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              // Reason input field.
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

              const SizedBox(height: 20),

              // 34. ATTACHMENT
              const Text(
                'Attachment (Optional)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              // Attachment field.
              _formContainer(
                background: fieldBackground,
                child: CupertinoListTile(
                  leading: const Icon(CupertinoIcons.paperclip, size: 21),
                  title: const Text(
                    'Add document',
                    style: TextStyle(fontSize: 14),
                  ),
                  trailing: const Icon(CupertinoIcons.chevron_right, size: 18),
                  onTap: () {
                    _showMessage('Attachment feature will be added later.');
                  },
                ),
              ),

              const SizedBox(height: 30),

              // 35. SUBMIT BUTTON
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

              // 36. YOUR LEAVE REQUESTS
              //
              // Displays requests submitted during this session.
              const Text(
                'Your Leave Requests',
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

  // 37. REUSABLE FORM CONTAINER
  //
  // Creates the common design used by form fields.
  Widget _formContainer({required Widget child, required Color background}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  // 38. REQUEST CARD
  //
  // Displays one submitted leave request.
  Widget _requestCard(LeaveRequest request, Color background) {
    // Previously this card always showed a hardcoded "Pending" label
    // regardless of the request's actual status — now it reads the
    // real status, same as leave_balances_screen.dart already did.
    final statusColor = leaveStatusColor(request.status).resolveFrom(context);

    String requestDate;

    if (request.durationType == 'Full Day') {
      requestDate =
          '${_formatShortDate(request.startDate)} – '
          '${_formatShortDate(request.endDate)}';
    } else {
      requestDate = _formatShortDate(request.startDate);
    }

    String requestDuration;

    if (request.durationType == 'Hours Leave') {
      requestDuration =
          '${request.leaveHours} '
          '${request.leaveHours == 1 ? 'Hour' : 'Hours'}';
    } else if (request.durationType == 'First Half Day' ||
        request.durationType == 'Second Half Day') {
      requestDuration = request.durationType;
    } else {
      final days = request.endDate.difference(request.startDate).inDays + 1;

      requestDuration = '$days ${days == 1 ? 'Day' : 'Days'}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  leaveStatusLabel(request.status),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            requestDate,
            style: const TextStyle(
              fontSize: 12.5,
              color: CupertinoColors.systemGrey,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            requestDuration,
            style: const TextStyle(
              fontSize: 12.5,
              color: CupertinoColors.systemGrey,
            ),
          ),

          if (request.durationType == 'Hours Leave' &&
              request.leaveStartTime != null) ...[
            const SizedBox(height: 3),
            Text(
              'Start: ${_formatTime(request.leaveStartTime!)}',
              style: const TextStyle(
                fontSize: 12.5,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],

          const SizedBox(height: 6),

          Text(request.reason, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  // 39. DISPOSE CONTROLLER
  //
  // Releases the controller when the screen
  // is removed from memory.
  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
}

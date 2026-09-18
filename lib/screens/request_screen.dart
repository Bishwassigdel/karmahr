// 1. IMPORT FLUTTER CUPERTINO
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../state/hr_request_state.dart';
import '../theme/app_colors.dart';

// 2-4. RequestStatus, RequestCategory, HrRequest, and their
// label/icon helpers all moved to state/hr_request_state.dart, so
// this screen and the new "My Requests" summary screen share the
// same definitions instead of each keeping a private copy.

// 5. HR REQUEST SCREEN
class HrRequestScreen extends StatefulWidget {
  const HrRequestScreen({super.key});

  @override
  State<HrRequestScreen> createState() => _HrRequestScreenState();
}

class _HrRequestScreenState extends State<HrRequestScreen> {
  // 6. SHARED CONTROLLERS
  final _notesController = TextEditingController();
  final _amountController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _subjectController =
      TextEditingController(); // Added: for General Inquiry's Subject field

  // 7. CATEGORY
  RequestCategory? _selectedCategory;

  // 8. TIME CORRECTION FIELDS
  final List<String> _timeIssueTypes = [
    'Missing Check-in',
    'Missing Check-out',
    'Incorrect Time',
  ];
  String? _selectedTimeIssueType;
  DateTime? _selectedDate;
  DateTime? _correctedTime;

  // 9. ID CARD REISSUE FIELDS
  final List<String> _reissueReasons = [
    'Lost',
    'Damaged',
    'Name Changed',
    'Other',
  ];
  String? _selectedReissueReason;

  // 10. REQUEST HISTORY
  //
  // No longer a local list — lives in the shared HrRequestState now,
  // so the "My Requests" screen can read it too.

  // 11. FORMAT HELPERS
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

  String _formatCurrency(double amount) {
    final wholeNumber = amount.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < wholeNumber.length; i++) {
      final positionFromEnd = wholeNumber.length - i;
      if (i != 0 && positionFromEnd % 3 == 0) buffer.write(',');
      buffer.write(wholeNumber[i]);
    }
    return 'Rs. $buffer';
  }

  // 12. SUMMARY LINE — used in the history card, one per category.
  String _summaryFor(HrRequest request) {
    switch (request.category) {
      case RequestCategory.timeCorrection:
        return '${_formatShortDate(request.issueDate!)} · Corrected to '
            '${_formatTime(request.correctedTime!)}';
      case RequestCategory.salaryAdvance:
        return _formatCurrency(request.amount!);
      case RequestCategory.idCardReissue:
        return 'Reason: ${request.reissueReason}';
      case RequestCategory.addressUpdate:
        final parts = <String>[];
        if (request.newAddress != null && request.newAddress!.isNotEmpty) {
          parts.add(request.newAddress!);
        }
        if (request.newPhone != null && request.newPhone!.isNotEmpty) {
          parts.add(request.newPhone!);
        }
        return parts.join(' · ');
      case RequestCategory.generalInquiry:
        return request.subject ?? ''; // Added
    }
  }

  // 13. SELECT CATEGORY
  void _selectCategory() {
    int selectedIndex = _selectedCategory == null
        ? 0
        : RequestCategory.values.indexOf(_selectedCategory!);

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
                      _selectedCategory = RequestCategory.values[index];
                    });
                  },
                  children: RequestCategory.values.map((category) {
                    return Center(child: Text(hrCategoryLabel(category)));
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 14. SELECT TIME ISSUE TYPE
  void _selectTimeIssueType() {
    int selectedIndex = _selectedTimeIssueType == null
        ? 0
        : _timeIssueTypes.indexOf(_selectedTimeIssueType!);

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
                      _selectedTimeIssueType = _timeIssueTypes[index];
                    });
                  },
                  children: _timeIssueTypes.map((type) {
                    return Center(child: Text(type));
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 15. SELECT REISSUE REASON
  void _selectReissueReason() {
    int selectedIndex = _selectedReissueReason == null
        ? 0
        : _reissueReasons.indexOf(_selectedReissueReason!);

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
                      _selectedReissueReason = _reissueReasons[index];
                    });
                  },
                  children: _reissueReasons.map((reason) {
                    return Center(child: Text(reason));
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 16. SELECT DATE (Time Correction only) — can't be in the future,
  // since this is reporting a problem with a day that already happened.
  void _selectDate() {
    final today = DateTime.now();
    final initialDate = _selectedDate ?? today;

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
                      setState(() => _selectedDate = selectedDate);
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
                  maximumDate: today,
                  onDateTimeChanged: (date) => selectedDate = date,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 17. SELECT CORRECTED TIME (Time Correction only)
  void _selectCorrectedTime() {
    final now = DateTime.now();
    final initialTime =
        _correctedTime ??
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
                      setState(() => _correctedTime = selectedTime);
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

  // 18. SUBMIT REQUEST
  void _submitRequest() {
    if (_selectedCategory == null) {
      _showMessage('Please select a request category.');
      return;
    }

    switch (_selectedCategory!) {
      case RequestCategory.timeCorrection:
        if (_selectedTimeIssueType == null) {
          _showMessage('Please select what went wrong.');
          return;
        }
        if (_selectedDate == null) {
          _showMessage('Please select the date of the issue.');
          return;
        }
        if (_correctedTime == null) {
          _showMessage('Please select the corrected time.');
          return;
        }
        break;

      case RequestCategory.salaryAdvance:
        final amount = double.tryParse(_amountController.text.trim());
        if (amount == null || amount <= 0) {
          _showMessage('Please enter a valid amount.');
          return;
        }
        break;

      case RequestCategory.idCardReissue:
        if (_selectedReissueReason == null) {
          _showMessage('Please select a reason for reissue.');
          return;
        }
        break;

      case RequestCategory.addressUpdate:
        if (_addressController.text.trim().isEmpty &&
            _phoneController.text.trim().isEmpty) {
          _showMessage('Please enter a new address or phone number.');
          return;
        }
        break;

      // Added: validation for General Inquiry.
      case RequestCategory.generalInquiry:
        if (_subjectController.text.trim().isEmpty) {
          _showMessage('Please enter a subject for your inquiry.');
          return;
        }
        break;
    }

    if (_notesController.text.trim().isEmpty) {
      _showMessage('Please enter a note explaining this request.');
      return;
    }

    // Goes into the shared HrRequestState (read, not watch — we're
    // calling a method, not rebuilding in response to a change) so
    // the "My Requests" summary screen sees it too.
    context.read<HrRequestState>().submitRequest(
      HrRequest(
        category: _selectedCategory!,
        status: RequestStatus.pending,
        notes: _notesController.text.trim(),
        timeIssueType: _selectedTimeIssueType,
        issueDate: _selectedDate,
        correctedTime: _correctedTime,
        amount: double.tryParse(_amountController.text.trim()),
        reissueReason: _selectedReissueReason,
        newAddress: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        newPhone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        subject: _subjectController.text.trim().isEmpty
            ? null
            : _subjectController.text.trim(),
      ),
    );

    // Reset the form — still local UI state, so setState is still
    // correct here; only the submitted request itself moved.
    setState(() {
      _selectedCategory = null;
      _selectedTimeIssueType = null;
      _selectedDate = null;
      _correctedTime = null;
      _selectedReissueReason = null;
      _notesController.clear();
      _amountController.clear();
      _addressController.clear();
      _phoneController.clear();
      _subjectController.clear();
    });

    _showMessage('Request submitted.');
  }

  // 19. SHOW MESSAGE
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

  // 20. BUILD METHOD
  @override
  Widget build(BuildContext context) {
    const karmaRed = AppColors.karmaRed;

    // CupertinoColors.systemGrey6 is a CupertinoDynamicColor — must be
    // resolved against the current context before use in a plain
    // Container/BoxDecoration, or it stays stuck on its light-mode
    // value even in Dark Mode.
    final fieldBackground = CupertinoColors.systemGrey6.resolveFrom(context);

    // context.watch (not .read) so this screen automatically rebuilds
    // whenever HrRequestState changes.
    final submittedRequests = context.watch<HrRequestState>().requests;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('HR Requests')),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 21. CATEGORY
              const Text(
                'Request Category',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _formField(
                background: fieldBackground,
                child: CupertinoListTile(
                  leading: Icon(
                    _selectedCategory == null
                        ? CupertinoIcons.doc_text
                        : hrCategoryIcon(_selectedCategory!),
                  ),
                  title: Text(
                    _selectedCategory == null
                        ? 'Select Request Category'
                        : hrCategoryLabel(_selectedCategory!),
                  ),
                  trailing: const Icon(CupertinoIcons.chevron_right, size: 18),
                  onTap: _selectCategory,
                ),
              ),

              // 22. TIME CORRECTION FIELDS
              if (_selectedCategory == RequestCategory.timeCorrection) ...[
                const SizedBox(height: 20),
                const Text(
                  'What Went Wrong',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _formField(
                  background: fieldBackground,
                  child: CupertinoListTile(
                    title: Text(_selectedTimeIssueType ?? 'Select Issue Type'),
                    trailing: const Icon(
                      CupertinoIcons.chevron_right,
                      size: 18,
                    ),
                    onTap: _selectTimeIssueType,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Date',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _formField(
                  background: fieldBackground,
                  child: CupertinoListTile(
                    title: Text(
                      _selectedDate == null
                          ? 'Select Date'
                          : _formatDate(_selectedDate!),
                    ),
                    trailing: const Icon(CupertinoIcons.calendar, size: 20),
                    onTap: _selectDate,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Corrected Time',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _formField(
                  background: fieldBackground,
                  child: CupertinoListTile(
                    title: Text(
                      _correctedTime == null
                          ? 'Select Time'
                          : _formatTime(_correctedTime!),
                    ),
                    trailing: const Icon(CupertinoIcons.time, size: 20),
                    onTap: _selectCorrectedTime,
                  ),
                ),
              ],

              // 23. SALARY ADVANCE FIELDS
              if (_selectedCategory == RequestCategory.salaryAdvance) ...[
                const SizedBox(height: 20),
                const Text(
                  'Amount Requested',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: _amountController,
                  placeholder: 'e.g. 15000',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  padding: const EdgeInsets.all(14),
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Text('Rs.'),
                  ),
                  decoration: BoxDecoration(
                    color: fieldBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ],

              // 24. ID CARD REISSUE FIELDS
              if (_selectedCategory == RequestCategory.idCardReissue) ...[
                const SizedBox(height: 20),
                const Text(
                  'Reason for Reissue',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _formField(
                  background: fieldBackground,
                  child: CupertinoListTile(
                    title: Text(_selectedReissueReason ?? 'Select Reason'),
                    trailing: const Icon(
                      CupertinoIcons.chevron_right,
                      size: 18,
                    ),
                    onTap: _selectReissueReason,
                  ),
                ),
              ],

              // 25. ADDRESS/CONTACT UPDATE FIELDS
              if (_selectedCategory == RequestCategory.addressUpdate) ...[
                const SizedBox(height: 20),
                const Text(
                  'New Address',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: _addressController,
                  placeholder: 'Optional — leave blank if unchanged',
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: fieldBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                const Text(
                  'New Phone Number',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: _phoneController,
                  placeholder: 'Optional — leave blank if unchanged',
                  keyboardType: TextInputType.phone,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: fieldBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ],

              // 25b. GENERAL INQUIRY (HR HELPDESK) FIELDS
              //
              // Only a Subject is unique to this category — the actual
              // question/details go in the shared Notes field below,
              // same as every other category.
              if (_selectedCategory == RequestCategory.generalInquiry) ...[
                const SizedBox(height: 20),
                const Text(
                  'Subject',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: _subjectController,
                  placeholder: 'e.g. Question about health insurance',
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: fieldBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ],

              // 26. NOTES (shared by every category)
              if (_selectedCategory != null) ...[
                const SizedBox(height: 20),
                const Text(
                  'Notes',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                CupertinoTextField(
                  controller: _notesController,
                  placeholder: 'Briefly explain this request',
                  maxLines: 4,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: fieldBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ],

              const SizedBox(height: 30),

              // 27. SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: karmaRed,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: _submitRequest,
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

              // 28. REQUEST HISTORY
              const Text(
                'Request History',
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

  // 29. REUSABLE FORM FIELD CONTAINER
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

  // 30. REQUEST CARD
  Widget _requestCard(HrRequest request, Color background) {
    final color = hrStatusColor(request.status).resolveFrom(context);

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
                  request.category == RequestCategory.timeCorrection
                      ? request.timeIssueType!
                      : hrCategoryLabel(request.category),
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
                  hrStatusLabel(request.status),
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
            _summaryFor(request),
            style: const TextStyle(
              fontSize: 12.5,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 6),
          Text(request.notes, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  // 31. DISPOSE CONTROLLERS
  @override
  void dispose() {
    _notesController.dispose();
    _amountController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _subjectController.dispose();
    super.dispose();
  }
}

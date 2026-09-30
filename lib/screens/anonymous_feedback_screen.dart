import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../state/feedback_state.dart';
import '../theme/app_colors.dart';

class AnonymousFeedbackScreen extends StatefulWidget {
  const AnonymousFeedbackScreen({super.key});

  @override
  State<AnonymousFeedbackScreen> createState() =>
      _AnonymousFeedbackScreenState();
}

class _AnonymousFeedbackScreenState extends State<AnonymousFeedbackScreen> {
  // TEXT CONTROLLERS — same role as _reasonController in leave_screen.dart:
  // they hold whatever the user has typed until we read .text on submit.
  final _messageController = TextEditingController();
  final _detailsController = TextEditingController();

  // Nothing is selected until the user taps the picker — null means
  // "no type chosen yet", which the submit button's validation checks for.
  FeedbackType? _selectedType;

  @override
  void dispose() {
    // Always dispose controllers you create — otherwise they (and the
    // listeners Flutter attaches to them) leak memory after this screen
    // is popped. Same reasoning as every other screen with a controller.
    _messageController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  // ============================================================
  // TYPE PICKER
  // ============================================================
  //
  // Same CupertinoPicker-in-a-modal pattern used everywhere else in
  // this app (leave type, HR request category, kudos recipient...).
  // It's a scrolling wheel of options with a "Done" button on top.
  void _selectType() {
    // If something is already selected, start the wheel there instead
    // of jumping back to the top — nicer UX when re-opening the picker.
    int selectedIndex = _selectedType == null
        ? 0
        : FeedbackType.values.indexOf(_selectedType!);

    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        // Tracks what the wheel is currently showing, WITHOUT committing
        // it yet — same pattern the date pickers in this app already use.
        // Starting it at selectedIndex is what makes "open the picker and
        // tap Done immediately" select the item that was visibly centered,
        // instead of selecting nothing at all.
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
                    // Done is the ONLY thing that commits — dismissing the
                    // sheet by tapping outside now correctly cancels.
                    onPressed: () {
                      setState(() {
                        _selectedType = FeedbackType.values[pendingIndex];
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
                  children: FeedbackType.values.map((type) {
                    return Center(child: Text(feedbackTypeLabel(type)));
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // VALIDATION MESSAGE
  // ============================================================
  //
  // Same _showMessage helper pattern as login_screen.dart,
  // leave_screen.dart, request_screen.dart — a simple alert dialog
  // for "you missed something" or "here's what happened" moments.
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

  // ============================================================
  // SUBMIT
  // ============================================================
  void _submitFeedback() {
    // 1. VALIDATE — same "check each required field, bail out with a
    // message on the first problem" style used in every other form
    // in this app (see _submitLeaveRequest, _submitRequest).
    if (_selectedType == null) {
      _showMessage('Please choose a feedback type.');
      return;
    }
    if (_messageController.text.trim().isEmpty) {
      _showMessage('Please write your feedback before submitting.');
      return;
    }

    // 2. SUBMIT — context.read (NOT context.watch) because this is a
    // one-off method call triggered by a button press, not something
    // that should make THIS widget rebuild in response to a change.
    // (watch is for build(); read is for callbacks like this one.)
    context.read<FeedbackState>().submitFeedback(
      type: _selectedType!,
      message: _messageController.text.trim(),
      details: _detailsController.text.trim(),
    );

    // 3. RESET THE FORM — this is still local UI state (what's
    // currently typed/selected), so setState is correct here even
    // though the submitted feedback itself now lives in FeedbackState.
    setState(() {
      _selectedType = null;
      _messageController.clear();
      _detailsController.clear();
    });

    // 4. CONFIRM — the exact message from your flow diagram.
    _showMessage('Your feedback has been submitted.');
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final fieldBackground = CupertinoColors.systemGrey6.resolveFrom(context);

    // context.watch (not .read) here in build() — this makes the
    // "Recently Submitted" list below rebuild automatically the
    // instant submitFeedback() calls notifyListeners().
    final submittedFeedback = context.watch<FeedbackState>().items;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Anonymous Feedback'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // A short reassurance line — worth stating explicitly on
              // an anonymous-feedback screen, since trust is the whole
              // point of the feature.
              Text(
                'Your feedback is not linked to your name or employee ID.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: CupertinoColors.systemGrey.resolveFrom(context),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 20),

              // FEEDBACK TYPE
              const Text(
                'Feedback Type',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: fieldBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CupertinoListTile(
                  leading: Icon(
                    _selectedType == null
                        ? CupertinoIcons.square_stack_3d_up
                        : feedbackTypeIcon(_selectedType!),
                  ),
                  title: Text(
                    _selectedType == null
                        ? 'Select Feedback Type'
                        : feedbackTypeLabel(_selectedType!),
                  ),
                  trailing: const Icon(CupertinoIcons.chevron_right, size: 18),
                  onTap: _selectType,
                ),
              ),

              const SizedBox(height: 20),

              // WRITE FEEDBACK (required)
              const Text(
                'Your Feedback',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: _messageController,
                placeholder: 'Share your thoughts, honestly and openly...',
                maxLines: 5,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: fieldBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                style: const TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 20),

              // OPTIONAL DETAILS — matches "(Optional) Add category/details"
              // in your flow diagram. Category is already its own picker
              // above, so this field covers the "details" half.
              const Text(
                'Additional Details (Optional)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: _detailsController,
                placeholder: 'Any extra context — dates, department, etc.',
                maxLines: 3,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: fieldBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                style: const TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 30),

              // SUBMIT ANONYMOUSLY
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: AppColors.karmaRed,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: _submitFeedback,
                  child: const Text(
                    'Submit Anonymously',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // RECENTLY SUBMITTED — same "history below the form"
              // convention as Leave/HR Requests. No name is ever shown
              // here because FeedbackItem never stored one to begin with.
              const Text(
                'Submitted From This Device',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              if (submittedFeedback.isEmpty)
                const Text(
                  'No feedback submitted yet',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: CupertinoColors.systemGrey,
                  ),
                )
              else
                ...submittedFeedback.map(
                  (item) => _feedbackCard(item, fieldBackground),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FEEDBACK CARD
  // ============================================================
  Widget _feedbackCard(FeedbackItem item, Color background) {
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
            children: [
              Icon(
                feedbackTypeIcon(item.type),
                size: 16,
                color: AppColors.karmaRed,
              ),
              const SizedBox(width: 8),
              Text(
                feedbackTypeLabel(item.type),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(item.message, style: const TextStyle(fontSize: 13.5)),
          if (item.details != null) ...[
            const SizedBox(height: 6),
            Text(
              item.details!,
              style: const TextStyle(
                fontSize: 12.5,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

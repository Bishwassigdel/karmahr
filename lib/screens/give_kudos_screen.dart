import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../data/employee_directory_data.dart';
import '../state/employee_records_state.dart';
import '../state/kudos_state.dart';
import '../theme/app_colors.dart';
import 'kudos_preview_screen.dart';

// The form for posting a new kudos — its own full page, same as HR
// Requests, since it has multiple fields that each need their own
// picker. Submitting here doesn't post anything yet — it navigates
// to KudosPreviewScreen, which is the only place that actually calls
// KudosState.giveKudos().
class GiveKudosScreen extends StatefulWidget {
  const GiveKudosScreen({super.key});

  @override
  State<GiveKudosScreen> createState() => _GiveKudosScreenState();
}

class _GiveKudosScreenState extends State<GiveKudosScreen> {
  final _messageController = TextEditingController();

  Employee? _selectedRecipient;
  String? _selectedCategory;
  int _selectedPoints = 0;

  // Active employees from the HR-managed records.
  List<Employee> get _employees =>
      context.read<EmployeeRecordsState>().directory;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // Scrolling picker over every coworker in the Employee Directory —
  // reuses _employees instead of a separate hardcoded name list.
  void _selectRecipient() {
    int selectedIndex = _selectedRecipient == null
        ? 0
        : _employees.indexOf(_selectedRecipient!);

    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        // Only commit on Done — see anonymous_feedback_screen.dart for why.
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
                        _selectedRecipient = _employees[pendingIndex];
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
                  children: _employees.map((employee) {
                    return Center(child: Text(employee.name));
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Same picker pattern, over the fixed kudosCategories list.
  void _selectCategory() {
    int selectedIndex = _selectedCategory == null
        ? 0
        : kudosCategories.indexOf(_selectedCategory!);

    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        // Only commit on Done — see anonymous_feedback_screen.dart for why.
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
                        _selectedCategory = kudosCategories[pendingIndex];
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
                  children: kudosCategories.map((category) {
                    return Center(child: Text(category));
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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

  // Validates the form, then hands everything off to the Preview
  // screen — this screen never calls giveKudos() itself.
  void _goToPreview() {
    if (_selectedRecipient == null) {
      _showMessage('Please select who you want to recognize.');
      return;
    }
    if (_selectedCategory == null) {
      _showMessage('Please select a category.');
      return;
    }
    if (_messageController.text.trim().isEmpty) {
      _showMessage('Please write a short message.');
      return;
    }

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => KudosPreviewScreen(
          recipientName: _selectedRecipient!.name,
          category: _selectedCategory!,
          message: _messageController.text.trim(),
          points: _selectedPoints,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fieldBackground = CupertinoColors.systemGrey6.resolveFrom(context);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Give Kudos')),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recognize a Coworker',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: fieldBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CupertinoListTile(
                  leading: const Icon(CupertinoIcons.person),
                  title: Text(_selectedRecipient?.name ?? 'Select Coworker'),
                  trailing: const Icon(CupertinoIcons.chevron_right, size: 18),
                  onTap: _selectRecipient,
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                'Category',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: fieldBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CupertinoListTile(
                  leading: const Icon(CupertinoIcons.star),
                  title: Text(_selectedCategory ?? 'Select Category'),
                  trailing: const Icon(CupertinoIcons.chevron_right, size: 18),
                  onTap: _selectCategory,
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                'Message',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: _messageController,
                placeholder: 'e.g. Thanks for helping with the client demo!',
                maxLines: 4,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: fieldBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                style: const TextStyle(fontSize: 14),
              ),

              // POINTS — a row of tappable chips, 0/5/10/20. Optional:
              // leaving it at 0 just means no points are attached.
              const SizedBox(height: 20),
              const Text(
                'Add Points (Optional)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: kudosPointOptions.map((points) {
                  final isSelected = _selectedPoints == points;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPoints = points),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.karmaRed
                            : fieldBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        points == 0 ? 'None' : '⭐ $points',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? CupertinoColors.white
                              : CupertinoColors.label.resolveFrom(context),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: AppColors.karmaRed,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: _goToPreview,
                  child: const Text(
                    'Preview',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Data model + demo dataset for company Notices.
//
// Same pattern as calendar_data.dart and employee_directory_data.dart —
// moved out of notices_screen.dart (where Notice used to be a private
// class only that screen could see) so other screens, like Global
// Search, can read the same data. Swap `demoNotices` for a real API
// call later; nothing reading this data needs to change.

class Notice {
  final String title;
  final String date;
  final String category; // 'General', 'Urgent', 'Policy', 'Holiday'
  final String body;

  const Notice({
    required this.title,
    required this.date,
    required this.category,
    required this.body,
  });
}

/// Demo/placeholder data only — swap for a real backend feed later.
const List<Notice> demoNotices = [
  Notice(
    title: 'Office Closed for Dashain',
    date: 'Oct 15, 2026',
    category: 'Holiday',
    body:
        'The office will remain closed from Ashwin 19 to Ashwin 23 (BS) '
        'for the Dashain festival. Regular operations resume on Ashwin 24. '
        'Branch staff should coordinate with their supervisors for '
        'skeleton-staff coverage where required.',
  ),
  Notice(
    title: 'Revised Attendance Policy',
    date: 'Sep 28, 2026',
    category: 'Policy',
    body:
        'Effective next month, the grace period for late check-in will be '
        'reduced from 15 minutes to 10 minutes. Employees checking in after '
        '10:10 AM will be marked late. Please plan your commute accordingly.',
  ),
  Notice(
    title: 'Mandatory IT Security Training',
    date: 'Sep 20, 2026',
    category: 'Urgent',
    body:
        'All staff must complete the annual IT security awareness training '
        'by the end of this month. Sessions are available on the internal '
        'learning portal. Non-completion may result in restricted system '
        'access.',
  ),
  Notice(
    title: 'New Health Insurance Provider',
    date: 'Sep 10, 2026',
    category: 'General',
    body:
        'Starting this quarter, KarmaHR is partnering with a new health '
        'insurance provider offering expanded coverage. HR will share '
        'enrollment details and updated ID cards within two weeks.',
  ),
];

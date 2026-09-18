// 1. IMPORT FLUTTER CUPERTINO
import 'package:flutter/cupertino.dart';

// 2. NOTICE MODEL
class _Notice {
  final String title;
  final String date;
  final String category; // 'General', 'Urgent', 'Policy', 'Holiday'
  final String body;

  const _Notice({
    required this.title,
    required this.date,
    required this.category,
    required this.body,
  });
}

// 3. DEMO DATA
//
// Local/dummy data for now — swap for a real backend feed later.
const List<_Notice> _notices = [
  _Notice(
    title: 'Office Closed for Dashain',
    date: 'Oct 15, 2026',
    category: 'Holiday',
    body:
        'The office will remain closed from Ashwin 19 to Ashwin 23 (BS) '
        'for the Dashain festival. Regular operations resume on Ashwin 24. '
        'Branch staff should coordinate with their supervisors for '
        'skeleton-staff coverage where required.',
  ),
  _Notice(
    title: 'Revised Attendance Policy',
    date: 'Sep 28, 2026',
    category: 'Policy',
    body:
        'Effective next month, the grace period for late check-in will be '
        'reduced from 15 minutes to 10 minutes. Employees checking in after '
        '10:10 AM will be marked late. Please plan your commute accordingly.',
  ),
  _Notice(
    title: 'Mandatory IT Security Training',
    date: 'Sep 20, 2026',
    category: 'Urgent',
    body:
        'All staff must complete the annual IT security awareness training '
        'by the end of this month. Sessions are available on the internal '
        'learning portal. Non-completion may result in restricted system '
        'access.',
  ),
  _Notice(
    title: 'New Health Insurance Provider',
    date: 'Sep 10, 2026',
    category: 'General',
    body:
        'Starting this quarter, KarmaHR is partnering with a new health '
        'insurance provider offering expanded coverage. HR will share '
        'enrollment details and updated ID cards within two weeks.',
  ),
];

// 4. CATEGORY COLOR
//
// Resolved once per build() since these are CupertinoDynamicColors —
// unresolved, they'd stay stuck on their light-mode value in Dark Mode.
Color _categoryColor(String category, Map<String, Color> resolved) {
  return resolved[category] ?? resolved['General']!;
}

// 5. NOTICES SCREEN
class NoticesScreen extends StatelessWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryColors = <String, Color>{
      'General': CupertinoColors.systemBlue.resolveFrom(context),
      'Urgent': CupertinoColors.systemRed.resolveFrom(context),
      'Policy': CupertinoColors.systemPurple.resolveFrom(context),
      'Holiday': CupertinoColors.systemGreen.resolveFrom(context),
    };
    final cardBackground = CupertinoColors.systemGrey6.resolveFrom(context);
    final subtleTextColor = CupertinoColors.systemGrey.resolveFrom(context);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Notices')),
      child: SafeArea(
        child: _notices.isEmpty
            ? Center(
                child: Text(
                  'No notices yet.',
                  style: TextStyle(color: subtleTextColor),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _notices.length,
                itemBuilder: (context, index) {
                  final notice = _notices[index];
                  final color = _categoryColor(notice.category, categoryColors);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) =>
                              _NoticeDetailScreen(notice: notice),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBackground,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  notice.category,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: color,
                                  ),
                                ),
                              ),
                              Text(
                                notice.date,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: subtleTextColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            notice.title,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            notice.body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: subtleTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

// 6. NOTICE DETAIL SCREEN
//
// A full screen (not a bottom sheet) since notice bodies read more
// like a short article than a quick holiday blurb.
class _NoticeDetailScreen extends StatelessWidget {
  final _Notice notice;

  const _NoticeDetailScreen({required this.notice});

  @override
  Widget build(BuildContext context) {
    final categoryColors = <String, Color>{
      'General': CupertinoColors.systemBlue.resolveFrom(context),
      'Urgent': CupertinoColors.systemRed.resolveFrom(context),
      'Policy': CupertinoColors.systemPurple.resolveFrom(context),
      'Holiday': CupertinoColors.systemGreen.resolveFrom(context),
    };
    final color = _categoryColor(notice.category, categoryColors);
    final subtleTextColor = CupertinoColors.systemGrey.resolveFrom(context);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Notice')),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  notice.category,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                notice.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                notice.date,
                style: TextStyle(fontSize: 13, color: subtleTextColor),
              ),
              const SizedBox(height: 20),
              Text(
                notice.body,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

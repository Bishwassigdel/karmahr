// 1. IMPORT FLUTTER CUPERTINO
import 'package:flutter/cupertino.dart';

import 'package:provider/provider.dart';

import '../data/notices_data.dart';
import '../state/notices_state.dart';
import 'apps/widgets/refreshable_list_view.dart';
import 'apps/widgets/staggered_entrance.dart';

// 2. NOTICE MODEL + DEMO DATA
//
// Both moved to data/notices_data.dart — Notice is public now (was
// _Notice) so Global Search can read the same list this screen does.

// 3. CATEGORY COLOR
//
// Resolved once per build() since these are CupertinoDynamicColors —
// unresolved, they'd stay stuck on their light-mode value in Dark Mode.
Color _categoryColor(String category, Map<String, Color> resolved) {
  return resolved[category] ?? resolved['General']!;
}

Map<String, Color> _categoryColors(BuildContext context) => {
  'General': CupertinoColors.systemBlue.resolveFrom(context),
  'Urgent': CupertinoColors.systemRed.resolveFrom(context),
  'Policy': CupertinoColors.systemPurple.resolveFrom(context),
  'Holiday': CupertinoColors.systemGreen.resolveFrom(context),
};

// 4. NOTICES SCREEN
class NoticesScreen extends StatelessWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notices = context.watch<NoticesState>().notices;
    final categoryColors = _categoryColors(context);
    final cardBackground = CupertinoColors.systemGrey6.resolveFrom(context);
    final subtleTextColor = CupertinoColors.systemGrey.resolveFrom(context);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Notices')),
      child: SafeArea(
        child: notices.isEmpty
            ? Center(
                child: Text(
                  'No notices yet.',
                  style: TextStyle(color: subtleTextColor),
                ),
              )
            : RefreshableListView.builder(
                onRefresh: simulatedRefresh,
                padding: const EdgeInsets.all(16),
                itemCount: notices.length,
                itemBuilder: (context, index) {
                  final notice = notices[index];
                  final color = _categoryColor(notice.category, categoryColors);

                  return StaggeredEntrance(
                    index: index,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) =>
                                NoticeDetailScreen(notice: notice),
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
                                Flexible(
                                  child: _CategoryPill(
                                    notice: notice,
                                    color: color,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    notice.date,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: subtleTextColor,
                                    ),
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
                    ),
                  );
                },
              ),
      ),
    );
  }
}

// 5. NOTICE DETAIL SCREEN
//
// A full screen (not a bottom sheet) since notice bodies read more
// like a short article than a quick holiday blurb. Public (was
// _NoticeDetailScreen) so Global Search can navigate straight to a
// specific notice instead of only opening the list.
class NoticeDetailScreen extends StatelessWidget {
  final Notice notice;

  const NoticeDetailScreen({super.key, required this.notice});

  @override
  Widget build(BuildContext context) {
    final categoryColors = _categoryColors(context);
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
              _CategoryPill(notice: notice, color: color),
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

// 6. CATEGORY PILL — shared by the list card and the detail screen.
//
// Wrapped in a Hero with the same tag in both places, so opening a
// notice flies the pill from its card into the detail header — the
// visual thread that says "this screen is THAT notice". The two used to
// be identical copy-pasted Containers; one widget guarantees they stay
// identical, which a Hero needs to look seamless.
class _CategoryPill extends StatelessWidget {
  final Notice notice;
  final Color color;

  const _CategoryPill({required this.notice, required this.color});

  @override
  Widget build(BuildContext context) {
    return Hero(
      // Title + date, not index: Global Search opens this detail screen
      // too, and an index would mean nothing there.
      tag: 'notice-pill-${notice.title}-${notice.date}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
    );
  }
}

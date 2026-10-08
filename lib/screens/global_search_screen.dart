// Searches across Employee Directory, Notices, and My Requests (Leave +
// HR) from one place. Each of those already has its own filter/search,
// but there was previously no way to search ACROSS all of them without
// already knowing which module the thing you're looking for lives in —
// e.g. typing a coworker's name should surface them from Directory
// without having to remember that's a separate tab from Apps.
//
// Frontend-only: reads the same static demo data and Provider state
// every other screen reads. Swapping any of those for a real backend
// call later doesn't change anything here.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../state/employee_records_state.dart';
import '../state/hr_request_state.dart';
import '../state/leave_state.dart';
import '../state/notices_state.dart';
import '../theme/app_colors.dart';
import 'employee_directory_screen.dart';
import 'my_requests_screen.dart';
import 'notices_screen.dart';

// One row in the results list, already resolved down to exactly what
// the list needs to render + where to navigate on tap — the filtering
// logic below never touches the UI directly.
class _SearchResult {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SearchResult({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  // Holds whatever's typed so far. Empty means "show the hint, not a
  // list" — searching everything on an empty query would just dump
  // every employee/notice/request at once, which isn't useful.
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final subtleTextColor = CupertinoColors.systemGrey.resolveFrom(context);
    final trimmed = _query.trim();
    final results = trimmed.isEmpty
        ? const <_SearchResult>[]
        : _buildResults(context, trimmed.toLowerCase());

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Search')),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: CupertinoSearchTextField(
                autofocus: true,
                placeholder: 'Search people, notices, requests…',
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Expanded(
              child: trimmed.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'Search across the Employee Directory, Notices, '
                          'and My Requests.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: subtleTextColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                  : results.isEmpty
                  ? Center(
                      child: Text(
                        'No results for "$trimmed".',
                        style: TextStyle(color: subtleTextColor),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: results.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 2),
                      itemBuilder: (context, index) {
                        final result = results[index];
                        return CupertinoListTile(
                          leading: Icon(result.icon, color: result.iconColor),
                          title: Text(result.title),
                          subtitle: Text(
                            result.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Icon(
                            CupertinoIcons.chevron_right,
                            size: 18,
                            color: subtleTextColor,
                          ),
                          onTap: result.onTap,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Rebuilds the filtered result list from scratch on every keystroke.
  // With only a handful of demo employees/notices/requests this is
  // trivially fast — a real backend-backed version would ask the
  // server to search instead of the phone, same caveat as
  // EmployeeDirectoryScreen's own filter.
  List<_SearchResult> _buildResults(BuildContext context, String q) {
    final results = <_SearchResult>[];
    final employeeColor = CupertinoColors.systemTeal.resolveFrom(context);
    final noticeColor = CupertinoColors.systemIndigo.resolveFrom(context);
    final hrColor = CupertinoColors.systemOrange.resolveFrom(context);

    for (final employee in context.read<EmployeeRecordsState>().directory) {
      final matches =
          employee.name.toLowerCase().contains(q) ||
          employee.department.toLowerCase().contains(q) ||
          employee.jobTitle.toLowerCase().contains(q);
      if (!matches) continue;

      results.add(
        _SearchResult(
          icon: CupertinoIcons.person_fill,
          iconColor: employeeColor,
          title: employee.name,
          subtitle: '${employee.jobTitle} · ${employee.department}',
          onTap: () => Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const EmployeeDirectoryScreen(),
            ),
          ),
        ),
      );
    }

    for (final notice in context.read<NoticesState>().notices) {
      final matches =
          notice.title.toLowerCase().contains(q) ||
          notice.body.toLowerCase().contains(q) ||
          notice.category.toLowerCase().contains(q);
      if (!matches) continue;

      results.add(
        _SearchResult(
          icon: CupertinoIcons.doc_text_fill,
          iconColor: noticeColor,
          title: notice.title,
          subtitle: '${notice.category} · ${notice.date}',
          onTap: () => Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => NoticeDetailScreen(notice: notice),
            ),
          ),
        ),
      );
    }

    // context.read, not watch — this list only needs to be correct at
    // the moment of typing, and the screen already rebuilds on every
    // keystroke via setState above.
    final leaveRequests = context.read<LeaveState>().requests;
    for (final request in leaveRequests) {
      final matches =
          request.leaveType.toLowerCase().contains(q) ||
          request.reason.toLowerCase().contains(q);
      if (!matches) continue;

      results.add(
        _SearchResult(
          icon: CupertinoIcons.airplane,
          iconColor: AppColors.karmaRed,
          title: request.leaveType,
          subtitle: 'Leave Request · ${leaveStatusLabel(request.status)}',
          onTap: () => Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => const MyRequestsScreen()),
          ),
        ),
      );
    }

    final hrRequests = context.read<HrRequestState>().requests;
    for (final request in hrRequests) {
      final label = hrCategoryLabel(request.category);
      final matches =
          label.toLowerCase().contains(q) ||
          request.notes.toLowerCase().contains(q);
      if (!matches) continue;

      results.add(
        _SearchResult(
          icon: CupertinoIcons.doc_on_doc_fill,
          iconColor: hrColor,
          title: label,
          subtitle: 'HR Request · ${hrStatusLabel(request.status)}',
          onTap: () => Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => const MyRequestsScreen()),
          ),
        ),
      );
    }

    return results;
  }
}

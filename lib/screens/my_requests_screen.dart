import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../state/hr_request_state.dart';
import '../state/leave_state.dart';

// Pulls together Leave requests and HR requests into one screen, so
// an employee doesn't have to check two separate places to see
// everything they've submitted and its status. Grouped into two
// sections rather than one merged chronological list — simpler, and
// neither request type currently stores a submission timestamp to
// sort a true merged list by.
class MyRequestsScreen extends StatelessWidget {
  const MyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // context.watch so this screen automatically refreshes if either
    // list changes while it's open (e.g. you submit something, back
    // out, and the badge reflects it immediately).
    final leaveRequests = context.watch<LeaveState>().requests;
    final hrRequests = context.watch<HrRequestState>().requests;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('My Requests')),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 12),

            // LEAVE REQUESTS SECTION
            CupertinoListSection.insetGrouped(
              header: const Text('LEAVE REQUESTS'),
              children: leaveRequests.isEmpty
                  ? const [
                      CupertinoListTile(title: Text('No leave requests yet')),
                    ]
                  : leaveRequests
                        .map((request) => _leaveTile(context, request))
                        .toList(),
            ),

            // HR REQUESTS SECTION
            CupertinoListSection.insetGrouped(
              header: const Text('HR REQUESTS'),
              children: hrRequests.isEmpty
                  ? const [CupertinoListTile(title: Text('No HR requests yet'))]
                  : hrRequests
                        .map((request) => _hrTile(context, request))
                        .toList(),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // One row for a leave request — reuses leaveStatusLabel/Color from
  // leave_state.dart so the badge always matches what leave_screen.dart
  // and leave_balances_screen.dart already show.
  Widget _leaveTile(BuildContext context, LeaveRequest request) {
    final color = leaveStatusColor(request.status).resolveFrom(context);

    return CupertinoListTile(
      title: Text(request.leaveType),
      subtitle: Text(
        request.reason,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: _statusPill(leaveStatusLabel(request.status), color),
    );
  }

  // One row for an HR request — reuses hrStatusLabel/Color and
  // hrCategoryLabel from hr_request_state.dart, same reasoning.
  Widget _hrTile(BuildContext context, HrRequest request) {
    final color = hrStatusColor(request.status).resolveFrom(context);

    return CupertinoListTile(
      title: Text(hrCategoryLabel(request.category)),
      subtitle: Text(
        request.notes,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: _statusPill(hrStatusLabel(request.status), color),
    );
  }

  // Small colored pill — same visual style used for status badges
  // everywhere else in the app, just reusable here for both kinds.
  Widget _statusPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/employee_directory_data.dart';
import '../state/employee_records_state.dart';
import '../theme/app_colors.dart';

/// Searchable list of coworkers. StatefulWidget because the search
/// query changes as the user types, and that change needs to
/// re-filter the visible list — a StatelessWidget has no way to
/// "remember" what was typed between rebuilds.
class EmployeeDirectoryScreen extends StatefulWidget {
  const EmployeeDirectoryScreen({super.key});

  @override
  State<EmployeeDirectoryScreen> createState() =>
      _EmployeeDirectoryScreenState();
}

class _EmployeeDirectoryScreenState extends State<EmployeeDirectoryScreen> {
  // Holds whatever the user has typed into the search box so far.
  // Starts empty, meaning "show everyone."
  String _query = '';

  @override
  Widget build(BuildContext context) {
    // Build the filtered list fresh on every rebuild (every keystroke).
    // With only ~8 demo employees this is trivially fast — a real
    // backend-backed version with thousands of employees would
    // instead ask the server to filter, not the phone.
    final filtered = context.watch<EmployeeRecordsState>().directory.where((employee) {
      if (_query.isEmpty) return true;

      // toLowerCase() on both sides makes the search
      // case-insensitive — "sita" should still find "Sita Gurung".
      final q = _query.toLowerCase();
      return employee.name.toLowerCase().contains(q) ||
          employee.department.toLowerCase().contains(q) ||
          employee.jobTitle.toLowerCase().contains(q);
    }).toList();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Employee Directory'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Cupertino's built-in search field — no extra package
            // needed for this part, unlike url_launcher below.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: CupertinoSearchTextField(
                placeholder: 'Search by name, department, or role',
                onChanged: (value) {
                  // setState tells Flutter "something changed, please
                  // rebuild this widget" — without it, _query would
                  // update internally but the screen would never
                  // visually refresh to show the new filtered list.
                  setState(() => _query = value);
                },
              ),
            ),

            // Expanded makes the list take up all remaining vertical
            // space below the search box.
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'No matching employees.',
                        style: TextStyle(color: CupertinoColors.systemGrey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return _buildEmployeeTile(context, filtered[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // One row in the directory list.
  Widget _buildEmployeeTile(BuildContext context, Employee employee) {
    return CupertinoListTile(
      leading: _buildAvatar(employee),
      title: Text(employee.name),
      subtitle: Text('${employee.jobTitle} · ${employee.department}'),
      trailing: const Icon(CupertinoIcons.chevron_right, size: 18),
      onTap: () => _showContactOptions(context, employee),
    );
  }

  // Small circular avatar with initials — same visual language as
  // the one already used on ProfileScreen.
  Widget _buildAvatar(Employee employee) {
    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        color: AppColors.karmaRed,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          employee.initials,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Tapping a coworker shows a bottom sheet with their full contact
  // details and quick actions — same CupertinoActionSheet pattern
  // used elsewhere in the app (e.g. the holiday detail sheet).
  void _showContactOptions(BuildContext context, Employee employee) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          title: Text(employee.name),
          message: Text(
            '${employee.jobTitle}\n'
            '${employee.department}\n\n'
            '${employee.phone}\n'
            '${employee.email}',
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop();
                _callEmployee(employee);
              },
              child: const Text('Call'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop();
                _emailEmployee(employee);
              },
              child: const Text('Email'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        );
      },
    );
  }

  // "tel:" is a special URI scheme the OS understands as "open the
  // phone dialer with this number pre-filled." url_launcher is what
  // actually knows how to hand this off to the OS.
  Future<void> _callEmployee(Employee employee) async {
    final uri = Uri(scheme: 'tel', path: employee.phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // Same idea, but "mailto:" opens the default mail app with the
  // recipient pre-filled.
  Future<void> _emailEmployee(Employee employee) async {
    final uri = Uri(scheme: 'mailto', path: employee.email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

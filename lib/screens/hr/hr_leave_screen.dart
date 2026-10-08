import 'package:flutter/cupertino.dart';

import '../../l10n/l10n.dart';
import 'hr_approvals_view.dart';
import 'hr_holidays_view.dart';
import 'hr_policy_view.dart';

enum _Tab { approvals, policy, holidays }

/// HR > Leave & Holidays: approvals inbox, leave policy and holidays.
class HrLeaveScreen extends StatefulWidget {
  const HrLeaveScreen({super.key});

  @override
  State<HrLeaveScreen> createState() => _HrLeaveScreenState();
}

class _HrLeaveScreenState extends State<HrLeaveScreen> {
  _Tab _tab = _Tab.approvals;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<_Tab>(
                  groupValue: _tab,
                  onValueChanged: (t) {
                    if (t != null) setState(() => _tab = t);
                  },
                  children: {
                    _Tab.approvals: Text(l10n.hrApprovalsTab),
                    _Tab.policy: Text(l10n.hrPolicyTab),
                    _Tab.holidays: Text(l10n.hrHolidaysTab),
                  },
                ),
              ),
            ),
            Expanded(
              child: switch (_tab) {
                _Tab.approvals => const HrApprovalsView(),
                _Tab.policy => const HrPolicyView(),
                _Tab.holidays => const HrHolidaysView(),
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';

import '../../domain/nepal/leave_policy.dart';
import '../../l10n/l10n.dart';

/// HR > Leave & Holidays > Policy: what each leave type gives, read from
/// the one policy table in leave_policy.dart. Read-only for now.
class HrPolicyView extends StatelessWidget {
  const HrPolicyView({super.key});

  // 12.0 -> "12", 1.5 -> "1.5"
  static String _days(double d) =>
      d == d.roundToDouble() ? d.toStringAsFixed(0) : d.toString();

  String _entitlement(AppLocalizations l10n, LeavePolicy p) {
    return p.isAccrualBased
        ? l10n.hrPolicyAccrual(_days(p.accrualPerWorkedDays!))
        : l10n.hrPolicyDaysPerYear(_days(p.annualGrant!));
  }

  String _carryForward(AppLocalizations l10n, LeavePolicy p) {
    if (p.carryForwardCap == double.infinity) return l10n.hrPolicyCarryAll;
    if (p.carryForwardCap <= 0) return l10n.hrPolicyNoCarry;
    return l10n.hrPolicyCarryUpTo(_days(p.carryForwardCap));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          children: [
            for (final p in leavePolicies.values)
              CupertinoListSection.insetGrouped(
                header: Text(p.type),
                children: [
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.calendar),
                    title: Text(_entitlement(l10n, p)),
                  ),
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.arrow_right_circle),
                    title: Text(_carryForward(l10n, p)),
                  ),
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.money_dollar_circle),
                    title: Text(
                      p.paid ? l10n.hrPolicyPaid : l10n.hrPolicyUnpaid,
                    ),
                    subtitle: p.requiresDocument
                        ? Text(
                            l10n.hrPolicyDocument(
                              p.documentThresholdDays.toString(),
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Text(
                l10n.hrPolicyNote,
                style: TextStyle(fontSize: 12.5, color: subtle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

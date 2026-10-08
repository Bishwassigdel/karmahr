import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../data/company_demo.dart';
import '../../data/current_employee.dart';
import '../../l10n/l10n.dart';
import '../../state/audit_log_state.dart';
import '../../theme/app_colors.dart';
import '../apps/widgets/ui_kit.dart';
import 'owner_people_screen.dart';
import 'owner_widgets.dart';

/// One person, as the CEO sees them: how long they have been here, how they
/// are doing, and, only on request, their pay. Showing pay asks first and
/// is written to the audit log.
class OwnerPersonScreen extends StatefulWidget {
  final String personId;

  const OwnerPersonScreen({super.key, required this.personId});

  @override
  State<OwnerPersonScreen> createState() => _OwnerPersonScreenState();
}

class _OwnerPersonScreenState extends State<OwnerPersonScreen> {
  // Pay hides again whenever the screen is left and reopened.
  var _payShown = false;

  Future<void> _showPay(DemoPerson p) async {
    final l10n = context.l10n;
    final ok = await confirm(
      context,
      title: l10n.ownerShowPayTitle(p.name),
      message: l10n.ownerShowPayMessage,
      confirmLabel: l10n.ownerShowPay,
    );
    if (!ok || !mounted) return;
    logAudit(context, AuditAction.payViewed, p.name);
    setState(() => _payShown = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.read<CompanyDemo>();
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);
    final matches = c.people.where((p) => p.id == widget.personId);

    if (matches.isEmpty) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(),
        child: Center(child: Text(l10n.ownerNoPeople)),
      );
    }
    final p = matches.first;
    final months = p.tenureMonths(c.today);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Column(
                  children: [
                    InitialsAvatar(initials: initialsOf(p.name), size: 72),
                    const SizedBox(height: 10),
                    Text(
                      p.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${p.jobTitle} · ${c.deptById(p.deptId).name}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: subtle),
                    ),
                    Text(
                      '${c.branchById(p.branchId).name} · '
                      '${l10n.ownerTenure(months ~/ 12, months % 12)}',
                      style: TextStyle(fontSize: 12.5, color: subtle),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SectionCard(
                  child: Column(
                    children: [
                      PercentBar(
                        label: l10n.ownerAttendance30,
                        value: p.attendance,
                      ),
                      PercentBar(
                        label: l10n.ownerGoalsThisQuarter,
                        value: p.goals,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                CupertinoListSection.insetGrouped(
                  margin: EdgeInsets.zero,
                  children: [
                    CupertinoListTile(
                      title: Text(l10n.ownerReviewLabel),
                      additionalInfo: TileInfo(
                        p.reviewDone
                            ? l10n.ownerReviewDone
                            : l10n.ownerReviewPending,
                      ),
                    ),
                    CupertinoListTile(
                      title: Text(l10n.ownerTrainingLabel),
                      additionalInfo: TileInfo(
                        p.trainingDone
                            ? l10n.ownerReviewDone
                            : l10n.ownerReviewPending,
                      ),
                    ),
                    CupertinoListTile(
                      title: Text(l10n.ownerLeaveBalance),
                      additionalInfo: TileInfo(
                        l10n.ownerDays(
                          p.leaveBalance == p.leaveBalance.roundToDouble()
                              ? p.leaveBalance.toStringAsFixed(0)
                              : p.leaveBalance.toString(),
                        ),
                      ),
                    ),
                    CupertinoListTile(
                      title: Text(l10n.ownerPay),
                      additionalInfo: TileInfo(
                        _payShown
                            ? formatRupees(p.monthlyGross)
                            : l10n.ownerPayHidden,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_payShown)
                  CupertinoButton(
                    onPressed: () => setState(() => _payShown = false),
                    child: Text(l10n.ownerHidePay),
                  )
                else
                  CupertinoButton(
                    color: AppColors.karmaRed,
                    onPressed: () => _showPay(p),
                    child: Text(
                      l10n.ownerShowPay,
                      style: const TextStyle(color: CupertinoColors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

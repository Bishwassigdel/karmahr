import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../data/calendar_data.dart';
import '../data/current_employee.dart';
import '../domain/pdf_documents.dart';
import '../l10n/l10n.dart';
import '../state/document_wallet_state.dart';
import '../state/emergency_info_state.dart';
import '../state/hr_request_state.dart';
import '../state/notification_state.dart';
import '../theme/app_colors.dart';
import 'apps/widgets/pdf_actions.dart';
import 'apps/widgets/ui_kit.dart';
import 'document_wallet_screen.dart';
import 'emergency_info_screen.dart';
import 'payslip_screen.dart';
import 'tax_planner_screen.dart';

/// The tabs of My Info, left to right.
enum _InfoTab { job, contact, pay, docs, emergency }

// MY INFO — everything about you on one page: a header, then tabs
// (Job · Contact · Pay · Docs · Emergency). Replaces jumping between
// Profile, Payslips, Document Wallet and Emergency Info; those screens
// are still one tap away from their tab for the full detail.
//
// Job details stay read-only (HR-controlled). The phone number is
// editable: a change files an "Address/Contact Update" HR request, so it
// shows up in Requests and only applies once HR approves it.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // The "official" phone number on file — stays fixed until HR approves
  // a change (which, with no backend yet, doesn't happen automatically).
  static const _officialPhone = '+977 97xxxxxxxx';

  _InfoTab _tab = _InfoTab.job;

  String _tabLabel(AppLocalizations l10n, _InfoTab tab) => switch (tab) {
    _InfoTab.job => l10n.infoTabJob,
    _InfoTab.contact => l10n.infoTabContact,
    _InfoTab.pay => l10n.infoTabPay,
    _InfoTab.docs => l10n.infoTabDocs,
    _InfoTab.emergency => l10n.infoTabEmergency,
  };

  void _open(Widget screen) {
    Navigator.push(context, CupertinoPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(middle: Text(l10n.myInfoTitle)),
      child: SafeArea(
        child: ListView(
          children: [
            const _Header(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<_InfoTab>(
                  groupValue: _tab,
                  onValueChanged: (t) {
                    if (t != null) setState(() => _tab = t);
                  },
                  children: {
                    for (final t in _InfoTab.values)
                      t: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          _tabLabel(l10n, t),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                  },
                ),
              ),
            ),
            ...switch (_tab) {
              _InfoTab.job => _jobTab(l10n),
              _InfoTab.contact => _contactTab(context, l10n),
              _InfoTab.pay => _payTab(l10n),
              _InfoTab.docs => _docsTab(context, l10n),
              _InfoTab.emergency => _emergencyTab(context, l10n),
            },
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  CupertinoListTile _row(IconData icon, String value, String label) {
    return CupertinoListTile(
      leading: Icon(icon),
      title: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(label),
    );
  }

  CupertinoListTile _link(
    IconData icon,
    String title,
    VoidCallback onTap, {
    String? subtitle,
  }) {
    return CupertinoListTile(
      leading: Icon(icon),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: subtitle == null
          ? null
          : Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const CupertinoListTileChevron(),
      onTap: onTap,
    );
  }

  List<Widget> _jobTab(AppLocalizations l10n) {
    final e = currentEmployee;
    final joined =
        '${adMonths[e.joiningDate.month - 1]} ${e.joiningDate.day}, '
        '${e.joiningDate.year}';
    return [
      CupertinoListSection.insetGrouped(
        children: [
          _row(CupertinoIcons.briefcase_fill, e.jobTitle, l10n.jobTitleLabel),
          _row(
            CupertinoIcons.building_2_fill,
            e.department,
            l10n.departmentLabel,
          ),
          _row(CupertinoIcons.person_2, e.manager, l10n.managerLabel),
          _row(CupertinoIcons.calendar_today, joined, l10n.joinedLabel),
          _row(
            CupertinoIcons.doc_text,
            e.employmentType,
            l10n.employmentTypeLabel,
          ),
          _row(
            CupertinoIcons.location_solid,
            e.workLocation,
            l10n.workLocationLabel,
          ),
        ],
      ),
    ];
  }

  List<Widget> _contactTab(BuildContext context, AppLocalizations l10n) {
    final hrRequests = context.watch<HrRequestState>().requests;
    // The most recent still-pending phone update, if any.
    final pending = hrRequests
        .where(
          (r) =>
              r.category == RequestCategory.addressUpdate &&
              r.status == RequestStatus.pending &&
              r.newPhone != null,
        )
        .map((r) => r.newPhone!)
        .firstOrNull;

    return [
      CupertinoListSection.insetGrouped(
        footer: pending == null
            ? null
            : Text(
                l10n.pendingHrApproval(pending),
                style: const TextStyle(
                  color: CupertinoColors.systemOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
        children: [
          _row(CupertinoIcons.mail, currentEmployee.email, l10n.workEmailLabel),
          CupertinoListTile(
            leading: const Icon(CupertinoIcons.phone),
            title: const Text(_officialPhone),
            subtitle: Text(l10n.phoneLabel),
            trailing: pending != null
                ? const Icon(
                    CupertinoIcons.clock,
                    color: CupertinoColors.systemOrange,
                    size: 20,
                  )
                : CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _showEditPhoneSheet(context),
                    child: Text(l10n.editAction),
                  ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _payTab(AppLocalizations l10n) {
    final e = currentEmployee;
    CupertinoListTile money(String label, double amount, {bool bold = false}) {
      return CupertinoListTile(
        title: Text(
          label,
          style: bold ? const TextStyle(fontWeight: FontWeight.w600) : null,
        ),
        additionalInfo: TileInfo(formatRupees(amount)),
      );
    }

    return [
      CupertinoListSection.insetGrouped(
        children: [
          money(l10n.basicSalaryLabel, e.basicSalary),
          money(l10n.dearnessAllowanceLabel, e.dearnessAllowance),
          money(l10n.transportAllowanceLabel, e.transportAllowance),
          money(l10n.grossMonthlyLabel, e.grossMonthly, bold: true),
        ],
      ),
      CupertinoListSection.insetGrouped(
        children: [
          _link(
            CupertinoIcons.money_dollar_circle,
            l10n.payslipsLabel,
            () => _open(const PayslipScreen()),
          ),
          _link(
            CupertinoIcons.chart_bar_alt_fill,
            l10n.taxPlannerLabel,
            () => _open(const TaxPlannerScreen()),
          ),
          _link(
            CupertinoIcons.doc_richtext,
            l10n.salaryCertificateLabel,
            () => showPdfActions(
              context,
              title: 'Salary Certificate',
              filename: 'salary-certificate-${e.employeeId}.pdf',
              build: () => buildSalaryCertificatePdf(),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _docsTab(BuildContext context, AppLocalizations l10n) {
    final docs = context.watch<DocumentWalletState>().documents;
    return [
      CupertinoListSection.insetGrouped(
        children: [
          if (docs.isEmpty)
            CupertinoListTile(title: Text(l10n.noDocuments))
          else
            for (final d in docs)
              CupertinoListTile(
                leading: Icon(walletDocTypeIcon(d.type)),
                title: Text(
                  d.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  d.number == null
                      ? walletDocTypeLabel(d.type)
                      : maskIdNumber(d.number!),
                ),
              ),
        ],
      ),
      CupertinoListSection.insetGrouped(
        children: [
          _link(
            CupertinoIcons.folder_fill,
            l10n.manageDocuments,
            () => _open(const DocumentWalletScreen()),
          ),
        ],
      ),
    ];
  }

  List<Widget> _emergencyTab(BuildContext context, AppLocalizations l10n) {
    final info = context.watch<EmergencyInfoState>();
    final ins = info.insurance;
    return [
      CupertinoListSection.insetGrouped(
        header: Text(l10n.emergencyContactsLabel.toUpperCase()),
        children: [
          for (final c in info.contacts)
            _row(
              CupertinoIcons.person_crop_circle_fill,
              c.name,
              '${c.relation} · ${c.phone}',
            ),
        ],
      ),
      CupertinoListSection.insetGrouped(
        header: Text(l10n.healthInsuranceLabel.toUpperCase()),
        children: [
          _row(
            CupertinoIcons.heart_circle_fill,
            ins.planName,
            '${ins.provider} · ${ins.memberId}',
          ),
          _link(
            CupertinoIcons.pencil,
            l10n.manageEmergency,
            () => _open(const EmergencyInfoScreen()),
          ),
        ],
      ),
    ];
  }

  // 6. EDIT PHONE SHEET
  //
  // Doesn't update anything directly — submits an "Address/Contact
  // Update" HR request, same as if the employee had filled out the
  // full HR Requests form. This is the ONLY way the phone number on
  // file changes, since there's no backend to apply it instantly.
  Future<void> _showEditPhoneSheet(BuildContext context) async {
    final entered = await showCupertinoModalPopup<String>(
      context: context,
      builder: (_) => const _EditPhoneSheet(initial: _officialPhone),
    );
    if (entered == null || !context.mounted) return;

    final newPhone = entered.trim();
    if (newPhone.isEmpty || newPhone == _officialPhone) return;

    // A Nepali mobile (NTC/Ncell/Smart): 10 digits starting 96/97/98,
    // optionally written with +977. Previously ANY text — even "abc" —
    // was filed as an HR request.
    final digits = newPhone.replaceAll(RegExp(r'[\s-]'), '');
    if (!RegExp(r'^(\+977)?9[678]\d{8}$').hasMatch(digits)) {
      await showMessage(
        context,
        title: 'Check the Number',
        message:
            'Enter a 10-digit mobile number starting with 96, 97 or 98 '
            '(optionally with +977).',
      );
      return;
    }
    if (!context.mounted) return;

    context.read<HrRequestState>().submitRequest(
      HrRequest(
        category: RequestCategory.addressUpdate,
        status: RequestStatus.pending,
        notes: 'Phone number update requested from Profile.',
        newPhone: newPhone,
      ),
    );
    notifyUser(
      context,
      kind: AppNotificationKind.hrRequest,
      title: 'Phone number update submitted',
      body: 'Your new number takes effect once HR approves it.',
    );
  }
}

// Owns its TextEditingController, so it's disposed only when the sheet is
// truly gone. It used to be created inside _showEditPhoneSheet and never
// disposed at all — one leaked controller per time the sheet opened.
class _EditPhoneSheet extends StatefulWidget {
  final String initial;

  const _EditPhoneSheet({required this.initial});

  @override
  State<_EditPhoneSheet> createState() => _EditPhoneSheetState();
}

class _EditPhoneSheetState extends State<_EditPhoneSheet> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      color: AppColors.surface.resolveFrom(context),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const Expanded(
                    child: Text(
                      'Update Phone Number',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context, _controller.text),
                    child: const Text('Submit'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: _controller,
                autofocus: true,
                keyboardType: TextInputType.phone,
                placeholder: 'Enter new phone number',
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6.resolveFrom(context),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Photo-style header: initials, name, role, staff ID.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final e = currentEmployee;
    final initials = e.name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0])
        .take(2)
        .join();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: AppColors.karmaRed,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            e.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${e.jobTitle} · ${e.department}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey.resolveFrom(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            context.l10n.staffIdValue(e.employeeId),
            style: TextStyle(
              fontSize: 12.5,
              color: CupertinoColors.systemGrey.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }
}

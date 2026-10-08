import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../data/calendar_data.dart';
import '../../data/current_employee.dart';
import '../../domain/nepal/tax_slabs.dart';
import '../../domain/pdf_documents.dart';
import '../../l10n/l10n.dart';
import '../../state/audit_log_state.dart';
import '../../state/checklist_state.dart';
import '../../state/employee_documents_state.dart';
import '../../state/employee_records_state.dart';
import '../../theme/app_colors.dart';
import '../apps/widgets/pdf_actions.dart';
import '../apps/widgets/status_badge.dart';
import '../apps/widgets/ui_kit.dart';
import 'hr_document_sheet.dart';
import 'hr_employee_form_screen.dart';

enum _Tab { job, contact, pay, docs, tasks }

/// One employee's record as HR sees it: the same header-and-tabs layout as
/// the employee's own My Info page, plus Edit and Deactivate.
class HrEmployeeDetailScreen extends StatefulWidget {
  final String employeeId;

  const HrEmployeeDetailScreen({super.key, required this.employeeId});

  @override
  State<HrEmployeeDetailScreen> createState() => _HrEmployeeDetailScreenState();
}

class _HrEmployeeDetailScreenState extends State<HrEmployeeDetailScreen> {
  _Tab _tab = _Tab.job;

  String _tabLabel(AppLocalizations l10n, _Tab t) => switch (t) {
    _Tab.job => l10n.infoTabJob,
    _Tab.contact => l10n.infoTabContact,
    _Tab.pay => l10n.infoTabPay,
    _Tab.docs => l10n.infoTabDocs,
    _Tab.tasks => l10n.hrTabTasks,
  };

  Future<void> _toggleStatus(EmployeeRecord r) async {
    final l10n = context.l10n;
    final deactivating = r.isActive;
    final ok = await confirm(
      context,
      title: deactivating
          ? l10n.hrDeactivateTitle(r.name)
          : l10n.hrReactivateTitle(r.name),
      message: deactivating
          ? l10n.hrDeactivateMessage
          : l10n.hrReactivateMessage,
      confirmLabel: deactivating
          ? l10n.hrDeactivateAction
          : l10n.hrReactivateAction,
      destructive: deactivating,
    );
    if (!ok || !mounted) return;
    context.read<EmployeeRecordsState>().setStatus(
      r.id,
      deactivating ? EmploymentStatus.inactive : EmploymentStatus.active,
    );
    logAudit(
      context,
      deactivating
          ? AuditAction.employeeDeactivated
          : AuditAction.employeeReactivated,
      r.name,
    );
  }

  Future<void> _addDocument(EmployeeRecord r) async {
    final entered = await showCupertinoModalPopup<NewDocument>(
      context: context,
      builder: (_) => const HrDocumentSheet(),
    );
    if (entered == null || !mounted) return;
    context.read<EmployeeDocumentsState>().add(
      employeeId: r.id,
      type: entered.type,
      title: entered.title,
      expiresOn: entered.expiresOn,
    );
    logAudit(context, AuditAction.documentAdded, '${r.name}: ${entered.title}');
  }

  Future<void> _removeDocument(EmployeeRecord r, EmployeeDocument d) async {
    final l10n = context.l10n;
    final ok = await confirm(
      context,
      title: l10n.hrRemoveDocTitle(d.title),
      message: l10n.hrRemoveDoc,
      confirmLabel: l10n.hrRemoveAction,
      destructive: true,
    );
    if (!ok || !mounted) return;
    context.read<EmployeeDocumentsState>().remove(d.id);
    logAudit(context, AuditAction.documentRemoved, '${r.name}: ${d.title}');
  }

  /// Appointment letter, experience letter or salary certificate, made as a
  /// PDF for this person.
  void _letters(EmployeeRecord r) {
    final l10n = context.l10n;
    final profile = r.toProfile();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheet) => CupertinoActionSheet(
        title: Text(l10n.hrLetters),
        message: Text(r.name),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(sheet);
              showPdfActions(
                context,
                title: l10n.hrLetterAppointment,
                filename: 'appointment-letter-${r.id}.pdf',
                build: () => buildAppointmentLetterPdf(employee: profile),
              );
            },
            child: Text(l10n.hrLetterAppointment),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(sheet);
              final today = dateOnly(DateTime.now());
              final last = await pickDate(
                context,
                initial: today,
                minimum: r.joiningDate,
                maximum: DateTime(today.year + 1, today.month, today.day),
              );
              if (last == null || !mounted) return;
              showPdfActions(
                context,
                title: l10n.hrLetterExperience,
                filename: 'experience-letter-${r.id}.pdf',
                build: () => buildExperienceLetterPdf(
                  employee: profile,
                  lastWorkingDay: last,
                ),
              );
            },
            child: Text(l10n.hrLetterExperience),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(sheet);
              showPdfActions(
                context,
                title: l10n.salaryCertificateLabel,
                filename: 'salary-certificate-${r.id}.pdf',
                build: () => buildSalaryCertificatePdf(employee: profile),
              );
            },
            child: Text(l10n.salaryCertificateLabel),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(sheet),
          child: Text(l10n.cancel),
        ),
      ),
    );
  }

  String _taskLabel(AppLocalizations l10n, ChecklistItem item) =>
      switch (item) {
        ChecklistItem.collectDocuments => l10n.hrTaskCollectDocs,
        ChecklistItem.createAccounts => l10n.hrTaskCreateAccounts,
        ChecklistItem.issueEquipment => l10n.hrTaskIssueEquipment,
        ChecklistItem.inductionSession => l10n.hrTaskInduction,
        ChecklistItem.introduceTeam => l10n.hrTaskIntroduceTeam,
        ChecklistItem.exitInterview => l10n.hrTaskExitInterview,
        ChecklistItem.returnAssets => l10n.hrTaskReturnAssets,
        ChecklistItem.finalSettlement => l10n.hrTaskFinalSettlement,
        ChecklistItem.disableAccounts => l10n.hrTaskDisableAccounts,
        ChecklistItem.issueExperienceLetter => l10n.hrTaskExperienceLetter,
      };

  /// One checklist as its own section: a ticked or empty circle per step.
  Widget _checklist(
    EmployeeRecord r,
    String title,
    List<ChecklistItem> items,
    ChecklistState checks,
  ) {
    final l10n = context.l10n;
    return CupertinoListSection.insetGrouped(
      header: Text(title.toUpperCase()),
      footer: Text(
        l10n.hrTasksDone(checks.doneCount(r.id, items), items.length),
      ),
      children: [
        for (final item in items)
          CupertinoListTile(
            leading: Icon(
              checks.isDone(r.id, item)
                  ? CupertinoIcons.check_mark_circled_solid
                  : CupertinoIcons.circle,
              color: checks.isDone(r.id, item)
                  ? CupertinoColors.activeGreen
                  : CupertinoColors.systemGrey,
            ),
            title: Text(_taskLabel(l10n, item)),
            onTap: () => context.read<ChecklistState>().toggle(r.id, item),
          ),
      ],
    );
  }

  CupertinoListTile _row(IconData icon, String value, String label) {
    return CupertinoListTile(
      leading: Icon(icon),
      title: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);
    final r = context.watch<EmployeeRecordsState>().byId(widget.employeeId);
    final docs = context.watch<EmployeeDocumentsState>().forEmployee(
      widget.employeeId,
    );
    final checks = context.watch<ChecklistState>();

    if (r == null) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(l10n.hrEmployeeTitle),
        ),
        child: Center(child: Text(l10n.hrNoEmployeesFound)),
      );
    }

    final joined =
        '${adMonths[r.joiningDate.month - 1]} ${r.joiningDate.day}, '
        '${r.joiningDate.year}';

    final tabContent = switch (_tab) {
      _Tab.job => [
        _row(CupertinoIcons.briefcase_fill, r.jobTitle, l10n.jobTitleLabel),
        _row(
          CupertinoIcons.building_2_fill,
          r.department,
          l10n.departmentLabel,
        ),
        _row(
          CupertinoIcons.person_2,
          r.manager.isEmpty ? l10n.hrNoManager : r.manager,
          l10n.managerLabel,
        ),
        _row(CupertinoIcons.calendar_today, joined, l10n.joinedLabel),
        _row(
          CupertinoIcons.doc_text,
          r.employmentType,
          l10n.employmentTypeLabel,
        ),
        _row(
          CupertinoIcons.location_solid,
          r.workLocation,
          l10n.workLocationLabel,
        ),
      ],
      _Tab.contact => [
        _row(CupertinoIcons.mail, r.email, l10n.workEmailLabel),
        CupertinoListTile(
          leading: const Icon(CupertinoIcons.phone),
          title: Text(r.phone),
          subtitle: Text(l10n.phoneLabel),
          trailing: const CupertinoListTileChevron(),
          onTap: () => callNumber(context, r.phone),
        ),
      ],
      _Tab.pay => [
        for (final (label, amount, bold) in <(String, double, bool)>[
          (l10n.basicSalaryLabel, r.basicSalary, false),
          (l10n.dearnessAllowanceLabel, r.dearnessAllowance, false),
          (l10n.transportAllowanceLabel, r.transportAllowance, false),
          (l10n.grossMonthlyLabel, r.grossMonthly, true),
        ])
          CupertinoListTile(
            title: Text(
              label,
              style: bold ? const TextStyle(fontWeight: FontWeight.w600) : null,
            ),
            additionalInfo: TileInfo(formatRupees(amount)),
          ),
        CupertinoListTile(
          title: Text(l10n.hrBankName),
          additionalInfo: TileInfo(r.bankName.isEmpty ? '-' : r.bankName),
        ),
        CupertinoListTile(
          title: Text(l10n.hrAccountNumber),
          additionalInfo: TileInfo(
            r.accountNumber.isEmpty
                ? '-'
                : r.accountNumber.length <= 4
                ? r.accountNumber
                : '•••• ${r.accountNumber.substring(r.accountNumber.length - 4)}',
          ),
        ),
        CupertinoListTile(
          title: Text(l10n.hrFilingStatus),
          additionalInfo: TileInfo(
            r.filingStatus == FilingStatus.married
                ? l10n.hrFilingMarried
                : l10n.hrFilingSingle,
          ),
        ),
      ],
      _Tab.tasks => const <Widget>[],
      _Tab.docs => [
        if (docs.isEmpty) CupertinoListTile(title: Text(l10n.hrNoDocs)),
        for (final d in docs)
          CupertinoListTile(
            leading: Icon(docTypeIcon(d.type)),
            title: Text(d.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(
              '${docTypeLabel(l10n, d.type)} · '
              '${docExpiryText(l10n, d, DateTime.now())}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color:
                    (d.daysLeft(DateTime.now()) ?? 999) <=
                        EmployeeDocumentsState.warningDays
                    ? CupertinoColors.destructiveRed
                    : null,
              ),
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              onPressed: () => _removeDocument(r, d),
              child: Icon(
                CupertinoIcons.minus_circle,
                color: CupertinoColors.destructiveRed,
                semanticLabel: l10n.hrRemoveDoc,
              ),
            ),
          ),
        CupertinoListTile(
          leading: const Icon(
            CupertinoIcons.add_circled,
            color: AppColors.karmaRed,
          ),
          title: Text(
            l10n.hrAddDocument,
            style: const TextStyle(color: AppColors.karmaRed),
          ),
          onTap: () => _addDocument(r),
        ),
      ],
    };

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(l10n.hrEmployeeTitle),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: () => Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => HrEmployeeFormScreen(existing: r),
            ),
          ),
          child: Text(l10n.editAction),
        ),
      ),
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              children: [
                Padding(
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
                          r.initials,
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        r.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${r.jobTitle} · ${r.department}',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: subtle),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.staffIdValue(r.id),
                        style: TextStyle(fontSize: 12.5, color: subtle),
                      ),
                      if (!r.isActive) ...[
                        const SizedBox(height: 8),
                        StatusBadge(
                          label: l10n.hrFilterInactive,
                          color: CupertinoColors.systemGrey,
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: CupertinoSlidingSegmentedControl<_Tab>(
                      groupValue: _tab,
                      onValueChanged: (t) {
                        if (t != null) setState(() => _tab = t);
                      },
                      children: {
                        for (final t in _Tab.values)
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
                if (_tab == _Tab.tasks) ...[
                  _checklist(r, l10n.hrOnboarding, onboardingItems, checks),
                  _checklist(r, l10n.hrOffboarding, offboardingItems, checks),
                ] else
                  CupertinoListSection.insetGrouped(children: tabContent),
                CupertinoListSection.insetGrouped(
                  footer: Text(l10n.hrLettersFooter),
                  children: [
                    CupertinoListTile(
                      leading: const Icon(CupertinoIcons.doc_richtext),
                      title: Text(l10n.hrLetters),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () => _letters(r),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: CupertinoButton(
                    color: r.isActive
                        ? CupertinoColors.destructiveRed
                        : AppColors.karmaRed,
                    onPressed: () => _toggleStatus(r),
                    child: Text(
                      r.isActive ? l10n.hrDeactivate : l10n.hrReactivate,
                      style: const TextStyle(color: CupertinoColors.white),
                    ),
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

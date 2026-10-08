import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/current_employee.dart';
import '../../domain/nepal/bs_dates.dart';
import '../../l10n/l10n.dart';
import '../../state/audit_log_state.dart';
import '../../state/employee_documents_state.dart';
import '../../state/employee_records_state.dart';
import '../../state/hr_inbox_state.dart';
import '../../state/payroll_state.dart';
import '../../theme/app_colors.dart';
import '../apps/widgets/request_status.dart';
import '../apps/widgets/ui_kit.dart';
import '../notifications_screen.dart' show relativeTime;
import 'hr_bar_row.dart';
import 'hr_document_sheet.dart';

String auditActionLabel(AppLocalizations l10n, AuditAction action) {
  return switch (action) {
    AuditAction.employeeAdded => l10n.hrAuditEmployeeAdded,
    AuditAction.employeeUpdated => l10n.hrAuditEmployeeUpdated,
    AuditAction.employeeDeactivated => l10n.hrAuditEmployeeDeactivated,
    AuditAction.employeeReactivated => l10n.hrAuditEmployeeReactivated,
    AuditAction.requestApproved => l10n.hrAuditRequestApproved,
    AuditAction.requestRejected => l10n.hrAuditRequestRejected,
    AuditAction.payrollRun => l10n.hrAuditPayrollRun,
    AuditAction.payrollApproved => l10n.hrAuditPayrollApproved,
    AuditAction.payrollPaid => l10n.hrAuditPayrollPaid,
    AuditAction.noticePublished => l10n.hrAuditNoticePublished,
    AuditAction.noticeDeleted => l10n.hrAuditNoticeDeleted,
    AuditAction.holidayAdded => l10n.hrAuditHolidayAdded,
    AuditAction.holidayRemoved => l10n.hrAuditHolidayRemoved,
    AuditAction.documentAdded => l10n.hrAuditDocumentAdded,
    AuditAction.documentRemoved => l10n.hrAuditDocumentRemoved,
    AuditAction.reviewStarted => l10n.hrAuditReviewStarted,
    AuditAction.jobPosted => l10n.hrAuditJobPosted,
    AuditAction.applicantHired => l10n.hrAuditApplicantHired,
    AuditAction.employeesImported => l10n.hrAuditEmployeesImported,
    AuditAction.payViewed => l10n.hrAuditPayViewed,
    AuditAction.teamCreated => l10n.hrAuditTeamCreated,
    AuditAction.teamUpdated => l10n.hrAuditTeamUpdated,
    AuditAction.teamDeleted => l10n.hrAuditTeamDeleted,
  };
}

/// HR > Reports: headcount, requests, the latest payroll, an employee export
/// and the audit log, all read from the same company data as the rest.
class HrReportsScreen extends StatelessWidget {
  const HrReportsScreen({super.key});

  Future<void> _copy(BuildContext context, String csv) async {
    final l10n = context.l10n;
    await Clipboard.setData(ClipboardData(text: csv));
    if (!context.mounted) return;
    await showMessage(
      context,
      title: l10n.hrCsvCopiedTitle,
      message: l10n.hrCsvCopied,
    );
  }

  /// Counts per label, largest first, as bar rows.
  Widget _bars(Map<String, int> counts) {
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final largest = entries.fold<int>(1, (m, e) => e.value > m ? e.value : m);
    return Column(
      children: [
        for (final e in entries)
          HrBarRow(name: e.key, count: e.value, fraction: e.value / largest),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final nepali = Localizations.localeOf(context).languageCode == 'ne';
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);

    final records = context.watch<EmployeeRecordsState>();
    final inbox = context.watch<HrInboxState>();
    final latest = context.watch<PayrollState>().latest;
    final audit = context.watch<AuditLogState>().entries;
    final expiring = context.watch<EmployeeDocumentsState>().expiringSoon();

    final active = records.active;
    final byDepartment = <String, int>{};
    final byType = <String, int>{};
    for (final r in active) {
      byDepartment[r.department] = (byDepartment[r.department] ?? 0) + 1;
      byType[r.employmentType] = (byType[r.employmentType] ?? 0) + 1;
    }

    int count(InboxStatus s) => inbox.items.where((i) => i.status == s).length;

    Widget stat(String label, String value, Color color) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceSecondary.resolveFrom(context),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.5, color: subtle),
              ),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SectionCard(
              title: l10n.hrReportsHeadcount,
              subtitle: l10n.hrEmployeeCount(active.length),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.hrReportsByDepartment,
                    style: TextStyle(fontSize: 12.5, color: subtle),
                  ),
                  _bars(byDepartment),
                  const SizedBox(height: 10),
                  Text(
                    l10n.hrReportsByType,
                    style: TextStyle(fontSize: 12.5, color: subtle),
                  ),
                  _bars(byType),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: l10n.hrReportsRequests,
              child: Row(
                children: [
                  stat(
                    l10n.statusPending,
                    '${inbox.pendingCount}',
                    RequestOutcome.pending.color,
                  ),
                  const SizedBox(width: 10),
                  stat(
                    l10n.statusApproved,
                    '${count(InboxStatus.approved)}',
                    RequestOutcome.approved.color,
                  ),
                  const SizedBox(width: 10),
                  stat(
                    l10n.statusRejected,
                    '${count(InboxStatus.rejected)}',
                    RequestOutcome.rejected.color,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: l10n.hrReportsPayroll,
              subtitle: latest == null
                  ? null
                  : bsMonthLabel(latest.year, latest.month, nepali: nepali),
              child: latest == null
                  ? Text(
                      l10n.hrReportsNoPayroll,
                      style: TextStyle(fontSize: 13, color: subtle),
                    )
                  : Row(
                      children: [
                        stat(
                          l10n.hrPayGross,
                          formatRupees(latest.totalGross),
                          AppColors.textPrimary.resolveFrom(context),
                        ),
                        const SizedBox(width: 10),
                        stat(
                          l10n.hrPayNet,
                          formatRupees(latest.totalNet),
                          AppColors.karmaRed,
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: l10n.hrReportsDocs,
              child: expiring.isEmpty
                  ? Text(
                      l10n.hrNoExpiringDocs,
                      style: TextStyle(fontSize: 13, color: subtle),
                    )
                  : Column(
                      children: [
                        for (final d in expiring)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                Icon(
                                  docTypeIcon(d.type),
                                  size: 18,
                                  color: AppColors.karmaRed,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        d.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        records.byId(d.employeeId)?.name ??
                                            d.employeeId,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: subtle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Capped, so a long translation shrinks instead
                                // of pushing the row off a narrow screen.
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.sizeOf(context).width * 0.3,
                                  ),
                                  child: Text(
                                    docExpiryText(l10n, d, DateTime.now()),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: CupertinoColors.destructiveRed,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: l10n.hrReportsExport,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 11),
                minimumSize: Size.zero,
                color: CupertinoColors.systemGrey5.resolveFrom(context),
                onPressed: () => _copy(context, records.toCsv()),
                child: Text(
                  l10n.hrExportEmployees,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary.resolveFrom(context),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: l10n.hrExportAudit,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 11),
                minimumSize: Size.zero,
                color: CupertinoColors.systemGrey5.resolveFrom(context),
                onPressed: () =>
                    _copy(context, context.read<AuditLogState>().toCsv()),
                child: Text(
                  l10n.hrExportAudit,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary.resolveFrom(context),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _AuditCard(entries: audit),
          ],
        ),
      ),
    );
  }
}

/// Which audit actions a filter chip shows.
enum _AuditGroup { all, people, requests, payroll, company }

_AuditGroup _groupOf(AuditAction a) => switch (a) {
  AuditAction.employeeAdded ||
  AuditAction.employeeUpdated ||
  AuditAction.employeeDeactivated ||
  AuditAction.employeeReactivated ||
  AuditAction.employeesImported ||
  AuditAction.payViewed ||
  AuditAction.documentAdded ||
  AuditAction.documentRemoved ||
  AuditAction.applicantHired => _AuditGroup.people,
  AuditAction.requestApproved ||
  AuditAction.requestRejected => _AuditGroup.requests,
  AuditAction.payrollRun ||
  AuditAction.payrollApproved ||
  AuditAction.payrollPaid => _AuditGroup.payroll,
  AuditAction.noticePublished ||
  AuditAction.noticeDeleted ||
  AuditAction.holidayAdded ||
  AuditAction.holidayRemoved ||
  AuditAction.reviewStarted ||
  AuditAction.teamCreated ||
  AuditAction.teamUpdated ||
  AuditAction.teamDeleted ||
  AuditAction.jobPosted => _AuditGroup.company,
};

/// Recent activity, filterable by what kind of change it was.
class _AuditCard extends StatefulWidget {
  final List<AuditEntry> entries;

  const _AuditCard({required this.entries});

  @override
  State<_AuditCard> createState() => _AuditCardState();
}

class _AuditCardState extends State<_AuditCard> {
  var _group = _AuditGroup.all;

  String _label(AppLocalizations l10n, _AuditGroup g) => switch (g) {
    _AuditGroup.all => l10n.filterAll,
    _AuditGroup.people => l10n.hrAuditGroupPeople,
    _AuditGroup.requests => l10n.hrReportsRequests,
    _AuditGroup.payroll => l10n.hrSectionPayroll,
    _AuditGroup.company => l10n.hrAuditGroupCompany,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);
    final shown = widget.entries
        .where((e) => _group == _AuditGroup.all || _groupOf(e.action) == _group)
        .toList();

    return SectionCard(
      title: l10n.hrReportsActivity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final g in _AuditGroup.values)
                GestureDetector(
                  onTap: () => setState(() => _group = g),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: g == _group
                          ? AppColors.karmaRed
                          : CupertinoColors.systemGrey5.resolveFrom(context),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _label(l10n, g),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: g == _group
                            ? CupertinoColors.white
                            : AppColors.textPrimary.resolveFrom(context),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (shown.isEmpty)
            Text(
              l10n.hrNoActivity,
              style: TextStyle(fontSize: 13, color: subtle),
            )
          else
            for (final e in shown.take(15))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auditActionLabel(l10n, e.action),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            l10n.hrAuditLine(e.actor, e.detail),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12.5, color: subtle),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      relativeTime(e.when),
                      style: TextStyle(fontSize: 12.5, color: subtle),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

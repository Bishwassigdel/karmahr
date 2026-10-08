import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/current_employee.dart';
import '../../domain/nepal/bs_dates.dart';
import '../../domain/pdf_documents.dart';
import '../../l10n/l10n.dart';
import '../../state/audit_log_state.dart';
import '../../state/employee_records_state.dart';
import '../../state/payroll_state.dart';
import '../../theme/app_colors.dart';
import '../apps/widgets/pdf_actions.dart';
import '../apps/widgets/request_status.dart';
import '../apps/widgets/ui_kit.dart';

/// HR > Payroll: pick a month, run it, approve it, mark it paid.
class HrPayrollScreen extends StatefulWidget {
  const HrPayrollScreen({super.key});

  @override
  State<HrPayrollScreen> createState() => _HrPayrollScreenState();
}

class _HrPayrollScreenState extends State<HrPayrollScreen> {
  late final List<BsMonth> _months = fiscalMonthsUpTo(bsToday());
  late BsMonth _period = _months.last; // the current BS month

  bool get _nepali => Localizations.localeOf(context).languageCode == 'ne';

  String _label(BsMonth m) => bsMonthLabel(m.year, m.month, nepali: _nepali);

  Future<void> _pickPeriod() async {
    final picked = await pickFromList<BsMonth>(
      context,
      items: _months,
      initial: _period,
      label: _label,
    );
    if (picked != null && mounted) setState(() => _period = picked);
  }

  void _run() {
    context.read<PayrollState>().calculate(
      _period.year,
      _period.month,
      context.read<EmployeeRecordsState>().records,
    );
    logAudit(context, AuditAction.payrollRun, _label(_period));
  }

  Future<void> _approve() async {
    final l10n = context.l10n;
    final ok = await confirm(
      context,
      title: l10n.hrApprovePayrollTitle(_label(_period)),
      message: l10n.hrApprovePayrollMessage,
      confirmLabel: l10n.hrApprovePayroll,
    );
    if (!ok || !mounted) return;
    context.read<PayrollState>().approve(_period.year, _period.month);
    logAudit(context, AuditAction.payrollApproved, _label(_period));
  }

  Future<void> _markPaid() async {
    final l10n = context.l10n;
    final ok = await confirm(
      context,
      title: l10n.hrMarkPaidTitle(_label(_period)),
      message: l10n.hrMarkPaidMessage,
      confirmLabel: l10n.hrMarkPaid,
    );
    if (!ok || !mounted) return;
    context.read<PayrollState>().markPaid(_period.year, _period.month);
    logAudit(context, AuditAction.payrollPaid, _label(_period));
  }

  Future<void> _copy(String csv) async {
    final l10n = context.l10n;
    await Clipboard.setData(ClipboardData(text: csv));
    if (!mounted) return;
    await showMessage(
      context,
      title: l10n.hrCsvCopiedTitle,
      message: l10n.hrCsvCopied,
    );
  }

  /// Everything the run can be exported as. The bank file waits for
  /// approval: nobody should pay out a draft.
  void _export(PayrollRun run) {
    final l10n = context.l10n;
    final approved = run.status != PayrollStatus.draft;
    final missing = run.missingBankDetails;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheet) {
        void pick(String csv) {
          Navigator.pop(sheet);
          _copy(csv);
        }

        return CupertinoActionSheet(
          title: Text(l10n.hrReportsExport),
          message: !approved
              ? Text(l10n.hrBankNeedsApproval)
              : missing.isEmpty
              ? null
              : Text(
                  l10n.hrBankMissing(
                    missing.length,
                    missing.map((l) => l.name).join(', '),
                  ),
                ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () => pick(run.toCsv()),
              child: Text(l10n.hrExportRegister),
            ),
            if (approved)
              CupertinoActionSheetAction(
                onPressed: () => pick(run.toBankCsv()),
                child: Text(l10n.hrExportBank),
              ),
            CupertinoActionSheetAction(
              onPressed: () => pick(run.toTdsCsv()),
              child: Text(l10n.hrExportTds),
            ),
            CupertinoActionSheetAction(
              onPressed: () => pick(run.toSsfCsv()),
              child: Text(l10n.hrExportSsf),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(sheet),
            child: Text(l10n.cancel),
          ),
        );
      },
    );
  }

  /// One person's figures, with their payslip as a PDF once approved.
  void _showBreakdown(PayrollRun run, PayrollLine line) {
    final l10n = context.l10n;
    final r = line.result;
    final record = context.read<EmployeeRecordsState>().byId(line.employeeId);
    final approved = run.status != PayrollStatus.draft;
    final month = bsMonthLabel(run.year, run.month);

    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheet) => CupertinoActionSheet(
        title: Text(line.name),
        message: Text(
          '${l10n.hrPayGross}: ${formatRupees(r.grossMonthly)}\n'
          '${l10n.hrPaySsf}: ${formatRupees(r.socialSecurityFundDeduction)}\n'
          '${l10n.hrPayCit}: ${formatRupees(r.citDeduction)}\n'
          '${l10n.hrPayInsurance}: ${formatRupees(r.insuranceDeduction)}\n'
          '${l10n.hrPayTax}: ${formatRupees(r.monthlyTax)}\n'
          '${l10n.hrPayNet}: ${formatRupees(r.netMonthly)}',
        ),
        actions: [
          if (record != null && approved)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(sheet);
                showPdfActions(
                  context,
                  title: '${l10n.hrSharePayslip} - $month',
                  filename:
                      'payslip-${line.employeeId}-${run.year}-${run.month}.pdf',
                  build: () => buildPayslipPdf(
                    payslipDataFromPayroll(
                      month: month,
                      payDate: 'End of $month',
                      status: run.status == PayrollStatus.paid
                          ? 'Paid'
                          : 'Approved',
                      basic: line.basic,
                      dearness: line.dearness,
                      transport: line.transport,
                      result: r,
                    ),
                    employee: record.toProfile(),
                  ),
                );
              },
              child: Text(l10n.hrSharePayslip),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(sheet),
          child: Text(l10n.cancel),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);
    final run = context.watch<PayrollState>().runFor(
      _period.year,
      _period.month,
    );

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          children: [
            CupertinoListSection.insetGrouped(
              children: [
                FormRow(
                  label: l10n.hrPayPeriod,
                  value: _label(_period),
                  onTap: _pickPeriod,
                ),
              ],
            ),
            if (run == null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  l10n.hrPayNotRun(_label(_period)),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: subtle),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CupertinoButton.filled(
                  onPressed: _run,
                  child: Text(l10n.hrRunPayroll),
                ),
              ),
            ] else ...[
              _Summary(run: run),
              _Actions(
                run: run,
                onRecalculate: _run,
                onApprove: _approve,
                onMarkPaid: _markPaid,
                onExport: () => _export(run),
              ),
              if (run.lines.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.hrNoActiveStaff,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: subtle),
                  ),
                )
              else
                CupertinoListSection.insetGrouped(
                  children: [
                    for (final line in run.lines)
                      CupertinoListTile(
                        leading: InitialsAvatar(
                          initials: line.initials,
                          size: 34,
                        ),
                        leadingSize: 34,
                        title: Text(
                          line.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          l10n.hrPayLineSubtitle(
                            formatRupees(line.gross),
                            formatRupees(line.tax),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        additionalInfo: TileInfo(
                          formatRupees(line.net),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: const CupertinoListTileChevron(),
                        onTap: () => _showBreakdown(run, line),
                      ),
                  ],
                ),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: NoteBanner(
                icon: CupertinoIcons.info,
                text: l10n.hrPayPlaceholderNote,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Status and the four headline numbers.
class _Summary extends StatelessWidget {
  final PayrollRun run;

  const _Summary({required this.run});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final outcome = switch (run.status) {
      PayrollStatus.draft => null,
      PayrollStatus.approved => RequestOutcome.approved,
      PayrollStatus.paid => RequestOutcome.paid,
    };

    Widget stat(String label, String value, {bool strong = false}) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary.resolveFrom(context),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                color: CupertinoColors.systemGrey.resolveFrom(context),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: strong ? AppColors.karmaRed : null,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          outcome == null
              ? _DraftBadge(label: l10n.hrPayrollDraft)
              : OutcomeBadge(outcome),
          const SizedBox(height: 10),
          // Rows, not a fixed-ratio grid: a card grows with its text, so
          // larger text or Devanagari never overflows it.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: stat(l10n.hrStatEmployees, '${run.employeeCount}'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: stat(l10n.hrPayGross, formatRupees(run.totalGross)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: stat(
                  l10n.hrPayDeductions,
                  formatRupees(run.totalDeductions),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: stat(
                  l10n.hrPayNet,
                  formatRupees(run.totalNet),
                  strong: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DraftBadge extends StatelessWidget {
  final String label;

  const _DraftBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    const color = CupertinoColors.systemOrange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// The buttons that make sense for where the run is right now.
class _Actions extends StatelessWidget {
  final PayrollRun run;
  final VoidCallback onRecalculate;
  final VoidCallback onApprove;
  final VoidCallback onMarkPaid;
  final VoidCallback onExport;

  const _Actions({
    required this.run,
    required this.onRecalculate,
    required this.onApprove,
    required this.onMarkPaid,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final grey = CupertinoColors.systemGrey5.resolveFrom(context);
    final ink = AppColors.textPrimary.resolveFrom(context);

    Widget button(String label, VoidCallback onTap, {bool primary = false}) {
      return CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
        minimumSize: Size.zero,
        color: primary ? AppColors.karmaRed : grey,
        onPressed: onTap,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            color: primary ? CupertinoColors.white : ink,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (run.status == PayrollStatus.draft)
            Row(
              children: [
                Expanded(child: button(l10n.hrRecalculate, onRecalculate)),
                const SizedBox(width: 10),
                Expanded(
                  child: button(
                    l10n.hrApprovePayroll,
                    onApprove,
                    primary: true,
                  ),
                ),
              ],
            ),
          if (run.status == PayrollStatus.approved)
            button(l10n.hrMarkPaid, onMarkPaid, primary: true),
          const SizedBox(height: 10),
          button(l10n.hrReportsExport, onExport),
        ],
      ),
    );
  }
}

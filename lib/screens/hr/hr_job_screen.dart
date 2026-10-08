import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../state/audit_log_state.dart';
import '../../state/hiring_state.dart';
import '../../theme/app_colors.dart';
import '../apps/widgets/status_badge.dart';
import '../apps/widgets/ui_kit.dart';
import 'hr_employee_form_screen.dart';

String applicantStageLabel(AppLocalizations l10n, ApplicantStage s) =>
    switch (s) {
      ApplicantStage.applied => l10n.hrAppApplied,
      ApplicantStage.screening => l10n.hrAppScreening,
      ApplicantStage.interview => l10n.hrAppInterview,
      ApplicantStage.offer => l10n.hrAppOffer,
      ApplicantStage.hired => l10n.hrAppHired,
      ApplicantStage.rejected => l10n.statusRejected,
    };

Color applicantStageColor(ApplicantStage s) => switch (s) {
  ApplicantStage.applied => CupertinoColors.systemGrey,
  ApplicantStage.screening => CupertinoColors.systemOrange,
  ApplicantStage.interview => CupertinoColors.systemBlue,
  ApplicantStage.offer => CupertinoColors.systemPurple,
  ApplicantStage.hired => CupertinoColors.activeGreen,
  ApplicantStage.rejected => CupertinoColors.destructiveRed,
};

/// One job: its applicants, and moving each along the stages.
class HrJobScreen extends StatelessWidget {
  final String jobId;

  const HrJobScreen({super.key, required this.jobId});

  Future<void> _addApplicant(BuildContext context) async {
    final entered =
        await showCupertinoModalPopup<({String name, String email})>(
          context: context,
          builder: (_) => const _AddApplicantSheet(),
        );
    if (entered == null || !context.mounted) return;
    context.read<HiringState>().addApplicant(
      jobId,
      entered.name,
      entered.email,
    );
  }

  void _advance(BuildContext context, Applicant a, JobPost job) {
    final state = context.read<HiringState>();
    state.advance(a.id);
    // Reaching "hired" is worth a line in the audit log.
    if (state.applicantsFor(jobId).firstWhere((x) => x.id == a.id).stage ==
        ApplicantStage.hired) {
      logAudit(context, AuditAction.applicantHired, '${a.name}: ${job.title}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);
    final hiring = context.watch<HiringState>();
    final job = hiring.jobById(jobId);

    if (job == null) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(),
        child: Center(child: Text(l10n.hrNoJobs)),
      );
    }
    final applicants = hiring.applicantsFor(jobId)
      // Still in the running first, in stage order; hired and rejected last.
      ..sort((a, b) {
        if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
        return a.stage.index - b.stage.index;
      });

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(job.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: () =>
              context.read<HiringState>().setOpen(job.id, !job.isOpen),
          child: Text(
            job.isOpen ? l10n.hrJobClose : l10n.hrJobReopen,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ),
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '${job.department} · '
                    '${l10n.hrJobSummary(hiring.activeCount(job.id), job.openings)}',
                    style: TextStyle(fontSize: 13, color: subtle),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: CupertinoButton.filled(
                    onPressed: () => _addApplicant(context),
                    child: Text(l10n.hrAddApplicant),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Text(
                    l10n.hrApplicants.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: subtle,
                    ),
                  ),
                ),
                if (applicants.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      l10n.hrNoApplicants,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: subtle),
                    ),
                  )
                else
                  for (final a in applicants)
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSecondary.resolveFrom(context),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      a.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (a.email.isNotEmpty)
                                      Text(
                                        a.email,
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
                              StatusBadge(
                                label: applicantStageLabel(l10n, a.stage),
                                color: applicantStageColor(a.stage),
                              ),
                            ],
                          ),
                          if (a.isActive) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: CupertinoButton(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 9,
                                    ),
                                    minimumSize: Size.zero,
                                    color: CupertinoColors.systemGrey5
                                        .resolveFrom(context),
                                    onPressed: () => context
                                        .read<HiringState>()
                                        .reject(a.id),
                                    child: Text(
                                      l10n.hrReject,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        color: CupertinoColors.destructiveRed,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: CupertinoButton(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 9,
                                    ),
                                    minimumSize: Size.zero,
                                    color: AppColors.karmaRed,
                                    onPressed: () => _advance(context, a, job),
                                    child: Text(
                                      l10n.hrApplicantAdvance,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        color: CupertinoColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (a.stage == ApplicantStage.hired) ...[
                            const SizedBox(height: 10),
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              minimumSize: Size.zero,
                              color: AppColors.karmaRed,
                              onPressed: () => Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) => HrEmployeeFormScreen(
                                    initialName: a.name,
                                    initialEmail: a.email,
                                    initialJobTitle: job.title,
                                    initialDepartment: job.department,
                                  ),
                                ),
                              ),
                              child: Text(
                                l10n.hrAddAsEmployee,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: CupertinoColors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
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

/// Name and email. Owns its controllers, so they are disposed only when the
/// sheet is truly gone.
class _AddApplicantSheet extends StatefulWidget {
  const _AddApplicantSheet();

  @override
  State<_AddApplicantSheet> createState() => _AddApplicantSheetState();
}

class _AddApplicantSheetState extends State<_AddApplicantSheet> {
  final _name = TextEditingController();
  final _email = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      await showMessage(
        context,
        title: context.l10n.hrCheckDetails,
        message: context.l10n.hrApplicantNeedsName,
      );
      return;
    }
    if (!mounted) return;
    Navigator.pop(context, (
      name: _name.text.trim(),
      email: _email.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final box = BoxDecoration(
      color: CupertinoColors.systemGrey6.resolveFrom(context),
      borderRadius: BorderRadius.circular(12),
    );
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                  Expanded(
                    child: Text(
                      l10n.hrAddApplicant,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _save,
                    child: Text(l10n.save),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: _name,
                autofocus: true,
                placeholder: l10n.hrApplicantName,
                padding: const EdgeInsets.all(14),
                decoration: box,
              ),
              const SizedBox(height: 10),
              CupertinoTextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                placeholder: l10n.hrApplicantEmail,
                padding: const EdgeInsets.all(14),
                decoration: box,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

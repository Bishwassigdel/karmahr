import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../state/audit_log_state.dart';
import '../../state/hiring_state.dart';
import '../../theme/app_colors.dart';
import '../apps/widgets/status_badge.dart';
import '../apps/widgets/ui_kit.dart';
import 'hr_job_screen.dart';

/// HR > Hiring: the jobs, how many people are in the running for each, and
/// a way to post a new one.
class HrHiringScreen extends StatelessWidget {
  const HrHiringScreen({super.key});

  Future<void> _newJob(BuildContext context) async {
    final entered = await showCupertinoModalPopup<_NewJob>(
      context: context,
      builder: (_) => const _NewJobSheet(),
    );
    if (entered == null || !context.mounted) return;
    final job = context.read<HiringState>().addJob(
      entered.title,
      entered.department,
      entered.openings,
    );
    if (job != null) {
      logAudit(context, AuditAction.jobPosted, job.title);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);
    final hiring = context.watch<HiringState>();
    final jobs = hiring.jobs;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CupertinoButton.filled(
                onPressed: () => _newJob(context),
                child: Text(l10n.hrJobNew),
              ),
            ),
            if (jobs.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.hrNoJobs,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: subtle),
                ),
              )
            else
              CupertinoListSection.insetGrouped(
                children: [
                  for (final j in jobs)
                    CupertinoListTile(
                      title: Text(
                        j.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${j.department}\n'
                        '${l10n.hrJobSummary(hiring.activeCount(j.id), j.openings)}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      additionalInfo: TileInfoBox(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: StatusBadge(
                            label: j.isOpen ? l10n.hrJobOpen : l10n.hrJobClosed,
                            color: j.isOpen
                                ? CupertinoColors.activeGreen
                                : CupertinoColors.systemGrey,
                          ),
                        ),
                      ),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => HrJobScreen(jobId: j.id),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

typedef _NewJob = ({String title, String department, int openings});

/// Title, department and number of openings. Owns its controllers, so they
/// are disposed only when the sheet is truly gone.
class _NewJobSheet extends StatefulWidget {
  const _NewJobSheet();

  @override
  State<_NewJobSheet> createState() => _NewJobSheetState();
}

class _NewJobSheetState extends State<_NewJobSheet> {
  final _title = TextEditingController();
  final _department = TextEditingController();
  var _openings = 1;

  @override
  void dispose() {
    _title.dispose();
    _department.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _department.text.trim().isEmpty) {
      await showMessage(
        context,
        title: context.l10n.hrCheckDetails,
        message: context.l10n.hrJobNeedsDetails,
      );
      return;
    }
    if (!mounted) return;
    Navigator.pop<_NewJob>(context, (
      title: _title.text.trim(),
      department: _department.text.trim(),
      openings: _openings,
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
                      l10n.hrJobNew,
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
                controller: _title,
                autofocus: true,
                placeholder: l10n.jobTitleLabel,
                padding: const EdgeInsets.all(14),
                decoration: box,
              ),
              const SizedBox(height: 10),
              CupertinoTextField(
                controller: _department,
                placeholder: l10n.departmentLabel,
                padding: const EdgeInsets.all(14),
                decoration: box,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: Text(l10n.hrJobOpenings)),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    onPressed: _openings > 1
                        ? () => setState(() => _openings--)
                        : null,
                    child: Icon(
                      CupertinoIcons.minus_circle,
                      semanticLabel: l10n.a11yFewerHours,
                    ),
                  ),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '$_openings',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    onPressed: () => setState(() => _openings++),
                    child: Icon(
                      CupertinoIcons.plus_circle,
                      semanticLabel: l10n.a11yMoreHours,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

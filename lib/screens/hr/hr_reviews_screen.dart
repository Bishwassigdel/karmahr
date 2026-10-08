import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../domain/nepal/bs_dates.dart';
import '../../domain/nepal/fiscal_year.dart';
import '../../l10n/l10n.dart';
import '../../state/audit_log_state.dart';
import '../../state/employee_records_state.dart';
import '../../state/reviews_state.dart';
import '../../theme/app_colors.dart';
import '../apps/widgets/ui_kit.dart';
import 'hr_review_cycle_screen.dart';

/// HR > Reviews: the review cycles, each with how far along it is.
class HrReviewsScreen extends StatelessWidget {
  const HrReviewsScreen({super.key});

  Future<void> _start(BuildContext context) async {
    final l10n = context.l10n;
    final records = context.read<EmployeeRecordsState>().active;
    final today = bsToday();
    final fy = NepaliFiscalYear.of(today);
    final defaultName = l10n.hrReviewDefaultName(
      NepaliFiscalYear.quarterOf(today),
      fy.label,
    );

    final name = await showCupertinoModalPopup<String>(
      context: context,
      builder: (_) => _StartSheet(
        initialName: defaultName,
        hint: l10n.hrReviewStartHint(records.length),
      ),
    );
    if (name == null || !context.mounted) return;

    final cycle = context.read<ReviewsState>().start(
      name,
      records.map((r) => r.id),
    );
    if (cycle != null) {
      logAudit(context, AuditAction.reviewStarted, cycle.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);
    final cycles = context.watch<ReviewsState>().cycles;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            CupertinoButton.filled(
              onPressed: () => _start(context),
              child: Text(l10n.hrReviewStart),
            ),
            const SizedBox(height: 12),
            if (cycles.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.hrReviewNoCycles,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: subtle),
                ),
              ),
            for (final c in cycles)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => HrReviewCycleScreen(cycleId: c.id),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
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
                            child: Text(
                              c.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const CupertinoListTileChevron(),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Stack(
                          children: [
                            Container(
                              height: 6,
                              color: CupertinoColors.systemGrey5.resolveFrom(
                                context,
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: c.progress.clamp(0.0, 1.0),
                              child: Container(
                                height: 6,
                                color: AppColors.karmaRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.hrReviewProgress(c.completed, c.total),
                        style: TextStyle(fontSize: 12.5, color: subtle),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Asks for a name. Owns its controller, so it is disposed only when the
/// sheet is truly gone.
class _StartSheet extends StatefulWidget {
  final String initialName;
  final String hint;

  const _StartSheet({required this.initialName, required this.hint});

  @override
  State<_StartSheet> createState() => _StartSheetState();
}

class _StartSheetState extends State<_StartSheet> {
  late final _name = TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      await showMessage(
        context,
        title: context.l10n.hrCheckDetails,
        message: context.l10n.hrReviewNeedsName,
      );
      return;
    }
    if (!mounted) return;
    Navigator.pop(context, _name.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
                      l10n.hrReviewStart,
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
                placeholder: l10n.hrReviewName,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6.resolveFrom(context),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.hint,
                style: TextStyle(
                  fontSize: 12.5,
                  color: CupertinoColors.systemGrey.resolveFrom(context),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

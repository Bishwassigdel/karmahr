import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../domain/org_chart.dart';
import '../../l10n/l10n.dart';
import '../../state/audit_log_state.dart';
import '../../state/employee_records_state.dart';
import '../../theme/app_colors.dart';
import '../apps/widgets/status_badge.dart';
import '../apps/widgets/ui_kit.dart';
import 'hr_employee_detail_screen.dart';
import 'hr_employee_form_screen.dart';

enum _StatusFilter { active, inactive, all }

/// HR > Employees: everyone in the company, searchable, with Add.
class HrEmployeesScreen extends StatefulWidget {
  const HrEmployeesScreen({super.key});

  @override
  State<HrEmployeesScreen> createState() => _HrEmployeesScreenState();
}

class _HrEmployeesScreenState extends State<HrEmployeesScreen> {
  String _query = '';
  _StatusFilter _filter = _StatusFilter.active;

  // Org chart instead of the list.
  var _orgChart = false;

  List<EmployeeRecord> _visible(List<EmployeeRecord> all) {
    final q = _query.trim().toLowerCase();
    return all.where((r) {
      final statusOk = switch (_filter) {
        _StatusFilter.active => r.isActive,
        _StatusFilter.inactive => !r.isActive,
        _StatusFilter.all => true,
      };
      if (!statusOk) return false;
      if (q.isEmpty) return true;
      return r.name.toLowerCase().contains(q) ||
          r.jobTitle.toLowerCase().contains(q) ||
          r.department.toLowerCase().contains(q) ||
          r.id.toLowerCase().contains(q);
    }).toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  void _open(Widget screen) {
    Navigator.push(context, CupertinoPageRoute(builder: (_) => screen));
  }

  Future<void> _import() async {
    final text = await showCupertinoModalPopup<String>(
      context: context,
      builder: (_) => const _ImportSheet(),
    );
    if (text == null || !mounted) return;
    final l10n = context.l10n;

    if (text.trim().isEmpty) {
      await showMessage(
        context,
        title: l10n.hrImportResult,
        message: l10n.hrImportNothing,
      );
      return;
    }

    final result = context.read<EmployeeRecordsState>().importCsv(text);
    if (result.added > 0) {
      logAudit(
        context,
        AuditAction.employeesImported,
        l10n.hrImportAdded(result.added),
      );
    }

    String reason(ImportProblem p) => switch (p) {
      ImportProblem.columns => l10n.hrImportBadColumns,
      ImportProblem.name => l10n.hrErrName,
      ImportProblem.job => l10n.hrErrJob,
      ImportProblem.email => l10n.hrErrEmail,
      ImportProblem.phone => l10n.hrErrPhone,
      ImportProblem.salary => l10n.hrErrSalary,
    };
    final lines = [
      l10n.hrImportAdded(result.added),
      if (result.skipped.isNotEmpty) ...[
        '',
        l10n.hrImportSkipped(result.skipped.length),
        for (final s in result.skipped)
          l10n.hrImportLine(s.line, reason(s.problem)),
      ],
    ];
    if (!mounted) return;
    await showMessage(
      context,
      title: l10n.hrImportResult,
      message: lines.join('\n'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);
    final visible = _visible(context.watch<EmployeeRecordsState>().records);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoSearchTextField(
                      placeholder: l10n.hrSearchEmployees,
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                  const SizedBox(width: 4),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    minimumSize: Size.zero,
                    onPressed: () => setState(() => _orgChart = !_orgChart),
                    child: Icon(
                      _orgChart
                          ? CupertinoIcons.list_bullet
                          : CupertinoIcons.person_3,
                      semanticLabel: _orgChart
                          ? l10n.hrShowList
                          : l10n.hrShowOrgChart,
                    ),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    minimumSize: Size.zero,
                    onPressed: _import,
                    child: Icon(
                      CupertinoIcons.arrow_down_doc,
                      semanticLabel: l10n.hrImportEmployees,
                    ),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    minimumSize: Size.zero,
                    onPressed: () => _open(const HrEmployeeFormScreen()),
                    child: Icon(
                      CupertinoIcons.person_add,
                      semanticLabel: l10n.hrAddEmployee,
                    ),
                  ),
                ],
              ),
            ),
            if (_orgChart)
              Expanded(
                child: _OrgChartView(
                  people: context.watch<EmployeeRecordsState>().active,
                  onOpen: (id) => _open(HrEmployeeDetailScreen(employeeId: id)),
                ),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoSlidingSegmentedControl<_StatusFilter>(
                    groupValue: _filter,
                    onValueChanged: (f) {
                      if (f != null) setState(() => _filter = f);
                    },
                    children: {
                      _StatusFilter.active: Text(l10n.hrFilterActive),
                      _StatusFilter.inactive: Text(l10n.hrFilterInactive),
                      _StatusFilter.all: Text(l10n.filterAll),
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.hrEmployeeCount(visible.length),
                    style: TextStyle(fontSize: 12.5, color: subtle),
                  ),
                ),
              ),
              Expanded(
                child: visible.isEmpty
                    ? Center(
                        child: Text(
                          l10n.hrNoEmployeesFound,
                          style: TextStyle(color: subtle),
                        ),
                      )
                    : ListView(
                        children: [
                          CupertinoListSection.insetGrouped(
                            children: [
                              for (final r in visible)
                                CupertinoListTile(
                                  leading: InitialsAvatar(
                                    initials: r.initials,
                                    size: 36,
                                  ),
                                  leadingSize: 36,
                                  title: Text(
                                    r.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    '${r.jobTitle} · ${r.department}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  additionalInfo: r.isActive
                                      ? null
                                      : TileInfoBox(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: StatusBadge(
                                              label: l10n.hrFilterInactive,
                                              color: CupertinoColors.systemGrey,
                                            ),
                                          ),
                                        ),
                                  trailing: const CupertinoListTileChevron(),
                                  onTap: () => _open(
                                    HrEmployeeDetailScreen(employeeId: r.id),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The reporting structure, indented by level.
class _OrgChartView extends StatelessWidget {
  final List<EmployeeRecord> people;
  final void Function(String employeeId) onOpen;

  const _OrgChartView({required this.people, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);
    final nodes = buildOrgChart(people);

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      children: [
        for (final n in nodes)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onOpen(n.person.id),
            child: Padding(
              // Each level steps in, but never so far that it can't fit.
              padding: EdgeInsets.only(
                left: (n.depth * 22.0).clamp(0.0, 110.0),
                top: 6,
                bottom: 6,
              ),
              child: Row(
                children: [
                  if (n.depth > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        CupertinoIcons.arrow_turn_down_right,
                        size: 14,
                        color: subtle,
                      ),
                    ),
                  InitialsAvatar(initials: n.person.initials, size: 36),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n.person.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          n.directReports == 0
                              ? n.person.jobTitle
                              : '${n.person.jobTitle} · '
                                    '${l10n.hrDirectReports(n.directReports)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.5, color: subtle),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Paste or type rows to add many people at once. Owns its controller, so
/// it is disposed only when the sheet is truly gone.
class _ImportSheet extends StatefulWidget {
  const _ImportSheet();

  @override
  State<_ImportSheet> createState() => _ImportSheetState();
}

class _ImportSheetState extends State<_ImportSheet> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
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
                      l10n.hrImportEmployees,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context, _text.text),
                    child: Text(l10n.hrImportAction),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.hrImportHint,
                style: TextStyle(
                  fontSize: 12.5,
                  color: CupertinoColors.systemGrey.resolveFrom(context),
                ),
              ),
              const SizedBox(height: 10),
              CupertinoTextField(
                controller: _text,
                autofocus: true,
                minLines: 6,
                maxLines: 10,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6.resolveFrom(context),
                  borderRadius: BorderRadius.circular(12),
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

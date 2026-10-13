import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../data/company_demo.dart';
import '../../l10n/l10n.dart';
import '../apps/widgets/ui_kit.dart';
import 'owner_person_screen.dart';

/// "Sagar Rai" -> "SR"
String initialsOf(String name) => name
    .trim()
    .split(RegExp(r'\s+'))
    .where((w) => w.isNotEmpty)
    .take(2)
    .map((w) => w[0].toUpperCase())
    .join();

/// A page around [OwnerPeopleScreen], for when it is opened from a
/// department or an alert rather than being a tab.
class OwnerPeoplePage extends StatelessWidget {
  final String? initialDeptId;
  final String? initialBranchId;

  const OwnerPeoplePage({super.key, this.initialDeptId, this.initialBranchId});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(context.l10n.ownerSecPeople),
      ),
      child: SafeArea(
        child: OwnerPeopleScreen(
          initialDeptId: initialDeptId,
          initialBranchId: initialBranchId,
        ),
      ),
    );
  }
}

/// Executive > People: everyone in the (demo) company, searchable and
/// filterable by department and branch. A long list, so it is built as you scroll.
class OwnerPeopleScreen extends StatefulWidget {
  final String? initialDeptId;
  final String? initialBranchId;

  const OwnerPeopleScreen({
    super.key,
    this.initialDeptId,
    this.initialBranchId,
  });

  @override
  State<OwnerPeopleScreen> createState() => _OwnerPeopleScreenState();
}

class _OwnerPeopleScreenState extends State<OwnerPeopleScreen> {
  var _query = '';
  late String? _deptId = widget.initialDeptId;
  late String? _branchId = widget.initialBranchId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.read<CompanyDemo>();
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);

    final q = _query.trim().toLowerCase();
    final shown =
        c
            .peopleIn(deptId: _deptId, branchId: _branchId)
            .where(
              (p) =>
                  q.isEmpty ||
                  p.name.toLowerCase().contains(q) ||
                  p.jobTitle.toLowerCase().contains(q),
            )
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: CupertinoSearchTextField(
                      placeholder: l10n.ownerSearchPeople,
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                  CupertinoListSection.insetGrouped(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    children: [
                      FormRow(
                        label: l10n.ownerDepartmentLabel,
                        value: _deptId == null
                            ? l10n.ownerAllDepartments
                            : c.deptById(_deptId!).name,
                        onTap: () async {
                          final picked = await pickFromList<String?>(
                            context,
                            items: [null, for (final d in c.depts) d.id],
                            initial: _deptId,
                            label: (id) => id == null
                                ? l10n.ownerAllDepartments
                                : c.deptById(id).name,
                          );
                          if (mounted) setState(() => _deptId = picked);
                        },
                      ),
                      FormRow(
                        label: l10n.ownerBranchLabel,
                        value: _branchId == null
                            ? l10n.ownerAllBranches
                            : c.branchById(_branchId!).name,
                        onTap: () async {
                          final picked = await pickFromList<String?>(
                            context,
                            items: [null, for (final b in c.branches) b.id],
                            initial: _branchId,
                            label: (id) => id == null
                                ? l10n.ownerAllBranches
                                : c.branchById(id).name,
                          );
                          if (mounted) setState(() => _branchId = picked);
                        },
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 6),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.hrEmployeeCount(shown.length),
                        style: TextStyle(fontSize: 12.5, color: subtle),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (shown.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    l10n.ownerNoPeople,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: subtle),
                  ),
                ),
              )
            else
              SliverList.builder(
                itemCount: shown.length,
                itemBuilder: (context, i) {
                  final p = shown[i];
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => OwnerPersonScreen(personId: p.id),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 7,
                      ),
                      child: Row(
                        children: [
                          InitialsAvatar(
                            initials: initialsOf(p.name),
                            size: 38,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${p.jobTitle} · ${c.deptById(p.deptId).name}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: subtle,
                                  ),
                                ),
                                Text(
                                  c.branchById(p.branchId).name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12, color: subtle),
                                ),
                              ],
                            ),
                          ),
                          const CupertinoListTileChevron(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../state/audit_log_state.dart';
import '../../state/employee_records_state.dart';
import '../../state/teams_state.dart';
import '../../theme/app_colors.dart';
import '../apps/widgets/status_badge.dart';
import '../apps/widgets/ui_kit.dart';

/// HR > Teams: make teams, choose who is in them and who leads each one.
class HrTeamsScreen extends StatelessWidget {
  const HrTeamsScreen({super.key});

  /// The head's name, or null when the team has none or its head has been
  /// deactivated (someone who has left can't lead a team).
  static String? _headName(EmployeeRecordsState records, Team team) {
    if (team.headId.isEmpty) return null;
    final head = records.byId(team.headId);
    return head != null && head.isActive ? head.name : null;
  }

  Future<void> _create(BuildContext context) async {
    final l10n = context.l10n;
    final name = await _askName(context, title: l10n.hrNewTeam);
    if (name == null || !context.mounted) return;
    final team = context.read<TeamsState>().create(name);
    if (team == null) {
      await showMessage(
        context,
        title: l10n.hrCheckDetails,
        message: l10n.hrTeamNameProblem,
      );
      return;
    }
    logAudit(context, AuditAction.teamCreated, team.name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);
    final teams = context.watch<TeamsState>().teams;
    final records = context.watch<EmployeeRecordsState>();

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CupertinoButton.filled(
                onPressed: () => _create(context),
                child: Text(l10n.hrNewTeam),
              ),
            ),
            if (teams.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Text(
                  l10n.hrTeamsEmpty,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: subtle),
                ),
              )
            else
              CupertinoListSection.insetGrouped(
                children: [
                  for (final t in teams)
                    CupertinoListTile(
                      leading: const Icon(CupertinoIcons.person_3_fill),
                      title: Text(
                        t.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${l10n.hrTeamMemberCount(t.memberIds.length)} · '
                        '${_headName(records, t) ?? l10n.hrNoHead}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => HrTeamDetailScreen(teamId: t.id),
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

/// One team: its members, its head, and the actions to change them.
class HrTeamDetailScreen extends StatelessWidget {
  final String teamId;

  const HrTeamDetailScreen({super.key, required this.teamId});

  Future<void> _rename(BuildContext context, Team team) async {
    final l10n = context.l10n;
    final name = await _askName(
      context,
      title: l10n.hrRenameTeam,
      initial: team.name,
    );
    if (name == null || !context.mounted) return;
    if (context.read<TeamsState>().rename(team.id, name)) {
      logAudit(context, AuditAction.teamUpdated, name);
    } else {
      await showMessage(
        context,
        title: l10n.hrCheckDetails,
        message: l10n.hrTeamNameProblem,
      );
    }
  }

  Future<void> _addMember(BuildContext context, Team team) async {
    final l10n = context.l10n;
    final candidates = [
      for (final r in context.read<EmployeeRecordsState>().active)
        if (!team.hasMember(r.id)) r,
    ];
    if (candidates.isEmpty) {
      await showMessage(
        context,
        title: l10n.hrAddMember,
        message: l10n.hrNoOneToAdd,
      );
      return;
    }
    final picked = await pickFromList<EmployeeRecord>(
      context,
      items: candidates,
      label: (r) => r.name,
    );
    if (picked == null || !context.mounted) return;
    if (context.read<TeamsState>().addMember(team.id, picked.id)) {
      logAudit(context, AuditAction.teamUpdated, team.name);
    }
  }

  Future<void> _memberActions(
    BuildContext context,
    Team team,
    EmployeeRecord person,
  ) async {
    final l10n = context.l10n;
    final teams = context.read<TeamsState>();
    final isHead = team.headId == person.id;
    final action = await showCupertinoModalPopup<String>(
      context: context,
      builder: (sheet) => CupertinoActionSheet(
        title: Text(person.name),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(sheet, isHead ? 'clear' : 'head'),
            child: Text(isHead ? l10n.hrRemoveHead : l10n.hrMakeHead),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(sheet, 'remove'),
            child: Text(l10n.hrRemoveFromTeam),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(sheet),
          child: Text(l10n.cancel),
        ),
      ),
    );
    if (action == null || !context.mounted) return;

    switch (action) {
      case 'head':
        if (teams.setHead(team.id, person.id)) {
          logAudit(context, AuditAction.teamUpdated, team.name);
        } else {
          // A person can lead only one team.
          final leads = teams.teamHeadedBy(person.id);
          await showMessage(
            context,
            title: l10n.hrMakeHead,
            message: l10n.hrHeadElsewhere(person.name, leads?.name ?? ''),
          );
        }
      case 'clear':
        teams.clearHead(team.id);
        logAudit(context, AuditAction.teamUpdated, team.name);
      case 'remove':
        if (teams.removeMember(team.id, person.id)) {
          logAudit(context, AuditAction.teamUpdated, team.name);
        }
    }
  }

  Future<void> _delete(BuildContext context, Team team) async {
    final l10n = context.l10n;
    final yes = await confirm(
      context,
      title: l10n.hrDeleteTeamTitle(team.name),
      message: l10n.hrDeleteTeamBody,
      confirmLabel: l10n.hrDeleteTeam,
      destructive: true,
    );
    if (!yes || !context.mounted) return;
    context.read<TeamsState>().delete(team.id);
    logAudit(context, AuditAction.teamDeleted, team.name);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final team = context.watch<TeamsState>().byId(teamId);
    final records = context.watch<EmployeeRecordsState>();

    // The team was deleted while this page was open.
    if (team == null) {
      return const CupertinoPageScaffold(child: SizedBox.shrink());
    }

    final subtle = CupertinoColors.systemGrey.resolveFrom(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(team.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: () => _rename(context, team),
          child: Text(l10n.hrRenameTeam),
        ),
      ),
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              children: [
                const SizedBox(height: 12),
                CupertinoListSection.insetGrouped(
                  header: Text(
                    l10n.hrTeamMemberCount(team.memberIds.length).toUpperCase(),
                  ),
                  footer: Text(l10n.hrTeamHint),
                  children: [
                    for (final id in team.memberIds)
                      if (records.byId(id) case final person?)
                        CupertinoListTile(
                          leading: InitialsAvatar(
                            initials: person.initials,
                            size: 36,
                          ),
                          leadingSize: 36,
                          title: Text(
                            person.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            person.jobTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          additionalInfo: team.headId == person.id
                              ? TileInfoBox(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: StatusBadge(
                                      label: l10n.hrTeamHead,
                                      color: AppColors.karmaRed,
                                    ),
                                  ),
                                )
                              : person.isActive
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
                          onTap: () => _memberActions(context, team, person),
                        ),
                    CupertinoListTile(
                      leading: const Icon(CupertinoIcons.person_add),
                      title: Text(l10n.hrAddMember),
                      onTap: () => _addMember(context, team),
                    ),
                  ],
                ),
                if (team.headId.isEmpty && team.memberIds.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      l10n.hrTeamNeedsHead,
                      style: TextStyle(fontSize: 13, color: subtle),
                    ),
                  ),
                CupertinoListSection.insetGrouped(
                  children: [
                    CupertinoListTile(
                      leading: const Icon(
                        CupertinoIcons.delete,
                        color: CupertinoColors.destructiveRed,
                      ),
                      title: Text(
                        l10n.hrDeleteTeam,
                        style: const TextStyle(
                          color: CupertinoColors.destructiveRed,
                        ),
                      ),
                      onTap: () => _delete(context, team),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Asks for a team name. Returns null if cancelled. Owns its controller so
/// it is disposed only when the dialog is truly gone.
Future<String?> _askName(
  BuildContext context, {
  required String title,
  String initial = '',
}) {
  return showCupertinoDialog<String>(
    context: context,
    builder: (_) => _NameDialog(title: title, initial: initial),
  );
}

class _NameDialog extends StatefulWidget {
  final String title;
  final String initial;

  const _NameDialog({required this.title, required this.initial});

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final _name = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CupertinoAlertDialog(
      title: Text(widget.title),
      content: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: CupertinoTextField(
          controller: _name,
          autofocus: true,
          placeholder: l10n.hrTeamName,
        ),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context, _name.text),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

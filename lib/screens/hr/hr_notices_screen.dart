import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../data/notices_data.dart';
import '../../l10n/l10n.dart';
import '../../state/audit_log_state.dart';
import '../../state/notices_state.dart';
import '../../theme/app_colors.dart';
import '../apps/widgets/status_badge.dart';
import '../apps/widgets/ui_kit.dart';
import 'hr_notice_form_screen.dart';

/// A notice category's translated name. The category itself is stored as
/// the plain English word ('Urgent'); only what HR reads is translated.
String noticeCategoryLabel(AppLocalizations l10n, String category) {
  return switch (category) {
    'Urgent' => l10n.hrCatUrgent,
    'Policy' => l10n.hrCatPolicy,
    'Holiday' => l10n.hrCatHoliday,
    _ => l10n.hrCatGeneral,
  };
}

Color noticeCategoryColor(String category) => switch (category) {
  'Urgent' => CupertinoColors.systemRed,
  'Policy' => CupertinoColors.systemPurple,
  'Holiday' => CupertinoColors.systemGreen,
  _ => CupertinoColors.systemBlue,
};

/// HR > Notices: what employees see in their Notices, with publish/delete.
class HrNoticesScreen extends StatelessWidget {
  const HrNoticesScreen({super.key});

  Future<void> _delete(BuildContext context, Notice notice) async {
    final l10n = context.l10n;
    final ok = await confirm(
      context,
      title: l10n.hrDeleteNoticeTitle(notice.title),
      message: l10n.hrDeleteNoticeMessage,
      confirmLabel: l10n.hrDeleteAction,
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    context.read<NoticesState>().remove(notice);
    logAudit(context, AuditAction.noticeDeleted, notice.title);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);
    final notices = context.watch<NoticesState>().notices;

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
                onPressed: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => const HrNoticeFormScreen(),
                  ),
                ),
                child: Text(l10n.hrNewNotice),
              ),
            ),
            if (notices.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.hrNoNotices,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: subtle),
                ),
              )
            else
              CupertinoListSection.insetGrouped(
                footer: Text(l10n.hrNoticesFooter),
                children: [
                  for (final n in notices)
                    CupertinoListTile(
                      title: Text(
                        n.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            StatusBadge(
                              label: noticeCategoryLabel(l10n, n.category),
                              color: noticeCategoryColor(n.category),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                n.date,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        onPressed: () => _delete(context, n),
                        child: Icon(
                          CupertinoIcons.trash,
                          size: 20,
                          color: AppColors.karmaRed,
                          semanticLabel: l10n.hrDeleteNotice,
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

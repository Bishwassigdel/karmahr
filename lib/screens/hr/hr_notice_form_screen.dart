import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../state/audit_log_state.dart';
import '../../state/notices_state.dart';
import '../apps/widgets/ui_kit.dart';
import 'hr_notices_screen.dart';

/// Write and publish a notice.
class HrNoticeFormScreen extends StatefulWidget {
  const HrNoticeFormScreen({super.key});

  @override
  State<HrNoticeFormScreen> createState() => _HrNoticeFormScreenState();
}

class _HrNoticeFormScreenState extends State<HrNoticeFormScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  String _category = noticeCategories.first;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    final l10n = context.l10n;
    if (_title.text.trim().isEmpty) {
      return showMessage(
        context,
        title: l10n.hrCheckDetails,
        message: l10n.hrNoticeNeedsTitle,
      );
    }
    if (_body.text.trim().isEmpty) {
      return showMessage(
        context,
        title: l10n.hrCheckDetails,
        message: l10n.hrNoticeNeedsBody,
      );
    }
    context.read<NoticesState>().publish(
      title: _title.text,
      category: _category,
      body: _body.text,
    );
    logAudit(context, AuditAction.noticePublished, _title.text.trim());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fieldBox = BoxDecoration(
      color: CupertinoColors.systemGrey6.resolveFrom(context),
      borderRadius: BorderRadius.circular(12),
    );

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(l10n.hrNewNotice),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: _publish,
          child: Text(
            l10n.hrPublish,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                CupertinoTextField(
                  controller: _title,
                  placeholder: l10n.hrNoticeTitleField,
                  padding: const EdgeInsets.all(14),
                  decoration: fieldBox,
                ),
                const SizedBox(height: 12),
                CupertinoListSection.insetGrouped(
                  margin: EdgeInsets.zero,
                  children: [
                    FormRow(
                      label: l10n.hrNoticeCategory,
                      value: noticeCategoryLabel(l10n, _category),
                      onTap: () async {
                        final picked = await pickFromList<String>(
                          context,
                          items: noticeCategories,
                          initial: _category,
                          label: (c) => noticeCategoryLabel(l10n, c),
                        );
                        if (picked != null && mounted) {
                          setState(() => _category = picked);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CupertinoTextField(
                  controller: _body,
                  placeholder: l10n.hrNoticeBodyField,
                  minLines: 6,
                  maxLines: 12,
                  padding: const EdgeInsets.all(14),
                  decoration: fieldBox,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

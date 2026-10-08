import 'package:flutter/cupertino.dart';

import '../../l10n/l10n.dart';
import '../../state/employee_documents_state.dart';
import '../../theme/app_colors.dart';
import '../apps/widgets/ui_kit.dart';

/// A document type's translated name.
String docTypeLabel(AppLocalizations l10n, DocType type) => switch (type) {
  DocType.contract => l10n.hrDocContract,
  DocType.citizenship => l10n.hrDocCitizenship,
  DocType.pan => l10n.hrDocPan,
  DocType.workPermit => l10n.hrDocPermit,
  DocType.certificate => l10n.hrDocCertificate,
  DocType.other => l10n.hrDocOther,
};

IconData docTypeIcon(DocType type) => switch (type) {
  DocType.contract => CupertinoIcons.doc_text_fill,
  DocType.citizenship => CupertinoIcons.person_crop_rectangle_fill,
  DocType.pan => CupertinoIcons.creditcard_fill,
  DocType.workPermit => CupertinoIcons.checkmark_seal_fill,
  DocType.certificate => CupertinoIcons.rosette,
  DocType.other => CupertinoIcons.folder_fill,
};

/// "Expired", "Expires in 12 days", or "No expiry".
String docExpiryText(AppLocalizations l10n, EmployeeDocument d, DateTime now) {
  final left = d.daysLeft(now);
  if (left == null) return l10n.hrDocNoExpiry;
  if (left < 0) return l10n.hrDocExpired;
  return l10n.hrDocExpiresIn(left);
}

/// The result of the sheet.
typedef NewDocument = ({String title, DocType type, DateTime? expiresOn});

/// Bottom sheet: name, type and an optional expiry date. Owns its text
/// controller, so it is disposed only when the sheet is truly gone.
class HrDocumentSheet extends StatefulWidget {
  const HrDocumentSheet({super.key});

  @override
  State<HrDocumentSheet> createState() => _HrDocumentSheetState();
}

class _HrDocumentSheetState extends State<HrDocumentSheet> {
  final _name = TextEditingController();
  DocType _type = DocType.contract;
  DateTime? _expiresOn;

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
        message: context.l10n.hrDocNeedsName,
      );
      return;
    }
    if (!mounted) return;
    Navigator.pop<NewDocument>(context, (
      title: _name.text.trim(),
      type: _type,
      expiresOn: _expiresOn,
    ));
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
                      l10n.hrAddDocument,
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
                placeholder: l10n.hrDocName,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6.resolveFrom(context),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 10),
              CupertinoListSection.insetGrouped(
                margin: EdgeInsets.zero,
                children: [
                  FormRow(
                    label: l10n.hrDocType,
                    value: docTypeLabel(l10n, _type),
                    onTap: () async {
                      final picked = await pickFromList<DocType>(
                        context,
                        items: DocType.values,
                        initial: _type,
                        label: (t) => docTypeLabel(l10n, t),
                      );
                      if (picked != null && mounted) {
                        setState(() => _type = picked);
                      }
                    },
                  ),
                  FormRow(
                    label: l10n.hrDocExpires,
                    value: _expiresOn == null
                        ? l10n.hrDocNoExpiry
                        : '${shortDate(_expiresOn!)}, ${_expiresOn!.year}',
                    placeholder: _expiresOn == null,
                    onTap: () async {
                      final today = dateOnly(DateTime.now());
                      final picked = await pickDate(
                        context,
                        initial: _expiresOn ?? today,
                        minimum: DateTime(today.year - 1),
                        maximum: DateTime(today.year + 15),
                      );
                      if (picked != null && mounted) {
                        setState(() => _expiresOn = picked);
                      }
                    },
                  ),
                ],
              ),
              if (_expiresOn != null)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => setState(() => _expiresOn = null),
                  child: Text(l10n.hrDocNoExpiry),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// Document Wallet: the employee's own PAN, citizenship, contract and
// certificates. When App Lock is on, the wallet asks for Face ID / Touch
// ID / passcode EVERY time it opens — being past the app's launch lock
// isn't enough for ID documents, since a colleague might be holding your
// already-unlocked phone.

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../state/app_lock_state.dart';
import '../state/document_wallet_state.dart';
import '../theme/app_colors.dart';
import 'apps/widgets/photo_picker.dart';
import 'apps/widgets/ui_kit.dart';

class DocumentWalletScreen extends StatefulWidget {
  const DocumentWalletScreen({super.key});

  @override
  State<DocumentWalletScreen> createState() => _DocumentWalletScreenState();
}

class _DocumentWalletScreenState extends State<DocumentWalletScreen> {
  bool _unlocked = false;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    final lock = context.read<AppLockState>();
    if (lock.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
    } else {
      _unlocked = true;
    }
  }

  Future<void> _unlock() async {
    setState(() => _checking = true);
    final ok = await context.read<AppLockState>().authenticate(
      reason: 'Unlock your Document Wallet',
    );
    if (!mounted) return;
    setState(() {
      _checking = false;
      _unlocked = ok;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lockEnabled = context.watch<AppLockState>().enabled;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Document Wallet'),
        trailing: _unlocked
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                onPressed: () => Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (_) => const AddDocumentScreen()),
                ),
                child: const Icon(CupertinoIcons.add),
              )
            : null,
      ),
      child: SafeArea(
        child: _unlocked
            ? _WalletList(lockEnabled: lockEnabled)
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.lock_shield_fill,
                        size: 56,
                        color: AppColors.karmaRed,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Your documents are locked',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _checking
                          ? const CupertinoActivityIndicator()
                          : CupertinoButton.filled(
                              onPressed: _unlock,
                              child: const Text('Unlock'),
                            ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _WalletList extends StatelessWidget {
  final bool lockEnabled;

  const _WalletList({required this.lockEnabled});

  @override
  Widget build(BuildContext context) {
    final docs = context.watch<DocumentWalletState>().documents;
    return ListView(
      children: [
        if (!lockEnabled)
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: NoteBanner(
              icon: CupertinoIcons.lock_open,
              text:
                  'Turn on App Lock in Settings so this wallet asks for Face '
                  'ID or your passcode before opening.',
            ),
          ),
        CupertinoListSection.insetGrouped(
          header: const Text('MY DOCUMENTS'),
          footer: const Text(
            'Stored only on this phone. Numbers are hidden except the last '
            '4 digits.',
          ),
          children: docs.isEmpty
              ? const [
                  CupertinoListTile(
                    title: Text('No documents yet — tap + to add.'),
                  ),
                ]
              : [
                  for (final d in docs)
                    CupertinoListTile(
                      leading: d.imagePath != null
                          ? PhotoThumb(path: d.imagePath!, size: 32)
                          : Icon(walletDocTypeIcon(d.type)),
                      title: Text(d.title),
                      subtitle: Text(
                        [
                          walletDocTypeLabel(d.type),
                          if (d.number != null) maskIdNumber(d.number!),
                        ].join(' · '),
                      ),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () => _showDocument(context, d),
                    ),
                ],
        ),
      ],
    );
  }

  void _showDocument(BuildContext context, WalletDocument doc) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: Text(doc.title),
        message: Column(
          children: [
            Text(walletDocTypeLabel(doc.type)),
            if (doc.number != null) ...[
              const SizedBox(height: 4),
              // Full number only inside this deliberate "open" view.
              Text('Number: ${doc.number}'),
            ],
            if (doc.imagePath != null) ...[
              const SizedBox(height: 12),
              PhotoThumb(path: doc.imagePath!, size: 200),
            ],
          ],
        ),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(sheetContext);
              final ok = await confirm(
                context,
                title: 'Delete document?',
                message: '"${doc.title}" will be removed from this phone.',
                confirmLabel: 'Delete',
                destructive: true,
              );
              if (ok && context.mounted) {
                context.read<DocumentWalletState>().remove(doc.id);
              }
            },
            child: const Text('Delete'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(sheetContext),
          child: const Text('Close'),
        ),
      ),
    );
  }
}

class AddDocumentScreen extends StatefulWidget {
  const AddDocumentScreen({super.key});

  @override
  State<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen> {
  final _title = TextEditingController();
  final _number = TextEditingController();
  WalletDocType _type = WalletDocType.citizenship;
  String? _photo;

  @override
  void dispose() {
    _title.dispose();
    _number.dispose();
    super.dispose();
  }

  void _save() {
    final title = _title.text.trim().isEmpty
        ? walletDocTypeLabel(_type)
        : _title.text.trim();
    if (_photo == null && _number.text.trim().isEmpty) {
      showMessage(
        context,
        title: 'Almost there',
        message: 'Add a photo of the document or its number (or both).',
      );
      return;
    }
    context.read<DocumentWalletState>().add(
      type: _type,
      title: title,
      number: _number.text,
      imagePath: _photo,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: CupertinoColors.systemGrey6.resolveFrom(context),
      borderRadius: BorderRadius.circular(10),
    );
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Add Document')),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              children: [
                FormRow(
                  label: 'Type',
                  value: walletDocTypeLabel(_type),
                  onTap: () async {
                    final picked = await pickFromList(
                      context,
                      items: WalletDocType.values,
                      label: walletDocTypeLabel,
                      initial: _type,
                    );
                    if (picked != null && mounted) setState(() => _type = picked);
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CupertinoTextField(
                    controller: _title,
                    placeholder: 'Name (default: ${walletDocTypeLabel(_type)})',
                    padding: const EdgeInsets.all(12),
                    decoration: decoration,
                  ),
                  const SizedBox(height: 10),
                  CupertinoTextField(
                    controller: _number,
                    placeholder: 'Document number (optional)',
                    padding: const EdgeInsets.all(12),
                    decoration: decoration,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (_photo != null) ...[
                        PhotoThumb(path: _photo!),
                        const SizedBox(width: 12),
                      ],
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          final path = await pickPhoto(context);
                          if (path != null && mounted) setState(() => _photo = path);
                        },
                        child: Text(
                          _photo == null ? 'Add photo' : 'Replace photo',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: AppColors.karmaRed,
                      borderRadius: BorderRadius.circular(12),
                      onPressed: _save,
                      child: const Text(
                        'Save',
                        style: TextStyle(color: CupertinoColors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

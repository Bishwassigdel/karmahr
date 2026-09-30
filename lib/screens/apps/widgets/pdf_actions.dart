// "Share PDF" / "Print" sheet, shared by the payslip and the salary
// certificate. Both hand off to the OS: Share opens the system share
// sheet (Mail, WhatsApp, Viber, Files...), Print opens the native print
// dialog — which on iOS also has "Save to Files". No Material widgets
// involved, so this works inside the app's all-Cupertino tree.

import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:printing/printing.dart';

void showPdfActions(
  BuildContext context, {
  required String title,
  required String filename,
  required Future<Uint8List> Function() build,
}) {
  showCupertinoModalPopup(
    context: context,
    builder: (sheetContext) => CupertinoActionSheet(
      title: Text(title),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(sheetContext);
            _run(context, () async {
              await Printing.sharePdf(bytes: await build(), filename: filename);
            });
          },
          child: const Text('Share PDF'),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(sheetContext);
            _run(context, () async {
              await Printing.layoutPdf(
                onLayout: (_) => build(),
                name: filename,
              );
            });
          },
          child: const Text('Print'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(sheetContext),
        child: const Text('Cancel'),
      ),
    ),
  );
}

Future<void> _run(BuildContext context, Future<void> Function() action) async {
  try {
    await action();
  } catch (_) {
    if (!context.mounted) return;
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text("Couldn't Open PDF"),
        content: const Text(
          'Sharing or printing isn\'t available right now. Please try '
          'again.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

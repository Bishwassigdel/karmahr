// "Take Photo / Choose from Library" — shared by expense receipts and the
// document wallet. Returns a local file path, or null if cancelled or
// unavailable. Failures (no camera on a simulator, permission denied)
// become a friendly message, never a crash.

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

import 'ui_kit.dart';

Future<String?> pickPhoto(BuildContext context) async {
  final source = await showCupertinoModalPopup<ImageSource>(
    context: context,
    builder: (sheetContext) => CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(sheetContext, ImageSource.camera),
          child: const Text('Take Photo'),
        ),
        CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(sheetContext, ImageSource.gallery),
          child: const Text('Choose from Library'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(sheetContext),
        child: const Text('Cancel'),
      ),
    ),
  );
  if (source == null) return null;

  try {
    // Downscaled on capture: a receipt doesn't need a 12 MP photo, and
    // smaller files keep the app's memory use (and a future upload) sane.
    final file = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 80,
    );
    return file?.path;
  } catch (_) {
    if (context.mounted) {
      await showMessage(
        context,
        title: source == ImageSource.camera
            ? "Couldn't Open Camera"
            : "Couldn't Open Photos",
        message:
            'Check that KarmaHR is allowed to use the camera and photos in '
            'your phone\'s Settings. (Simulators have no camera — use '
            'Choose from Library there.)',
      );
    }
    return null;
  }
}

/// A rounded thumbnail of a picked photo; shows a placeholder icon if the
/// file is gone (e.g. the OS cleared its temp folder).
class PhotoThumb extends StatelessWidget {
  final String path;
  final double size;

  const PhotoThumb({super.key, required this.path, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: kIsWeb
          // In a browser the picker returns a blob URL, not a file path,
          // and Image.file isn't supported there.
          ? Image.network(
              path,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: _placeholder,
            )
          : Image.file(
              File(path),
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: _placeholder,
            ),
    );
  }

  Widget _placeholder(BuildContext context, Object error, StackTrace? stack) {
    return Container(
      width: size,
      height: size,
      color: CupertinoColors.systemGrey5.resolveFrom(context),
      child: const Icon(CupertinoIcons.photo),
    );
  }
}

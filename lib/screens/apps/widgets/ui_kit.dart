// Small building blocks shared by the feature screens, so a dozen screens
// don't each carry their own copy of the same date picker, dialog, and
// card — and so they all behave the same way (e.g. every wheel picker
// commits only on Done, matching the rest of the app).

import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/calendar_data.dart';
import '../../../theme/app_colors.dart';

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// "Oct 2"
String shortDate(DateTime d) => '${adMonths[d.month - 1]} ${d.day}';

/// "Fri, Oct 2"
String dayDate(DateTime d) => '${_weekdays[d.weekday - 1]}, ${shortDate(d)}';

/// "9:30 AM"
String clockTime(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m ${d.hour < 12 ? 'AM' : 'PM'}';
}

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Rounded card with a bold title and an optional grey subtitle.
class SectionCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const SectionCard({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary.resolveFrom(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title!,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: TextStyle(fontSize: 12, color: subtle)),
          ],
          if (title != null || subtitle != null) const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// A tinted one-line-or-more callout: an icon and a message.
class NoteBanner extends StatelessWidget {
  final IconData icon;
  final String text;
  final CupertinoDynamicColor color;

  const NoteBanner({
    super.key,
    required this.icon,
    required this.text,
    this.color = CupertinoColors.systemOrange,
  });

  @override
  Widget build(BuildContext context) {
    final c = color.resolveFrom(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: c),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12.5, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class InitialsAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final Color? color;

  const InitialsAvatar({
    super.key,
    required this.initials,
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.karmaRed;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: c,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}

/// Right-hand text for a CupertinoListTile's `additionalInfo`, capped to
/// about a third of the screen and truncated.
///
/// CupertinoListTile gives `additionalInfo` its FULL natural width and
/// only shrinks the title — so any long value there (a Devanagari holiday
/// name, a date at large text size) pushes the row off the screen. Every
/// additionalInfo in the app should go through this or [TileInfoBox].
class TileInfo extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const TileInfo(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return TileInfoBox(
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.end,
        style: style,
      ),
    );
  }
}

/// The width cap behind [TileInfo], for non-text additionalInfo (e.g. an
/// amount stacked over a status).
class TileInfoBox extends StatelessWidget {
  final Widget child;

  const TileInfoBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.34,
      ),
      child: child,
    );
  }
}

/// A labelled, tappable form row (e.g. "Date  ·  Fri, Oct 2  >").
class FormRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool placeholder;

  const FormRow({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
    this.placeholder = false,
  });

  @override
  Widget build(BuildContext context) {
    final subtle = CupertinoColors.systemGrey.resolveFrom(context);
    return CupertinoListTile(
      title: Text(label),
      additionalInfo: TileInfo(
        value,
        style: TextStyle(color: placeholder ? subtle : null),
      ),
      trailing: onTap == null ? null : const CupertinoListTileChevron(),
      onTap: onTap,
    );
  }
}

Future<void> showMessage(
  BuildContext context, {
  required String title,
  required String message,
}) {
  return showCupertinoDialog<void>(
    context: context,
    builder: (dialogContext) => CupertinoAlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

/// Yes/No confirmation. Resolves true only if the user confirms.
Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  bool destructive = false,
}) async {
  final result = await showCupertinoDialog<bool>(
    context: context,
    builder: (dialogContext) => CupertinoAlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        CupertinoDialogAction(
          isDestructiveAction: destructive,
          isDefaultAction: !destructive,
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

// Bottom sheet with Cancel / Done over any picker — the Done-to-commit
// convention used by every picker in the app.
Future<bool> _pickerSheet(
  BuildContext context, {
  required Widget picker,
}) async {
  final result = await showCupertinoModalPopup<bool>(
    context: context,
    builder: (sheetContext) => Container(
      height: 300,
      color: AppColors.surface.resolveFrom(sheetContext),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  onPressed: () => Navigator.pop(sheetContext, false),
                  child: const Text('Cancel'),
                ),
                CupertinoButton(
                  onPressed: () => Navigator.pop(sheetContext, true),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            Expanded(child: picker),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

/// Date wheel; null if cancelled.
Future<DateTime?> pickDate(
  BuildContext context, {
  required DateTime initial,
  DateTime? minimum,
  DateTime? maximum,
}) async {
  var selected = dateOnly(initial);
  final done = await _pickerSheet(
    context,
    picker: CupertinoDatePicker(
      mode: CupertinoDatePickerMode.date,
      initialDateTime: selected,
      minimumDate: minimum == null ? null : dateOnly(minimum),
      maximumDate: maximum == null ? null : dateOnly(maximum),
      onDateTimeChanged: (d) => selected = dateOnly(d),
    ),
  );
  return done ? selected : null;
}

/// Wheel over [items]; null if cancelled.
Future<T?> pickFromList<T>(
  BuildContext context, {
  required List<T> items,
  required String Function(T) label,
  T? initial,
}) async {
  var index = initial == null
      ? 0
      : items.indexOf(initial).clamp(0, items.length - 1);
  final done = await _pickerSheet(
    context,
    picker: CupertinoPicker(
      itemExtent: 36,
      scrollController: FixedExtentScrollController(initialItem: index),
      onSelectedItemChanged: (i) => index = i,
      children: [for (final item in items) Center(child: Text(label(item)))],
    ),
  );
  return done ? items[index] : null;
}

/// Opens the phone dialer. Spaces/dashes are stripped so "+977 98..."
/// dials correctly; failure (e.g. a tablet with no phone) shows a message.
Future<void> callNumber(BuildContext context, String number) async {
  final uri = Uri(scheme: 'tel', path: number.replaceAll(RegExp(r'[\s-]'), ''));
  final opened = await launchUrl(uri);
  if (!opened && context.mounted) {
    await showMessage(
      context,
      title: "Can't Place Call",
      message: 'This device can\'t make phone calls. The number is $number.',
    );
  }
}

import 'package:flutter/cupertino.dart';

// A simple custom progress bar — Cupertino has no built-in one, and
// pulling in Material's LinearProgressIndicator would break the app's
// all-Cupertino look for one widget.
class ProgressBar extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final Color color;

  const ProgressBar({super.key, required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    final track = CupertinoColors.systemGrey5.resolveFrom(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 6,
        color: track,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(color: color),
        ),
      ),
    );
  }
}

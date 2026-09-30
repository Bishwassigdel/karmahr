// Shimmering placeholder cards shown while a list is loading — the
// "content-shaped" alternative to a bare spinner. A skeleton tells the
// user WHAT is coming (a list of cards) and roughly how much, so the
// real content landing in place feels like a reveal, not a jump.

import 'package:flutter/cupertino.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonList extends StatelessWidget {
  final int count;
  final double itemHeight;

  const SkeletonList({super.key, this.count = 4, this.itemHeight = 72});

  @override
  Widget build(BuildContext context) {
    // Resolved against context so the shimmer reads correctly in Dark
    // Mode too — the package's usual grey defaults are light-mode only
    // and glow far too brightly on a black background.
    final base = CupertinoColors.systemGrey5.resolveFrom(context);
    final highlight = CupertinoColors.systemGrey6.resolveFrom(context);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Column(
        children: [
          for (var i = 0; i < count; i++)
            Container(
              height: itemHeight,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: base,
                borderRadius: BorderRadius.circular(14),
              ),
              // Two "text line" bars inside each card — just enough
              // structure to read as a list row, not a solid block.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _bar(highlight, widthFactor: 0.55, height: 12),
                  const SizedBox(height: 8),
                  _bar(highlight, widthFactor: 0.8, height: 10),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _bar(
    Color color, {
    required double widthFactor,
    required double height,
  }) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

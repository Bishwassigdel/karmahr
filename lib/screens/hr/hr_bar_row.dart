import 'package:flutter/cupertino.dart';

import '../../theme/app_colors.dart';

/// A label, a count, and a bar sized against the largest in its group.
/// Used for headcount by department on Home and in Reports.
class HrBarRow extends StatelessWidget {
  final String name;
  final int count;
  final double fraction; // 0..1, relative to the largest in the group

  const HrBarRow({
    super.key,
    required this.name,
    required this.count,
    required this.fraction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(
                  height: 6,
                  color: CupertinoColors.systemGrey5.resolveFrom(context),
                ),
                FractionallySizedBox(
                  widthFactor: fraction.clamp(0.0, 1.0),
                  child: Container(height: 6, color: AppColors.karmaRed),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

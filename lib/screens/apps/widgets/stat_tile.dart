import 'package:flutter/cupertino.dart';

// A small "count + label" tile — used for Attendance's Present/Absent/
// Late/Half-day row and Tasks' Pending/In Progress/Completed row.
class StatTile extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color background;

  const StatTile({
    super.key,
    required this.label,
    required this.count,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

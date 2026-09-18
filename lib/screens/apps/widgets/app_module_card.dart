import 'package:flutter/cupertino.dart';

import '../../../theme/app_colors.dart';

// One tile in the Apps grid.
class AppModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  const AppModuleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // AppColors.surface/border are CupertinoDynamicColor — must be
    // resolved against the current context before use in a plain
    // Container, or they stay stuck on their light-mode value in Dark
    // Mode.
    final surface = AppColors.surface.resolveFrom(context);
    final border = AppColors.border.resolveFrom(context);
    final subtleTextColor = CupertinoColors.systemGrey.resolveFrom(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: subtleTextColor),
            ),
          ],
        ),
      ),
    );
  }
}

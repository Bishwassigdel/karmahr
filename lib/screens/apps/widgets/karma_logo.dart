import 'package:flutter/cupertino.dart';

import '../../../theme/app_colors.dart';

/// The KarmaHR logo, rounded, for the left of a navigation bar or a sidebar.
/// Falls back to an icon if the image can't load.
///
/// The source image is 450x450, so it stays sharp up to about 150 points.
class KarmaLogo extends StatelessWidget {
  /// 40 fits a navigation bar (44 points tall) with room to breathe.
  final double size;

  const KarmaLogo({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.25);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        // A hairline keeps the edge defined on light and dark backgrounds,
        // where a light logo would otherwise melt into the bar.
        border: Border.all(
          color: CupertinoColors.separator.resolveFrom(context),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Image.asset(
          'assets/images/logo.jpg',
          fit: BoxFit.cover,
          // The default filter looks soft when a large image is shrunk.
          filterQuality: FilterQuality.high,
          isAntiAlias: true,
          semanticLabel: 'KarmaHR',
          errorBuilder: (context, error, stackTrace) => Icon(
            CupertinoIcons.person_3_fill,
            color: AppColors.karmaRed,
            size: size * 0.6,
            semanticLabel: 'KarmaHR',
          ),
        ),
      ),
    );
  }
}

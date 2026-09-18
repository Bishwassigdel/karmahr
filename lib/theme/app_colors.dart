import 'package:flutter/cupertino.dart';

// Centralized color palette for KarmaHR.
//
// Most colors in Cupertino (systemGrey, systemGreen, etc.) already adapt
// to Dark Mode automatically — you don't need to touch those. This file
// only exists for the colors that WERE hardcoded (always white, always
// black) and needed a light + dark version defined explicitly.
//
// CupertinoDynamicColor.withBrightness lets ONE color name resolve to
// two different actual colors depending on the device's current
// brightness setting — Flutter picks the right one automatically
// wherever this color is used, no manual checking required.
class AppColors {
  // KarmaHR's brand red — deliberately the SAME in both light and dark
  // mode. Brand/accent colors usually don't flip; only neutral surface
  // and text colors need to.
  static const karmaRed = Color(0xFFC62828);

  // The screen's background, behind all cards/content.
  static final background = CupertinoDynamicColor.withBrightness(
    color: CupertinoColors.white,
    darkColor: const Color(0xFF000000),
  );

  // Card / container surfaces that sit ON TOP of the background —
  // e.g. the Attendance card, form fields' containers.
  static final surface = CupertinoDynamicColor.withBrightness(
    color: CupertinoColors.white,
    darkColor: const Color(0xFF1C1C1E),
  );

  // A slightly recessed surface — used for stat cards, input field fills
  // (previously the hardcoded 0xFFF7F7F7 / systemGrey6-style areas).
  static final surfaceSecondary = CupertinoDynamicColor.withBrightness(
    color: const Color(0xFFF7F7F7),
    darkColor: const Color(0xFF2C2C2E),
  );

  // Primary text — was hardcoded CupertinoColors.black in several places.
  static final textPrimary = CupertinoDynamicColor.withBrightness(
    color: CupertinoColors.black,
    darkColor: CupertinoColors.white,
  );

  // Subtle borders/dividers — was the hardcoded 0xFFEFEFEF everywhere.
  static final border = CupertinoDynamicColor.withBrightness(
    color: const Color(0xFFEFEFEF),
    darkColor: const Color(0xFF38383A),
  );
}

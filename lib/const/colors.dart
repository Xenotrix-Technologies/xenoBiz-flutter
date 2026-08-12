import 'package:flutter/material.dart';

/// Centralized application color palette following the XENO PALETTE specification.
abstract class AppColors {
  // XENO PALETTE Constants
  static const Color primaryBlue = Color(0xFF2563EB); // #2563EB Primary Blue
  static const Color deepNavy = Color(0xFF0F172A); // #0F172A Deep Navy
  static const Color darkBlueText = Color(0xFF1E3A5F); // #1E3A5F Dark Blue Text
  static const Color secondaryText = Color(0xFF64748B); // #64748B Secondary Text
  static const Color pageBackground = Color(0xFFF8FAFC); // #F8FAFC Page Background
  static const Color cardSurface = Color(0xFFFFFFFF); // #FFFFFF Card / Surface
  static const Color border = Color(0xFFE2E8F0); // #E2E8F0 Border
  static const Color blueTint = Color(0xFFEFF6FF); // #EFF6FF Blue Tint
  static const Color success = Color(0xFF059669); // #059669 Success
  static const Color successTint = Color(0xFFECFDF5); // #ECFDF5 Success Tint
  static const Color warning = Color(0xFFF59E0B); // #F59E0B Warning
  static const Color warningTint = Color(0xFFFFFBEB); // #FFFBEB Warning Tint
  static const Color danger = Color(0xFFEF4444); // #EF4444 Danger

  // Semantic Palette Aliases for App Widgets & Material Theme
  static const Color primary = primaryBlue;
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = blueTint;
  static const Color onPrimaryContainer = darkBlueText;

  static const Color secondary = deepNavy;
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = blueTint;
  static const Color onSecondaryContainer = darkBlueText;

  static const Color tertiary = blueTint;
  static const Color onTertiary = darkBlueText;

  // Surface & Backgrounds
  static const Color background = pageBackground;
  static const Color onBackground = darkBlueText;

  static const Color surface = cardSurface;
  static const Color surfaceCard = cardSurface;
  static const Color surfaceContainerLow = blueTint;
  static const Color surfaceContainer = pageBackground;
  static const Color surfaceContainerHigh = border;

  static const Color onSurface = darkBlueText;
  static const Color onSurfaceVariant = secondaryText;
  static const Color outline = secondaryText;
  static const Color outlineVariant = border;

  // Status & Feedback Colors
  static const Color successContainer = successTint;
  static const Color onSuccess = Color(0xFFFFFFFF);

  static const Color warningContainer = warningTint;
  static const Color onWarning = darkBlueText;

  static const Color error = danger;
  static const Color errorContainer = Color(0xFFFEF2F2);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = danger;

  static const Color info = primaryBlue;
  static const Color infoContainer = blueTint;

  // Neutral Tints
  static const Color divider = border;
  static const Color disabled = border;
  static const Color shimmerBase = border;
  static const Color shimmerHighlight = pageBackground;
}


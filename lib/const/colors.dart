import 'package:flutter/material.dart';

/// Centralized application color palette following Stitch "Executive Precision" theme.
abstract class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF050C1F); // Deep Navy
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF141B2E);
  static const Color onPrimaryContainer = Color(0xFF7C839B);

  static const Color secondary = Color(0xFF00BAFF); // Bright Blue accent
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFC6E7FF);
  static const Color onSecondaryContainer = Color(0xFF004663);

  static const Color tertiary = Color(0xFFECEEDC); // Soft Cream
  static const Color onTertiary = Color(0xFF1A1D12);

  // Surface & Backgrounds
  static const Color background = Color(0xFFF9F9F9);
  static const Color onBackground = Color(0xFF1A1C1C);
  
  static const Color surface = Color(0xFFF9F9F9);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F3F3);
  static const Color surfaceContainer = Color(0xFFEEEEEE);
  static const Color surfaceContainerHigh = Color(0xFFE8E8E8);
  
  static const Color onSurface = Color(0xFF1A1C1C);
  static const Color onSurfaceVariant = Color(0xFF45464D);
  static const Color outline = Color(0xFF76777D);
  static const Color outlineVariant = Color(0xFFC6C6CD);

  // Status & Feedback Colors
  static const Color success = Color(0xFF12B76A);
  static const Color successContainer = Color(0xFFD1FADF);
  static const Color onSuccess = Color(0xFFFFFFFF);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0xFFFEF08A);
  static const Color onWarning = Color(0xFF78350F);

  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color info = Color(0xFF00BAFF);
  static const Color infoContainer = Color(0xFFE0F2FE);

  // Neutral Tints
  static const Color divider = Color(0xFFE2E2E2);
  static const Color disabled = Color(0xFFC6C6CD);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
}
